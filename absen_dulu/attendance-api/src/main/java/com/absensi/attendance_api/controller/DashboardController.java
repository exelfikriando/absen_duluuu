package com.absensi.attendance_api.controller;

import com.absensi.attendance_api.repository.AbsensiRepository;
import com.absensi.attendance_api.repository.KelasRepository;
import com.absensi.attendance_api.repository.SiswaRepository;
import com.absensi.attendance_api.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "*")
public class DashboardController {

    @Autowired
    private SiswaRepository siswaRepository;
    @Autowired
    private KelasRepository kelasRepository;
    @Autowired
    private AbsensiRepository absensiRepository;
    @Autowired
    private UserRepository userRepository;

    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("total_siswa", siswaRepository.count());
        stats.put("total_kelas", kelasRepository.count());
        stats.put("total_user", userRepository.count());
        stats.put("absensi_hari_ini", absensiRepository.findByTanggal(LocalDate.now()).size());
        return stats;
    }
}
