import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mendukung format tanggal Indonesia (Senin, Selasa, dll)
  await initializeDateFormatting('id_ID', null); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Absen Dulu SMPN 5',
      // Menggunakan tema Material 3 yang modern
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      // Menjadikan Splash Screen sebagai halaman pertama
      home: const SplashScreen(),
    );
  }
}
