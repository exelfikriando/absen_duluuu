package com.absensi.attendance_api.repository;

import com.absensi.attendance_api.model.Kelas;
import com.absensi.attendance_api.model.Siswa;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface SiswaRepository extends JpaRepository<Siswa, Integer> {
    Optional<Siswa> findByNisn(String nisn);
    List<Siswa> findByKelas(Kelas kelas);
}
