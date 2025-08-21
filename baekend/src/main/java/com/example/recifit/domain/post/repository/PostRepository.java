package com.example.recifit.domain.post.repository;

import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.domain.post.enums.PostCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {

    /**
     * 전체(최신순)
     */
    List<Post> findAllByDeletedAtIsNullOrderByCreatedAtDesc();

    /**
     * 카테고리별(최신순)
     */
    List<Post> findAllByPostCategoryAndDeletedAtIsNullOrderByCreatedAtDesc(PostCategory postCategory);
}