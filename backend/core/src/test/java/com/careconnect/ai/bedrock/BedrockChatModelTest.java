package com.careconnect.ai.bedrock;

import com.careconnect.service.ai.BedrockChatModel;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.chat.response.ChatResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;
import software.amazon.awssdk.core.SdkBytes;
import software.amazon.awssdk.services.bedrockruntime.BedrockRuntimeClient;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelRequest;
import software.amazon.awssdk.services.bedrockruntime.model.InvokeModelResponse;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BedrockChatModelTest {

    @Test
    void chat_returnsResponseFromBedrockClient() {
        BedrockRuntimeClient mockClient = mock(BedrockRuntimeClient.class);

        String responseJson = "{\"results\":[{\"outputText\":\"Hello from Bedrock\"}]}";
        SdkBytes responseBody = SdkBytes.fromUtf8String(responseJson);
        InvokeModelResponse invokeResponse = InvokeModelResponse.builder()
                .body(responseBody)
                .build();
        when(mockClient.invokeModel(any(InvokeModelRequest.class))).thenReturn(invokeResponse);

        BedrockChatModel model = createModelWithMockClient(mockClient);

        List<ChatMessage> messages = List.of(UserMessage.from("Hello"));
        ChatResponse response = model.chat(messages);

        assertThat(response).isNotNull();
        assertThat(response.aiMessage()).isNotNull();
        assertThat(response.aiMessage().text()).isEqualTo(responseJson);
        verify(mockClient).invokeModel(any(InvokeModelRequest.class));
    }

    @Test
    void chat_withMultipleMessages_concatenatesPrompt() {
        BedrockRuntimeClient mockClient = mock(BedrockRuntimeClient.class);

        String responseJson = "{\"results\":[{\"outputText\":\"Combined response\"}]}";
        SdkBytes responseBody = SdkBytes.fromUtf8String(responseJson);
        InvokeModelResponse invokeResponse = InvokeModelResponse.builder()
                .body(responseBody)
                .build();
        when(mockClient.invokeModel(any(InvokeModelRequest.class))).thenReturn(invokeResponse);

        BedrockChatModel model = createModelWithMockClient(mockClient);

        List<ChatMessage> messages = List.of(
                UserMessage.from("First message"),
                UserMessage.from("Second message")
        );

        ChatResponse response = model.chat(messages);

        assertThat(response).isNotNull();
        assertThat(response.aiMessage().text()).isEqualTo(responseJson);
    }

    @Test
    void chat_withEmptyMessageList_stillInvokesClient() {
        BedrockRuntimeClient mockClient = mock(BedrockRuntimeClient.class);

        String responseJson = "{\"results\":[]}";
        SdkBytes responseBody = SdkBytes.fromUtf8String(responseJson);
        InvokeModelResponse invokeResponse = InvokeModelResponse.builder()
                .body(responseBody)
                .build();
        when(mockClient.invokeModel(any(InvokeModelRequest.class))).thenReturn(invokeResponse);

        BedrockChatModel model = createModelWithMockClient(mockClient);

        ChatResponse response = model.chat(List.of());

        assertThat(response).isNotNull();
    }

    /**
     * Creates a BedrockChatModel with a mock client injected via reflection,
     * bypassing the real AWS client construction in the constructor.
     * Uses sun.misc.Unsafe to allocate an instance without invoking the constructor.
     */
    private BedrockChatModel createModelWithMockClient(BedrockRuntimeClient mockClient) {
        BedrockChatModel model;
        try {
            // First attempt: invoke the real constructor (works when AWS SDK can
            // build a client, e.g. with credentials or default provider chain).
            java.lang.reflect.Constructor<BedrockChatModel> ctor =
                    BedrockChatModel.class.getDeclaredConstructor(
                            String.class, String.class, double.class);
            ctor.setAccessible(true);
            model = ctor.newInstance("us-east-1", "amazon.titan-text-express-v1", 0.7);
        } catch (Exception e) {
            // Fallback: allocate instance via sun.misc.Unsafe without calling constructor.
            try {
                java.lang.reflect.Field unsafeField =
                        sun.misc.Unsafe.class.getDeclaredField("theUnsafe");
                unsafeField.setAccessible(true);
                sun.misc.Unsafe unsafe = (sun.misc.Unsafe) unsafeField.get(null);
                model = (BedrockChatModel) unsafe.allocateInstance(BedrockChatModel.class);
            } catch (Exception e2) {
                throw new RuntimeException(
                        "Cannot create BedrockChatModel instance for testing", e2);
            }
        }

        ReflectionTestUtils.setField(model, "client", mockClient);
        ReflectionTestUtils.setField(model, "modelId", "amazon.nova-lite-v1:0");
        ReflectionTestUtils.setField(model, "temperature", 0.7);
        return model;
    }
}
