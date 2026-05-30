package com.careconnect.service;

import com.careconnect.model.CallRecording;
import com.careconnect.repository.CallRecordingRepository;
import com.careconnect.service.CallTranscriptService.TranscriptSegmentInput;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.Delete;
import software.amazon.awssdk.services.s3.model.DeleteObjectsRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Response;
import software.amazon.awssdk.services.s3.model.ObjectIdentifier;
import software.amazon.awssdk.services.transcribe.TranscribeClient;
import software.amazon.awssdk.services.transcribe.model.GetTranscriptionJobRequest;
import software.amazon.awssdk.services.transcribe.model.GetTranscriptionJobResponse;
import software.amazon.awssdk.services.transcribe.model.LanguageCode;
import software.amazon.awssdk.services.transcribe.model.Media;
import software.amazon.awssdk.services.transcribe.model.MediaFormat;
import software.amazon.awssdk.services.transcribe.model.Settings;
import software.amazon.awssdk.services.transcribe.model.StartTranscriptionJobRequest;
import software.amazon.awssdk.services.transcribe.model.TranscriptionJobStatus;

/**
 * Handles post-call transcription using AWS Transcribe.
 *
 * <p>When a system-initiated recording finishes concatenation, this service starts an AWS
 * Transcribe job with speaker diarization, waits for it to complete, stores the resulting segments
 * via {@link CallTranscriptService}, and then deletes the concatenated recording from S3 so that
 * calls are not permanently stored.
 */
@Service
public class PostCallTranscriptionService {

  private static final Logger log = LoggerFactory.getLogger(PostCallTranscriptionService.class);

  /** Maximum number of distinct speakers Transcribe will try to identify. */
  private static final int MAX_SPEAKER_LABELS = 10;

  /** How long to wait between Transcribe job status polls (ms). */
  private static final long POLL_INTERVAL_MS = 20_000L;

  /** Maximum wall-clock time to wait for a Transcribe job to finish (ms). */
  private static final long MAX_WAIT_MS = 15 * 60_000L;

  /** Source label stored with each segment so the UI can identify post-call transcripts. */
  private static final String TRANSCRIPT_SOURCE = "POST_CALL_TRANSCRIBE";

  /** Transcription status set while the job is in progress. */
  public static final String TRANSCRIPTION_STATUS_PROCESSING = "PROCESSING";

  /** Transcription status set when the job completes successfully. */
  public static final String TRANSCRIPTION_STATUS_COMPLETE = "COMPLETE";

  /** Transcription status set when the job fails. */
  public static final String TRANSCRIPTION_STATUS_FAILED = "FAILED";

  /** Maximum objects to delete in a single S3 DeleteObjects call. */
  private static final int S3_DELETE_BATCH = 1000;

  @Autowired(required = false)
  private TranscribeClient transcribeClient;

  @Autowired(required = false)
  private S3Client s3Client;

  @Autowired
  private CallTranscriptService callTranscriptService;

  @Autowired
  private CallTelemetryService callTelemetryService;

  @Autowired
  private CallRecordingRepository recordingRepository;

  private final ObjectMapper objectMapper = new ObjectMapper();

