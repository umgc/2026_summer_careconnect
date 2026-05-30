package com.careconnect.service;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.bedrockruntime.BedrockRuntimeClient;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelRequest;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelResponse;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BedrockAIChatServiceTest {

    private BedrockRuntimeClient mockClient;
    private BedrockAIChatService service;

    @BeforeEach
    void setUp() {
        mockClient = mock(BedrockRuntimeClient.class);
        // Create instance without invoking the real constructor (which builds a real AWS client).
        try {
            java.lang.reflect.Field unsafeField =
                    sun.misc.Unsafe.class.getDeclaredField("theUnsafe");
            unsafeField.setAccessible(true);
            sun.misc.Unsafe unsafe = (sun.misc.Unsafe) unsafeField.get(null);
            service = (BedrockAIChatService) unsafe.allocateInstance(BedrockAIChatService.class);
        } catch (Exception e) {
            // Fallback: try normal construction (will fail without AWS credentials).
            try {
                service = new BedrockAIChatService();
            } catch (Exception e2) {
                throw new RuntimeException(
                        "Cannot create BedrockAIChatService instance for testing", e2);
            }
        }
        ReflectionTestUtils.setField(service, "client", mockClient);
    }

    @Test
    void processChat_success_returnsResponse() {
        String aiResponseBody = "{\"output\":{\"message\":{\"content\":[{\"text\":\"Hello from Bedrock\"}]}}}";
        SdkBytes responseBytes = SdkBytes.fromUtf8String(aiResponseBody);
        InvokeModelResponse invokeResponse = InvokeModelResponse.builder()
                .body(responseBytes)
                .build();
        when(mockClient.invokeModel(any(InvokeModelRequest.class))).thenReturn(invokeResponse);

        ChatRequest request = new ChatRequest();
        request.setMessage("Hello");

        ChatResponse response = service.processChat(request);

        assertThat(response).isNotNull();
        assertThat(response.getAiResponse()).isEqualTo("Hello from Bedrock");
        assertThat(response.getSuccess()).isTrue();
        assertThat(response.getTimestamp()).isNotNull();
    }

    @Test
    void processChat_withQuotesInMessage_escapesCorrectly() {
        String aiResponseBody = "{\"output\":{\"message\":{\"content\":[{\"text\":\"Response\"}]}}}";
        SdkBytes responseBytes = SdkBytes.fromUtf8String(aiResponseBody);
        InvokeModelResponse invokeResponse = InvokeModelResponse.builder()
                .body(responseBytes)
                .build();
        when(mockClient.invokeModel(any(InvokeModelRequest.class))).thenReturn(invokeResponse);

        ChatRequest request = new ChatRequest();
        request.setMessage("He said \"hello\" to me");

        ChatResponse response = service.processChat(request);

        assertThat(response).isNotNull();
        assertThat(response.getSuccess()).isTrue();
    }

    @Test
    void getPatientConversations_throwsUnsupportedOperationException() {
        assertThatThrownBy(() -> service.getPatientConversations(1L))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    void getConversationMessages_throwsUnsupportedOperationException() {
        assertThatThrownBy(() -> service.getConversationMessages("conv-123"))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    void getRecentMessagesForUser_throwsUnsupportedOperationException() {
        assertThatThrownBy(() -> service.getRecentMessagesForUser(1L, 10))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    void deactivateConversation_throwsUnsupportedOperationException() {
        assertThatThrownBy(() -> service.deactivateConversation("conv-123"))
                .isInstanceOf(UnsupportedOperationException.class);
    }
}
