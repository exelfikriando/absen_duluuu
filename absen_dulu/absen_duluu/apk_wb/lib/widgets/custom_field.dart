import 'package:flutter/material.dart';

// Class CustomField adalah komponen input teks kustom yang dapat digunakan berulang kali
class CustomField extends StatefulWidget {
  final String label; // Teks petunjuk (label) di dalam input
  final IconData? icon; // Ikon di bagian depan (optional)
  final bool obscure; // Status untuk menyensor teks (biasanya untuk password)
  final bool isPassword; // Menentukan apakah ini input password atau bukan
  final VoidCallback? onToggle; // Fungsi untuk menampilkan/menyembunyikan password
  final TextEditingController? controller; // Pengendali teks untuk mengambil input

  const CustomField({
    super.key,
    required this.label,
    this.icon,
    this.obscure = false,
    this.isPassword = false,
    this.onToggle,
    this.controller,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool focus = false; // Menyimpan status apakah input sedang diklik/aktif
  final node = FocusNode(); // Objek untuk mendeteksi interaksi fokus pada input

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan fokus (ketika pengguna mengklik atau meninggalkan input)
    node.addListener(() {
      setState(() => focus = node.hasFocus);
    });
  }

  @override
  void dispose() {
    // Menghapus FocusNode dari memori saat widget tidak digunakan lagi
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      // Memberikan animasi transisi warna selama 300 milidetik
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        // Berubah warna latar belakang jika sedang fokus
        color: focus ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          // Berubah warna garis tepi (border) menjadi biru jika sedang fokus
          color: focus ? const Color(0xFF00B4DB) : Colors.transparent,
          width: 2,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: node,
        obscureText: widget.obscure,
        decoration: InputDecoration(
          border: InputBorder.none, // Menghilangkan garis bawah bawaan TextField
          labelText: widget.label,
          labelStyle: TextStyle(color: focus ? const Color(0xFF00B4DB) : Colors.grey),
          // Menampilkan ikon di depan jika disediakan
          prefixIcon: widget.icon != null 
              ? Icon(widget.icon, color: focus ? const Color(0xFF00B4DB) : Colors.grey)
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          // Menampilkan tombol mata jika ini adalah input password
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    widget.obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: Colors.grey,
                  ),
                  onPressed: widget.onToggle,
                )
              : null,
        ),
      ),
    );
  }
}

// PENJELASAN FUNGSI FILE CUSTOM_FIELD.DART:
// 1. Berfungsi sebagai komponen input teks yang fleksibel untuk digunakan di berbagai form.
// 2. Memiliki fitur deteksi fokus (FocusNode) untuk mengubah warna bingkai secara otomatis saat diklik.
// 3. Menggunakan AnimatedContainer agar perubahan warna terlihat halus (tidak kaku).
// 4. Terintegrasi dengan fitur "Lihat/Sembunyikan Password" melalui ikon di sebelah kanan.
// 5. Mempermudah standarisasi desain input di seluruh aplikasi agar terlihat seragam.
