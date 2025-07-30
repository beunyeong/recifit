package com.example.recifit.domain.ingredient.service;

import com.example.recifit.domain.ingredient.dto.FoodApiItemDto;
import com.example.recifit.domain.ingredient.dto.FoodApiResponseDto;
import com.example.recifit.domain.ingredient.dto.FoodItemResponseDto;
import com.example.recifit.global.client.FoodApiClient;
import com.example.recifit.global.util.XmlUtil;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class IngredientsService {

    private final FoodApiClient foodApiClient;

    public IngredientsService(FoodApiClient foodApiClient) {
        this.foodApiClient = foodApiClient;
    }

    public List<FoodItemResponseDto> searchFoodItems(String foodName) {
        String xml;
        try {
            xml = foodApiClient.getFoodXml(foodName).block();
        } catch (Exception e) {
            throw new RuntimeException("외부 식품 API 호출 실패: " + e.getMessage(), e);
        }
        FoodApiResponseDto response = XmlUtil.fromXml(xml, FoodApiResponseDto.class);

        // 정상코드("00")만 데이터 반환
        if (!"00".equals(response.getHeader().getResultCode())) {
            throw new RuntimeException("API 응답 오류: " + response.getHeader().getResultMsg());
        }

        List<FoodApiItemDto> items = response.getBody().getItems().getItem();

        return items.stream()
                .map(item -> new FoodItemResponseDto(
                        item.getFoodCd(),
                        item.getFoodNmKr(),
                        item.getDbGrpNm(),
                        item.getServingSize(),
                        item.getAmtNum1(),
                        item.getAmtNum2()
                )).collect(Collectors.toList());
    }
}