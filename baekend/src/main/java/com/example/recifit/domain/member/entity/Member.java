package com.example.recifit.domain.member.entity;

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
@NoArgsConstructor
@Builder
@Table(name = "members")
public class Member extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String email;

    private String password;

    private MemberRole memberRole;

    private MemberType memberType;

    private CookingLevel cookingLevel;

    public Member(Long id, String email, String password,
                  MemberRole memberrole, MemberType memberType, CookingLevel cookingLevel) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.memberRole = memberrole;
        this.memberType = memberType;
        this.cookingLevel = cookingLevel;
    }
}
