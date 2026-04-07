package com.devops.skill_hire.services;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.ses.SesClient;
import software.amazon.awssdk.services.ses.model.Body;
import software.amazon.awssdk.services.ses.model.Content;
import software.amazon.awssdk.services.ses.model.Destination;
import software.amazon.awssdk.services.ses.model.Message;
import software.amazon.awssdk.services.ses.model.SendEmailRequest;

@Service
public class SesService {

	private final SesClient sesClient;
	private final String sender;

	public SesService(@Value("${aws.access-key:}") String accessKey,
					 @Value("${aws.secret-key:}") String secretKey,
					 @Value("${aws.region:us-east-1}") String region,
					 @Value("${aws.ses.sender:}") String sender) {
		this.sender = sender;
		if (StringUtils.hasText(accessKey) && StringUtils.hasText(secretKey)) {
			this.sesClient = SesClient.builder()
					.region(Region.of(region))
					.credentialsProvider(StaticCredentialsProvider.create(AwsBasicCredentials.create(accessKey, secretKey)))
					.build();
		} else {
			this.sesClient = null;
		}
	}

	public void sendHireEmail(String toEmail, String userName) {
		if (sesClient == null) {
			throw new IllegalStateException("AWS SES credentials are not configured");
		}
		if (!StringUtils.hasText(sender)) {
			throw new IllegalStateException("aws.ses.sender is not configured");
		}
		if (!StringUtils.hasText(toEmail)) {
			throw new IllegalArgumentException("recipient email is required");
		}

		Message message = Message.builder()
				.subject(Content.builder().data("Congratulations! You have been Selected!").build())
				.body(Body.builder()
						.html(Content.builder()
								.data("<h2>Hi " + userName + ",</h2><p>We are pleased to inform you that you have been <b>selected</b> by our team.</p><p>We will reach out to you shortly with next steps.</p>")
								.build())
						.build())
					.build();

		sesClient.sendEmail(SendEmailRequest.builder()
				.source(sender)
				.destination(Destination.builder().toAddresses(toEmail).build())
				.message(message)
				.build());
	}
}