import 'package:flutter/material.dart';

// Class AnimatedLogo digunakan untuk menampilkan logo sekolah dengan efek animasi saat muncul
class AnimatedLogo extends StatelessWidget {
  const AnimatedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Widget pembangun animasi otomatis (Tween Animation)
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 1000), // Durasi animasi 1 detik
          tween: Tween<double>(begin: 0.5, end: 1), // Animasi dari ukuran kecil ke ukuran penuh
          curve: Curves.easeOutBack, // Memberikan efek sedikit memantul (bounce) agar terlihat hidup
          builder: (context, scale, child) {
            // Menerapkan perubahan skala hasil animasi ke widget child
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white, // Latar belakang putih untuk logo
              shape: BoxShape.circle, // Membuat bingkai berbentuk lingkaran sempurna
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2), // Garis tepi tipis transparan
            ),
            child: Image.asset(
              'assets/images/smp5logo.png', // Mengambil file gambar logo sekolah
              width: 100,
              height: 100,
            ),
          ),
        ),
        const SizedBox(height: 20), // Memberikan jarak antara logo dan teks di bawahnya
        const Text(
          "ABSENSI SISWA",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const Text(
          "SMP Negeri 5 Lumajang",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// PENJELASAN FUNGSI FILE ANIMATED_LOGO.DART:
// 1. Menampilkan identitas sekolah berupa logo dan nama sekolah di halaman Login/Splash.
// 2. Memberikan efek animasi "pop-up" atau pembesaran logo saat pertama kali halaman dibuka.
// 3. Menggunakan TweenAnimationBuilder untuk membuat animasi tanpa perlu manajemen state yang rumit.
// 4. Memastikan desain logo terlihat konsisten dengan tema putih-biru aplikasi.
