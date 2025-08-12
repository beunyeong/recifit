package com.example.recifit.domain.ingredient.dto;

import com.example.recifit.domain.ingredient.enums.StorageLocation;
import jakarta.validation.constraints.PastOrPresent;
import lombok.Getter;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Getter
public class IngredientRequestDto {

    private String ingredientName;
    private String description;
    private StorageLocation storageLocation;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @PastOrPresent
    private LocalDate storageDate;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate expirationDate;

    public IngredientRequestDto(String ingredientName, String description, StorageLocation storageLocation,
                                LocalDate storageDate, LocalDate expirationDate) {
        this.ingredientName = ingredientName;
        this.description = description;
        this.storageLocation = storageLocation;
        this.storageDate = storageDate;
        this.expirationDate = expirationDate;
    }
}