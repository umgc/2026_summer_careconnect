package com.careconnect.controller;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.careconnect.dto.CompetencyScaleDtos;
import com.careconnect.exception.AppException;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.SystemConfigService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

@ExtendWith(MockitoExtension.class)
class ConfigControllerTest {

    @Mock
    private SystemConfigService configService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private SecurityContext securityContext;

    @Mock
    private Authentication authentication;

    private ConfigController controller;

    private User adminUser;

    @BeforeEach
    void setUp() {
        controller = new ConfigController(configService, userRepository);

        adminUser = new User();
        adminUser.setId(1L);
        adminUser.setEmail("admin@test.com");
        adminUser.setRole(Role.ADMIN);

        SecurityContextHolder.setContext(securityContext);
        when(securityContext.getAuthentication()).thenReturn(authentication);
        when(authentication.getName()).thenReturn("admin@test.com");
        when(userRepository.findByEmail("admin@test.com")).thenReturn(Optional.of(adminUser));
    }

    // =========================================================================
    // GET /competency-scale
    // =========================================================================

    @Test
    @DisplayName("getCompetencyScale returns default scale when no config values exist")
    void getCompetencyScale_noConfigValues_returnsDefaults() {
        when(configService.getValue("competency_scale_min")).thenReturn(Optional.empty());
        when(configService.getValue("competency_scale_max")).thenReturn(Optional.empty());
        for (int v = 1; v <= 5; v++) {
            when(configService.getValue("competency_label_" + v)).thenReturn(Optional.empty());
        }

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.getCompetencyScale();

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        CompetencyScaleDtos.CompetencyScaleResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.getMin()).isEqualTo(1);
        assertThat(body.getMax()).isEqualTo(5);
        assertThat(body.getItems()).hasSize(5);
    }

    @Test
    @DisplayName("getCompetencyScale returns configured scale with labels")
    void getCompetencyScale_withConfigValues_returnsConfigured() {
        when(configService.getValue("competency_scale_min")).thenReturn(Optional.of("1"));
        when(configService.getValue("competency_scale_max")).thenReturn(Optional.of("3"));
        when(configService.getValue("competency_label_1")).thenReturn(Optional.of("Low"));
        when(configService.getValue("competency_label_2")).thenReturn(Optional.of("Medium"));
        when(configService.getValue("competency_label_3")).thenReturn(Optional.of("High"));

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.getCompetencyScale();

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        CompetencyScaleDtos.CompetencyScaleResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.getMin()).isEqualTo(1);
        assertThat(body.getMax()).isEqualTo(3);
        assertThat(body.getItems()).hasSize(3);
        assertThat(body.getLabels().get(1)).isEqualTo("Low");
        assertThat(body.getLabels().get(2)).isEqualTo("Medium");
        assertThat(body.getLabels().get(3)).isEqualTo("High");
    }

    @Test
    @DisplayName("getCompetencyScale resets to defaults when min > max")
    void getCompetencyScale_minGreaterThanMax_resetsToDefaults() {
        when(configService.getValue("competency_scale_min")).thenReturn(Optional.of("10"));
        when(configService.getValue("competency_scale_max")).thenReturn(Optional.of("3"));
        for (int v = 1; v <= 5; v++) {
            when(configService.getValue("competency_label_" + v)).thenReturn(Optional.empty());
        }

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.getCompetencyScale();

        CompetencyScaleDtos.CompetencyScaleResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.getMin()).isEqualTo(1);
        assertThat(body.getMax()).isEqualTo(5);
    }

    @Test
    @DisplayName("getCompetencyScale handles non-numeric min/max gracefully")
    void getCompetencyScale_nonNumericValues_fallsBackToDefaults() {
        when(configService.getValue("competency_scale_min")).thenReturn(Optional.of("abc"));
        when(configService.getValue("competency_scale_max")).thenReturn(Optional.of("xyz"));
        for (int v = 1; v <= 5; v++) {
            when(configService.getValue("competency_label_" + v)).thenReturn(Optional.empty());
        }

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.getCompetencyScale();

        CompetencyScaleDtos.CompetencyScaleResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.getMin()).isEqualTo(1);
        assertThat(body.getMax()).isEqualTo(5);
    }

    @Test
    @DisplayName("getCompetencyScale throws AppException when user not found")
    void getCompetencyScale_userNotFound_throwsAppException() {
        when(userRepository.findByEmail("admin@test.com")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> controller.getCompetencyScale())
                .isInstanceOf(AppException.class)
                .hasMessageContaining("User not authenticated");
    }

    // =========================================================================
    // PUT /competency-scale
    // =========================================================================

    @Test
    @DisplayName("putCompetencyScale successfully updates scale")
    void putCompetencyScale_validRequest_updatesAndReturnsScale() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(1, "Poor");
        labels.put(2, "Fair");
        labels.put(3, "Good");

        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 3, labels);

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.putCompetencyScale(request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        CompetencyScaleDtos.CompetencyScaleResponse body = response.getBody();
        assertThat(body).isNotNull();
        assertThat(body.getMin()).isEqualTo(1);
        assertThat(body.getMax()).isEqualTo(3);
        assertThat(body.getItems()).hasSize(3);
        assertThat(body.getLabels().get(1)).isEqualTo("Poor");
        assertThat(body.getLabels().get(2)).isEqualTo("Fair");
        assertThat(body.getLabels().get(3)).isEqualTo("Good");

        verify(configService).setValue("competency_scale_min", "1", 1L);
        verify(configService).setValue("competency_scale_max", "3", 1L);
        verify(configService).setValue("competency_label_1", "Poor", 1L);
        verify(configService).setValue("competency_label_2", "Fair", 1L);
        verify(configService).setValue("competency_label_3", "Good", 1L);
    }

    @Test
    @DisplayName("putCompetencyScale throws when min is null")
    void putCompetencyScale_nullMin_throwsAppException() {
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(null, 5, new LinkedHashMap<>());

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("min, max, and labels are required");
    }

    @Test
    @DisplayName("putCompetencyScale throws when max is null")
    void putCompetencyScale_nullMax_throwsAppException() {
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, null, new LinkedHashMap<>());

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("min, max, and labels are required");
    }

    @Test
    @DisplayName("putCompetencyScale throws when labels are null")
    void putCompetencyScale_nullLabels_throwsAppException() {
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 5, null);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("min, max, and labels are required");
    }

    @Test
    @DisplayName("putCompetencyScale throws when min < 1")
    void putCompetencyScale_minLessThanOne_throwsAppException() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(0, "Zero");
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(0, 3, labels);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Invalid min/max");
    }

    @Test
    @DisplayName("putCompetencyScale throws when min > max")
    void putCompetencyScale_minGreaterThanMax_throwsAppException() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(5, 3, labels);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Invalid min/max");
    }

    @Test
    @DisplayName("putCompetencyScale throws when a label is missing for a value")
    void putCompetencyScale_missingLabel_throwsAppException() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(1, "Low");
        // Missing label for value 2
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 2, labels);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Missing label for value 2");
    }

    @Test
    @DisplayName("putCompetencyScale throws when a label is blank")
    void putCompetencyScale_blankLabel_throwsAppException() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(1, "Low");
        labels.put(2, "   ");
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 2, labels);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Missing label for value 2");
    }

    @Test
    @DisplayName("putCompetencyScale trims label whitespace")
    void putCompetencyScale_labelsWithWhitespace_trims() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(1, "  Low  ");
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 1, labels);

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.putCompetencyScale(request);

        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getLabels().get(1)).isEqualTo("Low");
        verify(configService).setValue("competency_label_1", "Low", 1L);
    }

    @Test
    @DisplayName("putCompetencyScale throws AppException when user not authenticated")
    void putCompetencyScale_userNotFound_throwsAppException() {
        when(userRepository.findByEmail("admin@test.com")).thenReturn(Optional.empty());

        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(1, "Low");
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(1, 1, labels);

        assertThatThrownBy(() -> controller.putCompetencyScale(request))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("User not authenticated");
    }

    @Test
    @DisplayName("putCompetencyScale with single value min equals max")
    void putCompetencyScale_singleValue_succeeds() {
        Map<Integer, String> labels = new LinkedHashMap<>();
        labels.put(3, "Only");
        CompetencyScaleDtos.UpdateCompetencyScaleRequest request =
                new CompetencyScaleDtos.UpdateCompetencyScaleRequest(3, 3, labels);

        ResponseEntity<CompetencyScaleDtos.CompetencyScaleResponse> response =
                controller.putCompetencyScale(request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getMin()).isEqualTo(3);
        assertThat(response.getBody().getMax()).isEqualTo(3);
        assertThat(response.getBody().getItems()).hasSize(1);
    }
}
