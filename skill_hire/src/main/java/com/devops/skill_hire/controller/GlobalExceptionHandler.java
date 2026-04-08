package com.devops.skill_hire.controller;

import java.util.Map;

import com.devops.skill_hire.exception.ApiException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import software.amazon.awssdk.core.exception.SdkClientException;
import software.amazon.awssdk.core.exception.SdkException;

@RestControllerAdvice
public class GlobalExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	@ExceptionHandler(ApiException.class)
	public ResponseEntity<Map<String, Object>> handleApiException(ApiException ex) {
		log.warn("API error: {}", ex.getMessage());
		return ResponseEntity.status(ex.getStatus()).body(Map.of("success", false, "message", ex.getMessage()));
	}

	@ExceptionHandler(DataAccessException.class)
	public ResponseEntity<Map<String, Object>> handleDataAccessException(DataAccessException ex) {
		log.error("Database error", ex);
		return ResponseEntity.status(503)
				.body(Map.of("success", false, "message", "Database is unavailable. Please verify MongoDB connectivity."));
	}

	@ExceptionHandler({SdkException.class, SdkClientException.class})
	public ResponseEntity<Map<String, Object>> handleAwsException(Exception ex) {
		log.error("AWS integration error", ex);
		return ResponseEntity.status(502)
				.body(Map.of("success", false, "message", "AWS integration failed. Verify S3/SES credentials and region."));
	}

	@ExceptionHandler(IllegalStateException.class)
	public ResponseEntity<Map<String, Object>> handleIllegalStateException(IllegalStateException ex) {
		log.error("Configuration error", ex);
		return ResponseEntity.status(500).body(Map.of("success", false, "message", ex.getMessage()));
	}

	@ExceptionHandler(Exception.class)
	public ResponseEntity<Map<String, Object>> handleGenericException(Exception ex) {
		log.error("Unexpected server error", ex);
		return ResponseEntity.internalServerError().body(Map.of("success", false, "message", "Unexpected server error"));
	}
}