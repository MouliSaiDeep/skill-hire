package com.devops.skill_hire.controller;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.devops.skill_hire.document.User;
import com.devops.skill_hire.exception.ApiException;
import com.devops.skill_hire.repository.UserRepository;
import com.devops.skill_hire.service.AdminAuthService;
import com.devops.skill_hire.services.SesService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
@RequestMapping("/admin")
@CrossOrigin(origins = "*")
public class AdminController {

	private final AdminAuthService adminAuthService;
	private final UserRepository userRepository;
	private final SesService sesService;

	public AdminController(AdminAuthService adminAuthService, UserRepository userRepository, SesService sesService) {
		this.adminAuthService = adminAuthService;
		this.userRepository = userRepository;
		this.sesService = sesService;
	}

	@PostMapping("/register")
	public ResponseEntity<Map<String, Object>> registerAdmin(@RequestBody Map<String, String> body) {
		return ResponseEntity.status(HttpStatus.CREATED).body(adminAuthService.registerAdmin(body));
	}

	@PostMapping("/login")
	public ResponseEntity<Map<String, Object>> adminLogin(@RequestBody Map<String, String> body) {
		return ResponseEntity.ok(adminAuthService.loginAdmin(body));
	}

	@GetMapping("/candidates")
	public ResponseEntity<List<Map<String, Object>>> listCandidates(
			@RequestParam(required = false) String skill,
			@RequestParam(required = false) List<String> skills) {
		List<String> normalizedSkills = normalizeSkills(skill, skills);

		List<User> users;
		if (normalizedSkills.isEmpty()) {
			users = userRepository.findAll();
		} else if (normalizedSkills.size() == 1) {
			users = userRepository.findBySkill(normalizedSkills.get(0));
		} else {
			users = userRepository.findAll().stream()
					.filter(user -> hasAllSkills(user, normalizedSkills))
					.collect(Collectors.toList());
		}

		List<Map<String, Object>> response = users.stream().map(this::toCandidateResponse).collect(Collectors.toList());
		return ResponseEntity.ok(response);
	}

	private List<String> normalizeSkills(String skill, List<String> skills) {
		if (skills != null && !skills.isEmpty()) {
			return skills.stream()
					.filter(s -> s != null && !s.isBlank())
					.map(String::trim)
					.collect(Collectors.toList());
		}

		if (skill == null || skill.isBlank()) {
			return List.of();
		}

		return List.of(skill.trim());
	}

	private boolean hasAllSkills(User user, List<String> requiredSkills) {
		if (user.getSkills() == null || user.getSkills().isEmpty()) {
			return false;
		}

		List<String> userSkills = user.getSkills().stream()
				.filter(s -> s != null && !s.isBlank())
				.map(String::trim)
				.collect(Collectors.toList());

		return requiredSkills.stream().allMatch(required ->
				userSkills.stream().anyMatch(userSkill -> userSkill.equalsIgnoreCase(required)));
	}

	@PostMapping("/candidates/{id}/select")
	public ResponseEntity<Map<String, Object>> selectCandidate(@PathVariable String id) {
		User user = userRepository.findById(id)
				.orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "candidate not found"));

		user.setSelected(true);
		userRepository.save(user);

		String warning = null;
		try {
			sesService.sendHireEmail(user.getEmail(), user.getName());
		} catch (Exception ex) {
			warning = "candidate selected but email could not be sent";
		}

		Map<String, Object> body = warning == null
				? Map.of("success", true, "candidate", toCandidateResponse(user))
				: Map.of("success", true, "candidate", toCandidateResponse(user), "warning", warning);
		return ResponseEntity.ok(body);
	}

	private Map<String, Object> toCandidateResponse(User user) {
		String skills = user.getSkills() == null ? "" : String.join(", ", user.getSkills());
		return Map.of(
				"id", user.getId(),
				"name", user.getName(),
				"email", user.getEmail(),
				"phone", user.getPhone(),
				"skills", skills,
				"photoUrl", user.getPicUrl() == null ? "" : user.getPicUrl(),
				"gender", user.getGender() == null ? "Not Specified" : user.getGender(),
				"isSelected", user.isSelected());
	}
}