package com.example.recifit.domain.post.dto;

import com.example.recifit.domain.post.enums.PostCategory;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class PostResponseDto {

    private Long id;

    private Long memberId;

    private PostCategory postCategory;

    private String title;

    private String content;

    private String nickname;

    private int likeCount;

    private int commentCount;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;

    private boolean mine;

    private boolean likedByMe;

    public PostResponseDto(Long id, Long memberId, PostCategory postCategory, String title,
                           String content, String nickname, int likeCount,
                           int commentCount, LocalDateTime createdAt,
                           boolean mine, boolean likedByMe) {
        this.id = id;
        this.memberId = memberId;
        this.postCategory = postCategory;
        this.title = title;
        this.content = content;
        this.nickname = nickname;
        this.likeCount = likeCount;
        this.commentCount = commentCount;
        this.createdAt = createdAt;
        this.mine = mine;
        this.likedByMe = likedByMe;
    }
}