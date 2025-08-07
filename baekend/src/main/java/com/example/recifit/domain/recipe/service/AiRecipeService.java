package com.example.recifit.domain.recipe.service;

import com.example.recifit.domain.ingredient.entity.Ingredients;
import com.example.recifit.domain.ingredient.repository.IngredientsRepository;
import com.example.recifit.domain.recipe.dto.RecipeRequestDto;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.Resource;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
public class AiRecipeService {

    private final ChatClient chatClient;
    private final IngredientsRepository ingredientsRepository;

    @Value("classpath:templates/recipe-prompt.st")
    private Resource getRecipePrompt;

    public AiRecipeService(ChatClient chatClient, IngredientsRepository ingredientsRepository) {
        this.chatClient = chatClient;
        this.ingredientsRepository = ingredientsRepository;
    }

    public ResponseEntity<CommonResponseDto<String>> recommendRecipe(RecipeRequestDto recipeRequestDto, Long memberId) {
        List<String> ingredients = recipeRequestDto.getAvailableIngredients();
        if (CollectionUtils.isEmpty(ingredients)) {
            ingredients = ingredientsRepository.findByMemberId(memberId).stream()
                    .map(Ingredients::getName)
                    .collect(Collectors.toList());
            recipeRequestDto.setAvailableIngredients(ingredients);
        }
        PromptTemplate promptTemplate = new PromptTemplate(getRecipePrompt);
        Map<String, Object> variables = Map.of(
                "memberType", recipeRequestDto.getMemberType().name().toLowerCase(),
                "cookingLevel", recipeRequestDto.getCookingLevel().name().toLowerCase(),
                "availableIngredients", String.join(", ", recipeRequestDto.getAvailableIngredients()),
                "expiringIngredients", recipeRequestDto.getExpiringIngredients().isEmpty() ? "none" : String.join(", ", recipeRequestDto.getExpiringIngredients())
        );
        Prompt prompt = promptTemplate.create(variables);
        String content = chatClient.prompt(prompt).call().content();

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.AI_RECIPE_SUCCESS, content));
    }
}