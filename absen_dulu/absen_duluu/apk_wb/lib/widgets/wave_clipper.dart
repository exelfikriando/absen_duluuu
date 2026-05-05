import 'package:flutter/material.dart';

// Class WaveClipper digunakan untuk memotong widget (seperti Container) menjadi bentuk gelombang
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Memulai garis dari titik pojok kiri atas hingga ke bawah sebelum dasar widget
    path.lineTo(0, size.height - 40);

    // Membuat lengkungan pertama gelombang
    var firstStart = Offset(size.width / 4, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    // Membuat lengkungan kedua gelombang agar terlihat menyambung
    var secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 85);
    var secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    // Menarik garis ke pojok kanan atas dan menutup jalur pemotongan
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  // Menentukan apakah pemotongan perlu dihitung ulang (false berarti tidak perlu jika data tetap)
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// PENJELASAN FUNGSI FILE WAVE_CLIPPER.DART:
// 1. Digunakan untuk menciptakan efek visual dekoratif berupa bentuk gelombang (wave).
// 2. Berfungsi memotong widget kotak standar menjadi bentuk kurva yang lebih estetis.
// 3. Menggunakan algoritma Quadratic Bezier untuk menggambar lengkungan yang halus.
// 4. Biasanya diterapkan pada bagian header atau footer halaman seperti di halaman Login.
