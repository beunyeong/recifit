package com.example.recifit.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI openAPI() {

        Contact contact = new Contact()
                .name("Baek Eunyeong")
                .email("beunyeong.b@gmail.com");

        License license = new License()
                .name("Recifit License")
                .url("https://github.com/beunyeong/recifit")
                .url("배포 주소 추가 예정");

        Info info = new Info()
                .version("v1.0")
                .title("Recifit API")
                .description("")
                .contact(contact)
                .license(license);

        final String securityScheme = "bearerAuth";

        return new OpenAPI()
                .info(info)
                .addSecurityItem(new SecurityRequirement().addList(securityScheme))
                .components(new Components()
                        .addSecuritySchemes(securityScheme, new SecurityScheme()
                                .name(securityScheme)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")));
    }
}