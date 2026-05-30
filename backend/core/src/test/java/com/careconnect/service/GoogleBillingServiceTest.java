package com.careconnect.service;

import com.careconnect.dto.BillingVerifyRequest;
import com.careconnect.dto.BillingVerifyResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.MockedConstruction;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GoogleBillingServiceTest {

    private GoogleBillingService service;

    @BeforeEach
    void setUp() {
        service = new GoogleBillingService();
        ReflectionTestUtils.setField(service, "googleAccessToken", "test_access_token");
        ReflectionTestUtils.setField(service, "googleServiceAccountFile", "");
    }

    private BillingVerifyRequest buildRequest() {
        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setPackageName("com.careconnect.app");
        request.setProductId("premium_monthly");
        request.setReceipt("purchase_token_123");
        return request;
    }

    // ---- Input validation ------------------------------------------------------

    @Test
    void verifyReceipt_nullPackageName_throwsIllegalArgument() {
        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setProductId("premium_monthly");
        request.setReceipt("token");

        assertThatThrownBy(() -> service.verifyReceipt(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("packageName, productId and receipt token are required");
    }

    @Test
    void verifyReceipt_nullProductId_throwsIllegalArgument() {
        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setPackageName("com.app");
        request.setReceipt("token");

        assertThatThrownBy(() -> service.verifyReceipt(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("packageName, productId and receipt token are required");
    }

    @Test
    void verifyReceipt_nullReceipt_throwsIllegalArgument() {
        BillingVerifyRequest request = new BillingVerifyRequest();
        request.setPackageName("com.app");
        request.setProductId("premium");

        assertThatThrownBy(() -> service.verifyReceipt(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("packageName, productId and receipt token are required");
    }

    // ---- Success paths ---------------------------------------------------------

    @Test
    void verifyReceipt_successWithAllFields() throws Exception {
        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "orderId": "GPA.1234-5678",
                    "paymentState": 1
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getPlatform()).isEqualTo("GOOGLE");
            assertThat(response.getExternalTransactionId()).isEqualTo("GPA.1234-5678");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("GPA.1234-5678");
            assertThat(response.getStatus()).isEqualTo("ACTIVE");
            assertThat(response.getMessage()).contains("Verified with Google Play");
            assertThat(response.getMessage()).contains("purchaseState=1");
            assertThat(response.getPurchaseDate()).isNotNull();
            assertThat(response.getExpiryDate()).isNotNull();
        }
    }

    @Test
    void verifyReceipt_usePurchaseTimeMillis_whenStartTimeMissing() throws Exception {
        String googleResponse = """
                {
                    "purchaseTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "orderId": "GPA.1111"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getPurchaseDate()).isNotNull();
        }
    }

    @Test
    void verifyReceipt_noOrderId_usesReceiptToken() throws Exception {
        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "paymentState": 0
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getExternalTransactionId()).isEqualTo("purchase_token_123");
            assertThat(response.getExternalSubscriptionId()).isEqualTo("purchase_token_123");
        }
    }

    @Test
    void verifyReceipt_expiredSubscription_statusExpired() throws Exception {
        String googleResponse = """
                {
                    "startTimeMillis": "1600000000000",
                    "expiryTimeMillis": "1600100000000",
                    "orderId": "GPA.expired"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getStatus()).isEqualTo("EXPIRED");
        }
    }

    @Test
    void verifyReceipt_noPaymentState_showsUnknown() throws Exception {
        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "orderId": "GPA.no_payment_state"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.getMessage()).contains("purchaseState=UNKNOWN");
        }
    }

    // ---- Failure paths ---------------------------------------------------------

    @Test
    void verifyReceipt_nullResponseBody_returnsFailed() throws Exception {
        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(null));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isFalse();
            assertThat(response.getPlatform()).isEqualTo("GOOGLE");
            assertThat(response.getStatus()).isEqualTo("FAILED");
            assertThat(response.getMessage()).contains("Google verification failed");
        }
    }

    @Test
    void verifyReceipt_restTemplateThrows_propagatesException() {
        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenThrow(new RestClientException("Connection refused"));
                })) {

            assertThatThrownBy(() -> service.verifyReceipt(request))
                    .isInstanceOf(RestClientException.class)
                    .hasMessageContaining("Connection refused");
        }
    }

    // ---- Token resolution paths ------------------------------------------------

    @Test
    void verifyReceipt_emptyAccessToken_noServiceAccountFile_noAuth() throws Exception {
        ReflectionTestUtils.setField(service, "googleAccessToken", "");
        ReflectionTestUtils.setField(service, "googleServiceAccountFile", "");

        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "orderId": "GPA.no_auth"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
        }
    }

    @Test
    void verifyReceipt_nullAccessToken_noServiceAccountFile_noAuth() throws Exception {
        ReflectionTestUtils.setField(service, "googleAccessToken", null);
        ReflectionTestUtils.setField(service, "googleServiceAccountFile", null);

        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "expiryTimeMillis": "9999999999999",
                    "orderId": "GPA.null_token"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
        }
    }

    @Test
    void verifyReceipt_missingTimestamps_usesDefaults() throws Exception {
        String googleResponse = """
                {
                    "orderId": "GPA.no_times"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            assertThat(response.getPurchaseDate()).isNotNull();
            assertThat(response.getExpiryDate()).isNotNull();
        }
    }

    @Test
    void verifyReceipt_missingExpiryOnly_defaultsTo30Days() throws Exception {
        String googleResponse = """
                {
                    "startTimeMillis": "1700000000000",
                    "orderId": "GPA.no_expiry"
                }
                """;

        BillingVerifyRequest request = buildRequest();

        try (MockedConstruction<RestTemplate> mocked = mockConstruction(RestTemplate.class,
                (mock, context) -> {
                    when(mock.exchange(anyString(), eq(HttpMethod.GET), any(HttpEntity.class), eq(String.class)))
                            .thenReturn(ResponseEntity.ok(googleResponse));
                })) {

            BillingVerifyResponse response = service.verifyReceipt(request);

            assertThat(response.isSuccess()).isTrue();
            long expectedExpiry = 1700000000000L + 30L * 24L * 3600L * 1000L;
            assertThat(response.getExpiryDate().toEpochMilli()).isEqualTo(expectedExpiry);
        }
    }
}
