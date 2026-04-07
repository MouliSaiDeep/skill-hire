package com.devops.skill_hire;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SkillHireApplication {
	private static final Pattern PLACEHOLDER_PATTERN = Pattern.compile("\\$\\{([^}]+)}");

	public static void main(String[] args) {
		loadDotEnvFile();
		SpringApplication.run(SkillHireApplication.class, args);
	}

	private static void loadDotEnvFile() {
		Path dotEnvPath = resolveDotEnvPath();
		if (dotEnvPath == null) {
			return;
		}

		Map<String, String> loaded = new HashMap<>();
		try {
			List<String> lines = Files.readAllLines(dotEnvPath);
			for (String line : lines) {
				String trimmed = line.trim();
				if (trimmed.isEmpty() || trimmed.startsWith("#")) {
					continue;
				}

				int separator = trimmed.indexOf('=');
				if (separator <= 0) {
					continue;
				}

				String key = trimmed.substring(0, separator).trim();
				String rawValue = trimmed.substring(separator + 1).trim();
				String resolvedValue = resolvePlaceholders(rawValue, loaded);
				loaded.put(key, resolvedValue);

				setSystemPropertyIfMissing(key, resolvedValue);
			}

			setMappedSpringProperty(loaded, "MONGO_URI", "spring.mongodb.uri");
			setMappedSpringProperty(loaded, "AWS_ACCESS_KEY", "aws.access-key");
			setMappedSpringProperty(loaded, "AWS_SECRET_KEY", "aws.secret-key");
			setMappedSpringProperty(loaded, "AWS_REGION", "aws.region");
			setMappedSpringProperty(loaded, "S3_BUCKET_NAME", "aws.s3.bucket-name");
			setMappedSpringProperty(loaded, "SES_SENDER_EMAIL", "aws.ses.sender");
			setMappedSpringProperty(loaded, "ADMIN_EMAIL", "admin.email");
			setMappedSpringProperty(loaded, "ADMIN_PASSWORD", "admin.password");
		} catch (IOException ignored) {
			// Keep startup resilient when .env is unreadable; defaults/env vars still apply.
		}
	}

	private static Path resolveDotEnvPath() {
		Path currentDir = Path.of(".env");
		if (Files.exists(currentDir)) {
			return currentDir;
		}

		Path moduleDir = Path.of("skill_hire", ".env");
		if (Files.exists(moduleDir)) {
			return moduleDir;
		}

		return null;
	}

	private static void setMappedSpringProperty(Map<String, String> loaded, String envKey, String springKey) {
		String value = System.getenv(envKey);
		if (value == null || value.isBlank()) {
			value = loaded.get(envKey);
		}
		if (value == null || value.isBlank()) {
			return;
		}
		setSystemPropertyIfMissing(springKey, value);
	}

	private static void setSystemPropertyIfMissing(String key, String value) {
		if (System.getenv(key) == null && System.getProperty(key) == null) {
			System.setProperty(key, value);
		}
	}

	private static String resolvePlaceholders(String value, Map<String, String> loaded) {
		Matcher matcher = PLACEHOLDER_PATTERN.matcher(value);
		StringBuffer resolved = new StringBuffer();

		while (matcher.find()) {
			String key = matcher.group(1);
			String replacement = loaded.getOrDefault(
					key,
					System.getenv(key) != null
							? System.getenv(key)
							: System.getProperty(key, ""));
			matcher.appendReplacement(resolved, Matcher.quoteReplacement(replacement));
		}

		matcher.appendTail(resolved);
		return resolved.toString();
	}

}
