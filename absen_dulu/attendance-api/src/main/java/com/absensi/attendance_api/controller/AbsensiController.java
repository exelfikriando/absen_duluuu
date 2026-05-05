package com.absensi.attendance_api.controller;

import com.absensi.attendance_api.model.Kelas;
import com.absensi.attendance_api.model.Absensi;
import com.absensi.attendance_api.model.Siswa;
import com.absensi.attendance_api.repository.AbsensiRepository;
import com.absensi.attendance_api.repository.KelasRepository;
import com.absensi.attendance_api.repository.SiswaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

@RestController
@RequestMapping("/api/absensi")
@CrossOrigin(origins = "*")
public class AbsensiController {

    @Autowired
    private AbsensiRepository absensiRepository;

    @Autowired
    private SiswaRepository siswaRepository;

    @Autowired
    private KelasRepository kelasRepository;

    @GetMapping("/rekap")
    public Map<String, Object> getRekap(
            @RequestParam(required = false) String kelas,
            @RequestParam(required = false) String bulan,
            @RequestParam(required = false) String tahun,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tanggal) {

        List<Siswa> listSiswa;
        if (kelas != null && !kelas.equals("Semua Kelas") && !kelas.isEmpty()) {
            Optional<Kelas> kelasOpt = kelasRepository.findByNamaKelas(kelas);
            listSiswa = kelasOpt.isPresent() ? siswaRepository.findByKelas(kelasOpt.get()) : new ArrayList<>();
        } else {
            listSiswa = siswaRepository.findAll();
        }

        LocalDate start, end;
        if (tanggal != null) {
            start = tanggal;
            end = tanggal;
        } else {
            int m = (bulan != null) ? Integer.parseInt(bulan) : LocalDate.now().getMonthValue();
            int y = (tahun != null) ? Integer.parseInt(tahun) : LocalDate.now().getYear();
            YearMonth ym = YearMonth.of(y, m);
            start = ym.atDay(1);
            end = ym.atEndOfMonth();
        }

        List<Map<String, Object>> details = new ArrayList<>();
        int totalHadir = 0, totalSakit = 0, totalIzin = 0, totalAlpha = 0;

        for (Siswa s : listSiswa) {
            List<Absensi> absensiList = absensiRepository.findBySiswaAndTanggalBetween(s, start, end);
            
            long hadir = absensiList.stream().filter(a -> "Hadir".equalsIgnoreCase(a.getStatus())).count();
            long sakit = absensiList.stream().filter(a -> "Sakit".equalsIgnoreCase(a.getStatus())).count();
            long izin = absensiList.stream().filter(a -> "Izin".equalsIgnoreCase(a.getStatus())).count();
            long alpha = absensiList.stream().filter(a -> "Alpha".equalsIgnoreCase(a.getStatus())).count();

            totalHadir += hadir;
            totalSakit += sakit;
            totalIzin += izin;
            totalAlpha += alpha;

            Map<String, Object> map = new HashMap<>();
            map.put("nis", s.getNisn());
            map.put("nama_siswa", s.getNamaSiswa());
            map.put("jenis_kelamin", s.getJenisKelamin());
            map.put("kelas", s.getKelas() != null ? s.getKelas().getNamaKelas() : "-");
            map.put("hadir", hadir);
            map.put("sakit", sakit);
            map.put("izin", izin);
            map.put("alpha", alpha);
            
            long total = hadir + sakit + izin + alpha;
            double persentase = total == 0 ? 0 : (double) hadir / total * 100;
            map.put("persentase", Math.round(persentase));
            
            details.add(map);
        }

        Map<String, Object> summary = new HashMap<>();
        summary.put("total_siswa", listSiswa.size());
        summary.put("total_hadir", totalHadir);
        summary.put("total_sakit", totalSakit);
        summary.put("total_izin", totalIzin);
        summary.put("total_alpha", totalAlpha);

        Map<String, Object> response = new HashMap<>();
        response.put("summary", summary);
        response.put("details", details);
        
        return response;
    }

