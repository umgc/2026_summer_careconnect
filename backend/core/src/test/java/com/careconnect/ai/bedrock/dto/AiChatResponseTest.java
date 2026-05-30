package com.careconnect.ai.bedrock.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class AiChatResponseTest {

    @Test
    void constructor_setsResponse() {
        AiChatResponse response = new AiChatResponse("Hello from AI");

        assertThat(response.getResponse()).isEqualTo("Hello from AI");
    }

    @Test
    void constructor_allowsNull() {
        AiChatResponse response = new AiChatResponse(null);

        assertThat(response.getResponse()).isNull();
    }

    @Test
    void getResponse_returnsConstructorValue() {
        String expected = "This is a test response";
        AiChatResponse response = new AiChatResponse(expected);

        assertThat(response.getResponse()).isEqualTo(expected);
    }
}
