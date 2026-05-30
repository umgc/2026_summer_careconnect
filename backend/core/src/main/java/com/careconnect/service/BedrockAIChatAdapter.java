package com.careconnect.service;

import com.careconnect.ai.AIServiceFactory;
import com.careconnect.dto.ChatConversationSummary;
import com.careconnect.dto.ChatMessageSummary;
import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BedrockAIChatAdapter implements AIChatService {

    private final AIServiceFactory aiServiceFactory;

    @Override
    public ChatResponse processChat(ChatRequest request) {
        return aiServiceFactory.getService().processChat(request);
    }

    // 🚫 Not supported yet — safe stubs

    @Override
    public List<ChatConversationSummary> getPatientConversations(Long patientId) {
        throw new UnsupportedOperationException("Not supported in Bedrock mode yet.");
    }

    @Override
    public List<ChatMessageSummary> getConversationMessages(String conversationId) {
        throw new UnsupportedOperationException("Not supported in Bedrock mode yet.");
    }

    @Override
    public List<ChatMessageSummary> getRecentMessagesForUser(Long userId, int limit) {
        throw new UnsupportedOperationException("Not supported in Bedrock mode yet.");
    }

    @Override
    public void deactivateConversation(String conversationId) {
        throw new UnsupportedOperationException("Not supported in Bedrock mode yet.");
    }
}