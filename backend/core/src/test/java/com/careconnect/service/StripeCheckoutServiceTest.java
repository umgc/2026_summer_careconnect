package com.careconnect.service;

import com.careconnect.model.Plan;
import com.careconnect.repository.PlanRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link StripeCheckoutService}.
 *
 * <p>The service is a stub that retains only plan CRUD operations.
 * All repository dependencies are mocked.</p>
 */
class StripeCheckoutServiceTest {

    @Mock
    private PlanRepository planRepository;

    @InjectMocks
    private StripeCheckoutService stripeCheckoutService;

    private Plan plan;

    @BeforeEach
    void setUp() throws Exception {
        MockitoAnnotations.openMocks(this);

        plan = new Plan();
        plan.setId(100L);
        plan.setCode("price_abc123");
        plan.setName("Premium");
        plan.setPriceCents(1999);
        plan.setBillingPeriod("monthly");
        plan.setIsActive(true);
    }

    // ========== getAvailablePlans ==========

    @Test
    @DisplayName("getAvailablePlans: returns active plans from repository")
    void getAvailablePlans_shouldReturnActivePlans() throws Exception {
        when(planRepository.findByIsActiveTrue()).thenReturn(List.of(plan));

        final List<Plan> result = stripeCheckoutService.getAvailablePlans();

        assertEquals(1, result.size());
        assertEquals("Premium", result.get(0).getName());
        verify(planRepository).findByIsActiveTrue();
    }

    @Test
    @DisplayName("getAvailablePlans: returns empty list when no active plans exist")
    void getAvailablePlans_noActivePlans_shouldReturnEmptyList() throws Exception {
        when(planRepository.findByIsActiveTrue()).thenReturn(Collections.emptyList());

        final List<Plan> result = stripeCheckoutService.getAvailablePlans();

        assertTrue(result.isEmpty());
    }

    // ========== createPlan ==========

    @Test
    @DisplayName("createPlan: saves and returns a plan with all provided fields")
    void createPlan_shouldSaveAndReturnPlan() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> {
            final Plan p = inv.getArgument(0);
            p.setId(200L);
            return p;
        });

        final Plan result = stripeCheckoutService.createPlan("STANDARD", "Standard Plan", 2000, "MONTH", true);

        assertNotNull(result);
        assertEquals("STANDARD", result.getCode());
        assertEquals("Standard Plan", result.getName());
        assertEquals(2000, result.getPriceCents());
        assertEquals("MONTH", result.getBillingPeriod());
        assertTrue(result.getIsActive());
        verify(planRepository).save(any(Plan.class));
    }

    @Test
    @DisplayName("createPlan: defaults isActive to true when null is passed")
    void createPlan_withNullIsActive_shouldDefaultToTrue() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> inv.getArgument(0));

        final Plan result = stripeCheckoutService.createPlan("BASIC", "Basic", 500, "MONTH", null);

        assertTrue(result.getIsActive());
    }

    @Test
    @DisplayName("createPlan: respects explicit isActive=false")
    void createPlan_withFalseIsActive_shouldSetInactive() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> inv.getArgument(0));

        final Plan result = stripeCheckoutService.createPlan("TRIAL", "Trial", 0, "WEEK", false);

        assertFalse(result.getIsActive());
    }
}
