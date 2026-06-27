package com.careconnect.controller;

import com.careconnect.dto.CheckInCreateRequestDTO;
import com.careconnect.dto.CheckInCreateResponseDTO;
import com.careconnect.dto.CheckInSummaryDTO;
import com.careconnect.dto.QuestionDTO;
import com.careconnect.model.User;
import com.careconnect.security.Role;
import com.careconnect.service.CheckInSnapshotService;
import com.careconnect.service.QuestionService;
import com.careconnect.util.SecurityUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.OffsetDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class CheckInQuestionControllerTest {

    private MockMvc mockMvc;

    @Mock
    private QuestionService questionService;

    @Mock
    private CheckInSnapshotService checkInSnapshotService;

    @Mock
    private SecurityUtil securityUtil;

    @InjectMocks
    private CheckInQuestionController controller;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .standaloneSetup(controller)
                .build();
        User user = new User();
        user.setId(100L);
        user.setRole(Role.CAREGIVER);
        lenient().when(securityUtil.resolveCurrentUser()).thenReturn(user);
    }

    @Test
    void getQuestions_primaryPath_returnsSnapshots() throws Exception {
        final Long checkInId = 1L;
        when(checkInSnapshotService.getSnapshotQuestions(checkInId))
                .thenReturn(List.of(
                        new QuestionDTO(1L, "Snapshot prompt", "TEXT", true, true, 1)
                ));

        mockMvc.perform(get("/api/checkins/{checkInId}/questions", checkInId)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].prompt").value("Snapshot prompt"))
                .andExpect(jsonPath("$[0].type").value("TEXT"));

        verify(checkInSnapshotService, times(1)).getSnapshotQuestions(checkInId);
        verify(questionService, never()).findActiveOrdered();
    }

    @Test
    void getQuestions_versionedPath_returnsLegacyActiveQuestions() throws Exception {
        when(questionService.findActiveOrdered())
                .thenReturn(List.of(
                        new QuestionDTO(10L, "Legacy active", "TEXT", true, true, 1)
                ));

        mockMvc.perform(get("/v1/api/checkins/{checkInId}/questions", 99L))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].prompt").value("Legacy active"));

        verify(questionService).findActiveOrdered();
        verify(checkInSnapshotService, never()).getSnapshotQuestions(any());
    }

    @Test
    void getQuestions_versionedPath_withContextPath_stillUsesLegacyBehavior() throws Exception {
        when(questionService.findActiveOrdered())
                .thenReturn(List.of(
                        new QuestionDTO(10L, "Legacy active", "TEXT", true, true, 1)
                ));

        mockMvc.perform(get("/careconnect/v1/api/checkins/{checkInId}/questions", 99L)
                        .contextPath("/careconnect"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].prompt").value("Legacy active"));

        verify(questionService).findActiveOrdered();
        verify(checkInSnapshotService, never()).getSnapshotQuestions(any());
    }

    @Test
    void createCheckIn_persistsSnapshotAndReturnsCreated() throws Exception {
        CheckInCreateRequestDTO request = new CheckInCreateRequestDTO(7L, List.of(1L, 2L, 3L));
        OffsetDateTime createdAt = OffsetDateTime.parse("2026-06-26T10:15:30Z");
        when(checkInSnapshotService.createCheckInWithSnapshot(any(CheckInCreateRequestDTO.class)))
                .thenReturn(new CheckInCreateResponseDTO(42L, 7L, createdAt, 3));

        mockMvc.perform(post("/api/checkins")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.checkInId").value(42))
                .andExpect(jsonPath("$.patientId").value(7))
                .andExpect(jsonPath("$.questionCount").value(3));

        verify(checkInSnapshotService).createCheckInWithSnapshot(eq(request));
    }

    @Test
    void createCheckIn_withNullQuestionId_returnsBadRequest() throws Exception {
        mockMvc.perform(post("/api/checkins")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"patientId\":7,\"selectedQuestionIds\":[1,null,3]}"))
                .andExpect(status().isBadRequest());

        verify(checkInSnapshotService, never()).createCheckInWithSnapshot(any());
    }

    @Test
    void listPatientCheckIns_returnsSummaries() throws Exception {
        when(checkInSnapshotService.listCheckInsForPatient(7L))
                .thenReturn(List.of(new CheckInSummaryDTO(42L, 7L, OffsetDateTime.parse("2026-06-26T10:15:30Z"), null, 3)));

        mockMvc.perform(get("/api/checkins/patients/{patientId}", 7L)
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].checkInId").value(42))
                .andExpect(jsonPath("$[0].patientId").value(7))
                .andExpect(jsonPath("$[0].questionCount").value(3));

        verify(checkInSnapshotService).listCheckInsForPatient(7L);
    }

    @Test
    void latestPatientCheckIn_returnsNoContentWhenMissing() throws Exception {
        when(checkInSnapshotService.getLatestCheckInForPatient(7L))
                .thenReturn(java.util.Optional.empty());

        mockMvc.perform(get("/api/checkins/patients/{patientId}/latest", 7L))
                .andExpect(status().isNoContent());

        verify(checkInSnapshotService).getLatestCheckInForPatient(7L);
    }
}
