package com.example.recifit.global.common;

import lombok.Getter;

@Getter
public enum SuccessCode {

    /**
     * Auth 관련 Code
     */
    SIGNUP_SUCCESS("회원가입이 완료되었습니다."),
    LOGIN_SUCCESS("로그인이 완료되었습니다."),

    /**
     * INGREDIENT 관련 Code
     */
    ADD_INGREDIENT_SUCCESS("재료가 등록되었습니다."),
    GET_INGREDIENTS_SUCCESS("보유 재료 목록 불러오기 완료"),
    DELETE_INGREDIENT_SUCCESS("보유 재료가 정상적으로 삭제 되었습니다."),

    /**
     * 커뮤니티(Post) 관련 Code
     */
    ADD_POST_SUCCESS("게시글이 등록되었습니다."),
    UPDATE_POST_SUCCESS("게시글이 수정되었습니다."),
    GET_POST_SUCCESS("게시글 조회 완료"),
    DELETE_POST_SUCCESS("게시글이 삭제되었습니다."),

    /**
     * 댓글(Comment) 관련 Code
     */
    ADD_COMMENT_SUCCESS("댓글이 작성 되었습니다."),
    GET_COMMENT_SUCCESS("댓글이 조회 되었습니다."),


    /**
     * AI 레시피 추천 관련 Code
     */
    AI_RECIPE_SUCCESS("AI 레시피 추천 성공");



    private final String message;

    SuccessCode(String message) {
        this.message = message;
    }
}
