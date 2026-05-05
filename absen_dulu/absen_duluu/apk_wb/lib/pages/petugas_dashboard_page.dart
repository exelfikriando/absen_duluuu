import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../styles/app_styles.dart';

class PetugasDashboardPage extends StatefulWidget {
  final String namaPetugas; // Ini biasanya berisi Nama Kelas bagi petugas
  const PetugasDashboardPage({super.key, required this.namaPetugas});

  @override
  State<PetugasDashboardPage> createState() => _PetugasDashboardPageState();
}

class _PetugasDashboardPageState extends State<PetugasDashboardPage> {
  List _listSiswa = [];
  Map<String, String> _statusAbsensi = {};
  bool _loading = false;
  final String _today = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());
  final String baseUrl = "http://localhost:8080/api";

  @override
  void initState() {
    super.initState();
    _fetchSiswa(widget.namaPetugas);
  }

  Future<void> _fetchSiswa(String kelas) async {
    setState(() { _loading = true; _listSiswa = []; _statusAbsensi = {}; });
    try {
      final url = "$baseUrl/absensi/harian?kelas=${Uri.encodeComponent(kelas)}&tanggal=${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _listSiswa = data;
          for (var item in data) {
            String nis = item['nis'].toString();
            if (item['statusHariIni'] != null && item['statusHariIni'] != "") {
              _statusAbsensi[nis] = item['statusHariIni'];
            }
          }
        });
      }
    } catch (e) {
      _showMsg("Koneksi gagal ke server: $e", AppColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _hadirSemua() {
    setState(() {
      for (var s in _listSiswa) {
        _statusAbsensi[s['nis'].toString()] = "Hadir";
      }
    });
  }

  Future<void> _kirimKeAdmin() async {
    if (_statusAbsensi.isEmpty) { 
      _showMsg("Silakan isi absensi terlebih dahulu!", AppColors.error); 
      return; 
    }
    setState(() => _loading = true);
    String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Kita filter: Hanya kirim yang ada statusnya
    List<Map<String, String>> dataMasal = [];
    _statusAbsensi.forEach((nisn, status) {
      if (status.isNotEmpty) {
        dataMasal.add({
          "nisn": nisn,
          "tanggal": tanggal,
          "status": status
        });
      }
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/absensi/batch-update"), 
        headers: {"Content-Type": "application/json"}, 
        body: json.encode(dataMasal)
      );
      if (response.statusCode == 200) {
        _showMsg("Berhasil! Data absensi terkirim ke Admin.", AppColors.success);
        _fetchSiswa(widget.namaPetugas);
      } else {
        _showMsg("Gagal menyimpan: ${response.body}", AppColors.error);
      }
    } catch (e) {
      _showMsg("Koneksi bermasalah: $e", AppColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Petugas
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: AppDecorations.gradientHeader.copyWith(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Petugas Kelas", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("Kelas ${widget.namaPetugas}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(onPressed: _hadirSemua, icon: const Icon(Icons.done_all, color: Colors.white), tooltip: "Hadir Semua"),
                        IconButton(onPressed: () => _fetchSiswa(widget.namaPetugas), icon: const Icon(Icons.refresh, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 10),
                      Text(_today, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator())
              : _listSiswa.isEmpty
                ? const Center(child: Text("Data siswa tidak ditemukan untuk kelas ini"))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _listSiswa.length,
                    itemBuilder: (context, i) {
                      var s = _listSiswa[i];
                      String nis = s['nis'].toString();
                      String currentStatus = _statusAbsensi[nis] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: AppDecorations.cardDecoration,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(s['namaSiswa'][0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s['namaSiswa'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                                      Text("NIS: $nis", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statusIcon("H", "Hadir", currentStatus, nis),
                                _statusIcon("S", "Sakit", currentStatus, nis),
                                _statusIcon("I", "Izin", currentStatus, nis),
                                _statusIcon("A", "Alpha", currentStatus, nis),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15), 
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _kirimKeAdmin,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("SIMPAN & KIRIM", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(String short, String label, String currentStatus, String nis) {
    bool isSelected = currentStatus == label;
    Color color;
    switch (label) {
      case "Hadir": color = Colors.green; break;
      case "Sakit": color = Colors.blue; break;
      case "Izin": color = Colors.orange; break;
      case "Alpha": color = Colors.red; break;
      default: color = Colors.grey;
    }

    return GestureDetector(
      onTap: () => setState(() => _statusAbsensi[nis] = label),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Text(short, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? color : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
        ],
      ),
    );
  }
}
