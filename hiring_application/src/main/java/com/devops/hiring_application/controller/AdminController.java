package com.devops.hiring_application.controller;

import com.devops.hiring_application.entity.User;
import com.devops.hiring_application.repository.UserRepository;
import com.devops.hiring_application.services.SesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SesService sesService;

    @Value("${admin.email}")
    private String adminEmail;

    @Value("${admin.password}")
    private String adminPassword;

    // Admin Login
    @PostMapping("/login")
    public ResponseEntity<?> adminLogin(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        if (email.equals(adminEmail) && password.equals(adminPassword)) {
            return ResponseEntity.ok(Map.of("message", "Login successful", "status", "ok"));
        }

        return ResponseEntity.status(401).body(Map.of("message", "Invalid credentials"));
    }

    // Get All Users or Filter by Skill
    @GetMapping("/users")
    public ResponseEntity<?> getUsers(@RequestParam(required = false) String skill) {
        List<User> users;

        if (skill != null && !skill.isEmpty()) {
            users = userRepository.findBySkill(skill);
        } else {
            users = userRepository.findAll();
        }

        return ResponseEntity.ok(users);
    }

    // Select User and Send Hire Email
    @PostMapping("/select/{userId}")
    public ResponseEntity<?> selectUser(@PathVariable Long userId) {
        User user = userRepository.findById(userId).orElse(null);

        if (user == null) {
            return ResponseEntity.status(404).body(Map.of("message", "User not found"));
        }

        if (user.isSelected()) {
            return ResponseEntity.badRequest().body(Map.of("message", "User already selected"));
        }

        user.setSelected(true);
        userRepository.save(user);

        sesService.sendHireEmail(user.getEmail(), user.getName());

        return ResponseEntity.ok(Map.of("message", "User selected and email sent to " + user.getEmail()));
    }
}