  /**
   * Asynchronously transcribes the concatenated recording for a call, stores the result, and
   * deletes the S3 recording objects.
   *
   * @param callId call identifier
   * @param rec the completed {@link CallRecording}
   * @param playableKey S3 key of the concatenated MP4
   */
  @Async
  public void transcribeAndCleanup(
      final String callId, final CallRecording rec, final String playableKey) {
    if (transcribeClient == null || s3Client == null) {
      if (log.isWarnEnabled()) {
        log.warn("PostCallTranscription skipped for call {} — AWS clients not available", callId);
      }
      return;
    }
    if (callId == null || rec == null || playableKey == null || playableKey.isBlank()) {
      return;
    }

    final String mediaUri = "s3://" + rec.getS3Bucket() + "/" + playableKey;
    final String jobName = "cc-" + callId.replaceAll("[^A-Za-z0-9_-]", "-")
        + "-" + Instant.now().getEpochSecond();
    final String outputKey = rec.getS3Prefix() + "transcripts/" + jobName + ".json";

    setTranscriptionStatus(rec, TRANSCRIPTION_STATUS_PROCESSING);

    try {
      if (log.isInfoEnabled()) {
        log.info("Starting Transcribe job {} for call {} media {}", jobName, callId, mediaUri);
      }
      startTranscribeJob(jobName, mediaUri, rec.getS3Bucket(), rec.getS3Prefix());

      final boolean completed = pollForCompletion(jobName);
      if (!completed) {
        if (log.isWarnEnabled()) {
          log.warn("Transcribe job {} did not complete in time for call {}", jobName, callId);
        }
        setTranscriptionStatus(rec, TRANSCRIPTION_STATUS_FAILED);
        return;
      }

      // Build speaker label map using participant count from telemetry JOIN events
      final Map<String, String> speakerMap = buildSpeakerRoleMap(callId);
      final List<TranscriptSegmentInput> segments =
          downloadAndParse(rec.getS3Bucket(), outputKey, rec.getStartedAt(), speakerMap);
      if (!segments.isEmpty()) {
        final int stored = callTranscriptService.recordSegments(callId, null, segments);
        if (log.isInfoEnabled()) {
          log.info("Stored {} transcript segments for call {}", stored, callId);
        }
      }
      setTranscriptionStatus(rec, TRANSCRIPTION_STATUS_COMPLETE);
    } catch (Exception e) {
      if (log.isWarnEnabled()) {
        log.warn("Post-call transcription failed for call {}: {}", callId, e.getMessage(), e);
      }
      setTranscriptionStatus(rec, TRANSCRIPTION_STATUS_FAILED);
      return;
    }

    // Only delete the S3 recording if it is still system-initiated (not claimed for playback).
    // Re-fetch from DB so we see any claim that happened during the call.
    final CallRecording fresh = recordingRepository.findById(rec.getId()).orElse(rec);
    if (fresh.getInitiatedByUserId() == null) {
      deleteRecordingFromS3(rec);
    } else {
      if (log.isInfoEnabled()) {
        log.info(
            "Keeping S3 recording for call {} — claimed for playback by user {}",
            callId, fresh.getInitiatedByUserId());
      }
    }
  }

  // ----------------------------------------------------------------
  // Private helpers
  // ----------------------------------------------------------------

  private void startTranscribeJob(
      final String jobName,
      final String mediaUri,
      final String outputBucket,
      final String s3Prefix) {
    final String outputKey = s3Prefix + "transcripts/" + jobName + ".json";
    transcribeClient.startTranscriptionJob(
        StartTranscriptionJobRequest.builder()
            .transcriptionJobName(jobName)
            .languageCode(LanguageCode.EN_US)
            .mediaFormat(MediaFormat.MP4)
            .media(Media.builder().mediaFileUri(mediaUri).build())
            .outputBucketName(outputBucket)
            .outputKey(outputKey)
            .settings(
                Settings.builder()
                    .showSpeakerLabels(true)
                    .maxSpeakerLabels(MAX_SPEAKER_LABELS)
                    .build())
            .build());
  }

  /** Polls until the job reaches COMPLETED or FAILED; returns true iff COMPLETED. */
  private boolean pollForCompletion(final String jobName) throws InterruptedException {
    final long deadline = System.currentTimeMillis() + MAX_WAIT_MS;
    while (System.currentTimeMillis() < deadline) {
      final GetTranscriptionJobResponse resp =
          transcribeClient.getTranscriptionJob(
              GetTranscriptionJobRequest.builder().transcriptionJobName(jobName).build());
      final TranscriptionJobStatus status =
          resp.transcriptionJob().transcriptionJobStatus();

      if (TranscriptionJobStatus.COMPLETED.equals(status)) {
        return true;
      }
      if (TranscriptionJobStatus.FAILED.equals(status)) {
        if (log.isWarnEnabled()) {
          log.warn(
              "Transcribe job {} FAILED: {}",
              jobName,
              resp.transcriptionJob().failureReason());
        }
        return false;
      }
      Thread.sleep(POLL_INTERVAL_MS);
    }
    return false;
  }

