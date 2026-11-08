import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// The device's current position, or null when off, refused or too slow.
abstract class LocationService {
  Future<(double, double)?> current();
}

class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  @override
  Future<(double, double)?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return (position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}

/// Overridden in tests, where no location plugin runs.
final locationServiceProvider = Provider<LocationService>(
  (ref) => const DeviceLocationService(),
);
