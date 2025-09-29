import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Memastikan lokasi dan permission sudah aktif
  static Future<bool> ensureLocationEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Mendapatkan lokasi GPS saat ini
  static Future<Position?> getCurrentLocation() async {
    try {
      // Cek permission dulu
      final hasPermission = await ensureLocationEnabled();
      if (!hasPermission) {
        return null;
      }

      // Dapatkan posisi dengan akurasi tinggi
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Mendapatkan lokasi dengan format string "lat,long"
  static Future<String?> getCurrentLocationString() async {
    final position = await getCurrentLocation();
    if (position == null) return null;
    
    return '${position.latitude},${position.longitude}';
  }

  /// Cek apakah GPS fake (mock location)
  static Future<bool> isFakeGPS() async {
    try {
      final position = await getCurrentLocation();
      if (position == null) return false;

      // Di Android, isMocked mendeteksi mock location
      return position.isMocked;
    } catch (e) {
      return false;
    }
  }

  /// Hitung jarak antara 2 koordinat (dalam meter)
  static double calculateDistance({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  /// Cek apakah user berada dalam radius tertentu dari kantor
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