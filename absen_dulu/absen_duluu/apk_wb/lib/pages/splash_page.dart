import 'package:flutter/material.dart';
import 'home_page.dart';

// Class SplashPage adalah halaman pemuatan (loading) yang muncul pertama kali saat aplikasi dibuka
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller; // Pengendali jalannya animasi
  late Animation<double> _scaleAnimation; // Animasi untuk perubahan ukuran (skala)
  late Animation<double> _fadeAnimation; // Animasi untuk efek muncul perlahan (transparansi)

  @override
  void initState() {
    super.initState();
    // Mengatur durasi animasi logo selama 2 detik
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Membuat animasi skala: dari ukuran setengah (0.5) ke ukuran penuh (1.0)
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Membuat animasi fade: dari tidak terlihat (0) menjadi muncul penuh (1)
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Memulai proses jalannya animasi
    _controller.forward();

    // Berpindah ke halaman utama (HomePage) secara otomatis setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // pushReplacement digunakan agar pengguna tidak bisa kembali ke halaman splash lagi
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    // Menghapus pengendali animasi dari memori untuk menghemat baterai/performa
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur warna latar belakang halaman splash (Biru Tua)
      backgroundColor: const Color(0xFF1E3A8A), 
      body: Center(
        child: FadeTransition(
          // Menerapkan efek muncul perlahan (Fade)
          opacity: _fadeAnimation,
          child: ScaleTransition(
            // Menerapkan efek pembesaran (Scale)
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Wadah putih berbentuk lingkaran untuk Logo Sekolah
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/smp5logo.png', // File gambar logo
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 30), // Jarak antara logo dan teks
                const Text(
                  "SMP NEGERI 5",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "LUMAJANG",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 50),
                // Indikator garis pemuatan di bagian bawah logo
                const SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// PENJELASAN FUNGSI FILE SPLASH_PAGE.DART:
// 1. Berfungsi sebagai identitas pembuka aplikasi (Branding).
// 2. Memberikan waktu bagi sistem untuk memuat data di latar belakang sebelum masuk ke menu utama.
// 3. Menggunakan perpaduan ScaleTransition (pembesaran) dan FadeTransition (muncul halus) agar terlihat profesional.
// 4. Navigator.pushReplacement memastikan halaman ini hanya muncul sekali dan langsung diganti oleh HomePage.
// 5. Memberikan kesan aplikasi yang responsif dan modern melalui animasi Tween dan Curve.
