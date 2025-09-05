package com.example.recifit.domain.member.entity;

import com.example.recifit.domain.member.enums.AuthProvider;
import com.example.recifit.domain.member.enums.CookingLevel;
import com.example.recifit.domain.member.enums.MemberRole;
import com.example.recifit.domain.member.enums.MemberType;
import com.example.recifit.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;


@Entity
@Getter
@Table(name = "members")
@NoArgsConstructor
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;

    @Column(nullable = true)
    private String password;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AuthProvider provider = AuthProvider.LOCAL;

    private String nickname;

    @Column(name = "kakao_id", unique = true)
    private Long kakaoId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MemberRole memberRole = MemberRole.USER;

    @Enumerated(EnumType.STRING)
    private MemberType memberType;

    @Enumerated(EnumType.STRING)
    private CookingLevel cookingLevel;

    @Builder
    public Member(Long id, String email, String password, String nickname,
                  MemberType memberType, CookingLevel cookingLevel, Long kakaoId, AuthProvider provider) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.nickname = nickname;
        this.memberType = memberType;
        this.cookingLevel = cookingLevel;
        this.kakaoId = kakaoId;
        this.provider = provider;

    }
}