package com.example.recifit.domain.comment.controller;

import com.example.recifit.domain.comment.dto.CommentRequestDto;
import com.example.recifit.domain.comment.dto.CommentResponseDto;
import com.example.recifit.domain.comment.service.CommentService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.security.MemberDetailsImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/posts/{postId}/comments")
@Tag(name = "Comment", description = "커뮤니티 게시글 댓글 작성·조회·수정·삭제 API")
public class CommentController {

    private final CommentService commentService;

    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }

    @PostMapping
    public ResponseEntity<CommonResponseDto<CommentResponseDto>> addComment(@RequestBody CommentRequestDto commentRequestDto,
                                                                            @PathVariable Long postId,
                                                                            @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        CommentResponseDto commentResponseDto = commentService.addComment(commentRequestDto,memberId, postId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.ADD_COMMENT_SUCCESS, commentResponseDto));
    }

    @GetMapping
    public ResponseEntity<CommonResponseDto<List<CommentResponseDto>>> getComments(@PathVariable Long postId,
                                                                                   @AuthenticationPrincipal MemberDetailsImpl memberDetails) {
        Long currentMemberId = (memberDetails != null) ? memberDetails.getMember().getId() : null;
        List<CommentResponseDto> comments = commentService.getAllComments(postId, currentMemberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.GET_COMMENT_SUCCESS, comments));
    }

    @PatchMapping("/{commentId}")
    public ResponseEntity<CommonResponseDto<CommentResponseDto>> updateComment(@PathVariable Long postId,
                                                                               @PathVariable Long commentId,
                                                                               @RequestBody CommentRequestDto commentRequestDto,
                                                                               @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        CommentResponseDto commentResponseDto = commentService.updateComment(postId, commentId, memberId, commentRequestDto);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.UPDATE_COMMENT_SUCCESS, commentResponseDto));
    }

    @DeleteMapping("/{commentId}")
    public ResponseEntity<CommonResponseDto<Void>> deleteComment(@PathVariable Long postId,
                                                                 @PathVariable Long commentId,
                                                                 @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        commentService.deleteComment(postId, commentId, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.DELETE_COMMENT_SUCCESS, null));
    }
}