package com.example.recifit.domain.post.entity;

import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.post.enums.PostCategory;
import com.example.recifit.global.common.BaseEntity;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Getter
@Table(name = "posts")
@NoArgsConstructor
public class Post extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "제목은 필수 입력값입니다.")
    private String title;

    @NotBlank(message = "내용은 필수 입력값입니다.")
    private String content;

    private String name;

    @Enumerated(EnumType.STRING)
    private PostCategory postCategory;

    @Column(nullable = false)
    private int likeCount = 0;

    @Column(nullable = false)
    private int commentCount = 0;

    private LocalDateTime deletedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    @Builder
    public Post(String title, String content, String name,
                PostCategory postCategory, Member member) {
        this.title = title;
        this.content = content;
        this.name = name;
        this.postCategory = postCategory;
        this.member = member;
    }

    public void softDelete() {
        this.deletedAt = LocalDateTime.now();
    }

    public void update(String title, String content) {
        this.title = title;
        this.content = content;
    }
}