package com.example.recifit.domain.recipe.dto;

import com.example.recifit.domain.member.enums.CookingLevel;
import com.example.recifit.domain.member.enums.MemberType;
import lombok.Getter;

import java.util.ArrayList;
import java.util.List;

@Getter
public class RecipeRequestDto {

    private List<String> availableIngredients;

    private List<String> expiringIngredients;

    private MemberType memberType;

    private CookingLevel cookingLevel;

    private String recipeId;

    public void setAvailableIngredients(List<String> ingredients) {
        this.availableIngredients = (ingredients == null) ? new ArrayList<>() : ingredients;
    }
}
