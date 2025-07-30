package com.example.recifit.domain.ingredient.repository;

import com.example.recifit.domain.ingredient.entity.Ingredients;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IngredientsRepository extends JpaRepository<Ingredients, Long> {
}
