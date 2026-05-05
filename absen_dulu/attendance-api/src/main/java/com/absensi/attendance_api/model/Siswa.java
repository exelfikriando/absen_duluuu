package com.absensi.attendance_api.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
public class Siswa {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(unique = true)
    private String nisn;

    private String namaSiswa;

    @ManyToOne
    @JoinColumn(name = "kelas_id") // Hanya gunakan ini
    private Kelas kelas;

    @ManyToOne
    @JoinColumn(name = "parent_id")
    private User parent;

    private String jenisKelamin;

    @CreationTimestamp
    private LocalDateTime createdAt;

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getNisn() { return nisn; }
    public void setNisn(String nisn) { this.nisn = nisn; }
    public String getNamaSiswa() { return namaSiswa; }
    public void setNamaSiswa(String namaSiswa) { this.namaSiswa = namaSiswa; }
    public Kelas getKelas() { return kelas; }
    public void setKelas(Kelas kelas) { this.kelas = kelas; }
    public User getParent() { return parent; }
    public void setParent(User parent) { this.parent = parent; }
    public String getJenisKelamin() { return jenisKelamin; }
    public void setJenisKelamin(String jenisKelamin) { this.jenisKelamin = jenisKelamin; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    @Transient
    public String getNamaKelas() {
        return (kelas != null) ? kelas.getNamaKelas() : "-";
    }
}
