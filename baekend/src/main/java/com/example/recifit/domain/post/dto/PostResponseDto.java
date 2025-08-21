package com.example.recifit.domain.post.dto;

import com.example.recifit.domain.post.enums.PostCategory;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class PostResponseDto {

    private Long id;

    private PostCategory postCategory;

    private String title;

    private String content;

    private String nickname;

    private int likeCount;

    private int commentCount;

    private LocalDateTime createdAt;

    public PostResponseDto(Long id, PostCategory postCategory, String title,
                           String content, String nickname, int likeCount,
                           int commentCount, LocalDateTime createdAt) {
        this.id = id;
        this.postCategory = postCategory;
        this.title = title;
        this.content = content;
        this.nickname = nickname;
        this.likeCount = likeCount;
        this.commentCount = commentCount;
        this.createdAt = createdAt;
    }
}