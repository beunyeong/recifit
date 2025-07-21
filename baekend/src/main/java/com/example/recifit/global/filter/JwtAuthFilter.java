package com.example.recifit.global.filter;

import com.example.recifit.global.jwt.JwtProvider;
import com.example.recifit.global.security.MemberDetailsServiceImpl;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtProvider jwtProvider;
    private final MemberDetailsServiceImpl memberDetailsServiceImpl;

    public JwtAuthFilter(JwtProvider jwtProvider, MemberDetailsServiceImpl memberDetailsServiceImpl) {
        this.jwtProvider = jwtProvider;
        this.memberDetailsServiceImpl = memberDetailsServiceImpl;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest httpServletRequest,
                                    HttpServletResponse httpServletResponse,
                                    FilterChain filterChain)
        throws ServletException, IOException {

        /**
         * 1. 토큰 추출
         */
        String token = jwtProvider.resolveToken((httpServletRequest));

        /**
         * 2. 토큰이 존재하고 유효하면
         * - 사용자 이메일(subject) 추출
         * - 이메일로 사용자 정보 로딩 (MemberDetailsServiceImpl 활용)
         * - 인증 객체 생성
         * - SecurityContext에 등록
         * - 다음 필터로 넘김
         */
        if (token != null && jwtProvider.validateToken(token)) {
            String email = jwtProvider.getEmailFromToken(token);
            UserDetails userDetails = memberDetailsServiceImpl.loadUserByUsername(email);
            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }
        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }

}
