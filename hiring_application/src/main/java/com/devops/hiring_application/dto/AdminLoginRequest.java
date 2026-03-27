package com.devops.hiring_application.dto;

public record AdminLoginRequest(
        String email,
        String password
) {
}
