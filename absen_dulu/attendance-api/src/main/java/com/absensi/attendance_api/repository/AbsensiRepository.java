package com.absensi.attendance_api.repository;

import com.absensi.attendance_api.model.Absensi;
import com.absensi.attendance_api.model.Siswa;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AbsensiRepository extends JpaRepository<Absensi, Integer> {
    Optional<Absensi> findBySiswaAndTanggal(Siswa siswa, LocalDate tanggal);
    List<Absensi> findByTanggal(LocalDate tanggal);
    List<Absensi> findBySiswaAndTanggalBetween(Siswa siswa, LocalDate start, LocalDate end);
}
