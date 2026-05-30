package com.careconnect.dto.evv.hhaexchange;

import lombok.*;

import java.util.List;

/**
 * Top-level request body for the HHAExchange POST /api/v2/visits endpoint.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HhaExchangeVisitRequest {

    private List<HhaExchangeVisit> visits;
}
