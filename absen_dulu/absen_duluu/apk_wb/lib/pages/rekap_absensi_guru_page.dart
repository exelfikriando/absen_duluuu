import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../styles/app_styles.dart';

class RekapAbsensiGuruPage extends StatefulWidget {
  const RekapAbsensiGuruPage({super.key});

  @override
  State<RekapAbsensiGuruPage> createState() => _RekapAbsensiGuruPageState();
}

class _RekapAbsensiGuruPageState extends State<RekapAbsensiGuruPage> {
  Map<String, dynamic> _rekapData = {"summary": {}, "details": []};
  List _kelas = [];
  bool _loading = true;
  String _selectedKelas = "Semua Kelas";
  final String baseUrl = "http://localhost:8080/api";
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchKelas();
    _fetchRekap();
  }

  Future<void> _handlePdfAction({required bool isPrint}) async {
    try {
      final pdf = pw.Document();
      final summary = _rekapData['summary'] ?? {};
      final List details = _rekapData['details'] ?? [];

      if (details.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data tidak ditemukan")));
        return;
      }

      Map<String, List<dynamic>> groupedData = {};
      if (_selectedKelas == "Semua Kelas") {
        for (var d in details) {
          String k = (d['nama_kelas'] ?? 'Lainnya').toString();
          if (!groupedData.containsKey(k)) groupedData[k] = [];
          groupedData[k]!.add(d);
        }
      } else {
        groupedData[_selectedKelas] = details;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(35),
          build: (pw.Context context) {
            List<pw.Widget> widgets = [];
            widgets.add(pw.Center(child: pw.Text("LAPORAN REKAPITULASI ABSENSI SISWA", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))));
            widgets.add(pw.Center(child: pw.Text("SMPN 5 LUMAJANG", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold))));
            widgets.add(pw.SizedBox(height: 5));
            widgets.add(pw.Center(child: pw.Text("Tanggal: ${DateFormat('dd MMMM yyyy').format(_selectedDate)}")));
            widgets.add(pw.Divider(thickness: 1.5));
            widgets.add(pw.SizedBox(height: 10));

            groupedData.forEach((kelas, siswaList) {
              widgets.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 10, bottom: 5),
                child: pw.Text("KELAS: $kelas", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              ));
              widgets.add(pw.TableHelper.fromTextArray(
                headers: ['No', 'NIS', 'Nama Siswa', 'Status'],
                data: List<List<dynamic>>.generate(siswaList.length, (index) {
                  final d = siswaList[index];
                  int h = d['hadir'] ?? 0;
                  int s = d['sakit'] ?? 0;
                  int iz = d['izin'] ?? 0;
                  int a = d['alpha'] ?? 0;
                  String status = h > 0 ? "Hadir" : (s > 0 ? "Sakit" : (iz > 0 ? "Izin" : (a > 0 ? "Alpha" : "-")));
                  return [index + 1, d['nis'] ?? '-', d['nama_siswa'] ?? '-', status];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                columnWidths: {0: const pw.FixedColumnWidth(25), 1: const pw.FixedColumnWidth(70), 3: const pw.FixedColumnWidth(50)},
              ));
            });

            widgets.add(pw.SizedBox(height: 30));
            widgets.add(
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Ringkasan:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Table(
                        border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                        children: [
                          _buildSummaryRow("Hadir", "${summary['total_hadir'] ?? 0}"),
                          _buildSummaryRow("Sakit", "${summary['total_sakit'] ?? 0}"),
                          _buildSummaryRow("Izin", "${summary['total_izin'] ?? 0}"),
                          _buildSummaryRow("Alpha", "${summary['total_alpha'] ?? 0}"),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text("Lumajang, ${DateFormat('dd MMMM yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 5),
                      pw.Text("Petugas / Guru Pamong,", style: const pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 45),
                      pw.Container(width: 130, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 1)))),
                      pw.SizedBox(height: 2),
                      pw.Text("NIP. ...........................", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
            return widgets;
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final fileName = "Rekap_Absen_${DateFormat('ddMMyy').format(_selectedDate)}.pdf";
      if (isPrint) {
        await Printing.layoutPdf(onLayout: (format) async => pdfBytes, name: fileName);
      } else {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    }
  }

  pw.TableRow _buildSummaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
        pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center)),
      ],
    );
  }

  Future<void> _fetchKelas() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/kelas"));
      if (res.statusCode == 200) setState(() => _kelas = json.decode(res.body));
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _fetchRekap() async {
    setState(() => _loading = true);
    try {
      final url = "$baseUrl/absensi/rekap?kelas=${Uri.encodeComponent(_selectedKelas)}&tanggal=${DateFormat('yyyy-MM-dd').format(_selectedDate)}";
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) setState(() => _rekapData = json.decode(res.body));
    } catch (e) { debugPrint("Error: $e"); }
    finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    var summary = _rekapData['summary'] ?? {};
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading 
      ? const Center(child: CircularProgressIndicator())
      : Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // HEADER BIRU FULL
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 50, 10, 30),
                    decoration: AppDecorations.gradientHeader.copyWith(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text("Rekap Absensi", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                IconButton(tooltip: "Download PDF", icon: const Icon(Icons.picture_as_pdf, color: Colors.white), onPressed: () => _handlePdfAction(isPrint: false)),
                                IconButton(tooltip: "Print", icon: const Icon(Icons.print, color: Colors.white), onPressed: () => _handlePdfAction(isPrint: true)),
                                IconButton(
                                  icon: const Icon(Icons.calendar_month, color: Colors.white),
                                  onPressed: () async {
                                    final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
                                    if (d != null) { setState(() => _selectedDate = d); _fetchRekap(); }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryItem(label: "Hadir", value: "${summary['total_hadir'] ?? 0}", icon: Icons.check_circle_outline),
                            _SummaryItem(label: "Sakit", value: "${summary['total_sakit'] ?? 0}", icon: Icons.medication_outlined),
                            _SummaryItem(label: "Izin", value: "${summary['total_izin'] ?? 0}", icon: Icons.info_outline),
                            _SummaryItem(label: "Alpha", value: "${summary['total_alpha'] ?? 0}", icon: Icons.cancel_outlined),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tanggal: ${DateFormat('dd MMM yyyy').format(_selectedDate)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: _selectedKelas,
                          items: [
                            const DropdownMenuItem(value: "Semua Kelas", child: Text("Semua Kelas")),
                            ..._kelas.map((k) => DropdownMenuItem(value: k['namaKelas'].toString(), child: Text("Kelas ${k['namaKelas']}"))),
                          ],
                          onChanged: (v) { setState(() => _selectedKelas = v!); _fetchRekap(); },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _rekapData['details'].isEmpty 
                    ? const Padding(padding: EdgeInsets.all(30), child: Center(child: Text("Data Kosong")))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: _rekapData['details'].length,
                        itemBuilder: (context, index) {
                          final d = _rekapData['details'][index];
                          String status = (d['hadir'] ?? 0) > 0 ? "Hadir" : ((d['sakit'] ?? 0) > 0 ? "Sakit" : ((d['izin'] ?? 0) > 0 ? "Izin" : ((d['alpha'] ?? 0) > 0 ? "Alpha" : "-")));
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                              title: Text(d['nama_siswa'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                              subtitle: Text("NIS: ${d['nis'] ?? '-'}", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              trailing: _statusBadge(status),
                            ),
                          );
                        },
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // TOMBOL LOGOUT STICKY DI BAWAH
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, 
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  label: const Text("LOGOUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15), 
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = Colors.grey;
    if (status == "Hadir") color = Colors.green;
    else if (status == "Sakit") color = Colors.blue;
    else if (status == "Izin") color = Colors.orange;
    else if (status == "Alpha") color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _SummaryItem({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }
}
