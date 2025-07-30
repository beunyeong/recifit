package com.example.recifit.domain.ingredient.controller;

import com.example.recifit.domain.ingredient.dto.FoodItemResponseDto;
import com.example.recifit.domain.ingredient.service.IngredientsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ingredients")
public class IngredientsController {

    private final IngredientsService ingredientsService;

    public IngredientsController(IngredientsService ingredientsService) {
        this.ingredientsService = ingredientsService;
    }


    @GetMapping("/search")
    public ResponseEntity<List<FoodItemResponseDto>> searchFood(@RequestParam("query") String foodName) {
        List<FoodItemResponseDto> result = ingredientsService.searchFoodItems(foodName);

        return ResponseEntity.ok(result);
    }
}