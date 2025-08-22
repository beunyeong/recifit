package com.example.recifit.domain.post.dto;

import lombok.Getter;

@Getter
public class UpdatePostResponseDto {

    private Long postId;

    private String title;

    private String content;

    public UpdatePostResponseDto(Long postId, String title, String content) {
        this.postId = postId;
        this.title = title;
        this.content = content;
    }
}
