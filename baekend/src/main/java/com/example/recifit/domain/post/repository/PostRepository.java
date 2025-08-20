package com.example.recifit.domain.post.repository;

import com.example.recifit.domain.post.entity.Post;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository extends JpaRepository<Post, Long> {
}