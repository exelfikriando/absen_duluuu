import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/app_styles.dart';
import 'login_page.dart';
import 'parent_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _totalSiswa = "...";
  String _totalKelas = "...";
  String _totalStaff = "...";
  
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Efek bernafas (gerak pelan)
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:8080/api/dashboard/stats"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _totalSiswa = data['total_siswa'].toString();
          _totalKelas = data['total_kelas'].toString();
          _totalStaff = data['total_user'].toString();
        });
      }
    } catch (e) {
      debugPrint("Error Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
              decoration: AppDecorations.gradientHeader,
              child: Column(
                children: [
                  // Logo Animasi (ML Style Pulse)
                  ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.1).animate(_logoController),
                    child: Image.asset('assets/images/smp5logo.png', width: 90),
                  ),
                  const SizedBox(height: 15),
                  const Text("ABSEN DULU", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const Text("SMP NEGERI 5 LUMAJANG", style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                  
                  const SizedBox(height: 30),
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickStat(label: "Siswa", value: _totalSiswa, icon: Icons.people_outline),
                        _QuickStat(label: "Kelas", value: _totalKelas, icon: Icons.meeting_room_outlined),
                        _QuickStat(label: "Staff", value: _totalStaff, icon: Icons.badge_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Pilih Akses Login", style: AppTextStyles.heading),
                  const SizedBox(height: 20),
                  
                  // Grid Menu Kotak-Kotak
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1,
                    children: [
                      _SquareMenu(
                        title: "ADMIN",
                        icon: Icons.admin_panel_settings_rounded,
                        color: Colors.redAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage(userType: "ADMIN"))),
                      ),
                      _SquareMenu(
                        title: "GURU",
                        icon: Icons.school_rounded,
                        color: Colors.blueAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage(userType: "GURU"))),
                      ),
                      _SquareMenu(
                        title: "PETUGAS",
                        icon: Icons.assignment_ind_rounded,
                        color: Colors.orangeAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LoginPage(userType: "SISWA / PETUGAS"))),
                      ),
                      _SquareMenu(
                        title: "WALI MURID",
                        icon: Icons.family_restroom_rounded,
                        color: Colors.purpleAccent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ParentDashboardPage())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _QuickStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _SquareMenu extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SquareMenu({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: AppDecorations.cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color, letterSpacing: 1.2)),
          ],
        ),
      ),
    );
  }
}
