import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'kelola_absensi_page.dart';
import 'kelola_kelas_page.dart';
import 'kelola_siswa_page.dart';
import 'rekap_absensi_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardPage extends StatefulWidget {
  final String namaGuru;
  const AdminDashboardPage({super.key, required this.namaGuru});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int totalKelas = 0;
  int totalSiswa = 0;
  int totalAbsensi = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/api/dashboard/stats"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalKelas = int.parse(data['total_kelas'].toString());
          totalSiswa = int.parse(data['total_siswa'].toString());
          totalAbsensi = int.parse(data['absensi_hari_ini'].toString());
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              decoration: AppDecorations.gradientHeader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Halo, Selamat Bekerja", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(widget.namaGuru, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      _QuickStat(label: "Kelas", value: totalKelas.toString(), icon: Icons.meeting_room_outlined),
                      const SizedBox(width: 15),
                      _QuickStat(label: "Siswa", value: totalSiswa.toString(), icon: Icons.people_outline),
                      const SizedBox(width: 15),
                      _QuickStat(label: "Hadir", value: totalAbsensi.toString(), icon: Icons.check_circle_outline),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(25),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _MenuCard(title: "Kelola Kelas", icon: Icons.class_outlined, color: Colors.blue, destination: const KelolaKelasPage(), onBack: _fetchStats),
                _MenuCard(title: "Kelola Siswa", icon: Icons.person_add_alt_1_outlined, color: Colors.indigo, destination: const KelolaSiswaPage(), onBack: _fetchStats),
                _MenuCard(title: "Input Absen", icon: Icons.edit_calendar_outlined, color: Colors.teal, destination: const KelolaAbsensiPage(), onBack: _fetchStats),
                _MenuCard(title: "Rekap Laporan", icon: Icons.analytics_outlined, color: Colors.deepOrange, destination: const RekapAbsensiPage(), onBack: _fetchStats),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.cardDecoration,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.accent),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text("Gunakan fitur Import Excel pada Kelola Siswa untuk mempercepat input data.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.logout_rounded),
          label: const Text("LOGOUT DARI SISTEM"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error.withOpacity(0.1),
            foregroundColor: AppColors.error,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _QuickStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.2))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget destination;
  final VoidCallback onBack;

  const _MenuCard({required this.title, required this.icon, required this.color, required this.destination, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => destination)).then((_) => onBack()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: AppDecorations.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
