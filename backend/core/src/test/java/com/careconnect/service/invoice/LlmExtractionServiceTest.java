package com.careconnect.service.invoice;

import com.careconnect.ai.AIService;
import com.careconnect.ai.AIServiceFactory;
import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class LlmExtractionServiceTest {

    @Mock
    private AIServiceFactory aiServiceFactory;

    @Mock
    private AIService aiService;

    @InjectMocks
    private LlmExtractionService llmExtractionService;

    @Test
    void extractInvoiceData_validResponse_returnsTrimmedText() {

        ChatResponse chatResponse = new ChatResponse();
        chatResponse.setAiResponse("  {\"invoiceNumber\":\"INV-001\"}  ");

        when(aiServiceFactory.getService()).thenReturn(aiService);
        when(aiService.processChat(any(ChatRequest.class))).thenReturn(chatResponse);

        String result = llmExtractionService.extractInvoiceData("Raw invoice text");

        assertThat(result).isEqualTo("{\"invoiceNumber\":\"INV-001\"}");
    }

    @Test
    void extractInvoiceData_nullResponse_returnsEmpty() {

        ChatResponse chatResponse = new ChatResponse();
        chatResponse.setAiResponse(null);

        when(aiServiceFactory.getService()).thenReturn(aiService);
        when(aiService.processChat(any())).thenReturn(chatResponse);

        String result = llmExtractionService.extractInvoiceData("Raw invoice text");

        assertThat(result).isEmpty();
    }

    @Test
    void extractInvoiceData_nullAiResponse_returnsEmpty() {

        ChatResponse chatResponse = new ChatResponse();
        chatResponse.setAiResponse(null);

        when(aiServiceFactory.getService()).thenReturn(aiService);
        when(aiService.processChat(any())).thenReturn(chatResponse);

        String result = llmExtractionService.extractInvoiceData("Raw invoice text");

        assertThat(result).isEmpty();
    }

    @Test
    void extractInvoiceData_emptyResponse_returnsEmpty() {

        ChatResponse chatResponse = new ChatResponse();
        chatResponse.setAiResponse("   ");

        when(aiServiceFactory.getService()).thenReturn(aiService);
        when(aiService.processChat(any())).thenReturn(chatResponse);

        String result = llmExtractionService.extractInvoiceData("Raw invoice text");

        assertThat(result).isEmpty();
    }
}