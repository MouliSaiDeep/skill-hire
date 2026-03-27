package com.devops.hiring_application.service;

import com.devops.hiring_application.dto.AdminAuthResponse;
import com.devops.hiring_application.dto.AdminLoginRequest;
import com.devops.hiring_application.dto.AdminRegisterRequest;
import com.devops.hiring_application.entity.Recruiter;
import com.devops.hiring_application.exception.ApiException;
import com.devops.hiring_application.repository.RecruiterRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AdminAuthService {

    private final RecruiterRepository recruiterRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public AdminAuthService(RecruiterRepository recruiterRepository) {
        this.recruiterRepository = recruiterRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    public AdminAuthResponse registerAdmin(AdminRegisterRequest request) {
        String recruiterName = normalize(request.recruiterName());
        String email = normalize(request.email());
        String password = request.password();

        if (!StringUtils.hasText(recruiterName) || !StringUtils.hasText(email) || !StringUtils.hasText(password)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "recruiterName, email and password are required");
        }
        if (password.length() < 8) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "password must be at least 8 characters");
        }
        if (recruiterRepository.existsByEmail(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "admin already exists with this email");
        }

        Recruiter recruiter = new Recruiter();
        recruiter.setRecruiterName(recruiterName);
        recruiter.setEmail(email);
        recruiter.setPassword(passwordEncoder.encode(password));

        Recruiter saved = recruiterRepository.save(recruiter);
        return new AdminAuthResponse(saved.getId(), saved.getRecruiterName(), saved.getEmail());
    }

    public AdminAuthResponse loginAdmin(AdminLoginRequest request) {
        String email = normalize(request.email());
        String password = request.password();

        if (!StringUtils.hasText(email) || !StringUtils.hasText(password)) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "email and password are required");
        }

        Recruiter recruiter = recruiterRepository.findByEmail(email)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials"));

        if (!passwordEncoder.matches(password, recruiter.getPassword())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials");
        }

        return new AdminAuthResponse(recruiter.getId(), recruiter.getRecruiterName(), recruiter.getEmail());
    }

    private String normalize(String value) {
        return value == null ? null : value.trim();
    }
}
