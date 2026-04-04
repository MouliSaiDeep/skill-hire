package com.devops.hiring_application.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.model.*;

@Service
public class SesService {

    private final SesClient sesClient;

    @Value("${aws.ses.sender}")
    private String sender;

    public SesService(
            @Value("${aws.access-key}") String accessKey,
            @Value("${aws.secret-key}") String secretKey,
            @Value("${aws.region}") String region) {

        this.sesClient = SesClient.builder()
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)))
                .build();
    }

    public void sendHireEmail(String toEmail, String userName) {
        Message message = Message.builder()
                .subject(Content.builder()
                        .data("Congratulations! You have been Selected!")
                        .build())
                .body(Body.builder()
                        .html(Content.builder()
                                .data("<h2>Hi " + userName + ",</h2>" +
                                      "<p>We are pleased to inform you that you have been " +
                                      "<b>selected</b> by our team.</p>" +
                                      "<p>We will reach out to you shortly with next steps.</p>")
                                .build())
                        .build())
                .build();

        sesClient.sendEmail(SendEmailRequest.builder()
                .source(sender)
                .destination(Destination.builder()
                        .toAddresses(toEmail)
                        .build())
                .message(message)
                .build());
    }
}