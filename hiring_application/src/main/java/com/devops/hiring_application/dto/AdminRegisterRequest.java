package com.devops.hiring_application.dto;

public record AdminRegisterRequest(
        String recruiterName,
        String email,
        String password
) {
}
