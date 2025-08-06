package com.example.recifit.domain.recipe.controller;

import com.example.recifit.domain.recipe.dto.RecipeRequestDto;
import com.example.recifit.domain.recipe.service.AiRecipeService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.security.MemberDetailsImpl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;


@Controller
@RequestMapping("/api/recipes")
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
