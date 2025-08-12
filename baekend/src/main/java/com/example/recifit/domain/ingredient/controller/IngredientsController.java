package com.example.recifit.domain.ingredient.controller;

import com.example.recifit.domain.ingredient.dto.FoodItemResponseDto;
import com.example.recifit.domain.ingredient.dto.IngredientRequestDto;
import com.example.recifit.domain.ingredient.dto.IngredientResponseDto;
import com.example.recifit.domain.ingredient.service.IngredientsService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.security.MemberDetailsImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ingredients")
@Tag(name = "Ingredients", description = "냉장고 재료 관리 기능을 제공하는 API")
public class IngredientsController {

    private final IngredientsService ingredientsService;

    public IngredientsController(IngredientsService ingredientsService) {
        this.ingredientsService = ingredientsService;
    }

    @PostMapping("/add")
    public ResponseEntity<CommonResponseDto<String>> addIngredient(@RequestBody IngredientRequestDto ingredientRequestDto) {

        return ingredientsService.addIngredient(ingredientRequestDto);
    }

    @GetMapping("/search")
    public ResponseEntity<List<FoodItemResponseDto>> searchFood(@RequestParam("query") String foodName) {
        List<FoodItemResponseDto> result = ingredientsService.searchFoodItems(foodName);

        return ResponseEntity.ok(result);
    }

    @GetMapping("/my")
    public ResponseEntity<List<IngredientResponseDto>> getMyIngredients(
            @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        List<IngredientResponseDto> result = ingredientsService.getMyIngredients(memberId);

        return ResponseEntity.ok(result);
    }
}