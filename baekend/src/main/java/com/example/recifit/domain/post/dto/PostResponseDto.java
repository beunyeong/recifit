package com.example.recifit.domain.post.dto;

import com.example.recifit.domain.post.enums.PostCategory;
import lombok.Getter;

@Getter
public class PostResponseDto {

    private Long id;

    private PostCategory postCategory;

    private String title;

    private String content;

    private String nickname;

    private int likeCount;

    private int commentCount;

    public PostResponseDto(PostCategory postCategory, Long id, String title, String content,
                           String nickname, int likeCount, int commentCount) {
        this.postCategory = postCategory;
        this.id = id;
        this.title = title;
        this.content = content;
        this.nickname = nickname;
        this.likeCount = likeCount;
        this.commentCount = commentCount;
    }
}