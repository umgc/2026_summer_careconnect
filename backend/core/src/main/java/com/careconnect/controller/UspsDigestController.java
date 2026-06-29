package com.careconnect.controller;

import com.careconnect.security.Permission;
import com.careconnect.security.RequirePermission;

import com.careconnect.model.USPSDigest;
import com.careconnect.model.User;
import com.careconnect.security.AuthorizationService;
import com.careconnect.security.UnauthorizedException;
import com.careconnect.service.USPSDigestService;
import com.careconnect.util.SecurityUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.careconnect.repository.UserRepository; // Import the UserRepository to fetch user details based on userId

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("v1/api/usps")
@RequiredArgsConstructor
public class UspsDigestController {

    private final SecurityUtil securityUtil;
    private final AuthorizationService authorizationService;
    private final USPSDigestService uspsDigestService;
    private final UserRepository userRepository; // Inject the UserRepository

    @RequirePermission(Permission.VIEW_ASSIGNED_PATIENTS)


    @GetMapping("/latest")
    public ResponseEntity<USPSDigest> getLatestDigest(
            @RequestParam String userId,
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) throws UnauthorizedException {


            //replace the following line with the actual logic to fetch the current user and the patient user based on userId
         User currentUser = securityUtil.resolveCurrentUser();
        User patientUser = userRepository.findByEmail(userId)
                .orElseThrow(() -> new UnauthorizedException("No patient found for userId: " + userId));
        authorizationService.requirePatientAccess(currentUser, patientUser.getId());

        var digest = date != null
                ? uspsDigestService.digestForDate(userId, date)
                : uspsDigestService.latestForUser(userId);

        return digest
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.noContent().build());
    }

    @RequirePermission(Permission.VIEW_ASSIGNED_PATIENTS)


    @GetMapping("/search")
    public ResponseEntity<List<Map<String, Object>>> search(
            @RequestParam String userId,
            @RequestParam String keyword) throws UnauthorizedException {

        User currentUser = securityUtil.resolveCurrentUser();
        User patientUser = userRepository.findByEmail(userId)
                .orElseThrow(() -> new UnauthorizedException("No patient found for userId: " + userId));
        authorizationService.requirePatientAccess(currentUser, patientUser.getId());

        var results = uspsDigestService.search(userId, keyword);
        return ResponseEntity.ok(results);
    }

    @RequirePermission(Permission.CREATE_TASKS)


    @PostMapping("/clear-cache")
    public ResponseEntity<String> clearCache(
            @RequestParam String userId) throws UnauthorizedException {

        User currentUser = securityUtil.resolveCurrentUser();
        User patientUser = userRepository.findByEmail(userId)
                .orElseThrow(() -> new UnauthorizedException("No patient found for userId: " + userId));
        authorizationService.requirePatientAccess(currentUser, patientUser.getId());

        uspsDigestService.clearCacheForUser(userId);
        return ResponseEntity.ok("Cache cleared successfully for user: " + userId);
    }
}
