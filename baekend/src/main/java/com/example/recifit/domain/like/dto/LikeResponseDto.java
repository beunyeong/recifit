package com.example.recifit.domain.like.dto;

import lombok.Getter;


@Getter
public class LikeResponseDto {

    private final boolean isLiked;      // 현재 내가 좋아요 중인지

    private final Long postId;          // 좋아요 누른 게시글 ID

    private final int likePostCount;        // 게시글 총 좋아요 수

    public LikeResponseDto(boolean isLiked, Long postId, int likePostCount) {
        this.isLiked = isLiked;
        this.postId = postId;
        this.likePostCount = likePostCount;
    }
}
