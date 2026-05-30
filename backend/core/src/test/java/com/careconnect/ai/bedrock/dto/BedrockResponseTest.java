package com.careconnect.ai.bedrock.dto;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BedrockResponseTest {

    @Test
    void constructor_setsResponse() {
        BedrockResponse response = new BedrockResponse("AI response text");

        assertThat(response.getResponse()).isEqualTo("AI response text");
    }

    @Test
    void constructor_allowsNull() {
        BedrockResponse response = new BedrockResponse(null);

        assertThat(response.getResponse()).isNull();
    }

    @Test
    void getResponse_returnsConstructorValue() {
        String expected = "Bedrock generated this response";
        BedrockResponse response = new BedrockResponse(expected);

        assertThat(response.getResponse()).isEqualTo(expected);
    }
}
