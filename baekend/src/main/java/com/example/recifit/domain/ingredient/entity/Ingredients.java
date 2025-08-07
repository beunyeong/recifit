package com.example.recifit.domain.ingredient.entity;

import com.example.recifit.domain.ingredient.enums.StorageLocation;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;

@Entity
@Getter
@Builder
public class Ingredients extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String description;

    @Enumerated(EnumType.STRING)
    private StorageLocation storageLocation;

    private LocalDate storageDate;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    public Ingredients(Long id, String name, String description,
                       StorageLocation storageLocation, LocalDate storageDate,
                       Member member) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.storageLocation = storageLocation;
        this.storageDate = storageDate;
        this.member = member;
    }

    public Ingredients() {}
}
