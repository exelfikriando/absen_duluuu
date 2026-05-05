package com.absensi.attendance_api.controller;

import com.absensi.attendance_api.model.Kelas;
import com.absensi.attendance_api.repository.KelasRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/kelas")
@CrossOrigin(origins = "*")
public class KelasController {

    @Autowired
    private KelasRepository kelasRepository;

    @GetMapping
    public List<Kelas> getAllKelas() {
        return kelasRepository.findAll();
    }

    @PostMapping("/add")
    public ResponseEntity<?> addKelas(@RequestBody Kelas kelas) {
        Map<String, Object> response = new HashMap<>();
        kelasRepository.save(kelas);
        response.put("status", "success");
        response.put("message", "Kelas berhasil ditambahkan");
        return ResponseEntity.ok(response);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<?> updateKelas(@PathVariable Integer id, @RequestBody Kelas kelasDetails) {
        Map<String, Object> response = new HashMap<>();
        return kelasRepository.findById(id).map(kelas -> {
            kelas.setNamaKelas(kelasDetails.getNamaKelas());
            kelas.setWaliKelas(kelasDetails.getWaliKelas());
            kelasRepository.save(kelas);
            response.put("status", "success");
            response.put("message", "Kelas berhasil diperbarui");
            return ResponseEntity.ok(response);
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteKelas(@PathVariable Integer id) {
        Map<String, Object> response = new HashMap<>();
        kelasRepository.deleteById(id);
        response.put("status", "success");
        response.put("message", "Kelas berhasil dihapus");
        return ResponseEntity.ok(response);
    }
}
