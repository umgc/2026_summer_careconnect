package com.careconnect.repository;

import com.careconnect.model.CallTranscriptSegment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CallTranscriptSegmentRepository
        extends JpaRepository<CallTranscriptSegment, Long> {

    /**
     * Returns transcript segments for a call in timeline order.
     *
     * @param callId call identifier
     * @return matching segments in ascending timeline order
     */
    List<CallTranscriptSegment>
            findByCallIdOrderByStartMsAscOccurredAtAsc(String callId);

    /**
     * Counts transcript segments for a call.
     *
     * @param callId call identifier
     * @return number of matching transcript segments
     */
    long countByCallId(String callId);

    /**
     * Returns whether a user has transcript segments for a call.
     *
     * @param callId call identifier
     * @param actorUserId actor user identifier
     * @return {@code true} when a matching transcript segment exists
     */
    boolean existsByCallIdAndActorUserId(String callId, Long actorUserId);

    /**
     * Returns whether any transcript segments exist for a call.
     *
     * @param callId call identifier
     * @return {@code true} when a matching transcript segment exists
     */
    boolean existsByCallId(String callId);

    /**
     * Deletes transcript segments for a call.
     *
     * @param callId call identifier
     * @return number of deleted rows
     */
    long deleteByCallId(String callId);
}
