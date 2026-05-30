package com.careconnect.model;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class CallTranscriptArchiveTest {

    @Test
    void defaultConstructor_createsInstance() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        assertThat(archive).isNotNull();
        assertThat(archive.getId()).isNull();
    }

    @Test
    void setAndGetId() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setId(1L);
        assertThat(archive.getId()).isEqualTo(1L);
    }

    @Test
    void setAndGetCallId() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setCallId("call-abc-123");
        assertThat(archive.getCallId()).isEqualTo("call-abc-123");
    }

    @Test
    void setAndGetStorageProvider() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setStorageProvider("S3");
        assertThat(archive.getStorageProvider()).isEqualTo("S3");
    }

    @Test
    void setAndGetStorageKey() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setStorageKey("transcripts/2026/03/call-abc-123.json");
        assertThat(archive.getStorageKey()).isEqualTo("transcripts/2026/03/call-abc-123.json");
    }

    @Test
    void setAndGetSegmentCount() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setSegmentCount(42);
        assertThat(archive.getSegmentCount()).isEqualTo(42);
    }

    @Test
    void setAndGetTranscriptChars() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setTranscriptChars(15000);
        assertThat(archive.getTranscriptChars()).isEqualTo(15000);
    }

    @Test
    void setAndGetParticipantUserIds() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setParticipantUserIds("1,2,3");
        assertThat(archive.getParticipantUserIds()).isEqualTo("1,2,3");
    }

    @Test
    void setAndGetSha256Checksum() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        String checksum = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855";
        archive.setSha256Checksum(checksum);
        assertThat(archive.getSha256Checksum()).isEqualTo(checksum);
    }

    @Test
    void setAndGetArchivedAt() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        LocalDateTime now = LocalDateTime.of(2026, 3, 17, 10, 30, 0);
        archive.setArchivedAt(now);
        assertThat(archive.getArchivedAt()).isEqualTo(now);
    }

    @Test
    void allFieldsRoundTrip() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        LocalDateTime archivedAt = LocalDateTime.of(2026, 1, 15, 14, 0, 0);

        archive.setId(100L);
        archive.setCallId("call-xyz-789");
        archive.setStorageProvider("GCS");
        archive.setStorageKey("bucket/path/to/transcript.json");
        archive.setSegmentCount(10);
        archive.setTranscriptChars(5000);
        archive.setParticipantUserIds("10,20");
        archive.setSha256Checksum("abc123def456");
        archive.setArchivedAt(archivedAt);

        assertThat(archive.getId()).isEqualTo(100L);
        assertThat(archive.getCallId()).isEqualTo("call-xyz-789");
        assertThat(archive.getStorageProvider()).isEqualTo("GCS");
        assertThat(archive.getStorageKey()).isEqualTo("bucket/path/to/transcript.json");
        assertThat(archive.getSegmentCount()).isEqualTo(10);
        assertThat(archive.getTranscriptChars()).isEqualTo(5000);
        assertThat(archive.getParticipantUserIds()).isEqualTo("10,20");
        assertThat(archive.getSha256Checksum()).isEqualTo("abc123def456");
        assertThat(archive.getArchivedAt()).isEqualTo(archivedAt);
    }

    @Test
    void nullableFieldsCanBeNull() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        archive.setParticipantUserIds(null);
        archive.setSha256Checksum(null);

        assertThat(archive.getParticipantUserIds()).isNull();
        assertThat(archive.getSha256Checksum()).isNull();
    }

    @Test
    void inheritsFromAuditable() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        // Auditable provides createdAt and updatedAt
        assertThat(archive).isInstanceOf(Auditable.class);
    }

    @Test
    void auditableFieldsCanBeSet() {
        CallTranscriptArchive archive = new CallTranscriptArchive();
        LocalDateTime now = LocalDateTime.now();

        archive.setCreatedAt(now);
        archive.setUpdatedAt(now);

        assertThat(archive.getCreatedAt()).isEqualTo(now);
        assertThat(archive.getUpdatedAt()).isEqualTo(now);
    }
}
