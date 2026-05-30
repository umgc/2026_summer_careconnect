package com.careconnect.service;

import com.careconnect.dto.BillingVerifyRequest;
import com.careconnect.dto.BillingVerifyResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedConstruction;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AppleBillingServiceTest {

    private AppleBillingService service;

    @BeforeEach
    void setUp() {
        service = new AppleBillingService();
        ReflectionTestUtils.setField(service, "appleSharedSecret", "test_secret");
    }

    @Test
    void verifyReceipt_successWithLatestReceiptInfo() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "transaction_id": "txn_001",
                            "original_transaction_id": "orig_001",
                            "purchase_date_ms": "1700000000000",
                            "expires_date_ms": "9999999999999"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("base64_receipt_data");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getPlatform()).isEqualTo("APPLE");
            assertThat(response.getExternalTransactionId()).isEqualTo("txn_001");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("orig_001");
            assertThat(response.getStatus()).isEqualTo("ACTIVE");
            assertThat(response.getMessage()).isEqualTo("Verified with Apple");
        }
    }

    @Test
    void verifyReceipt_successWithInAppReceipt() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "receipt": {
                        "in_app": [
                            {
                                "transaction_id": "txn_002",
                                "original_transaction_id": "orig_002",
                                "purchase_date_ms": "1700000000000",
                                "expires_date_ms": "9999999999999"
                            }
                        ]
                    }
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("base64_receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getExternalTransactionId()).isEqualTo("txn_002");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("orig_002");
        }
    }

    @Test
    void verifyReceipt_sandboxRedirect_status21007() throws Exception {
        String productionResponse = """
                { "status": 21007 }
                """;
        String sandboxResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "transaction_id": "sandbox_txn",
                            "original_transaction_id": "sandbox_orig",
                            "purchase_date_ms": "1700000000000",
                            "expires_date_ms": "9999999999999"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("sandbox_receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(
                            eq("https://buy.itunes.apple.com/verifyReceipt"),
                            any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(productionResponse));
                    when(mock.postForEntity(
                            eq("https://sandbox.itunes.apple.com/verifyReceipt"),
                            any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(sandboxResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getExternalTransactionId()).isEqualTo("sandbox_txn");
        }
    }

    @Test
    void verifyReceipt_failedStatus_returnsFailed() throws Exception {
        String appleResponse = """
                { "status": 21002 }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("bad_receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isFalse();
            assertThat(response.getStatus()).isEqualTo("FAILED");
            assertThat(response.getPlatform()).isEqualTo("APPLE");
        }
    }

    @Test
    void verifyReceipt_nullResponseBody_returnsFailed() throws Exception {
        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt_data");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(null));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isFalse();
            assertThat(response.getStatus()).isEqualTo("FAILED");
            assertThat(response.getMessage()).contains("Apple verification failed");
        }
    }

    @Test
    void verifyReceipt_successButNoLatestInfo_returnsFailed() throws Exception {
        String appleResponse = """
                { "status": 0 }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isFalse();
            assertThat(response.getStatus()).isEqualTo("FAILED");
        }
    }

    @Test
    void verifyReceipt_expiredSubscription_statusExpired() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "transaction_id": "txn_expired",
                            "original_transaction_id": "orig_expired",
                            "purchase_date_ms": "1600000000000",
                            "expires_date_ms": "1600100000000"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("expired_receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getStatus()).isEqualTo("EXPIRED");
        }
    }

    @Test
    void verifyReceipt_missingTransactionId_usesOriginalTransactionId() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "original_transaction_id": "orig_only",
                            "purchase_date_ms": "1700000000000",
                            "expires_date_ms": "9999999999999"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getExternalTransactionId()).isEqualTo("orig_only");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("orig_only");
        }
    }

    @Test
    void verifyReceipt_missingDates_usesDefaults() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "transaction_id": "txn_no_dates"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getPurchaseDate()).isNotNull();
            assertThat(response.getExpiryDate()).isNotNull();
        }
    }

    @Test
    void verifyReceipt_nullSharedSecret_usesEmptyString() throws Exception {
        ReflectionTestUtils.setField(service, "appleSharedSecret", null);

        String appleResponse = """
                { "status": 21002 }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isFalse();
            assertThat(response.getPlatform()).isEqualTo("APPLE");
        }
    }

    @Test
    void verifyReceipt_multipleReceiptEntries_usesLast() throws Exception {
        String appleResponse = """
                {
                    "status": 0,
                    "latest_receipt_info": [
                        {
                            "transaction_id": "txn_first",
                            "original_transaction_id": "orig_first",
                            "purchase_date_ms": "1600000000000",
                            "expires_date_ms": "9999999999999"
                        },
                        {
                            "transaction_id": "txn_last",
                            "original_transaction_id": "orig_last",
                            "purchase_date_ms": "1700000000000",
                            "expires_date_ms": "9999999999999"
                        }
                    ]
                }
                """;

        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setReceipt("receipt");

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.postForEntity(anyString(), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(appleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getExternalTransactionId()).isEqualTo("txn_last");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("orig_last");
        }
    }
}
