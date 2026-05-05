import 'package:flutter/material.dart';
import 'pages/splash_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Menghilangkan label "Debug" yang biasanya muncul di pojok kanan atas
      debugShowCheckedModeBanner: false,
      
      // Judul aplikasi yang muncul pada sistem Android/Web
      title: 'Absensi SMPN 5',
      
      // Konfigurasi tema warna dan tampilan aplikasi secara global
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          primary: Colors.blue.shade700,
        ),
        // Menggunakan desain Material 3 yang lebih modern dan terbaru
        useMaterial3: true,
        // Menentukan jenis huruf yang digunakan di seluruh aplikasi
        fontFamily: 'sans-serif',
      ),
      
      // Halaman pertama yang akan ditampilkan saat aplikasi dijalankan
      home: const SplashPage(),
    );
  }
}

// PENJELASAN FUNGSI FILE APP.DART:
// 1. Sebagai pusat konfigurasi utama aplikasi Flutter.
// 2. Mengatur "identitas" aplikasi seperti Nama Aplikasi (title) dan halaman awal (home).
// 3. Mengelola tema desain global (Warna, Font, Gaya UI) agar konsisten di semua halaman.
// 4. MaterialApp di sini bertindak sebagai pembungkus seluruh navigasi dan fitur dasar Android/iOS.
