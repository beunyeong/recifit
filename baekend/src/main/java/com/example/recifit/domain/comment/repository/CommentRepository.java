package com.example.recifit.domain.comment.repository;

import com.example.recifit.domain.comment.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;


public interface CommentRepository extends JpaRepository<Comment, Long> {
}