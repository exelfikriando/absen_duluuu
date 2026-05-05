package com.absensi.attendance_api.repository;

import com.absensi.attendance_api.model.Kelas;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface KelasRepository extends JpaRepository<Kelas, Integer> {
    Optional<Kelas> findByNamaKelas(String namaKelas);
}
