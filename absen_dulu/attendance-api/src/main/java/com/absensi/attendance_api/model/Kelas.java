package com.absensi.attendance_api.model;

import jakarta.persistence.*;

@Entity
@Table(name = "kelas")
public class Kelas {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "nama_kelas", unique = true, length = 15, nullable = false)
    private String namaKelas;

    @Column(name = "wali_kelas", length = 35)
    private String waliKelas;

    // Manual Getter and Setter
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getNamaKelas() { return namaKelas; }
    public void setNamaKelas(String namaKelas) { this.namaKelas = namaKelas; }
    public String getWaliKelas() { return waliKelas; }
    public void setWaliKelas(String waliKelas) { this.waliKelas = waliKelas; }
}
