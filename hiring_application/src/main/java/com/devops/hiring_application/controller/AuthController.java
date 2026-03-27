package com.devops.hiring_application.controller;

import com.devops.hiring_application.dto.AdminAuthResponse;
import com.devops.hiring_application.dto.AdminLoginRequest;
import com.devops.hiring_application.dto.AdminRegisterRequest;
import com.devops.hiring_application.dto.ApiResponse;
import com.devops.hiring_application.service.AdminAuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AdminAuthService adminAuthService;

    public AuthController(AdminAuthService adminAuthService) {
        this.adminAuthService = adminAuthService;
    }

    @PostMapping("/register-admin")
    public ResponseEntity<ApiResponse<AdminAuthResponse>> registerAdmin(@RequestBody AdminRegisterRequest request) {
        AdminAuthResponse response = adminAuthService.registerAdmin(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Admin registered successfully", response));
    }

    @PostMapping({"/login-admin", "/admin-login"})
    public ResponseEntity<ApiResponse<AdminAuthResponse>> loginAdmin(@RequestBody AdminLoginRequest request) {
        AdminAuthResponse response = adminAuthService.loginAdmin(request);
        return ResponseEntity.ok(ApiResponse.success("Admin login successful", response));
    }
}
