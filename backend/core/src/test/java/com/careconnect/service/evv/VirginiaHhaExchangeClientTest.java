package com.careconnect.service.evv;

import com.careconnect.config.HhaExchangeProperties;
import com.careconnect.dto.evv.hhaexchange.HhaExchangeVisitRequest;
import com.careconnect.model.Address;
import com.careconnect.model.Patient;
import com.careconnect.model.evv.EvvRecord;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import java.time.OffsetDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class VirginiaHhaExchangeClientTest {

    @Mock private RestTemplate restTemplate;

    private HhaExchangeProperties props;
    private VirginiaHhaExchangeClient client;

    @BeforeEach
    void setUp() {
        props = new HhaExchangeProperties();
        props.getApi().setBaseUrl("https://implementation.hhaexchange.com");
        props.getApi().setKey("test-api-key");
        props.getProvider().setTaxId("999999999");
        props.getProvider().setNpi("NP01");
        props.getProvider().setName("Test Agency");
        props.getPayer().setId("LCDP");

        client = new VirginiaHhaExchangeClient(restTemplate, props);
    }

    // ─── destination() ───────────────────────────────────────────────────────

    @Test
    void destination_returnsVirginiaHhaExchange() {
        assertThat(client.destination()).isEqualTo("virginia-hhaexchange");
    }

    // ─── submit() ────────────────────────────────────────────────────────────

    @Test
    void submit_delegatesToSubmitBatch() throws Exception {
        when(restTemplate.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submit(buildRecord(false));

        verify(restTemplate, times(1))
                .postForEntity(anyString(), any(HttpEntity.class), eq(String.class));
    }

    // ─── submitBatch() ───────────────────────────────────────────────────────

    @Test
    void submitBatch_postsToCorrectUrl() throws Exception {
        when(restTemplate.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        verify(restTemplate).postForEntity(
                eq("https://implementation.hhaexchange.com/api/v2/visits"),
                any(HttpEntity.class),
                eq(String.class));
    }

    @Test
    void submitBatch_includesApiKeyHeader() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        assertThat(captor.getValue().getHeaders().get("X-API-KEY"))
                .containsExactly("test-api-key");
    }

    @Test
    void submitBatch_payloadContainsProviderTaxId() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        HhaExchangeVisitRequest body = captor.getValue().getBody();
        assertThat(body).isNotNull();
        assertThat(body.getVisits()).hasSize(1);
        assertThat(body.getVisits().get(0).getProviderTaxId()).isEqualTo("999999999");
    }

    @Test
    void submitBatch_correctedRecord_setsEditedTrue() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(true)));

        HhaExchangeVisitRequest body = captor.getValue().getBody();
        assertThat(body.getVisits().get(0).getEditVisit().getEdited()).isTrue();
    }

    @Test
    void submitBatch_uncorrectedRecord_setsEditedFalse() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        HhaExchangeVisitRequest body = captor.getValue().getBody();
        assertThat(body.getVisits().get(0).getEditVisit().getEdited()).isFalse();
    }

    @Test
    void submitBatch_memberIdentifierUsesMaNumber() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        HhaExchangeVisitRequest body = captor.getValue().getBody();
        assertThat(body.getVisits().get(0).getMember().getIdentifier()).isEqualTo("MA12345");
    }

    @Test
    void submitBatch_nullPatient_fallsBackToSyntheticMemberId() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        EvvRecord record = buildRecord(false);
        record.setPatient(null);

        client.submitBatch(List.of(record));

        String memberId = captor.getValue().getBody().getVisits().get(0).getMember().getIdentifier();
        assertThat(memberId).startsWith("UNKNOWN-");
    }

    @Test
    void submitBatch_nonSuccessResponse_throwsRuntimeException() {
        when(restTemplate.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                .thenReturn(ResponseEntity.status(400).<String>build());

        assertThatThrownBy(() -> client.submitBatch(List.of(buildRecord(false))))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Batch submission failed");
    }

    @Test
    void submitBatch_caregiverIdentifierMatchesRecordCaregiverId() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false)));

        assertThat(captor.getValue().getBody().getVisits().get(0)
                .getCaregiver().getIdentifier()).isEqualTo("7");
    }

    @Test
    void submitBatch_multipleBatchedInSingleRequest() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        client.submitBatch(List.of(buildRecord(false), buildRecord(true)));

        // Only ONE HTTP call should be made for both records
        verify(restTemplate, times(1))
                .postForEntity(anyString(), any(HttpEntity.class), eq(String.class));
        assertThat(captor.getValue().getBody().getVisits()).hasSize(2);
    }

    // ─── Procedure code mapping ───────────────────────────────────────────────

    @Test
    void submitBatch_personalCare_mapsToProcedureCodeT1019() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        EvvRecord record = buildRecord(false);
        record.setServiceType("Personal Care");
        client.submitBatch(List.of(record));

        assertThat(captor.getValue().getBody().getVisits().get(0).getProcedureCode())
                .isEqualTo("T1019");
    }

    @Test
    void submitBatch_skilledNursing_mapsToProcedureCodeG0299() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        EvvRecord record = buildRecord(false);
        record.setServiceType("Skilled Nursing");
        client.submitBatch(List.of(record));

        assertThat(captor.getValue().getBody().getVisits().get(0).getProcedureCode())
                .isEqualTo("G0299");
    }

    @Test
    void submitBatch_unknownServiceType_defaultsToT1019() throws Exception {
        @SuppressWarnings("unchecked")
        ArgumentCaptor<HttpEntity<HhaExchangeVisitRequest>> captor =
                ArgumentCaptor.forClass(HttpEntity.class);

        when(restTemplate.postForEntity(anyString(), captor.capture(), eq(String.class)))
                .thenReturn(ResponseEntity.ok(""));

        EvvRecord record = buildRecord(false);
        record.setServiceType("Some Unknown Type");
        client.submitBatch(List.of(record));

        assertThat(captor.getValue().getBody().getVisits().get(0).getProcedureCode())
                .isEqualTo("T1019");
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private EvvRecord buildRecord(boolean corrected) {
        Patient patient = new Patient();
        patient.setMaNumber("MA12345");
        patient.setPhone("5550001234");
        Address addr = new Address("123 Main St", null, "Richmond", "VA", "23220");
        patient.setAddress(addr);

        EvvRecord record = new EvvRecord();
        record.setId(42L);
        record.setCaregiverId(7L);
        record.setServiceType("Personal Care");
        record.setStateCode("VA");
        record.setStatus("APPROVED");
        record.setIndividualName("John Doe");
        record.setDateOfService(java.time.LocalDate.of(2026, 3, 20));
        record.setTimeIn(OffsetDateTime.parse("2026-03-20T09:00:00-05:00"));
        record.setTimeOut(OffsetDateTime.parse("2026-03-20T11:00:00-05:00"));
        record.setCheckinLocationLat(38.9072);
        record.setCheckinLocationLng(-77.0369);
        record.setCheckoutLocationLat(38.9072);
        record.setCheckoutLocationLng(-77.0369);
        record.setPatient(patient);
        record.setCreatedAt(OffsetDateTime.now());
        record.setUpdatedAt(OffsetDateTime.now());
        record.setIsOffline(false);
        record.setEorApprovalRequired(false);
        record.setIsCorrected(corrected);
        if (corrected) {
            record.setCorrectionReasonCode("TIME_ERROR");
            record.setCorrectionExplanation("Clock-in time was incorrect");
        }
        return record;
    }
}
