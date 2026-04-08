package com.devops.skill_hire.controller;

import com.devops.skill_hire.document.User;
import com.devops.skill_hire.exception.ApiException;
import com.devops.skill_hire.repository.UserRepository;
import com.devops.skill_hire.services.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.util.StringUtils;
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
            @RequestParam String gender,
            @RequestParam String phone,
            @RequestParam List<String> skills,
            @RequestParam MultipartFile pic)
            throws IOException {
        if (!StringUtils.hasText(name) || !StringUtils.hasText(email) || !StringUtils.hasText(phone)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "name, email and phone are required");
        }
        if (pic == null || pic.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "profile photo is required");
        }
        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message","Email already registered"));
        }

        String picUrl;
        try {
            picUrl = s3Service.uploadFile(pic);
        } catch (IllegalStateException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new ApiException(HttpStatus.BAD_GATEWAY,
                    "Failed to upload profile image. Verify AWS S3 configuration and permissions.");
        }

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setGender(gender);
        user.setPhone(phone);
        user.setSkills(skills);
        user.setPicUrl(picUrl);
        userRepository.save(user);
        return ResponseEntity.status(201).body(Map.of("message","User registered successfully"));
    }
}
