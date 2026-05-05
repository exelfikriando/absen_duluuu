import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../styles/app_styles.dart';

class KelolaSiswaPage extends StatefulWidget {
  const KelolaSiswaPage({super.key});

  @override
  State<KelolaSiswaPage> createState() => _KelolaSiswaPageState();
}

class _KelolaSiswaPageState extends State<KelolaSiswaPage> {
  List _siswa = [];
  List _kelas = [];
  bool _loading = true;
  String _selectedFilterKelas = "Semua Kelas";
  final String baseUrl = "http://localhost:8080/api";

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchKelas();
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse("$baseUrl/siswa"));
      if (res.statusCode == 200) {
        setState(() => _siswa = json.decode(res.body));
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchKelas() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/kelas"));
      if (res.statusCode == 200) {
        setState(() => _kelas = json.decode(res.body));
      }
    } catch (e) {
      debugPrint("Error Fetch Kelas: $e");
    }
  }

  Future<void> _deleteSiswa(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Siswa?"),
        content: const Text("Data yang dihapus tidak bisa dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm) {
      try {
        final res = await http.delete(Uri.parse("$baseUrl/siswa/delete/$id"));
        if (res.statusCode == 200) {
          _fetchData();
          _showSnack("Siswa berhasil dihapus", AppColors.success);
        }
      } catch (e) {
        _showSnack("Gagal menghapus", AppColors.error);
      }
    }
  }

  Future<void> _deleteAllSiswa() async {
    bool confirm = await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hapus Semua Siswa?"),
        content: const Text("Tindakan ini akan menghapus SELURUH data siswa secara permanen. Apakah Anda yakin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("YA, HAPUS SEMUA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (confirm) {
      setState(() => _loading = true);
      try {
        final res = await http.delete(Uri.parse("$baseUrl/siswa/delete-all"));
        if (res.statusCode == 200) {
          _fetchData();
          _showSnack("Semua data siswa berhasil dibersihkan", AppColors.success);
        }
      } catch (e) {
        _showSnack("Gagal menghapus semua data", AppColors.error);
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  void _showForm({Map? data}) {
    final namaController = TextEditingController(text: data?['namaSiswa'] ?? "");
    final nisnController = TextEditingController(text: data?['nisn'] ?? "");
    String jk = data?['jenisKelamin'] ?? "Laki-laki";
    dynamic selectedKelas = data?['kelas']?['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data == null ? "Tambah Siswa Baru" : "Edit Data Siswa", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(controller: namaController, decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: nisnController, decoration: const InputDecoration(labelText: "NIS / NISN", border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              const Text("Jenis Kelamin"),
              Row(
                children: [
                  Radio(value: "Laki-laki", groupValue: jk, onChanged: (v) => setModalState(() => jk = v!)),
                  const Text("Laki-laki"),
                  const SizedBox(width: 20),
                  Radio(value: "Perempuan", groupValue: jk, onChanged: (v) => setModalState(() => jk = v!)),
                  const Text("Perempuan"),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: selectedKelas,
                items: _kelas.map((k) => DropdownMenuItem(value: k['id'], child: Text(k['namaKelas']))).toList(),
                onChanged: (v) => setModalState(() => selectedKelas = v),
                decoration: const InputDecoration(labelText: "Pilih Kelas", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Map payload = {
                    "namaSiswa": namaController.text,
                    "nisn": nisnController.text,
                    "jenisKelamin": jk,
                    "id_kelas": selectedKelas
                  };
                  
                  var url = data == null 
                    ? Uri.parse("$baseUrl/siswa/add") 
                    : Uri.parse("$baseUrl/siswa/update/${data['id']}");
                  
                  var res = data == null 
                    ? await http.post(url, headers: {"Content-Type": "application/json"}, body: json.encode(payload))
                    : await http.put(url, headers: {"Content-Type": "application/json"}, body: json.encode(payload));

                  if (res.statusCode == 200) {
                    Navigator.pop(context);
                    _fetchData();
                    _showSnack("Data berhasil disimpan", AppColors.success);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                child: const Text("SIMPAN DATA"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _importExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx', 'xls']);
      if (result != null) {
        setState(() => _loading = true);
        var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/siswa/import"));
        
        // Perbaikan: Gunakan Bytes untuk web/emulator agar tidak error 'path unavailable'
        if (result.files.single.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes('file', result.files.single.bytes!, filename: result.files.single.name));
        } else if (result.files.single.path != null) {
          request.files.add(await http.MultipartFile.fromPath('file', result.files.single.path!));
        }

        var response = await http.Response.fromStream(await request.send());
        if (response.statusCode == 200) {
          _showSnack(json.decode(response.body)['message'], AppColors.success);
          _fetchData();
        }
      }
    } catch (e) {
      _showSnack("Error: $e", AppColors.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        const Text("Kelola Data Siswa", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Icon(Icons.people_alt_outlined, size: 50, color: Colors.white),
                    const SizedBox(height: 10),
                    const Text("SMPN 5 Lumajang", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Tombol Import
              ElevatedButton.icon(
                onPressed: _importExcel,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text("IMPORT DARI EXCEL"),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  const Expanded(
                    child: Text(
                      "Daftar Tabel Siswa", 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 35,
                        constraints: const BoxConstraints(maxWidth: 130), // Batasi lebar filter
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilterKelas,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary),
                            isExpanded: false, // Biarkan menyesuaikan isi
                            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                            items: [
                              const DropdownMenuItem(value: "Semua Kelas", child: Text("Semua")),
                              ..._kelas.map((k) => DropdownMenuItem(value: k['namaKelas'].toString(), child: Text("Kls ${k['namaKelas']}"))),
                            ],
                            onChanged: (v) => setState(() => _selectedFilterKelas = v!),
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _deleteAllSiswa, 
                        icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 22)
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: _fetchData, 
                        icon: const Icon(Icons.refresh, size: 20)
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 10),

              // HEADER TABEL (Mirip Gambar 2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text("NIS", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12))),
                    Expanded(flex: 4, child: Text("NAMA", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12))),
                    Expanded(flex: 1, child: Text("L/P", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12))),
                    Expanded(flex: 1, child: Text("KLS", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12))),
                    Expanded(flex: 2, child: Center(child: Text("AKSI", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12)))),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ISI TABEL (Card Style Mirip Gambar 2)
              Builder(
                builder: (context) {
                  // Logika Filter
                  final filteredSiswa = _selectedFilterKelas == "Semua Kelas"
                      ? _siswa
                      : _siswa.where((s) => s['kelas'] != null && s['kelas']['namaKelas'].toString() == _selectedFilterKelas).toList();

                  if (filteredSiswa.isEmpty) {
                    return const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("Data siswa tidak ditemukan untuk filter ini", style: TextStyle(fontSize: 12, color: Colors.grey))));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredSiswa.length,
                    itemBuilder: (context, index) {
                      final s = filteredSiswa[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: index == filteredSiswa.length - 1 
                            ? const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                            : BorderRadius.zero,
                        ),
                        child: Row(
                          children: [
                            Expanded(flex: 2, child: Text(s['nisn'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
                            Expanded(flex: 4, child: Text(s['namaSiswa'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis)),
                            Expanded(flex: 1, child: Text(s['jenisKelamin'] == 'Perempuan' ? 'P' : 'L', style: const TextStyle(fontSize: 12))),
                            Expanded(flex: 1, child: Text(s['kelas'] != null ? s['kelas']['namaKelas'] : '-', style: const TextStyle(fontSize: 12))),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showForm(data: s),
                                    child: const Icon(Icons.edit, color: Colors.orange, size: 20),
                                  ),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () => _deleteSiswa(s['id']),
                                    child: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
