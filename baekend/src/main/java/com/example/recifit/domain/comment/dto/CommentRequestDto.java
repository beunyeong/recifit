package com.example.recifit.domain.comment.dto;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;


@Getter
public class CommentRequestDto {

    private final String content;

    @JsonCreator
    public CommentRequestDto(@JsonProperty("content") String content) {
        this.content = content;
    }
}
