package com.example.recifit.domain.member.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;

public class KakaoDTO {

    @Getter
    public static class OAuthToken{

        @JsonProperty("token_type")
        private String tokenType;

        @JsonProperty("access_token")
        private String accessToken;

        @JsonProperty("expires_in")
        private int expiresIn;

        @JsonProperty("refresh_token")
        private String refreshToken;

        @JsonProperty("refresh_token_expires_in")
        private int refreshTokenExpiresIn;

        @JsonProperty("scope")
        private String scope;
    }

    @Getter
    public static class KakaoProfile{
        private Long id;

        @JsonProperty("connected_at")
        private String connectedAt;

        private Properties properties;

        @JsonProperty("kakao_account")
        private KakaoAccount kakaoAccount;

        @Getter
        public static class Properties{
            private String nickname;
        }

        @Getter
        public static class KakaoAccount{
            private String email;

            @JsonProperty("is_email_valid")
            private Boolean isEmailValid;

            @JsonProperty("is_email_verified")
            private Boolean isEmailVerified;

            @JsonProperty("email_needs_agreement")
            private Boolean emailNeedsAgreement;

            @JsonProperty("profile_nickname_needs_agreement")
            private Boolean profileNicknameNeedsAgreement;

            private Profile profile;

            @Getter
            public static class Profile{
                public String nickname;

                @JsonProperty("is_default_nickname")
                public Boolean isDefaultNickname;
            }
        }
    }
}