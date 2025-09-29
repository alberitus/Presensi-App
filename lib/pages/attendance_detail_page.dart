import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../model/absensi.dart';

class AttendanceDetailPage extends StatelessWidget {
  final Absensi absensi;

  const AttendanceDetailPage({super.key, required this.absensi});

  Future<void> _openMap(BuildContext context, String lokasi) async {
    final parts = lokasi.split(',');
    if (parts.length == 2) {
      final lat = parts[0].trim();
      final lng = parts[1].trim();
      final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Absensi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(absensi.tanggal),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Text('Jam Masuk: ${absensi.jamMasuk ?? '--:--'}'),
            Text('Jam Keluar: ${absensi.jamKeluar ?? '--:--'}'),
            Text('Status: ${absensi.status}'),

            const SizedBox(height: 24),

            if (absensi.lokasiMasuk != null && absensi.lokasiMasuk!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openMap(context, absensi.lokasiMasuk!),
                icon: const Icon(Icons.location_on),
                label: const Text('Lihat Lokasi Masuk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),

            const SizedBox(height: 12),

            if (absensi.lokasiKeluar != null && absensi.lokasiKeluar!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openMap(context, absensi.lokasiKeluar!),
                icon: const Icon(Icons.location_on),
                label: const Text('Lihat Lokasi Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
