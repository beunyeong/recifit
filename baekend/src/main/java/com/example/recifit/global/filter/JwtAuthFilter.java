package com.example.recifit.global.filter;

import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.jwt.JwtProvider;
import com.example.recifit.global.security.MemberDetailsServiceImpl;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
@Slf4j
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

        try {
            if (token != null && jwtProvider.validateTokenOrThrow(token)) {
                String email = jwtProvider.getEmailFromToken(token);
                UserDetails userDetails = memberDetailsServiceImpl.loadUserByUsername(email);
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (ExpiredJwtException e) {
            log.warn("Expired JWT token");
            setErrorResponse(httpServletResponse, ErrorCode.TOKEN_EXPIRED);
            return;
        } catch (MalformedJwtException e) {
            log.error("Invalid JWT format");
            setErrorResponse(httpServletResponse, ErrorCode.INTERNAL_FORMAT_ERROR);
            return;
        } catch (IllegalArgumentException e) {
            log.error("JWT token is empty or null");
            setErrorResponse(httpServletResponse, ErrorCode.TOKEN_ILLEGAL);
            return;
        } catch (Exception e) {
            log.error("Failed to validate JWT token", e);
            setErrorResponse(httpServletResponse, ErrorCode.INTERNAL_SERVER_ERROR);
            return;
        }

        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }

    private void setErrorResponse(HttpServletResponse httpServletResponse, ErrorCode errorCode)
            throws IOException {
        httpServletResponse.setContentType("application/json;charset=UTF-8");
        httpServletResponse.setStatus(errorCode.getHttpStatus().value());

        String json = String.format("{\"code\": \"%s\", \"message\": \"%s\"}",
                errorCode.name(), errorCode.getMessage());

        httpServletResponse.getWriter().write(json);
    }
}
