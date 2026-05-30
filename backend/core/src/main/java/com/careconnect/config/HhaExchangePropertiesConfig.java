package com.careconnect.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(HhaExchangeProperties.class)
public class HhaExchangePropertiesConfig {
}
