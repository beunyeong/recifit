package com.example.recifit.domain.member.service;

import com.example.recifit.domain.member.dto.KakaoDTO;
import com.example.recifit.domain.member.dto.LoginRequestDto;
import com.example.recifit.domain.member.dto.LoginResponseDto;
import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.enums.AuthProvider;
import com.example.recifit.domain.member.enums.MemberType;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import com.example.recifit.global.jwt.JwtProvider;
import com.example.recifit.global.util.KakaoUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class AuthService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;
    private final KakaoUtil kakaoUtil;

    public AuthService(MemberRepository memberRepository,
                       PasswordEncoder passwordEncoder,
                       JwtProvider jwtProvider,
                       KakaoUtil kakaoUtil) {
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtProvider = jwtProvider;
        this.kakaoUtil = kakaoUtil;
    }

    @Transactional
    public LoginResponseDto oAuthLogin(String code) {
        KakaoDTO.OAuthToken token = kakaoUtil.requestToken(code).block();
        if(token == null || token.getAccessToken() == null) {
            throw new CustomException(ErrorCode.OAUTH_TOKEN_ISSUE_FAILED);
        }

        KakaoDTO.KakaoProfile profile = kakaoUtil.getMemberInfo(token.getAccessToken()).block();
        if(profile == null || profile.getId() == null) {
            throw new CustomException(ErrorCode.OAUTH_PROFILE_FETCH_FAILED);
        }

        Long kakaoId = profile.getId();
        String email = (profile.getKakaoAccount() != null)
                ? profile.getKakaoAccount().getEmail()
                : null;
        String nickname = (profile.getKakaoAccount() != null && profile.getKakaoAccount().getProfile() != null)
                ? profile.getKakaoAccount().getProfile().getNickname()
                : "닉네임을 설정해주세요";

        Member member = memberRepository.findByKakaoId(kakaoId)
                .orElseGet(() -> memberRepository.save(
                        Member.builder()
                                .kakaoId(kakaoId)
                                .email(email)
                                .nickname(nickname)
                                .memberType(MemberType.SINGLE)
                                .password(null)
                                .provider(AuthProvider.KAKAO)
                                .build()
                ));
        String subject = (member.getEmail() != null)
                ? member.getEmail()
                : String.valueOf(member.getId());
        String accessToken = jwtProvider.generateAccessToken(subject);
        String refreshToken = jwtProvider.generateRefreshToken(subject);

        return new LoginResponseDto(accessToken, refreshToken);
    }

    @Transactional
    public void signup(SignupRequestDto signupRequestDto) {
        // 중복 이메일 확인
        if (memberRepository.findByEmail(signupRequestDto.getEmail()).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_EMAIL);
        }

        // 닉네임 중복 확인
        if (memberRepository.findByNickname(signupRequestDto.getNickname()).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_NICKNAME);
        }

        // 비밀번호 암호화 후 저장
        String encodedPassword = passwordEncoder.encode(signupRequestDto.getPassword());

        // 회원 Entity 저장
        Member member = Member.builder()
                .email(signupRequestDto.getEmail())
                .password(encodedPassword)
                .nickname(signupRequestDto.getNickname())
                .provider(AuthProvider.LOCAL)
                .build();

        memberRepository.save(member);

        log.info("저장된 회원: {}", member.getEmail());
        log.info("저장된 닉네임: {}", member.getNickname());
    }

    public LoginResponseDto login(LoginRequestDto loginRequestDto) {
        // 이메일이 있는지 확인
        Member member = memberRepository.findByEmail(loginRequestDto.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_LOGIN));

        // 비밀번호가 맞는지 확인
        if (!passwordEncoder.matches(loginRequestDto.getPassword(), member.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_LOGIN);
        }

        // 위 조건이 모두 만족 한다면
        // jwtProvider에서 member에서 가져온 email을 통해서 accessToken, refreshToken 생성
        String accessToken = jwtProvider.generateAccessToken(member.getEmail());
        String refreshToken = jwtProvider.generateRefreshToken(member.getEmail());

        return new LoginResponseDto(accessToken, refreshToken);
    }
}