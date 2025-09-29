import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
// import 'package:logger/logger.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Future<void> _checkLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika GPS tidak aktif, arahkan ke settings lokasi
      AppSettings.openAppSettings();
      return;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User menolak izin → arahkan ke settings
        AppSettings.openAppSettings();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Izin permanen ditolak → harus ke settings
      AppSettings.openAppSettings();
      return;
    }

    // Jika sudah diizinkan
    Position pos = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high, // ganti desiredAccuracy -> accuracy
        distanceFilter: 0, // optional: minimal jarak update lokasi (meter)
      ),
    );
    print("Lokasi: ${pos.latitude}, ${pos.longitude}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Lokasi')),
      body: Center(
        child: ElevatedButton(
          onPressed: _checkLocation,
          child: const Text('Cek Lokasi'),
        ),
      ),
    );
  }
}
