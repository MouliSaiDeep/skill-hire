package com.devops.skill_hire.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class SmtpEmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromEmail;

    public void sendOtpEmail(String toEmail, String otp) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(fromEmail);
        message.setTo(toEmail);
        message.setSubject("Your SkillHire Admin OTP");
        message.setText("Hello,\n\nYour One-Time Password (OTP) for SkillHire Admin authentication is: " + otp + "\n\nThis OTP is valid for a short time. Please do not share it with anyone.");

        mailSender.send(message);
    }
}
