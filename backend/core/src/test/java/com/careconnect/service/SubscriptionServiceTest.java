package com.careconnect.service;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import com.careconnect.model.Plan;
import com.careconnect.model.Subscription;
import com.careconnect.model.User;
import com.careconnect.repository.PlanRepository;
import com.careconnect.repository.SubscriptionRepository;
import com.careconnect.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Optional;

/**
 * Unit tests for {@link SubscriptionService}.
 *
 * <p>All external dependencies (repositories) are mocked with Mockito so these
 * tests validate the service's business logic in isolation — no database or
 * Spring context is needed.</p>
 */
class SubscriptionServiceTest {

    @Mock
    private SubscriptionRepository subscriptionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PlanRepository planRepository;

    @InjectMocks
    private SubscriptionService subscriptionService;

    @BeforeEach
    void setUp() throws Exception {
        MockitoAnnotations.openMocks(this);
    }

    // ==========================================================================
    // createPlan
    // ==========================================================================

    @Test
    @DisplayName("createPlan: saves and returns a new plan with all fields set")
    void testCreatePlan_savesAndReturnsPlan() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> {
            Plan saved = inv.getArgument(0);
            saved.setId(1L);
            return saved;
        });

        final Plan result = subscriptionService.createPlan("STANDARD", "Standard Plan", 2000, "MONTH", true);

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
    void testCreatePlan_nullIsActive_defaultsToTrue() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> inv.getArgument(0));

        final Plan result = subscriptionService.createPlan("BASIC", "Basic Plan", 1000, "MONTH", null);

        assertTrue(result.getIsActive());
        verify(planRepository).save(any(Plan.class));
    }

    @Test
    @DisplayName("createPlan: respects explicit isActive=false")
    void testCreatePlan_explicitFalse_setsInactive() throws Exception {
        when(planRepository.save(any(Plan.class))).thenAnswer(inv -> inv.getArgument(0));

        final Plan result = subscriptionService.createPlan("TRIAL", "Trial", 0, "WEEK", false);

        assertFalse(result.getIsActive());
    }

    // ==========================================================================
    // getPlan
    // ==========================================================================

    @Test
    @DisplayName("getPlan: returns the Plan entity when the ID is found")
    void testGetPlan_found() throws Exception {
        final Plan plan = new Plan();
        plan.setId(1L);
        plan.setName("Premium Plan");
        when(planRepository.findById(1L)).thenReturn(Optional.of(plan));

        final Plan result = subscriptionService.getPlan(1L);

        assertNotNull(result);
        assertEquals("Premium Plan", result.getName());
        verify(planRepository).findById(1L);
    }

    @Test
    @DisplayName("getPlan: throws IllegalArgumentException when no plan exists for the ID")
    void testGetPlan_notFound() throws Exception {
        when(planRepository.findById(99L)).thenReturn(Optional.empty());

        final IllegalArgumentException ex = assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.getPlan(99L)
        );

        assertTrue(ex.getMessage().contains("99"),
                "Exception message should include the missing plan ID");
        verify(planRepository).findById(99L);
    }

    // ==========================================================================
    // cancelSubscription
    // ==========================================================================

    @Test
    @DisplayName("cancelSubscription: throws IllegalArgumentException when the subscription ID does not exist")
    void testCancelSubscription_notFound() throws Exception {
        when(subscriptionRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.cancelSubscription(999L)
        );
    }

    @Test
    @DisplayName("cancelSubscription: marks subscription CANCELLED and clears currentPeriodEnd")
    void testCancelSubscription_updatesLocalRecord() throws Exception {
        final Subscription sub = new Subscription();
        sub.setId(1L);
        sub.setStatus("ACTIVE");
        when(subscriptionRepository.findById(1L)).thenReturn(Optional.of(sub));
        when(subscriptionRepository.save(any(Subscription.class))).thenAnswer(inv -> inv.getArgument(0));

        subscriptionService.cancelSubscription(1L);

        assertEquals("CANCELLED", sub.getStatus());
        assertNull(sub.getCurrentPeriodEnd());
        verify(subscriptionRepository).save(sub);
    }

    // ==========================================================================
    // getUserSubscriptions
    // ==========================================================================

    @Test
    @DisplayName("getUserSubscriptions: throws IllegalArgumentException when the user does not exist")
    void testGetUserSubscriptions_userNotFound() throws Exception {
        when(userRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.getUserSubscriptions(99L)
        );
    }

    @Test
    @DisplayName("getUserSubscriptions: returns subscriptions for a valid user")
    void testGetUserSubscriptions_returnsSubscriptions() throws Exception {
        final User user = User.builder().id(1L).email("test@x.com").password("pw").build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));

        final Subscription sub = new Subscription();
        sub.setStatus("ACTIVE");
        when(subscriptionRepository.findByUser(user)).thenReturn(List.of(sub));

        final List<Subscription> result = subscriptionService.getUserSubscriptions(1L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("ACTIVE", result.get(0).getStatus());
        verify(subscriptionRepository).findByUser(user);
    }

    @Test
    @DisplayName("getUserSubscriptions: returns empty list when user has no subscriptions")
    void testGetUserSubscriptions_emptyList() throws Exception {
        final User user = User.builder().id(3L).email("test@x.com").password("pw").build();
        when(userRepository.findById(3L)).thenReturn(Optional.of(user));
        when(subscriptionRepository.findByUser(user)).thenReturn(List.of());

        final List<Subscription> result = subscriptionService.getUserSubscriptions(3L);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ==========================================================================
    // getUserActiveSubscriptions
    // ==========================================================================

    @Test
    @DisplayName("getUserActiveSubscriptions: throws IllegalArgumentException when the user does not exist")
    void testGetUserActiveSubscriptions_userNotFound() throws Exception {
        when(userRepository.findById(88L)).thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.getUserActiveSubscriptions(88L)
        );
    }

    @Test
    @DisplayName("getUserActiveSubscriptions: returns only ACTIVE subscriptions")
    void testGetUserActiveSubscriptions_returnsActiveOnly() throws Exception {
        final User user = User.builder().id(5L).email("test@x.com").password("pw").build();
        when(userRepository.findById(5L)).thenReturn(Optional.of(user));

        final Subscription activeSub = new Subscription();
        activeSub.setStatus("ACTIVE");
        when(subscriptionRepository.findByUserAndStatus(user, "ACTIVE")).thenReturn(List.of(activeSub));

        final List<Subscription> result = subscriptionService.getUserActiveSubscriptions(5L);

        assertNotNull(result);
        assertEquals(1, result.size());
        assertEquals("ACTIVE", result.get(0).getStatus());
        verify(subscriptionRepository).findByUserAndStatus(user, "ACTIVE");
    }

    @Test
    @DisplayName("getUserActiveSubscriptions: returns empty list when no ACTIVE subscriptions exist")
    void testGetUserActiveSubscriptions_emptyList() throws Exception {
        final User user = User.builder().id(6L).email("test@x.com").password("pw").build();
        when(userRepository.findById(6L)).thenReturn(Optional.of(user));
        when(subscriptionRepository.findByUserAndStatus(user, "ACTIVE")).thenReturn(List.of());

        final List<Subscription> result = subscriptionService.getUserActiveSubscriptions(6L);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ==========================================================================
    // createSubscriptionForUser
    // ==========================================================================

    @Test
    @DisplayName("createSubscriptionForUser: creates an ACTIVE subscription with correct fields")
    void testCreateSubscriptionForUser_success() throws Exception {
        final User user = User.builder().id(1L).email("test@x.com").password("pw").build();
        final Plan plan = new Plan();
        plan.setId(10L);
        plan.setName("Standard");
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(planRepository.findById(10L)).thenReturn(Optional.of(plan));
        when(subscriptionRepository.save(any(Subscription.class))).thenAnswer(inv -> {
            Subscription saved = inv.getArgument(0);
            saved.setId(100L);
            return saved;
        });

        final Subscription result = subscriptionService.createSubscriptionForUser(1L, 10L, "WEB");

        assertNotNull(result);
        assertEquals("ACTIVE", result.getStatus());
        assertEquals(user, result.getUser());
        assertEquals(plan, result.getPlan());
        assertNotNull(result.getStartedAt());
        assertNotNull(result.getCurrentPeriodEnd());
        assertNotNull(result.getPaymentSubscriptionId());
        assertTrue(result.getPaymentSubscriptionId().startsWith("web_"));
        verify(subscriptionRepository).save(any(Subscription.class));
    }

    @Test
    @DisplayName("createSubscriptionForUser: throws IllegalArgumentException when user does not exist")
    void testCreateSubscriptionForUser_userNotFound() throws Exception {
        when(userRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.createSubscriptionForUser(99L, 10L, "WEB")
        );
    }

    @Test
    @DisplayName("createSubscriptionForUser: throws IllegalArgumentException when plan does not exist")
    void testCreateSubscriptionForUser_planNotFound() throws Exception {
        final User user = User.builder().id(1L).email("test@x.com").password("pw").build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(planRepository.findById(99L)).thenReturn(Optional.empty());

        assertThrows(
                IllegalArgumentException.class,
                () -> subscriptionService.createSubscriptionForUser(1L, 99L, "WEB")
        );
    }
}
