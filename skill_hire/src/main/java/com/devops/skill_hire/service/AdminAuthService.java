package com.devops.skill_hire.service;

import java.util.Map;
import java.util.LinkedHashMap;

import com.devops.skill_hire.document.Recruiter;
import com.devops.skill_hire.exception.ApiException;
import com.devops.skill_hire.repository.RecruiterRepository;
import com.devops.skill_hire.services.OtpService;
import com.devops.skill_hire.services.SmtpEmailService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class AdminAuthService {

	private final RecruiterRepository recruiterRepository;
	private final PasswordEncoder passwordEncoder;
	private final OtpService otpService;
	private final SmtpEmailService smtpEmailService;

	private static final String REQUIRED_ADMIN_EMAIL = "pediredlarishi2005@gmail.com";
	private static final String REQUIRED_ADMIN_PASSWORD = "SkillHire@admin";

	public AdminAuthService(RecruiterRepository recruiterRepository, PasswordEncoder passwordEncoder, OtpService otpService, SmtpEmailService smtpEmailService) {
		this.recruiterRepository = recruiterRepository;
		this.passwordEncoder = passwordEncoder;
		this.otpService = otpService;
		this.smtpEmailService = smtpEmailService;
	}

	public Map<String, Object> registerAdmin(Map<String, String> request) {
		String recruiterName = normalize(request == null ? null : request.get("recruiterName"));
		String email = normalize(request == null ? null : request.get("email"));
		String password = request == null ? null : request.get("password");

		if (!StringUtils.hasText(recruiterName) || !StringUtils.hasText(email) || !StringUtils.hasText(password)) {
			throw new ApiException(HttpStatus.BAD_REQUEST, "recruiterName, email and password are required");
		}
		
		if (!REQUIRED_ADMIN_EMAIL.equalsIgnoreCase(email) || !REQUIRED_ADMIN_PASSWORD.equals(password)) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "You are not authorized to register as an admin.");
		}

		if (recruiterRepository.existsByEmail(email)) {
			throw new ApiException(HttpStatus.CONFLICT, "admin already exists with this email");
		}

		// Generate and send OTP
		String otp = otpService.generateAndStoreOtp(email);
		smtpEmailService.sendOtpEmail(email, otp);

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("otp_required", true);
		response.put("message", "OTP sent to your email. Please verify to complete registration.");
		return response;
	}

	public Map<String, Object> verifyRegisterOtp(Map<String, String> request) {
		String recruiterName = normalize(request == null ? null : request.get("recruiterName"));
		String email = normalize(request == null ? null : request.get("email"));
		String password = request == null ? null : request.get("password");
		String otp = normalize(request == null ? null : request.get("otp"));

		if (!StringUtils.hasText(email) || !StringUtils.hasText(otp)) {
			throw new ApiException(HttpStatus.BAD_REQUEST, "email and otp are required");
		}

		if (!otpService.verifyOtp(email, otp)) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid or expired OTP");
		}

		// Proceed with registration
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

		if (!REQUIRED_ADMIN_EMAIL.equalsIgnoreCase(email)) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials");
		}

		Recruiter recruiter = recruiterRepository.findByEmail(email)
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials"));

		if (!passwordEncoder.matches(password, recruiter.getPassword())) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "invalid admin credentials");
		}

		// Generate and send OTP
		String otp = otpService.generateAndStoreOtp(email);
		smtpEmailService.sendOtpEmail(email, otp);

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("otp_required", true);
		response.put("message", "OTP sent to your email. Please verify to login.");
		return response;
	}

	public Map<String, Object> verifyLoginOtp(Map<String, String> request) {
		String email = normalize(request == null ? null : request.get("email"));
		String otp = normalize(request == null ? null : request.get("otp"));

		if (!StringUtils.hasText(email) || !StringUtils.hasText(otp)) {
			throw new ApiException(HttpStatus.BAD_REQUEST, "email and otp are required");
		}

		if (!otpService.verifyOtp(email, otp)) {
			throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid or expired OTP");
		}

		Recruiter recruiter = recruiterRepository.findByEmail(email)
				.orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Admin not found"));

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("success", true);
		response.put("message", "OTP Verified successfully");
		response.put("id", recruiter.getId());
		response.put("recruiterName", recruiter.getRecruiterName());
		response.put("email", recruiter.getEmail());
		return response;
	}

	private String normalize(String value) {
		return value == null ? null : value.trim();
	}
}