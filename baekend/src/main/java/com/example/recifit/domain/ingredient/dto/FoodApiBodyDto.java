package com.example.recifit.domain.ingredient.dto;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import lombok.Getter;

@Getter
public class FoodApiBodyDto {

    @JacksonXmlProperty(localName = "numOfRows")
    private String numOfRows;

    @JacksonXmlProperty(localName = "pageNo")
    private String pageNo;

    @JacksonXmlProperty(localName = "totalCount")
    private String totalCount;

    @JacksonXmlProperty(localName = "items")
    private FoodApiItemsDto items;
}