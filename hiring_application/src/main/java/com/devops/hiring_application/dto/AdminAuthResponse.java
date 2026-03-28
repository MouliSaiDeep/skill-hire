package com.devops.hiring_application.dto;

public record AdminAuthResponse(
        Long id,
        String recruiterName,
        String email
) {
}
