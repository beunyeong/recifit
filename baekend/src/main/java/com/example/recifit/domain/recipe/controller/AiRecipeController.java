package com.example.recifit.domain.recipe.controller;

import com.example.recifit.domain.recipe.dto.RecipeRequestDto;
import com.example.recifit.domain.recipe.service.AiRecipeService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.security.MemberDetailsImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/api/recipes")
@Tag(name = "AI 레시피 추천", description = "냉장고 속 재료, 유통기한, 사용자 정보를 기반으로 AI가 맞춤형 레시피를 추천하는 API")
public class AiRecipeController {

    private final AiRecipeService aiRecipeService;

    public AiRecipeController(AiRecipeService aiRecipeService) {
        this.aiRecipeService = aiRecipeService;
    }

    @PostMapping("/recommendations")
    public ResponseEntity<CommonResponseDto<String>> recommendRecipe(@RequestBody RecipeRequestDto recipeRequestDto,
                                                                     @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {

        Long memberId = memberDetailsImpl.getMember().getId();
        return aiRecipeService.recommendRecipe(recipeRequestDto, memberId);
    }
}
