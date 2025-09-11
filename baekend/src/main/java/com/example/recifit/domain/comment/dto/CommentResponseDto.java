package com.example.recifit.domain.comment.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;


@Getter
public class CommentResponseDto {

    private Long id;

    private Long postId;

    private String nickname;

    private String content;

    private boolean mine;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt;

    @Builder
    public CommentResponseDto(Long id, Long postId, String nickname,
                              String content, LocalDateTime createdAt, boolean mine) {
        this.id = id;
        this.postId = postId;
        this.nickname = nickname;
        this.content = content;
        this.createdAt = createdAt;
        this.mine = mine;
    }
}
