package com.devops.skill_hire.repository;

import java.util.Optional;

import com.devops.skill_hire.document.Recruiter;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface RecruiterRepository extends MongoRepository<Recruiter, String> {

	Optional<Recruiter> findByEmail(String email);

	boolean existsByEmail(String email);
}