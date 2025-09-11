package com.example.recifit.domain.comment.service;

import com.example.recifit.domain.comment.dto.CommentRequestDto;
import com.example.recifit.domain.comment.dto.CommentResponseDto;
import com.example.recifit.domain.comment.entity.Comment;
import com.example.recifit.domain.comment.repository.CommentRepository;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.domain.post.repository.PostRepository;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;


@Service
public class CommentService {

    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final MemberRepository memberRepository;

    public CommentService(PostRepository postRepository,
                          CommentRepository commentRepository,
                          MemberRepository memberRepository) {
        this.postRepository = postRepository;
        this.commentRepository = commentRepository;
        this.memberRepository = memberRepository;
    }

    private CommentResponseDto toDto(Comment comment, Long currentMemberId) {
        boolean mine = currentMemberId != null && currentMemberId.equals(comment.getMember().getId());
        return new CommentResponseDto(
                comment.getId(),
                comment.getPost().getId(),
                comment.getNickname(),
                comment.getContent(),
                comment.getCreatedAt(),
                mine
        );

    }

    public CommentResponseDto addComment(CommentRequestDto commentRequestDto, Long memberId, Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        Comment comment = commentRepository.save(Comment.builder()
                .nickname(member.getNickname())
                .content(commentRequestDto.getContent())
                .post(post)
                .member(member)
                .build()
        );

        return toDto(comment, memberId);
    }

    public List<CommentResponseDto> getAllComments(Long postId, Long currentMemberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        List<Comment> comments = commentRepository.findByPost(post);

        return comments.stream()
                .map(comment -> toDto(comment, currentMemberId))
                .collect(Collectors.toList());
    }

    @Transactional
    public CommentResponseDto updateComment(Long postId, Long commentId, Long memberId, CommentRequestDto commentRequestDto) {

        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new CustomException(ErrorCode.COMMENT_NOT_FOUND));

        if (!comment.getPost().getId().equals(postId)) {
            throw new CustomException(ErrorCode.COMMENT_NOT_IN_POST);
        }

        if (!comment.getMember().getId().equals(memberId)) {
            throw new CustomException(ErrorCode.NO_COMMENT_MODIFY_PERMISSION);
        }

        comment.updateComment(commentRequestDto.getContent());

        return toDto(comment, memberId);
    }
}