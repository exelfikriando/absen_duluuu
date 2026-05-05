import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../styles/app_styles.dart';
import 'home_page.dart';

class ParentDashboardPage extends StatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  State<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends State<ParentDashboardPage> {
  final _namaController = TextEditingController();
  String? _selectedKelas;
  List _listKelas = [];
  Map<String, dynamic>? _result;
  bool _loading = false;
  final String baseUrl = "http://localhost:8080/api";

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/kelas")).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        setState(() => _listKelas = json.decode(res.body));
      }
    } catch (e) {
      debugPrint("Gagal memuat kelas: $e");
    }
  }

  Future<void> _cariAbsensi() async {
    if (_namaController.text.isEmpty) {
      _showSnack("masukan nama sekali lagi dengan benar", AppColors.error);
      return;
    }
    if (_selectedKelas == null) {
      _showSnack("Pilih kelas terlebih dahulu", AppColors.error);
      return;
    }

    setState(() {
      _loading = true;
      _result = null;
    });

    final tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final url = "$baseUrl/absensi/cari?nama=${Uri.encodeComponent(_namaController.text)}&kelas=${Uri.encodeComponent(_selectedKelas!)}&tanggal=$tanggal";
    
    try {
      final res = await http.get(Uri.parse(url));
      final data = json.decode(res.body);

      // Cek apakah data ditemukan (biasanya ditandai dengan status 200 dan data tidak null)
      if (res.statusCode == 200 && (data['data'] != null || data['nama'] != null)) {
        setState(() => _result = data);
      } else {
        // Jika tidak ditemukan, tampilkan pesan sesuai instruksi
        String errorMsg = (data['message'] ?? "").toString().toLowerCase();
        
        if (errorMsg.contains("kelas")) {
          _showSnack("kelas tidak ditemukan", AppColors.error);
        } else {
          // Default jika nama tidak ditemukan atau error lainnya
          _showSnack("masukan nama sekali lagi dengan benar", AppColors.error);
        }
      }
    } catch (e) {
      _showSnack("Gagal menghubungkan ke server", AppColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              width: double.infinity,
              decoration: AppDecorations.gradientHeader,
              child: const Column(
                children: [
                  Icon(Icons.family_restroom_rounded, size: 50, color: Colors.white),
                  SizedBox(height: 15),
                  Text("Cek Kehadiran Anak", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text("Cari data kehadiran berdasarkan nama dan kelas", style: TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.cardDecoration,
                child: Column(
                  children: [
                    TextField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama Lengkap Siswa", prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      hint: Text(_listKelas.isEmpty ? "Sedang memuat kelas..." : "Pilih Kelas"),
                      value: _selectedKelas,
                      items: _listKelas.map((k) => DropdownMenuItem(
                        value: k['namaKelas'].toString(), 
                        child: Text("Kelas ${k['namaKelas']}")
                      )).toList(),
                      onChanged: _listKelas.isEmpty ? null : (v) => setState(() => _selectedKelas = v),
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.class_outlined)),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _cariAbsensi,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("CARI SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.cardDecoration.copyWith(color: AppColors.accent),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _result!['data']['nama'], 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "NIS: ${_result!['data']['nis']}", 
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _result!['data']['status'], 
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 100), // Memberi ruang agar tidak tertutup tombol Home
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
