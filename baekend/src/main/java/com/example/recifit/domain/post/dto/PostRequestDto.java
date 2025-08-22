package com.example.recifit.domain.post.dto;

import com.example.recifit.domain.post.enums.PostCategory;
import lombok.Getter;

@Getter
public class PostRequestDto {

    private PostCategory postCategory;

    private String title;

    private String content;

    public PostRequestDto(PostCategory postCategory, String title, String content) {
        this.postCategory = postCategory;
        this.title = title;
        this.content = content;
    }
}