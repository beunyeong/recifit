package com.example.recifit.domain.ingredient.repository;

import com.example.recifit.domain.ingredient.entity.Ingredients;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface IngredientsRepository extends JpaRepository<Ingredients, Long> {

    List<Ingredients> findByMemberId(Long memberId);

    /**
     * 1. 유통기한 있는 재료: 가까운 날짜 기준 오름차순
     */
    @Query("""
        select i
        from Ingredients i
        where i.member.id = :memberId and i.expirationDate is not null
        order by i.member.id asc
        """)
    List<Ingredients> findAllWithExpiryByMemberOrderByExpiryAsc(@Param("memberId") Long memberId);

    /**
     * 2. 유통기한 없는 재료
     */
    @Query("""
        select i
        from Ingredients i
        where i.member.id = :memberId and i.expirationDate is null
        """)
    List<Ingredients> findAllWithoutExpiryByMember(@Param("memberId") Long memberId);

    Optional<Ingredients> findByIdAndMemberId(Long id, Long memberId);
}
