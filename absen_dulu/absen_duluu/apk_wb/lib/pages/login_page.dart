import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';
import 'register_page.dart';
import 'admin_dashboard_page.dart';
import 'petugas_dashboard_page.dart';
import 'rekap_absensi_page.dart';
import 'rekap_absensi_guru_page.dart';
import 'home_page.dart';
import '../widgets/custom_field.dart';

class LoginPage extends StatefulWidget {
  final String userType;
  const LoginPage({super.key, required this.userType});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMsg("Harap isi Username dan Password", AppColors.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      String baseUrl = "http://localhost:8080/api";
      var response = await http.post(Uri.parse("$baseUrl/login"), body: {
        "username": _usernameController.text,
        "password": _passwordController.text,
      }).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == "success") {
          String nama = data['data']['nama_lengkap'] ?? "User";
          if (mounted) {
            if (widget.userType == "ADMIN") {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => AdminDashboardPage(namaGuru: nama)));
            } else if (widget.userType == "GURU") {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const RekapAbsensiGuruPage()));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => PetugasDashboardPage(namaPetugas: nama)));
            }
          }
        } else {
          _showMsg(data['message'], AppColors.error);
        }
      } else {
        _showMsg("Terjadi kesalahan server", AppColors.error);
      }
    } catch (e) {
      _showMsg("Koneksi gagal", Colors.orange);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
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
              padding: const EdgeInsets.fromLTRB(25, 80, 25, 50),
              decoration: AppDecorations.gradientHeader,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                    child: Image.asset('assets/images/smp5logo.png', width: 60, height: 60),
                  ),
                  const SizedBox(height: 20),
                  Text("Portal ${widget.userType}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text("Silakan masuk ke akun Anda", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    children: [
                      CustomField(label: "Username", icon: Icons.person_outline, controller: _usernameController),
                      const SizedBox(height: 15),
                      CustomField(
                        label: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscure: !_isPasswordVisible,
                        controller: _passwordController,
                        onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                          ),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("MASUK", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun? ", style: TextStyle(color: AppColors.textSecondary)),
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterPage(userType: widget.userType))),
                            child: const Text("Daftar", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
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
