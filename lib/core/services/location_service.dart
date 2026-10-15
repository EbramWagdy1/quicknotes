import 'package:geolocator/geolocator.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

/// Represents a note that is near a user's location with its computed distance.
class NearbyNote {
  final Note note;
  final double distanceInMeters;

  const NearbyNote({
    required this.note,
    required this.distanceInMeters,
  });

  /// Formats the distance into human-friendly format (e.g. '150 m' or '2.3 km').
  String get formattedDistance {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }
}

class LocationService {
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Please enable location services.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it from settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Calculates geodesic distance between two points in meters.
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Filters notes with GPS coordinates that are within [radiusInMeters] from
  /// the specified user coordinates.
  ///
  /// Returns a list of [NearbyNote] objects sorted by closest distance first.
  List<NearbyNote> getNearbyNotes({
    required double userLatitude,
    required double userLongitude,
    required List<Note> notes,
    double radiusInMeters = 500.0,
  }) {
    final nearby = <NearbyNote>[];

    for (final note in notes) {
      if (note.latitude != null && note.longitude != null) {
        final distance = calculateDistance(
          startLatitude: userLatitude,
          startLongitude: userLongitude,
          endLatitude: note.latitude!,
          endLongitude: note.longitude!,
        );

        if (distance <= radiusInMeters) {
          nearby.add(NearbyNote(
            note: note,
            distanceInMeters: distance,
          ));
        }
      }
    }

    // Sort closest first
    nearby.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
    return nearby;
  }
}
