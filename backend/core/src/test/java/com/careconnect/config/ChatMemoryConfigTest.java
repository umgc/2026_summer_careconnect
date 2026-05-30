package com.careconnect.config;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ChatMemoryConfigTest {

    private ChatMemoryConfig config;

    @BeforeEach
    void setUp() {
        config = new ChatMemoryConfig();
    }

    @Test
    void defaultUseDatabasePersistence_isTrue() {
        assertThat(config.isUseDatabasePersistence()).isTrue();
    }

    @Test
    void setUseDatabasePersistence_updatesValue() {
        config.setUseDatabasePersistence(false);

        assertThat(config.isUseDatabasePersistence()).isFalse();
    }

    @Test
    void defaultMaxMessages_isTwenty() {
        assertThat(config.getDefaultMaxMessages()).isEqualTo(20);
    }

    @Test
    void setDefaultMaxMessages_updatesValue() {
        config.setDefaultMaxMessages(10);

        assertThat(config.getDefaultMaxMessages()).isEqualTo(10);
    }

    @Test
    void defaultPremiumMaxMessages_isFifty() {
        assertThat(config.getPremiumMaxMessages()).isEqualTo(50);
    }

    @Test
    void setPremiumMaxMessages_updatesValue() {
        config.setPremiumMaxMessages(100);

        assertThat(config.getPremiumMaxMessages()).isEqualTo(100);
    }

    @Test
    void defaultAutoCleanup_isTrue() {
        assertThat(config.isAutoCleanup()).isTrue();
    }

    @Test
    void setAutoCleanup_updatesValue() {
        config.setAutoCleanup(false);

        assertThat(config.isAutoCleanup()).isFalse();
    }

    @Test
    void defaultCleanupAfterDays_isThirty() {
        assertThat(config.getCleanupAfterDays()).isEqualTo(30);
    }

    @Test
    void setCleanupAfterDays_updatesValue() {
        config.setCleanupAfterDays(60);

        assertThat(config.getCleanupAfterDays()).isEqualTo(60);
    }

    @Test
    void defaultCompressOldMessages_isFalse() {
        assertThat(config.isCompressOldMessages()).isFalse();
    }

    @Test
    void setCompressOldMessages_updatesValue() {
        config.setCompressOldMessages(true);

        assertThat(config.isCompressOldMessages()).isTrue();
    }

    @Test
    void defaultEnableSummarization_isTrue() {
        assertThat(config.isEnableSummarization()).isTrue();
    }

    @Test
    void setEnableSummarization_updatesValue() {
        config.setEnableSummarization(false);

        assertThat(config.isEnableSummarization()).isFalse();
    }

    @Test
    void defaultSummarizationThreshold_isOneHundred() {
        assertThat(config.getSummarizationThreshold()).isEqualTo(100);
    }

    @Test
    void setSummarizationThreshold_updatesValue() {
        config.setSummarizationThreshold(200);

        assertThat(config.getSummarizationThreshold()).isEqualTo(200);
    }
}
