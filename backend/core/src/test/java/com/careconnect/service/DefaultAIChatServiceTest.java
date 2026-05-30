package com.careconnect.service;

import com.careconnect.dto.ChatRequest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DisplayName("DefaultAIChatService — disabled stub")
class DefaultAIChatServiceTest {

    @Test
    @DisplayName("no-arg constructor creates instance successfully")
    void noArgConstructor_createsInstance() {
        assertThat(new DefaultAIChatService()).isNotNull();
    }

    @Test
    @DisplayName("test constructor with all-null args creates instance successfully")
    void testConstructor_allNullArgs_createsInstance() {
        DefaultAIChatService service = new DefaultAIChatService(
                null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null, null, null);
        assertThat(service).isNotNull();
    }

    @Test
    @DisplayName("processChat throws UnsupportedOperationException with descriptive message")
    void processChat_throwsUnsupportedOperationException() {
        DefaultAIChatService service = new DefaultAIChatService();
        ChatRequest request = new ChatRequest();

        assertThatThrownBy(() -> service.processChat(request))
                .isInstanceOf(UnsupportedOperationException.class)
                .hasMessageContaining("DeepSeek AI is disabled");
    }

    @Test
    @DisplayName("getPatientConversations throws UnsupportedOperationException")
    void getPatientConversations_throwsUnsupportedOperationException() {
        DefaultAIChatService service = new DefaultAIChatService();

        assertThatThrownBy(() -> service.getPatientConversations(1L))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    @DisplayName("getConversationMessages throws UnsupportedOperationException")
    void getConversationMessages_throwsUnsupportedOperationException() {
        DefaultAIChatService service = new DefaultAIChatService();

        assertThatThrownBy(() -> service.getConversationMessages("conv-id"))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    @DisplayName("getRecentMessagesForUser throws UnsupportedOperationException")
    void getRecentMessagesForUser_throwsUnsupportedOperationException() {
        DefaultAIChatService service = new DefaultAIChatService();

        assertThatThrownBy(() -> service.getRecentMessagesForUser(1L, 10))
                .isInstanceOf(UnsupportedOperationException.class);
    }

    @Test
    @DisplayName("deactivateConversation throws UnsupportedOperationException")
    void deactivateConversation_throwsUnsupportedOperationException() {
        DefaultAIChatService service = new DefaultAIChatService();

        assertThatThrownBy(() -> service.deactivateConversation("conv-id"))
                .isInstanceOf(UnsupportedOperationException.class);
    }
}