  /**
   * Downloads the Transcribe JSON output from S3 and converts it to transcript segment records.
   * {@code recordingStartedAt} is used to set accurate {@code occurredAt} timestamps on each
   * segment so the sentiment-highlight logic can match transcript lines to plot samples.
   * {@code speakerMap} maps raw Transcribe labels (e.g. {@code spk_0}) to human-readable role
   * names (e.g. {@code Caregiver}).
   */
  private List<TranscriptSegmentInput> downloadAndParse(
      final String bucket,
      final String key,
      final LocalDateTime recordingStartedAt,
      final Map<String, String> speakerMap) throws Exception {
    final byte[] bytes;
    try (ResponseInputStream<GetObjectResponse> is =
        s3Client.getObject(GetObjectRequest.builder().bucket(bucket).key(key).build())) {
      bytes = is.readAllBytes();
    }

    final JsonNode root = objectMapper.readTree(bytes);
    return parseTranscriptItems(root, recordingStartedAt, speakerMap);
  }

  /**
   * Parses the AWS Transcribe JSON result into {@link TranscriptSegmentInput} records.
   *
   * <p>Items with the same speaker label are grouped into continuous segments so that the UI
   * receives speaker-level utterances rather than individual words.
   */
  /**
   * Parses AWS Transcribe JSON into {@link TranscriptSegmentInput} records.
   *
   * @param root JSON root from the Transcribe output file
   * @param recordingStartedAt actual UTC start of the recording; used to compute per-segment
   *     {@code occurredAt} so the sentiment-highlight logic can match plot samples to lines
   * @param speakerMap mapping from raw Transcribe labels (e.g. {@code spk_0}) to human-readable
   *     role names (e.g. {@code Caregiver})
   */
  private List<TranscriptSegmentInput> parseTranscriptItems(
      final JsonNode root,
      final LocalDateTime recordingStartedAt,
      final Map<String, String> speakerMap) {
    final List<TranscriptSegmentInput> segments = new ArrayList<>();
    final JsonNode items = root.path("results").path("items");
    if (!items.isArray() || items.isEmpty()) {
      return segments;
    }

    // Group consecutive pronunciation tokens by speaker into utterances
    String currentSpeaker = null;
    final StringBuilder currentText = new StringBuilder();
    Long currentStart = null;
    Long currentEnd = null;

    for (final JsonNode item : items) {
      final String type = item.path("type").asText();
      if (!"pronunciation".equals(type)) {
        // Punctuation: append directly to current utterance without resetting speaker
        if (currentText.length() > 0) {
          final String punct = item.path("alternatives").path(0).path("content").asText("");
          currentText.append(punct);
        }
        continue;
      }

      final String rawSpeaker = item.path("speaker_label").asText(null);
      final String speaker = rawSpeaker != null
          ? speakerMap.getOrDefault(rawSpeaker, toSpeakerLabel())
          : null;
      final String word = item.path("alternatives").path(0).path("content").asText("");
      final long startMs = toMs(item.path("start_time").asText("0"));
      final long endMs = toMs(item.path("end_time").asText("0"));

      if (speaker != null && !speaker.equals(currentSpeaker)) {
        // Flush previous utterance
        if (currentSpeaker != null && currentText.length() > 0) {
          segments.add(buildSegment(
              currentSpeaker, currentText.toString().trim(),
              currentStart, currentEnd, recordingStartedAt));
        }
        currentSpeaker = speaker;
        currentText.setLength(0);
        currentText.append(word);
        currentStart = startMs;
        currentEnd = endMs;
      } else {
        if (currentText.length() > 0) {
          currentText.append(' ');
        }
        currentText.append(word);
        currentEnd = endMs;
        if (currentStart == null) {
          currentStart = startMs;
        }
      }
    }

    // Flush last utterance
    if (currentSpeaker != null && currentText.length() > 0) {
      segments.add(buildSegment(
          currentSpeaker, currentText.toString().trim(),
          currentStart, currentEnd, recordingStartedAt));
    }
    return segments;
  }

  /** Builds a {@link TranscriptSegmentInput} with an accurate {@code occurredAt} timestamp. */
  private static TranscriptSegmentInput buildSegment(
      final String speaker,
      final String text,
      final Long startMs,
      final Long endMs,
      final LocalDateTime recordingStartedAt) {
    final LocalDateTime occurredAt = recordingStartedAt != null && startMs != null
        ? recordingStartedAt.plusNanos(startMs * 1_000_000L)
        : null;
    return new TranscriptSegmentInput(speaker, text, startMs, endMs, TRANSCRIPT_SOURCE, occurredAt);
  }

