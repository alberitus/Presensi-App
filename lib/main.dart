import 'package:flutter/material.dart';
import 'config/env.dart';
import 'pages/login_screen.dart';
import 'services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Presensi App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LocationCheckScreen(),
    );
  }
}

class LocationCheckScreen extends StatefulWidget {
  const LocationCheckScreen({super.key});

  @override
  State<LocationCheckScreen> createState() => _LocationCheckScreenState();
}

class _LocationCheckScreenState extends State<LocationCheckScreen> {
  bool checking = true;
  bool locationReady = false;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    final enabled = await LocationService.ensureLocationEnabled();
    setState(() {
      checking = false;
      locationReady = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!locationReady) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 80, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Lokasi tidak aktif atau izin lokasi belum diberikan.\n'
                  'Silakan aktifkan layanan lokasi (GPS) dan berikan izin lokasi untuk melanjutkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _checkLocation,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Jika lokasi aktif, lanjut ke Login
    return const LoginScreen();
  }
}
