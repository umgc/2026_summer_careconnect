package com.careconnect.controller;

import com.careconnect.dto.ActivityLogDtos;
import com.careconnect.exception.AppException;
import com.careconnect.model.ActivityLog;
import com.careconnect.model.Patient;
import com.careconnect.model.User;
import com.careconnect.repository.ActivityLogRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.CaregiverPatientLinkService;
import com.careconnect.service.FamilyMemberService;
import com.careconnect.service.PatientService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ActivityLogControllerTest {

    @Mock
    private PatientService patientService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private CaregiverPatientLinkService caregiverPatientLinkService;

    @Mock
    private FamilyMemberService familyMemberService;

    @Mock
    private ActivityLogRepository activityLogRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    @InjectMocks
    private ActivityLogController controller;

    private User adminUser;
    private User caregiverUser;
    private User patientUser;
    private User familyMemberUser;
    private Patient patient;

    @BeforeEach
    void setUp() {
        SecurityContextHolder.setContext(securityContext);
        lenient().when(securityContext.getAuthentication()).thenReturn(authentication);
        lenient().when(authentication.getName()).thenReturn("test@example.com");

        adminUser = User.builder()
                .id(1L)
                .email("admin@example.com")
                .role(Role.ADMIN)
                .password("password")
                .build();

        caregiverUser = User.builder()
                .id(2L)
                .email("caregiver@example.com")
                .role(Role.CAREGIVER)
                .password("password")
                .build();

        patientUser = User.builder()
                .id(3L)
                .email("patient@example.com")
                .role(Role.PATIENT)
                .password("password")
                .build();

        familyMemberUser = User.builder()
                .id(4L)
                .email("family@example.com")
                .role(Role.FAMILY_MEMBER)
                .password("password")
                .build();

        patient = Patient.builder()
                .id(10L)
                .user(patientUser)
                .build();
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    // ========== createActivityLog tests ==========

    @Test
    void createActivityLog_success() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(caregiverPatientLinkService.hasAccessToPatient(2L, 3L)).thenReturn(true);

        ActivityLog saved = ActivityLog.builder()
                .id(100L)
                .clientId(10L)
                .activityId(5L)
                .activityName("Walking")
                .caregiverUserId(2L)
                .competencyScore(7)
                .satisfactionRating(2)
                .notes("Good session")
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setActivityName("Walking");
        req.setCompetencyScore(7);
        req.setSatisfactionRating(2);
        req.setNotes("Good session");

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isEqualTo(saved);
    }

    @Test
    void createActivityLog_missingClientId_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(null);
        req.setActivityId(5L);
        req.setCompetencyScore(7);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("clientId, activityId, and competencyScore are required");
    }

    @Test
    void createActivityLog_missingActivityId_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(null);
        req.setCompetencyScore(7);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("clientId, activityId, and competencyScore are required");
    }

    @Test
    void createActivityLog_missingCompetencyScore_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(null);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("clientId, activityId, and competencyScore are required");
    }

    @Test
    void createActivityLog_competencyScoreTooLow_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(0);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("competencyScore out of range");
    }

    @Test
    void createActivityLog_competencyScoreTooHigh_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(11);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("competencyScore out of range");
    }

    @Test
    void createActivityLog_satisfactionRatingTooLow_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setSatisfactionRating(0);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("satisfactionRating out of range");
    }

    @Test
    void createActivityLog_satisfactionRatingTooHigh_throwsBadRequest() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setSatisfactionRating(6);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("satisfactionRating out of range");
    }

    @Test
    void createActivityLog_satisfactionRatingNull_isAllowed() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(101L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(5)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setSatisfactionRating(null);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_activityNameBlank_setsNull() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(102L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(5)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setActivityName("   ");

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_patientRoleAccessDenied_throwsForbidden() {
        User otherPatientUser = User.builder()
                .id(99L)
                .email("other@example.com")
                .role(Role.PATIENT)
                .password("password")
                .build();
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(otherPatientUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void createActivityLog_caregiverAccessDenied_throwsForbidden() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(caregiverUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(caregiverPatientLinkService.hasAccessToPatient(2L, 3L)).thenReturn(false);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void createActivityLog_familyMemberAccessDenied_throwsForbidden() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(familyMemberUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(familyMemberService.hasAccessToPatient(4L, 3L)).thenReturn(false);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void createActivityLog_adminRole_alwaysHasAccess() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(103L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(5)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_patientAccessesOwnData_succeeds() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(patientUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(104L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(3L)
                .competencyScore(5)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_userNotAuthenticated_throwsUnauthorized() {
        when(userRepository.findByEmail("test@example.com")).thenReturn(Optional.empty());

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);

        assertThatThrownBy(() -> controller.createActivityLog(req))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("User not authenticated");
    }

    // ========== getActivityLogs tests ==========

    @Test
    void getActivityLogs_success() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        LocalDateTime now = LocalDateTime.now();
        List<ActivityLog> logs = List.of(
                ActivityLog.builder()
                        .id(1L)
                        .clientId(10L)
                        .activityId(5L)
                        .activityName("Walking")
                        .competencyScore(7)
                        .satisfactionRating(2)
                        .notes("Good")
                        .createdAt(now)
                        .build()
        );
        when(activityLogRepository.findByClientIdOrderByCreatedAtDesc(eq(10L), any()))
                .thenReturn(logs);

        ResponseEntity<List<ActivityLogDtos.ActivityLogResponse>> response =
                controller.getActivityLogs(10L, 50);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).hasSize(1);
        assertThat(response.getBody().get(0).getActivityName()).isEqualTo("Walking");
    }

    @Test
    void getActivityLogs_limitClampedToMinimum() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(activityLogRepository.findByClientIdOrderByCreatedAtDesc(eq(10L), any()))
                .thenReturn(List.of());

        ResponseEntity<List<ActivityLogDtos.ActivityLogResponse>> response =
                controller.getActivityLogs(10L, -5);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isEmpty();
    }

    @Test
    void getActivityLogs_limitClampedToMaximum() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(activityLogRepository.findByClientIdOrderByCreatedAtDesc(eq(10L), any()))
                .thenReturn(List.of());

        ResponseEntity<List<ActivityLogDtos.ActivityLogResponse>> response =
                controller.getActivityLogs(10L, 1000);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isEmpty();
    }

    @Test
    void getActivityLogs_accessDenied_throwsForbidden() {
        User otherPatientUser = User.builder()
                .id(99L)
                .email("other@example.com")
                .role(Role.PATIENT)
                .password("password")
                .build();
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(otherPatientUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        assertThatThrownBy(() -> controller.getActivityLogs(10L, 100))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Access denied");
    }

    @Test
    void getActivityLogs_familyMemberWithAccess_succeeds() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(familyMemberUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);
        when(familyMemberService.hasAccessToPatient(4L, 3L)).thenReturn(true);
        when(activityLogRepository.findByClientIdOrderByCreatedAtDesc(eq(10L), any()))
                .thenReturn(List.of());

        ResponseEntity<List<ActivityLogDtos.ActivityLogResponse>> response =
                controller.getActivityLogs(10L, 100);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void createActivityLog_competencyScoreBoundary_minValid() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(105L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(1)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(1);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_competencyScoreBoundary_maxValid() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(106L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(10)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(10);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_satisfactionRatingBoundary_minValid() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(107L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(5)
                .satisfactionRating(1)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setSatisfactionRating(1);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void createActivityLog_satisfactionRatingBoundary_maxValid() {
        when(userRepository.findByEmail("test@example.com"))
                .thenReturn(Optional.of(adminUser));
        when(patientService.getPatientById(10L)).thenReturn(patient);

        ActivityLog saved = ActivityLog.builder()
                .id(108L)
                .clientId(10L)
                .activityId(5L)
                .caregiverUserId(1L)
                .competencyScore(5)
                .satisfactionRating(3)
                .createdAt(LocalDateTime.now())
                .build();
        when(activityLogRepository.save(any(ActivityLog.class))).thenReturn(saved);

        ActivityLogDtos.CreateActivityLogRequest req = new ActivityLogDtos.CreateActivityLogRequest();
        req.setClientId(10L);
        req.setActivityId(5L);
        req.setCompetencyScore(5);
        req.setSatisfactionRating(3);

        ResponseEntity<?> response = controller.createActivityLog(req);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }
}
