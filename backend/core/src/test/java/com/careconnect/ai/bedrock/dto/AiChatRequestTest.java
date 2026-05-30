package com.careconnect.ai.bedrock.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AiChatRequestTest {

    @Test
    void defaultConstructor_createsInstanceWithNullMessage() {
        AiChatRequest request = new AiChatRequest();

        assertThat(request.getMessage()).isNull();
    }

    @Test
    void setMessage_updatesMessage() {
        AiChatRequest request = new AiChatRequest();

        request.setMessage("Hello, AI!");

        assertThat(request.getMessage()).isEqualTo("Hello, AI!");
    }

    @Test
    void setMessage_allowsNull() {
        AiChatRequest request = new AiChatRequest();
        request.setMessage("initial");

        request.setMessage(null);

        assertThat(request.getMessage()).isNull();
    }

    @Test
    void getMessage_returnsSetValue() {
        AiChatRequest request = new AiChatRequest();
        request.setMessage("test message");

        String result = request.getMessage();

        assertThat(result).isEqualTo("test message");
    }
}
