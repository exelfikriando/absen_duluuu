package com.absensi.attendance_api.controller;

import com.absensi.attendance_api.model.User;
import com.absensi.attendance_api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestParam String nama, 
                                    @RequestParam String username, 
                                    @RequestParam String password, 
                                    @RequestParam String role) {
        Map<String, Object> response = new HashMap<>();
        
        if (userRepository.findByUsername(username).isPresent()) {
            response.put("status", "error");
            response.put("message", "Username sudah digunakan");
            return ResponseEntity.badRequest().body(response);
        }

        User user = new User();
        user.setNama(nama);
        user.setUsername(username);
        user.setPassword(password); // Catatan: Sebaiknya gunakan BCryptPasswordEncoder
        user.setRole(role);
        
        userRepository.save(user);
        
        response.put("status", "success");
        response.put("message", "Pendaftaran Berhasil");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestParam String username, @RequestParam String password) {
        Map<String, Object> response = new HashMap<>();
        Optional<User> userOpt = userRepository.findByUsername(username);

        if (userOpt.isPresent() && userOpt.get().getPassword().equals(password)) {
            User user = userOpt.get();
            response.put("status", "success");
            response.put("message", "Login Berhasil");
            
            Map<String, Object> userData = new HashMap<>();
            userData.put("id", user.getId());
            userData.put("username", user.getUsername());
            userData.put("nama_lengkap", user.getNama());
            userData.put("role", user.getRole());
            
            response.put("data", userData);
            return ResponseEntity.ok(response);
        }

        response.put("status", "error");
        response.put("message", "Username atau Password salah");
        return ResponseEntity.status(401).body(response);
    }
}
