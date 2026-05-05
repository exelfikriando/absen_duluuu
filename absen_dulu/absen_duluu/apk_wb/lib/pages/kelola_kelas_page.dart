import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/app_styles.dart';

class KelolaKelasPage extends StatefulWidget {
  const KelolaKelasPage({super.key});

  @override
  State<KelolaKelasPage> createState() => _KelolaKelasPageState();
}

class _KelolaKelasPageState extends State<KelolaKelasPage> {
  List _kelas = [];
  bool _loading = true;
  final TextEditingController _kelasController = TextEditingController();
  final String baseUrl = "http://localhost:8080/api/kelas";

  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  Future<void> _fetchKelas() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) setState(() => _kelas = json.decode(res.body));
    } catch (e) {
      debugPrint("Error fetch: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addKelas() async {
    String nama = _kelasController.text.trim().toUpperCase();
    if (nama.isEmpty) return;

    setState(() => _loading = true);
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"namaKelas": nama}),
      );
      if (res.statusCode == 200) {
        _kelasController.clear();
        _fetchKelas();
        _showSnack("Kelas $nama berhasil ditambah", AppColors.success);
      }
    } catch (e) {
      _showSnack("Gagal menambah kelas", AppColors.error);
      setState(() => _loading = false);
    }
  }

  Future<void> _updateKelas(int id, String namaBaru) async {
    setState(() => _loading = true);
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/update/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"namaKelas": namaBaru.toUpperCase()}),
      );
      if (res.statusCode == 200) {
        _fetchKelas();
        _showSnack("Berhasil memperbarui kelas", AppColors.success);
      }
    } catch (e) {
      _showSnack("Gagal memperbarui kelas", AppColors.error);
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteKelas(int id, String nama) async {
    try {
      final res = await http.delete(Uri.parse("$baseUrl/delete/$id"));
      if (res.statusCode == 200) {
        _fetchKelas();
        _showSnack("Kelas $nama berhasil dihapus", AppColors.success);
      }
    } catch (e) {
      _showSnack("Gagal menghapus kelas", AppColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showEditDialog(int id, String currentNama) {
    final editController = TextEditingController(text: currentNama);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Nama Kelas"),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(
            hintText: "Nama Kelas Baru",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL")),
          ElevatedButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                _updateKelas(id, editController.text);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // HEADER BIRU FULL (Menggantikan AppBar)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 50, 10, 40),
            decoration: AppDecorations.gradientHeader.copyWith(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("Kelola Data Kelas", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Icon(Icons.meeting_room_outlined, size: 50, color: Colors.white),
                const SizedBox(height: 10),
                const Text("Atur daftar kelas SMPN 5 Lumajang", style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                
                // INPUT SECTION
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: AppDecorations.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tambah Kelas Baru", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _kelasController,
                              decoration: InputDecoration(
                                hintText: "Ketik Nama Kelas (Contoh: 7A)",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _loading ? null : _addKelas,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("TAMBAH"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Daftar Kelas Tersedia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),

                // LIST KELAS
                _loading && _kelas.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _kelas.isEmpty
                        ? const Center(child: Text("\nBelum ada data kelas"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _kelas.length,
                            itemBuilder: (context, i) {
                              final k = _kelas[i];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: AppDecorations.cardDecoration,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: const Icon(Icons.meeting_room, color: AppColors.primary),
                                  ),
                                  title: Text("Kelas ${k['namaKelas']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text("${k['jumlahSiswa'] ?? 0} Siswa Terdaftar", style: const TextStyle(fontSize: 12)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                                        onPressed: () => _showEditDialog(k['id'], k['namaKelas']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Hapus Kelas?"),
                                              content: Text("Yakin ingin menghapus kelas ${k['namaKelas']}?"),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL")),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteKelas(k['id'], k['namaKelas']);
                                                    Navigator.pop(ctx);
                                                  },
                                                  child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