  /**
   * Builds a speaker-label map sized to the number of unique participants who joined the call.
   * spk_0 → "Speaker 1", spk_1 → "Speaker 2", ..., spk_(N-1) → "Speaker N".
   * Any Transcribe label beyond the known participant count is left unmapped so it falls
   * through to "Unidentified Speaker" — indicating AWS Transcribe detected more voices
   * than there were participants (e.g. background noise, echo).
   */
  private Map<String, String> buildSpeakerRoleMap(final String callId) {
    final Set<Long> participantIds = new HashSet<>();
    try {
      callTelemetryService.getTelemetryForCall(callId).stream()
          .filter(e -> "CALL_JOIN".equalsIgnoreCase(e.getEventType()) && e.getActorUserId() != null)
          .forEach(e -> participantIds.add(e.getActorUserId()));
    } catch (Exception e) {
      log.warn("Could not resolve participant count for call {} — defaulting to 2 speakers: {}", callId, e.getMessage());
    }
    final int participantCount = Math.max(participantIds.size(), 2);
    final Map<String, String> map = new HashMap<>();
    for (int i = 0; i < participantCount; i++) {
      map.put("spk_" + i, "Speaker " + (i + 1));
    }
    return map;
  }

  /**
   * Fallback label when a Transcribe speaker tag has no entry in the speaker map —
   * meaning AWS detected more distinct voices than known participants on the call.
   */
  private static String toSpeakerLabel() {
    return "Unidentified Speaker";
  }

  private static long toMs(final String seconds) {
    if (seconds == null || seconds.isBlank()) {
      return 0L;
    }
    try {
      return Math.round(Double.parseDouble(seconds) * 1000.0);
    } catch (NumberFormatException e) {
      return 0L;
    }
  }

  /** Deletes the concatenated MP4 and the transcript JSON from S3. */
  private void setTranscriptionStatus(final CallRecording rec, final String status) {
    try {
      rec.setTranscriptionStatus(status);
      recordingRepository.save(rec);
    } catch (Exception e) {
      if (log.isWarnEnabled()) {
        log.warn("Failed to update transcriptionStatus for recording {}: {}",
            rec.getId(), e.getMessage());
      }
    }
  }

  private void deleteRecordingFromS3(final CallRecording rec) {
    if (rec.getS3Bucket() == null) {
      return;
    }
    try {
      // Delete the concatenated recording prefix (everything under concatenated/)
      final String concatenatedPrefix = rec.getS3Prefix() + "concatenated/";
      deletePrefix(rec.getS3Bucket(), concatenatedPrefix);

      // Delete the transcript output JSON
      final String transcriptPrefix = rec.getS3Prefix() + "transcripts/";
      deletePrefix(rec.getS3Bucket(), transcriptPrefix);

      if (log.isInfoEnabled()) {
        log.info(
            "Deleted S3 recording artifacts for call {} under prefix {}",
            rec.getCallId(),
            rec.getS3Prefix());
      }
    } catch (Exception e) {
      if (log.isWarnEnabled()) {
        log.warn(
            "Failed to delete S3 artifacts for call {}: {}", rec.getCallId(), e.getMessage(), e);
      }
    }
  }

  private void deletePrefix(final String bucket, final String prefix) {
    String continuationToken = null;
    do {
      final ListObjectsV2Request.Builder listBuilder =
          ListObjectsV2Request.builder()
              .bucket(bucket)
              .prefix(prefix)
              .maxKeys(S3_DELETE_BATCH);
      if (continuationToken != null) {
        listBuilder.continuationToken(continuationToken);
      }
      final ListObjectsV2Response listing = s3Client.listObjectsV2(listBuilder.build());
      if (!listing.contents().isEmpty()) {
        final List<ObjectIdentifier> toDelete =
            listing.contents().stream()
                .map(obj -> ObjectIdentifier.builder().key(obj.key()).build())
                .toList();
        s3Client.deleteObjects(
            DeleteObjectsRequest.builder()
                .bucket(bucket)
                .delete(Delete.builder().objects(toDelete).quiet(true).build())
                .build());
      }
      continuationToken = listing.isTruncated() ? listing.nextContinuationToken() : null;
    } while (continuationToken != null);
  }
}
