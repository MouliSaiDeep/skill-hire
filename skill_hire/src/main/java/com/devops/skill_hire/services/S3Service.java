package com.devops.skill_hire.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import java.io.IOException;
import java.util.UUID;

@Service
public class S3Service {
    private final S3Client s3Client;
    @Value("${aws.s3.bucket-name}")
    private String bucketName;
    @Value("${aws.region}")
    private String region;

    public S3Service(
            @Value("${aws.access-key}") String accessKey,
            @Value("${aws.secret-key}") String secretKey,
            @Value("${aws.region}") String region) {
        if (StringUtils.hasText(accessKey) && StringUtils.hasText(secretKey)) {
            this.s3Client = S3Client.builder()
                    .region(Region.of(region))
                    .credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey)))
                    .build();
        } else {
            this.s3Client = null;
        }
    }

    public String uploadFile(MultipartFile file)
            throws IOException {
        if (s3Client == null) {
            throw new IllegalStateException("AWS S3 credentials are not configured");
        }
        if (!StringUtils.hasText(bucketName)) {
            throw new IllegalStateException("aws.s3.bucket-name is not configured");
        }
        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(fileName)
                .contentType(file.getContentType())
                .build();
        s3Client.putObject(request, RequestBody.fromInputStream(file.getInputStream(), file.getSize()));
        return "https://" + bucketName + ".s3." + region + ".amazonaws.com/" + fileName;
    }
}