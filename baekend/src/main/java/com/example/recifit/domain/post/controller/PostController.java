package com.example.recifit.domain.post.controller;

import com.example.recifit.domain.post.dto.PostRequestDto;
import com.example.recifit.domain.post.dto.PostResponseDto;
import com.example.recifit.domain.post.dto.UpdatePostRequestDto;
import com.example.recifit.domain.post.dto.UpdatePostResponseDto;
import com.example.recifit.domain.post.enums.PostCategory;
import com.example.recifit.domain.post.service.PostService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.security.MemberDetailsImpl;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/posts")
@Tag(name = "Post", description = "커뮤니티 게시글 작성·조회·수정·삭제 및 댓글·좋아요·카테고리 관리 API")
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    @PostMapping("/add")
    public ResponseEntity<CommonResponseDto<PostResponseDto>> addPost(@RequestBody PostRequestDto postRequestDto,
                                                                      @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        PostResponseDto postResponseDto = postService.addPost(postRequestDto, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.ADD_POST_SUCCESS, postResponseDto));
    }

    @PatchMapping("/{postId}")
    public ResponseEntity<CommonResponseDto<UpdatePostResponseDto>> updatePost(@PathVariable Long postId,
                                                                               @RequestBody UpdatePostRequestDto updatePostRequestDto,
                                                                               @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl) {
        Long memberId = memberDetailsImpl.getMember().getId();
        UpdatePostResponseDto postResponseDto = postService.updatePost(memberId, postId, updatePostRequestDto);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.UPDATE_POST_SUCCESS, postResponseDto));
    }

    @GetMapping
    public ResponseEntity<CommonResponseDto<List<PostResponseDto>>> getAllPost(PostCategory postCategory,
                                                                               @AuthenticationPrincipal MemberDetailsImpl memberDetailsImpl,
                                                                               @RequestParam(value = "mine", defaultValue = "false") boolean mine) {
        Long memberId = (mine ? memberDetailsImpl.getMember().getId() : null);

        List<PostResponseDto> result = postService.getposts(postCategory, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.GET_POST_SUCCESS, result));
    }

    @DeleteMapping("/{postId}")
    public ResponseEntity<CommonResponseDto<Void>> deletePost(@PathVariable Long postId,
                                                              @AuthenticationPrincipal MemberDetailsImpl memberDetails) {
        Long memberId = memberDetails.getMember().getId();
        postService.deletePost(postId, memberId);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.DELETE_POST_SUCCESS, null));
    }
}