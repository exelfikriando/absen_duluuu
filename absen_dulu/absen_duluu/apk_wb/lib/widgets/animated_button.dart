import 'package:flutter/material.dart';

// Class AnimatedButton adalah tombol kustom yang memiliki efek animasi saat ditekan dan saat loading
class AnimatedButton extends StatefulWidget {
  final bool isLoading; // Status apakah tombol sedang dalam proses loading
  final VoidCallback onTap; // Fungsi yang akan dijalankan ketika tombol diklik

  const AnimatedButton({
    super.key,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool pressed = false; // Variabel untuk mendeteksi apakah tombol sedang ditekan jari pengguna

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Deteksi saat jari mulai menyentuh tombol
      onTapDown: (_) => setState(() => pressed = true),
      // Deteksi saat jari diangkat dari tombol
      onTapUp: (_) => setState(() => pressed = false),
      // Deteksi jika sentuhan dibatalkan (misal jari bergeser keluar tombol)
      onTapCancel: () => setState(() => pressed = false),
      // Jika sedang loading, tombol tidak bisa diklik (null)
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedScale(
        // Memberikan efek mengecil sedikit (scale 0.96) saat ditekan agar terasa seperti tombol asli
        scale: pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            // Memberikan warna gradasi biru dari terang ke gelap
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade900],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              // Memberikan efek bayangan biru di bawah tombol
              BoxShadow(
                color: Colors.blue.shade900.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Center(
            // Logika tampilan: jika loading tampilkan muter-muter, jika tidak tampilkan teks "MASUK"
            child: widget.isLoading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Text(
                    "MASUK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// PENJELASAN FUNGSI FILE ANIMATED_BUTTON.DART:
// 1. Berfungsi sebagai tombol utama (Login) yang memiliki respons visual interaktif.
// 2. Menggunakan AnimatedScale untuk memberikan efek "feedback" (mengecil saat ditekan).
// 3. Memiliki dua kondisi tampilan: teks label standar atau animasi loading (CircularProgressIndicator).
// 4. Menggunakan gradasi warna (LinearGradient) agar tombol terlihat lebih premium dan modern.
// 5. Mencegah klik ganda (double-tap) saat proses login sedang berjalan (isLoading).
