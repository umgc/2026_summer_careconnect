package com.careconnect.dto.evv;

import jakarta.validation.constraints.NotEmpty;
import lombok.*;

import java.util.List;

/**
 * Request body for batch EVV submission to the Virginia HHAExchange aggregator.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HhaExchangeBatchSubmitRequest {

    @NotEmpty(message = "At least one record ID must be provided")
    private List<Long> recordIds;
}
