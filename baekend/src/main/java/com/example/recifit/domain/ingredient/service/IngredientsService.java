package com.example.recifit.domain.ingredient.service;

import com.example.recifit.domain.ingredient.dto.FoodApiItemDto;
import com.example.recifit.domain.ingredient.dto.FoodApiResponseDto;
import com.example.recifit.domain.ingredient.dto.FoodItemResponseDto;
import com.example.recifit.domain.ingredient.dto.IngredientRequestDto;
import com.example.recifit.domain.ingredient.entity.Ingredients;
import com.example.recifit.domain.ingredient.repository.IngredientsRepository;
import com.example.recifit.global.client.FoodApiClient;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import com.example.recifit.global.util.XmlUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class IngredientsService {

    private final FoodApiClient foodApiClient;
    private final IngredientsRepository ingredientsRepository;

    public IngredientsService(FoodApiClient foodApiClient, IngredientsRepository ingredientsRepository) {
        this.foodApiClient = foodApiClient;
        this.ingredientsRepository = ingredientsRepository;
    }

    public ResponseEntity<CommonResponseDto<String>> addIngredient(IngredientRequestDto ingredientRequestDto) {

        if (ingredientRequestDto.getStorageDate().isAfter(LocalDate.now())) {
            throw new CustomException(ErrorCode.INVALID_STORAGE_DATE);
        }

        Ingredients ingredients = Ingredients.builder()
                .ingredientName(ingredientRequestDto.getIngredientName())
                .description(ingredientRequestDto.getDescription())
                .storageLocation(ingredientRequestDto.getStorageLocation())
                .storageDate(ingredientRequestDto.getStorageDate())
                .build();

        ingredientsRepository.save(ingredients);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.ADD_INGREDIENT_SUCCESS, null));
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