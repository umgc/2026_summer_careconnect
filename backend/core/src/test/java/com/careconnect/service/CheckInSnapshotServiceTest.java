package com.careconnect.service;

import com.careconnect.dto.CheckInCreateRequestDTO;
import com.careconnect.dto.CheckInCreateResponseDTO;
import com.careconnect.dto.QuestionDTO;
import com.careconnect.exception.AppException;
import com.careconnect.model.CheckIn;
import com.careconnect.model.CheckInQuestion;
import com.careconnect.model.Patient;
import com.careconnect.model.Question;
import com.careconnect.model.QuestionType;
import com.careconnect.repository.CheckInQuestionRepository;
import com.careconnect.repository.CheckInRepository;
import com.careconnect.repository.PatientRepository;
import com.careconnect.repository.QuestionRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CheckInSnapshotServiceTest {

    @Mock
    private CheckInRepository checkInRepository;
    @Mock
    private CheckInQuestionRepository checkInQuestionRepository;
    @Mock
    private PatientRepository patientRepository;
    @Mock
    private QuestionRepository questionRepository;

    private CheckInSnapshotService service;

    @BeforeEach
    void setUp() {
        service = new CheckInSnapshotService(
                checkInRepository,
                checkInQuestionRepository,
                patientRepository,
                questionRepository
        );
    }

    @Test
    void createCheckInWithSnapshot_persistsSnapshotFields() {
        Patient patient = Patient.builder().id(8L).build();
        Question q1 = Question.builder().id(1L).prompt("Prompt 1").type(QuestionType.TEXT).required(true).ordinal(10).active(true).build();
        Question q2 = Question.builder().id(2L).prompt("Prompt 2").type(QuestionType.YES_NO).required(false).ordinal(20).active(true).build();
        CheckIn persisted = CheckIn.builder().id(100L).patient(patient).createdAt(OffsetDateTime.parse("2026-06-26T18:00:00Z")).build();

        when(patientRepository.findById(8L)).thenReturn(Optional.of(patient));
        when(questionRepository.findAllById(any())).thenReturn(List.of(q1, q2));
        when(checkInRepository.save(any(CheckIn.class))).thenReturn(persisted);

        CheckInCreateResponseDTO result = service.createCheckInWithSnapshot(
                new CheckInCreateRequestDTO(8L, List.of(1L, 2L))
        );

        assertThat(result.checkInId()).isEqualTo(100L);
        assertThat(result.questionCount()).isEqualTo(2);

        ArgumentCaptor<List<CheckInQuestion>> captor = ArgumentCaptor.forClass(List.class);
        verify(checkInQuestionRepository).saveAll(captor.capture());
        List<CheckInQuestion> snapshots = captor.getValue();

        assertThat(snapshots).hasSize(2);
        assertThat(snapshots.get(0).getPromptSnapshot()).isEqualTo("Prompt 1");
        assertThat(snapshots.get(0).getTypeSnapshot()).isEqualTo("TEXT");
        assertThat(snapshots.get(0).isRequired()).isTrue();
        assertThat(snapshots.get(0).getOrdinal()).isEqualTo(10);
    }

    @Test
    void createCheckInWithSnapshot_throwsForMissingPatient() {
        when(patientRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.createCheckInWithSnapshot(
                new CheckInCreateRequestDTO(99L, List.of(1L))
        )).isInstanceOf(AppException.class)
          .hasMessageContaining("Patient not found");
    }

    @Test
    void createCheckInWithSnapshot_throwsForUnknownQuestionIds() {
        Patient patient = Patient.builder().id(8L).build();
        Question q1 = Question.builder().id(1L).prompt("Prompt 1").type(QuestionType.TEXT).required(true).ordinal(10).active(true).build();
        when(patientRepository.findById(8L)).thenReturn(Optional.of(patient));
        when(questionRepository.findAllById(any())).thenReturn(List.of(q1));

        assertThatThrownBy(() -> service.createCheckInWithSnapshot(
                new CheckInCreateRequestDTO(8L, List.of(1L, 2L))
        )).isInstanceOf(AppException.class)
          .hasMessageContaining("Unknown question ids");
    }

    @Test
    void getSnapshotQuestions_returnsRepositoryResult() {
        when(checkInQuestionRepository.findSnapshotQuestionDtosByCheckInId(5L))
                .thenReturn(List.of(new QuestionDTO(1L, "P", "TEXT", true, true, 1)));

        List<QuestionDTO> result = service.getSnapshotQuestions(5L);
        assertThat(result).hasSize(1);
        assertThat(result.get(0).prompt()).isEqualTo("P");
    }

    @Test
    void getSnapshotQuestions_throwsWhenCheckInMissing() {
        when(checkInQuestionRepository.findSnapshotQuestionDtosByCheckInId(5L))
                .thenReturn(List.of());
        when(checkInRepository.existsById(5L)).thenReturn(false);

        assertThatThrownBy(() -> service.getSnapshotQuestions(5L))
                .isInstanceOf(AppException.class)
                .hasMessageContaining("Check-in not found");
    }
}
