package com.devops.skill_hire.service;

import java.util.Map;
import java.util.LinkedHashMap;

import com.devops.skill_hire.document.Recruiter;
import com.devops.skill_hire.exception.ApiException;
import com.devops.skill_hire.repository.RecruiterRepository;
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

	public Map<String, Object> registerAdmin(Map<String, String> request) {
		String recruiterName = normalize(request == null ? null : request.get("recruiterName"));
		String email = normalize(request == null ? null : request.get("email"));
		String password = request == null ? null : request.get("password");

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
		Map<String, Object> response = new LinkedHashMap<>();
		response.put("id", saved.getId());
		response.put("recruiterName", saved.getRecruiterName());
		response.put("email", saved.getEmail());
		return response;
	}

	public Map<String, Object> loginAdmin(Map<String, String> request) {
		String email = normalize(request == null ? null : request.get("email"));
		String password = request == null ? null : request.get("password");

		if (!StringUtils.hasText(email) || !StringUtils.hasText(password)) {
			throw new ApiException(HttpStatus.BAD_REQUEST, "email and password are required");
		}

		Recruiter recruiter = recruiterRepository.findByEmail(email)
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials"));

		if (!passwordEncoder.matches(password, recruiter.getPassword())) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials");
		}

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("id", recruiter.getId());
		response.put("recruiterName", recruiter.getRecruiterName());
		response.put("email", recruiter.getEmail());
		return response;
	}

	private String normalize(String value) {
		return value == null ? null : value.trim();
	}
}