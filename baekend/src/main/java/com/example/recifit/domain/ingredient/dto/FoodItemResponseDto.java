package com.example.recifit.domain.ingredient.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;

@Getter
public class FoodItemResponseDto {

    @JsonProperty("식품코드")
    private String foodCd;

    @JsonProperty("식품명")
    private String foodNmKr;

    @JsonProperty("식품 그룹명")
    private String dbGrpNm;

    @JsonProperty("1회 제공량")
    private String servingSize;

    @JsonProperty("에너지(Kcal)")
    private String amtNum1;

    @JsonProperty("탄수화물(g)")
    private String amtNum2;

    public FoodItemResponseDto(String foodCd, String foodNmKr,
                               String dbGrpNm, String servingSize,
                               String amtNum1, String amtNum2) {
        this.foodCd = foodCd;
        this.foodNmKr = foodNmKr;
        this.dbGrpNm = dbGrpNm;
        this.servingSize = servingSize;
        this.amtNum1 = amtNum1;
        this.amtNum2 = amtNum2;
    }
}