    @GetMapping("/harian")
    public List<Map<String, Object>> getAbsensiHarian(
            @RequestParam String kelas,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tanggal) {
        
        List<Map<String, Object>> result = new ArrayList<>();
        Optional<Kelas> kelasOpt = kelasRepository.findByNamaKelas(kelas);
        
        if (kelasOpt.isPresent()) {
            List<Siswa> listSiswa = siswaRepository.findByKelas(kelasOpt.get());
            for (Siswa s : listSiswa) {
                Map<String, Object> map = new HashMap<>();
                map.put("nis", s.getNisn());
                map.put("namaSiswa", s.getNamaSiswa());
                
                Optional<Absensi> absensiOpt = absensiRepository.findBySiswaAndTanggal(s, tanggal);
                map.put("statusHariIni", absensiOpt.isPresent() ? absensiOpt.get().getStatus() : "");
                
                result.add(map);
            }
        }
        return result;
    }

    @PostMapping("/update")
    public ResponseEntity<?> updateAbsensi(@RequestBody Map<String, String> payload) {
        try {
            String nis = payload.get("nis");
            LocalDate tanggal = LocalDate.parse(payload.get("tanggal"));
            String status = payload.get("status");

            Optional<Siswa> siswaOpt = siswaRepository.findByNisn(nis);
            if (siswaOpt.isPresent()) {
                Siswa siswa = siswaOpt.get();
                Absensi absensi = absensiRepository.findBySiswaAndTanggal(siswa, tanggal)
                        .orElse(new Absensi());
                
                absensi.setSiswa(siswa);
                absensi.setTanggal(tanggal);
                absensi.setStatus(status);
                absensiRepository.save(absensi);
                
                return ResponseEntity.ok(Collections.singletonMap("status", "success"));
            }
            return ResponseEntity.badRequest().body(Collections.singletonMap("message", "Siswa tidak ditemukan"));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("message", e.getMessage()));
        }
    }

    @PostMapping("/batch-update")
    public ResponseEntity<?> batchUpdateAbsensi(@RequestBody List<Map<String, String>> payload) {
        try {
            int count = 0;
            for (Map<String, String> item : payload) {
                String nisn = item.get("nisn");
                if (nisn != null) nisn = nisn.trim(); // Bersihkan spasi jika ada

                String tanggalStr = item.get("tanggal");
                String status = item.get("status");

                if (nisn == null || status == null) continue;

                LocalDate tanggal = (tanggalStr != null) ? LocalDate.parse(tanggalStr) : LocalDate.now();

                // Cari berdasarkan NISN
                Optional<Siswa> siswaOpt = siswaRepository.findByNisn(nisn);
                if (siswaOpt.isPresent()) {
                    Siswa siswa = siswaOpt.get();
                    Absensi absensi = absensiRepository.findBySiswaAndTanggal(siswa, tanggal)
                            .orElse(new Absensi());
                    
                    absensi.setSiswa(siswa);
                    absensi.setTanggal(tanggal);
                    absensi.setStatus(status);
                    absensiRepository.save(absensi);
                    count++;
                }
            }
            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "Berhasil menyimpan " + count + " data absensi");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Collections.singletonMap("message", "Error: " + e.getMessage()));
        }
    }

    @GetMapping("/cari")
    public ResponseEntity<?> cariAbsensi(
            @RequestParam String nama,
            @RequestParam String kelas,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate tanggal) {
        
        Optional<Kelas> kelasOpt = kelasRepository.findByNamaKelas(kelas);
        if (kelasOpt.isPresent()) {
            List<Siswa> listSiswa = siswaRepository.findByKelas(kelasOpt.get());
            Optional<Siswa> siswaOpt = listSiswa.stream()
                    .filter(s -> s.getNamaSiswa().equalsIgnoreCase(nama))
                    .findFirst();

            if (siswaOpt.isPresent()) {
                Siswa s = siswaOpt.get();
                Optional<Absensi> absensiOpt = absensiRepository.findBySiswaAndTanggal(s, tanggal);
                
                Map<String, Object> data = new HashMap<>();
                data.put("nama", s.getNamaSiswa());
                data.put("nis", s.getNisn());
                data.put("status", absensiOpt.isPresent() ? absensiOpt.get().getStatus() : "Belum Absen");

                Map<String, Object> response = new HashMap<>();
                response.put("status", "success");
                response.put("data", data);
                return ResponseEntity.ok(response);
            }
        }

        Map<String, Object> response = new HashMap<>();
        response.put("status", "error");
        response.put("message", "Data siswa tidak ditemukan.");
        return ResponseEntity.ok(response);
    }
}
