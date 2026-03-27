package com.devops.hiring_application.controller;

import com.devops.hiring_application.entity.User;
import com.devops.hiring_application.repository.UserRepository;
import com.devops.hiring_application.services.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private S3Service s3Service;

    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @PostMapping(value = "/signup", consumes = "multipart/form-data")
    public ResponseEntity<?> signup(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String password,
            @RequestParam String phone,
            @RequestParam List<String> skills,
            @RequestParam MultipartFile pic) throws IOException {

        // Check if email already exists
        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Email already registered"));
        }

        // Upload pic to S3
        String picUrl = s3Service.uploadFile(pic);

        // Create and save user
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(encoder.encode(password));
        user.setPhone(phone);
        user.setSkills(skills);
        user.setPicUrl(picUrl);

        userRepository.save(user);

        return ResponseEntity.status(201).body(Map.of("message", "User registered successfully"));
    }
}