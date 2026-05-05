import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../styles/app_styles.dart';

class KelolaAbsensiPage extends StatefulWidget {
  const KelolaAbsensiPage({super.key});

  @override
  State<KelolaAbsensiPage> createState() => _KelolaAbsensiPageState();
}

class _KelolaAbsensiPageState extends State<KelolaAbsensiPage> {
  String? _selectedKelas;
  List _listKelas = [];
  List _listSiswa = [];
  Map<String, String> _statusAbsensi = {};
  bool _loading = false;
  DateTime _selectedDate = DateTime.now();
  final String baseUrl = "http://localhost:8080/api";

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/kelas"));
      if (res.statusCode == 200) {
        setState(() => _listKelas = json.decode(res.body));
      }
    } catch (e) {
      debugPrint("Error fetch kelas: $e");
    }
  }

  Future<void> _fetchSiswa(String kelas) async {
    setState(() {
      _loading = true;
      _statusAbsensi = {};
      _listSiswa = [];
    });
    try {
      final url = "$baseUrl/absensi/harian?kelas=${Uri.encodeComponent(kelas)}&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          _listSiswa = data;
          for (var i in data) {
            String nis = i['nis'].toString();
            if (i['statusHariIni'] != null && i['statusHariIni'] != "") {
              _statusAbsensi[nis] = i['statusHariIni'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetch siswa: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _simpanAbsensi() async {
    if (_statusAbsensi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih status kehadiran terlebih dahulu")));
      return;
    }

    setState(() => _loading = true);
    List<Map<String, String>> payload = [];
    _statusAbsensi.forEach((nis, status) {
      payload.add({
        "nis": nis,
        "tanggal": DateFormat('yyyy-MM-dd').format(_selectedDate),
        "status": status
      });
    });

    try {
      final res = await http.post(
        Uri.parse("$baseUrl/absensi/batch-update"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Absensi berhasil disimpan!"), backgroundColor: Colors.green));
        if (_selectedKelas != null) _fetchSiswa(_selectedKelas!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menyimpan: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header Modern
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: AppDecorations.gradientHeader,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text(
                          "Kelola Absensi",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_rounded, color: Colors.white, size: 28),
                      onPressed: _simpanAbsensi,
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // Search & Date Filters
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: AppDecorations.cardDecoration,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Pilih Kelas"),
                        value: _selectedKelas,
                        isExpanded: true,
                        items: _listKelas.map((k) => DropdownMenuItem(
                          value: k['namaKelas'].toString(),
                          child: Text("Kelas ${k['namaKelas']}"),
                        )).toList(),
                        onChanged: (v) {
                          setState(() => _selectedKelas = v);
                          _fetchSiswa(v!);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) {
                      setState(() => _selectedDate = d);
                      if (_selectedKelas != null) _fetchSiswa(_selectedKelas!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppDecorations.cardDecoration.copyWith(color: AppColors.primary),
                    child: const Icon(Icons.calendar_month, color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          // List Siswa
          Expanded(
            child: _loading 
              ? const Center(child: CircularProgressIndicator())
              : _listSiswa.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Pilih kelas untuk melihat siswa", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _listSiswa.length,
                    itemBuilder: (context, i) {
                      final s = _listSiswa[i];
                      final String nis = s['nis'].toString();
                      String currentStatus = _statusAbsensi[nis] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(15),
                        decoration: AppDecorations.cardDecoration,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(s['namaSiswa'][0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s['namaSiswa'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("NIS: $nis", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(thickness: 0.5),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statusButton("H", "Hadir", currentStatus, nis),
                                _statusButton("S", "Sakit", currentStatus, nis),
                                _statusButton("I", "Izin", currentStatus, nis),
                                _statusButton("A", "Alpha", currentStatus, nis),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Floating Action Button Style Save
          if (_listSiswa.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: _simpanAbsensi,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text("SIMPAN KEHADIRAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _statusButton(String short, String label, String currentStatus, String nis) {
    bool isSelected = currentStatus == label;
    Color color;
    switch (label) {
      case "Hadir": color = Colors.green; break;
      case "Sakit": color = Colors.blue; break;
      case "Izin": color = Colors.orange; break;
      case "Alpha": color = Colors.red; break;
      default: color = Colors.grey;
    }

    return InkWell(
      onTap: () => setState(() => _statusAbsensi[nis] = label),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.grey[100],
              shape: BoxShape.circle,
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))] : [],
            ),
            child: Text(
              short,
              style: TextStyle(color: isSelected ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: isSelected ? color : Colors.grey[600], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))
        ],
      ),
    );
  }
}
