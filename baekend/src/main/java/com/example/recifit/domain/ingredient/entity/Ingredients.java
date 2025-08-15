package com.example.recifit.domain.ingredient.entity;

import com.example.recifit.domain.ingredient.enums.IngredientsStatus;
import com.example.recifit.domain.ingredient.enums.StorageLocation;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.global.common.BaseEntity;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Ingredients extends BaseEntity {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String description;

    @Enumerated(EnumType.STRING)
    private StorageLocation storageLocation;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    private LocalDate storageDate;

    private LocalDate expirationDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IngredientsStatus ingredientsStatus;

    private LocalDateTime deletedAt;

    public void deleteIngredients() {
        this.ingredientsStatus = IngredientsStatus.USED;
        this.deletedAt = LocalDateTime.now();
    }

    public Ingredients(Long id, String name, String description,
                       StorageLocation storageLocation, LocalDate storageDate,
                       LocalDate expirationDate, Member member) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.storageLocation = storageLocation;
        this.storageDate = storageDate;
        this.expirationDate = expirationDate;
        this.member = member;
    }
}
