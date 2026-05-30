package com.careconnect.ai;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import com.careconnect.dto.ChatConversationSummary;
import com.careconnect.dto.ChatMessageSummary;

import java.util.List;

public interface AIService {

    ChatResponse processChat(ChatRequest request);

    List<ChatConversationSummary> getPatientConversations(Long patientId);

    List<ChatMessageSummary> getConversationMessages(String conversationId);

    List<ChatMessageSummary> getRecentMessagesForUser(Long userId, int limit);

    void deactivateConversation(String conversationId);
}