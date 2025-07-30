package com.example.recifit.domain.ingredient.dto;

import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlProperty;
import com.fasterxml.jackson.dataformat.xml.annotation.JacksonXmlRootElement;
import lombok.Getter;

@Getter
@JacksonXmlRootElement(localName = "response")
public class FoodApiResponseDto {

    @JacksonXmlProperty(localName = "header")
    private FoodApiHeaderDto header;

    @JacksonXmlProperty(localName = "body")
    private FoodApiBodyDto body;
}