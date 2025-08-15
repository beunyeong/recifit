package com.example.recifit.domain.ingredient.service;

import com.example.recifit.domain.ingredient.dto.*;
import com.example.recifit.domain.ingredient.entity.Ingredients;
import com.example.recifit.domain.ingredient.repository.IngredientsRepository;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.global.client.FoodApiClient;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import com.example.recifit.global.util.XmlUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class IngredientsService {

    private final FoodApiClient foodApiClient;
    private final IngredientsRepository ingredientsRepository;
    private final MemberRepository memberRepository;

    public IngredientsService(FoodApiClient foodApiClient, IngredientsRepository ingredientsRepository, MemberRepository memberRepository) {
        this.foodApiClient = foodApiClient;
        this.ingredientsRepository = ingredientsRepository;
        this.memberRepository = memberRepository;
    }

    public ResponseEntity<CommonResponseDto<String>> addIngredient(IngredientRequestDto ingredientRequestDto) {

        if (ingredientRequestDto.getStorageDate().isAfter(LocalDate.now())) {
            throw new CustomException(ErrorCode.INVALID_STORAGE_DATE);
        }
        if (ingredientRequestDto.getExpirationDate().isBefore(LocalDate.now())) {
            throw new CustomException(ErrorCode.INVALID_EXPIRATION_DATE);
        }
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();

        Member member = memberRepository.findByEmail(userEmail)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Ingredients ingredients = Ingredients.builder()
                .name(ingredientRequestDto.getIngredientName())
                .description(ingredientRequestDto.getDescription())
                .storageLocation(ingredientRequestDto.getStorageLocation())
                .storageDate(ingredientRequestDto.getStorageDate())
                .expirationDate(ingredientRequestDto.getExpirationDate())
                .member(member)
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

    public List<IngredientResponseDto> getMyIngredients(Long memberId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName();

        Member member = memberRepository.findByEmail(userEmail)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        List<Ingredients> withExpiry = ingredientsRepository
                .findAllWithExpiryByMemberOrderByExpiryAsc(member.getId());
        List<Ingredients> withoutExpiry = ingredientsRepository
                .findAllWithoutExpiryByMember(member.getId());

        List<Ingredients> all = new ArrayList<>(withExpiry.size() + withoutExpiry.size());
        all.addAll(withExpiry);
        all.addAll(withoutExpiry);

        LocalDate currentDate = LocalDate.now();
        return all.stream().map(ingredient -> toDto(ingredient, currentDate)).toList();
    }

    private IngredientResponseDto toDto(Ingredients ingredient, LocalDate currentDate) {
        Integer remainingDays = null;
        if (ingredient.getExpirationDate() != null) {
            remainingDays = (int) ChronoUnit.DAYS.between(currentDate, ingredient.getExpirationDate());
        }
        return IngredientResponseDto.builder()
                .id(ingredient.getId())
                .ingredientName(ingredient.getName())
                .description(ingredient.getDescription())
                .storageLocation(ingredient.getStorageLocation())
                .storageDate(ingredient.getStorageDate())
                .expirationDate(ingredient.getExpirationDate())
                .remainingDays(remainingDays)
                .build();
    }

    @Transactional
    public void deleteIngredient(Long id, Long memberId) {
        Ingredients ingredient = ingredientsRepository.findByIdAndMemberId(id, memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.INGREDIENT_NOT_FOUND));
        ingredient.deleteIngredients();
    }
}