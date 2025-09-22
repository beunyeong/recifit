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

            return new LikeResponseDto(true, postId,post.getLikeCount());
        }

        Like like = likeRepository.save(Like.builder()
                .member(member)
                .post(post)
                .build());

        post.incrementPostLikeCount();

        return new LikeResponseDto(true, postId,post.getLikeCount());
    }
}

