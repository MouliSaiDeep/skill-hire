package com.devops.hiring_application.repository;

import com.devops.hiring_application.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    // Add this line — fixes the error
    Optional<User> findByEmail(String email);

    // For skill filter — admin dashboard
    @Query("SELECT DISTINCT u FROM User u JOIN u.skills s WHERE s = :skill")
    List<User> findBySkill(@Param("skill") String skill);
}