package com.careconnect.service;

import com.careconnect.dto.PlanDTO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class StripeServiceTest {

    private StripeService stripeService;

    @BeforeEach
    void setUp() {
        stripeService = new StripeService();
    }

    // ========== listPlans ==========

    @Test
    @DisplayName("listPlans should return an empty list")
    void listPlans_shouldReturnEmptyList() {
        List<PlanDTO> result = stripeService.listPlans();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ========== listProducts ==========

    @Test
    @DisplayName("listProducts should return empty JSON object string")
    void listProducts_shouldReturnEmptyJson() {
        String result = stripeService.listProducts();

        assertEquals("{}", result);
    }

    // ========== listSubscriptions ==========

    @Test
    @DisplayName("listSubscriptions with customerId should return empty JSON object string")
    void listSubscriptions_withCustomerId_shouldReturnEmptyJson() {
        String result = stripeService.listSubscriptions("cus_123");

        assertEquals("{}", result);
    }

    @Test
    @DisplayName("listSubscriptions with null customerId should return empty JSON object string")
    void listSubscriptions_withNullCustomerId_shouldReturnEmptyJson() {
        String result = stripeService.listSubscriptions(null);

        assertEquals("{}", result);
    }

    // ========== getSubscription ==========

    @Test
    @DisplayName("getSubscription should return empty JSON object string")
    void getSubscription_shouldReturnEmptyJson() {
        String result = stripeService.getSubscription("sub_123");

        assertEquals("{}", result);
    }

    // ========== createCustomer ==========

    @Test
    @DisplayName("createCustomer should return a map with an id and success flag")
    void createCustomer_shouldReturnStubMap() {
        Map<String, Object> result = stripeService.createCustomer("Test User", "test@example.com");

        assertNotNull(result);
        assertNotNull(result.get("id"));
        assertTrue(result.get("id").toString().startsWith("cus_stub_"));
        assertEquals(true, result.get("success"));
    }

    // ========== createSubscription ==========

    @Test
    @DisplayName("createSubscription should return a map with an id and success flag")
    void createSubscription_shouldReturnStubMap() {
        Map<String, Object> result = stripeService.createSubscription("cus_123", "price_abc");

        assertNotNull(result);
        assertNotNull(result.get("id"));
        assertTrue(result.get("id").toString().startsWith("sub_stub_"));
        assertEquals(true, result.get("success"));
    }

    // ========== getCustomerActiveSubscriptions ==========

    @Test
    @DisplayName("getCustomerActiveSubscriptions should return empty JSON object string")
    void getCustomerActiveSubscriptions_shouldReturnEmptyJson() {
        String result = stripeService.getCustomerActiveSubscriptions("cus_789");

        assertEquals("{}", result);
    }
}
