package com.careconnect.repository;

import com.careconnect.model.CallSummary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CallSummaryRepository
        extends JpaRepository<CallSummary, Long> {

    /**
     * Returns the most recent summary for a call.
     *
     * @param callId call identifier
     * @return most recent summary, when present
     */
    Optional<CallSummary> findTopByCallIdOrderByGeneratedAtDesc(String callId);

    /**
     * Deletes summaries for a call.
     *
     * @param callId call identifier
     * @return number of deleted rows
     */
    long deleteByCallId(String callId);
}
