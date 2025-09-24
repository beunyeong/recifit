package com.example.recifit.domain.like.repository;

import com.example.recifit.domain.like.entity.Like;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;


@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {

    boolean existsByPostIdAndMemberId(Long postId, Long memberId);

    Optional<Like> findByPostIdAndMemberId(Long postId, Long memberId);
}
