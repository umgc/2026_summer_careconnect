package com.careconnect.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(
        name = "call_summaries",
        indexes = {
                @Index(
                        name = "idx_call_summary_call_id",
                        columnList = "call_id"
                ),
                @Index(
                        name = "idx_call_summary_generated_at",
                        columnList = "generated_at"
                )
        }
)
public class CallSummary extends Auditable {

    /** Maximum length for call identifier columns. */
    private static final int
            CALL_ID_LENGTH = 120;

    /** Maximum length for status columns. */
    private static final int
            STATUS_LENGTH = 24;

    /** Database identifier for the summary row. */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Call identifier associated with the generated summary. */
    @Column(name = "call_id", nullable = false, length = CALL_ID_LENGTH)
    private String callId;

    /** Serialized summary payload stored as JSON text. */
    @Column(name = "summary_json", nullable = false, columnDefinition = "TEXT")
    private String summaryJson;

    /** Current summary generation status. */
    @Column(name = "status", nullable = false, length = STATUS_LENGTH)
    private String status;

    /**
     * Number of transcript segments included in the summary.
     */
    @Column(name = "transcript_segment_count", nullable = false)
    private Integer transcriptSegmentCount;

    /**
     * User identifier of the generator when available.
     */
    @Column(name = "generated_by_user_id")
    private Long generatedByUserId;

    /** Error details captured during summary generation. */
    @Column(name = "error_message", columnDefinition = "TEXT")
    private String errorMessage;

    /** Timestamp when the summary was generated. */
    @Column(name = "generated_at", nullable = false)
    private LocalDateTime generatedAt;
}
