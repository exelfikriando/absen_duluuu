import 'package:flutter/material.dart';
import 'dart:ui';
import 'custom_field.dart';
import 'animated_button.dart';

// Class LoginForm adalah komponen UI untuk kotak input login
class LoginForm extends StatelessWidget {
  final bool isLoading; // Status apakah sedang loading (saat menekan tombol login)
  final bool isPasswordVisible; // Status apakah password sedang ditampilkan/disembunyikan
  final VoidCallback onTogglePassword; // Fungsi untuk mengubah tampilan password
  final VoidCallback onLogin; // Fungsi yang dijalankan saat tombol login ditekan

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.isPasswordVisible,
    required this.onTogglePassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Memberikan efek lengkungan pada pojok kotak form
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        // Memberikan efek blur (buram) pada latar belakang di belakang kotak form
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
          decoration: BoxDecoration(
            // Warna latar belakang form putih transparan agar efek blur terlihat
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                // Memberikan efek bayangan lembut agar form terlihat melayang
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            children: [
              // Input field untuk NISN atau Email
              CustomField(
                label: "NISN / Email",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),
              // Input field untuk Password dengan fitur sembunyikan/tampilkan
              CustomField(
                label: "Password",
                icon: Icons.lock_outline_rounded,
                obscure: !isPasswordVisible, // Mengatur apakah teks disensor atau tidak
                isPassword: true,
                onToggle: onTogglePassword,
              ),
              const SizedBox(height: 30),
              // Tombol Login yang memiliki animasi loading
              AnimatedButton(
                isLoading: isLoading,
                onTap: onLogin,
              )
            ],
          ),
        ),
      ),
    );
  }
}

// PENJELASAN FUNGSI FILE LOGIN_FORM.DART:
// 1. Berfungsi sebagai wadah (container) untuk semua inputan di halaman login.
// 2. Menggunakan BackdropFilter untuk menciptakan desain modern "Glassmorphism" (efek kaca).
// 3. Menggabungkan widget CustomField dan AnimatedButton ke dalam satu susunan vertikal.
// 4. Memisahkan logika status (loading/visibility) dari tampilan utama agar kode lebih rapi.
