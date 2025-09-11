package com.example.recifit.domain.post.service;


import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.domain.post.dto.PostRequestDto;
import com.example.recifit.domain.post.dto.PostResponseDto;
import com.example.recifit.domain.post.dto.UpdatePostRequestDto;
import com.example.recifit.domain.post.dto.UpdatePostResponseDto;
import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.domain.post.enums.PostCategory;
import com.example.recifit.domain.post.repository.PostRepository;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
@Slf4j
public class PostService {

    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    public PostService(PostRepository postRepository, MemberRepository memberRepository) {
        this.postRepository = postRepository;
        this.memberRepository = memberRepository;
    }

    public PostResponseDto addPost(PostRequestDto postRequestDto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Post post = Post.builder()
                .title(postRequestDto.getTitle())
                .content(postRequestDto.getContent())
                .name(member.getNickname())
                .postCategory(postRequestDto.getPostCategory())
                .member(member)
                .build();
        postRepository.save(post);

        log.info("저장된 게시글 카테고리: {}", post.getPostCategory());

        return new PostResponseDto(
                post.getId(),
                post.getMember().getId(),
                post.getPostCategory(),
                post.getTitle(),
                post.getContent(),
                post.getName(),
                post.getLikeCount(),
                post.getCommentCount(),
                post.getCreatedAt(),
                true
        );
    }

    @Transactional
    public UpdatePostResponseDto updatePost(Long memberId, Long postId, UpdatePostRequestDto updatePostRequestDto) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        if(!post.getMember().getId().equals(memberId)) {
            throw new CustomException(ErrorCode.NO_POST_MODIFY_PERMISSION);
        }

        post.update(updatePostRequestDto.getTitle(), updatePostRequestDto.getContent());

        return new UpdatePostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getContent()
        );
    }

    public Page<PostResponseDto> getposts(PostCategory postCategory, Long memberId, Pageable pageable, Long currentMemberId) {
        Page<Post> posts;
        if(memberId == null && postCategory == null) {
            posts = postRepository.findAllByDeletedAtIsNull(pageable);
        } else if(memberId == null) {
            posts = postRepository.findAllByPostCategoryAndDeletedAtIsNull(postCategory, pageable);
        } else {
            posts = postRepository.findAllByMemberIdAndDeletedAtIsNull(memberId, pageable);
        }

        return posts.map(post -> toDto(post, currentMemberId));
    }

    private PostResponseDto toDto(Post post, Long currentMemberId) {
        boolean mine = (currentMemberId != null && currentMemberId.equals(post.getMember().getId()));
        return new PostResponseDto(
                post.getId(),
                post.getMember().getId(),
                post.getPostCategory(),
                post.getTitle(),
                post.getContent(),
                post.getMember().getNickname(),
                post.getLikeCount(),
                post.getCommentCount(),
                post.getCreatedAt(),
                mine
        );
    }

    public PostResponseDto getPost(Long postId, Long memberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        return toDto(post, memberId);
    }

    @Transactional
    public void deletePost(Long postId, Long memberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
        if(!post.getMember().getId().equals(memberId)) {
            throw new CustomException(ErrorCode.NO_DELETE_MODIFY_PERMISSION);
        }
        post.softDelete();
        post.softDeleteWithComments();
    }
}