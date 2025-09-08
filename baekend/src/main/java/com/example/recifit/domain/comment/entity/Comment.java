package com.example.recifit.domain.comment.entity;

import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;


@Entity
@Getter
@Table(name = "comments")
@NoArgsConstructor
public class Comment extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private String nickname;

    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    private int likeCount;

    @Builder
    public Comment(String nickname, String content, Post post, Member member) {
        this.nickname = nickname;
        this.content = content;
        this.post = post;
        this.member = member;
        this.likeCount = 0;
    }

    // 좋아요 수 증가
    public void incrementLikeCount() {
        this.likeCount++;
    }

    // 좋아요 수 감소
    public void decrementLikeCount() {
        if (this.likeCount > 0) {
            this.likeCount--;
        }
    }

    public void updateComment(String comment) {
        this.content = comment;
    }
}
