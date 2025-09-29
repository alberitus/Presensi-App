import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Position? _lastPosition;
  static DateTime? _lastTimestamp;

  static Future<bool> ensureLocationEnabled() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await ensureLocationEnabled();
      if (!hasPermission) return null;

      const settings = LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      );

      final position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      ).timeout(const Duration(seconds: 10));

      return position;
    } on TimeoutException {
      print('Timeout saat mengambil lokasi');
      return null;
    } catch (e) {
      print('Error getCurrentLocation: $e');
      return null;
    }
  }

  static Future<String?> getCurrentLocationString() async {
    final position = await getCurrentLocation();
    if (position == null) return null;
    return '${position.latitude},${position.longitude}';
  }

  static Future<bool> isFakeGPS() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return false;

      final now = DateTime.now();

      if (position.isMocked) {
        print('Lokasi di-mock oleh aplikasi pihak ketiga.');
        return true;
      }

      if (_lastPosition != null && _lastTimestamp != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        final timeDiff = now.difference(_lastTimestamp!).inSeconds;
        if (timeDiff > 0) {
          final speedMps = distance / timeDiff;

          if (speedMps > 50) {
            print(
                'Lompatan lokasi terdeteksi: ${distance.toStringAsFixed(1)} m dalam $timeDiff s (≈${speedMps.toStringAsFixed(1)} m/s)');
            _lastPosition = position;
            _lastTimestamp = now;
            return true;
          }
        }
      }

      _lastPosition = position;
      _lastTimestamp = now;

      return false;
    } catch (e) {
      print('Error deteksi fake GPS: $e');
      return false;
    }
  }

  /// Hitung jarak antar dua titik (meter)
  static double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  /// Cek apakah user dalam radius kantor
  static Future<bool> isWithinOfficeRadius({
    required double officeLat,
    required double officeLon,
    required double radiusInMeters,
  }) async {
    final position = await getCurrentLocation();
    if (position == null) return false;

    final distance = calculateDistance(
      startLat: position.latitude,
      startLon: position.longitude,
      endLat: officeLat,
      endLon: officeLon,
    );

    return distance <= radiusInMeters;
  }
}
