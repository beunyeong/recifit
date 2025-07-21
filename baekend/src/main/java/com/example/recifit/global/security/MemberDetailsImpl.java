package com.example.recifit.global.security;

import com.example.recifit.domain.member.entity.Member;
import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Getter
public class MemberDetailsImpl implements UserDetails {

    private final Member member;

    public MemberDetailsImpl(Member member) {
        this.member = member;
    }

    /**
     * 1. 권한 목록 반환
     */
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + member.getMemberRole().name())
        );
    }

    /**
     * 2. 사용자 ID 반환
     */
    @Override
    public String getUsername() {
        return member.getEmail();
    }

    /**
     * 3. 비밀번호 반환(인증 시 사용)
     */
    @Override
    public String getPassword() {
        return member.getPassword();
    }

    /**
     * 4. 계정 만료 여부(true = 사용 가능)
     */
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    /**
     * 5. 계정 잠김 여부
     */
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    /**
     * 6. 자격 증명(비밀번호 등) 만료 여부
     */
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    /**
     * 7. 계정 활성화 여부
     */
    @Override
    public boolean isEnabled() {
        return true;
    }
}