package com.devops.skill_hire.services;

import org.springframework.stereotype.Service;
import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class OtpService {

    private final Map<String, String> otpCache = new ConcurrentHashMap<>();
    private final SecureRandom random = new SecureRandom();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

    public String generateAndStoreOtp(String email) {
        // Generate a 4-digit OTP
        int otpNum = 1000 + random.nextInt(9000);
        String otp = String.valueOf(otpNum);
        
        otpCache.put(email.toLowerCase(), otp);

        // Schedule expiration after 5 minutes
        scheduler.schedule(() -> {
            otpCache.remove(email.toLowerCase(), otp);
        }, 5, TimeUnit.MINUTES);

        return otp;
    }

    public boolean verifyOtp(String email, String otp) {
        if (email == null || otp == null) {
            return false;
        }
        String storedOtp = otpCache.get(email.toLowerCase());
        if (storedOtp != null && storedOtp.equals(otp)) {
            otpCache.remove(email.toLowerCase());
            return true;
        }
        return false;
    }
}
