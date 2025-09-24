package com.example.recifit.domain.like.service;

import com.example.recifit.domain.like.dto.LikeResponseDto;
import com.example.recifit.domain.like.entity.Like;
import com.example.recifit.domain.like.repository.LikeRepository;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.domain.post.repository.PostRepository;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
public class LikeService {

    private final LikeRepository likeRepository;
    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    public LikeService(LikeRepository likeRepository,
                       PostRepository postRepository,
                       MemberRepository memberRepository) {
        this.likeRepository = likeRepository;
        this.postRepository = postRepository;
        this.memberRepository = memberRepository;
    }

    @Transactional
    public LikeResponseDto likeAddPost(Long postId, Long memberId) {

        // 게시글이 있는지 확인
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        // 좋아요 누른 멤버 확인
        // 해당 멤버가 중복 좋아요를 눌렀는지 확인할 수 있음
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        // 이미 좋아요 누른 상태라면 그대로 반환하기
        if (likeRepository.existsByPostIdAndMemberId(postId, memberId)) {


            // 이 조건이 항상 true로 걸리니까, 새로운 Like를 만들지 않고 그대로 return 하고 있음.
            // 즉, 카운트를 0으로 줄여도, 실제 likes 행이 남아 있기 때문에 "이미 좋아요 눌렀다" 라고 판단하고 있음.
            return new LikeResponseDto(true, postId,post.getLikeCount(), true);
        }

        Like like = likeRepository.save(Like.builder()
                .member(member)
                .post(post)
                .build());

        post.incrementPostLikeCount();

        return new LikeResponseDto(true, postId,post.getLikeCount(), true);
    }

    @Transactional
    public LikeResponseDto likeDeletePost(Long postId, Long memberId) {

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Like like = likeRepository.findByPostIdAndMemberId(postId, memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_LIKE_NOT_FOUND));

        // 내가 좋아요한 것인지 확인 -> 예외 처리
        if (!like.getMember().getId().equals(memberId)) {
            throw new CustomException(ErrorCode.POST_LIKE_DELETE_FORBIDDEN);
        }

        if(!like.getPost().getId().equals(postId)) {
            throw new CustomException(ErrorCode.POST_LIKE_DELETE_FORBIDDEN);
        }

        // 좋아요 눌렀는지 확인
        likeRepository.findByPostIdAndMemberId(postId, memberId)
                // null이 발생하면 실행되지 않음(.ifPresent())
                .ifPresent(a -> {
                    likeRepository.delete(like);         // 실제 Like 행 삭제
                });
        post.decrementPostLikeCount();

        return new LikeResponseDto(false, postId,post.getLikeCount(), false);
    }
}