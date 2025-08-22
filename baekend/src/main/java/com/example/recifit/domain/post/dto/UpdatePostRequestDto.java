package com.example.recifit.domain.post.dto;

import lombok.Getter;

@Getter
public class UpdatePostRequestDto {

    private String title;

    private String content;

    public UpdatePostRequestDto(String title, String content) {
        this.title = title;
        this.content = content;
    }
}
