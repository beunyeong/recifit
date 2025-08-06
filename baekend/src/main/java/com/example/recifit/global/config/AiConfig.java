package com.example.recifit.global.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.openai.OpenAiChatModel;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.openai.api.OpenAiApi;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.client.RestTemplate;

@Configuration
public class AiConfig {

    @Value("${spring.ai.openai.api-key}")
    private String secretKey;

    @Value("${spring.ai.openai.chat.options.model}")
    private String openAiModel;

    @Value("${spring.ai.openai.chat.options.temperature}")
    private Float openAiTemperature;

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();

        return new RestTemplate();
    }

    @Bean
    public HttpHeaders httpHeaders() {
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.set("Authorization", "Bearer " + secretKey);
        httpHeaders.setContentType(MediaType.APPLICATION_JSON);

        return httpHeaders;
    }

    @Bean
    public OpenAiApi openAiApi() {

        return new OpenAiApi(secretKey);
    }

    @Bean
    public ChatModel chatModel(OpenAiApi openAiApi) {

        return new OpenAiChatModel(openAiApi, OpenAiChatOptions.builder()
                .withModel(openAiModel)
                .withTemperature(openAiTemperature)
                .build());
    }

    @Bean
    public ChatClient chatClient(ChatModel chatModel) {

        return ChatClient.builder(chatModel).build();
    }
}