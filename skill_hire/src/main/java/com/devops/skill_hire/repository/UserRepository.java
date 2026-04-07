package com.devops.skill_hire.repository;

import com.devops.skill_hire.document.User;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import java.util.List;
import java.util.Optional;

public interface UserRepository
        extends MongoRepository<User, String> {
    Optional<User> findByEmail(String email);

    @Query("{'skills': ?0}")
    List<User> findBySkill(String skill);
}