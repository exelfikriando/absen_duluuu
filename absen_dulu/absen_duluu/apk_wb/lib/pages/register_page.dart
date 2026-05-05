import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../styles/app_styles.dart';
import '../widgets/custom_field.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  final String userType; 
  const RegisterPage({super.key, required this.userType});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _register() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showMsg("Username dan Password harus diisi", AppColors.error);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://localhost:8080/api/register"),
        body: {
          "nama": _userController.text, // Username otomatis jadi Nama
          "username": _userController.text,
          "password": _passController.text,
          "role": widget.userType,
        },
      );

      dynamic data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        data = null;
      }

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_user', _userController.text);
        await prefs.setString('saved_pass', _passController.text);
        
        _showMsg("Registrasi Berhasil!", AppColors.success);
        if (mounted) Navigator.pop(context);
      } else {
        String errorMsg = data != null ? (data['message'] ?? data['error'] ?? "Error ${response.statusCode}") : "Server Error ${response.statusCode}";
        _showMsg(errorMsg, AppColors.error);
      }
    } catch (e) {
      _showMsg("Koneksi Terputus: $e", AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), 
      backgroundColor: color, 
      behavior: SnackBarBehavior.floating
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 70, 25, 40),
              decoration: AppDecorations.gradientHeader,
              child: Column(
                children: [
                  const Icon(Icons.person_add_outlined, size: 60, color: Colors.white),
                  const SizedBox(height: 15),
                  const Text("Buat Akun Baru", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Daftar sebagai ${widget.userType}", style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    children: [
                      // Menampilkan info khusus untuk petugas agar username diisi nama kelas
                      if (widget.userType == "SISWA / PETUGAS")
                        const Padding(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Text(
                            "Untuk Petugas, gunakan Nama Kelas sebagai Username (Contoh: 7A)",
                            style: TextStyle(fontSize: 12, color: AppColors.accent, fontStyle: FontStyle.italic),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      CustomField(label: "Username", icon: Icons.alternate_email, controller: _userController),
                      const SizedBox(height: 15),
                      CustomField(
                        label: "Password", 
                        icon: Icons.lock_outline, 
                        isPassword: true, 
                        obscure: !_isPasswordVisible, 
                        controller: _passController,
                        onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Text("DAFTAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Sudah punya akun? Login")),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const HomePage()), (route) => false),
        backgroundColor: AppColors.primary,
        elevation: 5,
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
