package com.absensi.attendance_api.model;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Entity
@Table(name = "absensi")
public class Absensi {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "siswa_id", nullable = false)
    private Siswa siswa;

    @Column(nullable = false)
    private LocalDate tanggal;

    @Column(nullable = true)
    private LocalTime waktu;

    @Column(nullable = false)
    private String status; 

    @Column(columnDefinition = "TEXT")
    private String keterangan;

    @Column(name = "foto_bukti", length = 35)
    private String fotoBukti;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    // Manual Getter and Setter
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public Siswa getSiswa() { return siswa; }
    public void setSiswa(Siswa siswa) { this.siswa = siswa; }
    public LocalDate getTanggal() { return tanggal; }
    public void setTanggal(LocalDate tanggal) { this.tanggal = tanggal; }
    public LocalTime getWaktu() { return waktu; }
    public void setWaktu(LocalTime waktu) { this.waktu = waktu; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getKeterangan() { return keterangan; }
    public void setKeterangan(String keterangan) { this.keterangan = keterangan; }
    public String getFotoBukti() { return fotoBukti; }
    public void setFotoBukti(String fotoBukti) { this.fotoBukti = fotoBukti; }
}
