package com.example.recifit.domain.post.repository;

import com.example.recifit.domain.post.entity.Post;
import com.example.recifit.domain.post.enums.PostCategory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;


public interface PostRepository extends JpaRepository<Post, Long> {

    /**
     * 전체(최신순)
     */
    Page<Post> findAllByDeletedAtIsNull(Pageable pageable);

    /**
     * 카테고리별(최신순)
     */
    Page<Post> findAllByPostCategoryAndDeletedAtIsNull(PostCategory postCategory, Pageable pageable);

    /**
     * 로그인된 사용자가 작성한 게시글 조회(최신순)
     */
    Page<Post> findAllByMemberIdAndDeletedAtIsNull(Long memberId, Pageable pageable);
}