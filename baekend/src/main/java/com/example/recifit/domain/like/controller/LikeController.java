package com.example.recifit.domain.like.controller;

import com.example.recifit.domain.like.dto.LikeResponseDto;
import com.example.recifit.domain.like.service.LikeService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.security.MemberDetailsImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/likes/post/{postId}")
@Tag(name = "Like", description = "게시글, 댓글 좋아요 카운트 API")
public class LikeController {

    private final LikeService likeService;

    public LikeController(LikeService likeService) {
        this.likeService = likeService;
    }

    @PostMapping
    public ResponseEntity<CommonResponseDto<LikeResponseDto>> likeAddPost(@PathVariable Long postId,
                                                                          @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();

        LikeResponseDto likeResponseDto = likeService.likeAddPost(postId, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.ADD_POST_LIKE_SUCCESS, likeResponseDto));
    }

    @DeleteMapping
    public ResponseEntity<CommonResponseDto<LikeResponseDto>> likeDeletePost(@PathVariable Long postId,
                                                                             @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();

        LikeResponseDto likeResponseDto = likeService.likeDeletePost(postId, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.REMOVE_POST_LIKE_SUCCESS, likeResponseDto));
    }
}