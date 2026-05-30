package com.careconnect.controller;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AddressAutocompleteControllerTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private AddressAutocompleteController controller;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(controller, "restTemplate", restTemplate);
    }

    // ========== getAddressSuggestions tests ==========

    @Test
    void getAddressSuggestions_noApiKey_returnsEmptyPredictions() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "");

        ResponseEntity<Map<String, Object>> response = controller.getAddressSuggestions("123 Main");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "NO_API_KEY");
        assertThat(response.getBody().get("predictions")).isInstanceOf(List.class);
        assertThat((List<?>) response.getBody().get("predictions")).isEmpty();
    }

    @Test
    void getAddressSuggestions_nullApiKey_returnsEmptyPredictions() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", null);

        ResponseEntity<Map<String, Object>> response = controller.getAddressSuggestions("123 Main");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "NO_API_KEY");
    }

    @Test
    @SuppressWarnings("unchecked")
    void getAddressSuggestions_success_returnsApiResponse() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "test-api-key");

        Map<String, Object> apiResponse = new HashMap<>();
        apiResponse.put("status", "OK");
        apiResponse.put("predictions", List.of(Map.of("description", "123 Main St")));

        when(restTemplate.getForObject(anyString(), eq(Map.class))).thenReturn(apiResponse);

        ResponseEntity<Map<String, Object>> response = controller.getAddressSuggestions("123 Main");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "OK");
    }

    @Test
    void getAddressSuggestions_exception_returnsErrorResponse() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "test-api-key");

        when(restTemplate.getForObject(anyString(), eq(Map.class)))
                .thenThrow(new RuntimeException("Connection refused"));

        ResponseEntity<Map<String, Object>> response = controller.getAddressSuggestions("123 Main");

        assertThat(response.getStatusCode().value()).isEqualTo(500);
        assertThat(response.getBody()).containsEntry("status", "ERROR");
        assertThat((String) response.getBody().get("message"))
                .contains("Failed to fetch suggestions");
        assertThat((String) response.getBody().get("message"))
                .contains("Connection refused");
    }

    // ========== getPlaceDetails tests ==========

    @Test
    void getPlaceDetails_noApiKey_returnsNoApiKeyStatus() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "");

        ResponseEntity<Map<String, Object>> response =
                controller.getPlaceDetails("ChIJN1t_tDeuEmsRUsoyG83frY4");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "NO_API_KEY");
    }

    @Test
    void getPlaceDetails_nullApiKey_returnsNoApiKeyStatus() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", null);

        ResponseEntity<Map<String, Object>> response =
                controller.getPlaceDetails("ChIJN1t_tDeuEmsRUsoyG83frY4");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "NO_API_KEY");
    }

    @Test
    @SuppressWarnings("unchecked")
    void getPlaceDetails_success_returnsApiResponse() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "test-api-key");

        Map<String, Object> apiResponse = new HashMap<>();
        apiResponse.put("status", "OK");
        apiResponse.put("result", Map.of("formatted_address", "123 Main St, City, ST 12345"));

        when(restTemplate.getForObject(anyString(), eq(Map.class))).thenReturn(apiResponse);

        ResponseEntity<Map<String, Object>> response =
                controller.getPlaceDetails("ChIJN1t_tDeuEmsRUsoyG83frY4");

        assertThat(response.getStatusCode().value()).isEqualTo(200);
        assertThat(response.getBody()).containsEntry("status", "OK");
    }

    @Test
    void getPlaceDetails_exception_returnsErrorResponse() {
        ReflectionTestUtils.setField(controller, "googlePlacesApiKey", "test-api-key");

        when(restTemplate.getForObject(anyString(), eq(Map.class)))
                .thenThrow(new RuntimeException("Timeout"));

        ResponseEntity<Map<String, Object>> response =
                controller.getPlaceDetails("ChIJN1t_tDeuEmsRUsoyG83frY4");

        assertThat(response.getStatusCode().value()).isEqualTo(500);
        assertThat(response.getBody()).containsEntry("status", "ERROR");
        assertThat((String) response.getBody().get("message"))
                .contains("Failed to fetch place details");
        assertThat((String) response.getBody().get("message"))
                .contains("Timeout");
    }
}
