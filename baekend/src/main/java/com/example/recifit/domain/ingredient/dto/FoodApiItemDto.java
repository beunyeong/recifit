package com.example.recifit.domain.ingredient.dto;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import lombok.Getter;

@Getter
public class FoodApiItemDto {

    @JacksonXmlProperty(localName = "FOOD_CD")
    private String foodCd;

    @JacksonXmlProperty(localName = "FOOD_NM_KR")
    private String foodNmKr;

    @JacksonXmlProperty(localName = "DB_GRP_NM")
    private String dbGrpNm;

    @JacksonXmlProperty(localName = "DB_CLASS_NM")
    private String dbClassNm;

    @JacksonXmlProperty(localName = "SERVING_SIZE")
    private String servingSize;

    @JacksonXmlProperty(localName = "AMT_NUM1")
    private String amtNum1;

    @JacksonXmlProperty(localName = "AMT_NUM2")
    private String amtNum2;
}