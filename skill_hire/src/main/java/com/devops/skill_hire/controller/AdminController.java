package com.devops.skill_hire.controller;

import java.util.Map;

import com.devops.skill_hire.service.AdminAuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

	private final AdminAuthService adminAuthService;

	public AdminController(AdminAuthService adminAuthService) {
		this.adminAuthService = adminAuthService;
	}

	@PostMapping("/register")
	public ResponseEntity<Map<String, Object>> registerAdmin(@RequestBody Map<String, String> body) {
		return ResponseEntity.status(HttpStatus.CREATED).body(adminAuthService.registerAdmin(body));
	}

	@PostMapping("/login")
	public ResponseEntity<Map<String, Object>> adminLogin(@RequestBody Map<String, String> body) {
		return ResponseEntity.ok(adminAuthService.loginAdmin(body));
	}
}