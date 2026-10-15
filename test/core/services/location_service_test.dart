import 'package:flutter_test/flutter_test.dart';
import 'package:quicknotes/core/services/location_service.dart';
import 'package:quicknotes/features/home/model/note_model.dart';

void main() {
  group('LocationService Proximity & Distance Calculation Tests', () {
    late LocationService service;

    setUp(() {
      service = LocationService();
    });

    test('calculateDistance calculates geodesic distance between two points', () {
      // Cairo Tower: 30.0459, 31.2243
      // Tahrir Square: 30.0444, 31.2357
      final distance = service.calculateDistance(
        startLatitude: 30.0459,
        startLongitude: 31.2243,
        endLatitude: 30.0444,
        endLongitude: 31.2357,
      );

      // Distance between Cairo Tower and Tahrir is approximately 1.1 km (1100m)
      expect(distance, greaterThan(900));
      expect(distance, lessThan(1300));
    });

    test('NearbyNote formattedDistance returns meters or kilometers correctly', () {
      final now = DateTime.now();
      final note = Note(
        id: 1,
        title: 'Coffee Shop',
        body: 'Near downtown',
        createdAt: now,
        updatedAt: now,
        latitude: 30.0450,
        longitude: 31.2250,
      );

      final close = NearbyNote(note: note, distanceInMeters: 450.4);
      expect(close.formattedDistance, equals('450 m'));

      final far = NearbyNote(note: note, distanceInMeters: 2500.0);
      expect(far.formattedDistance, equals('2.5 km'));
    });

    test('getNearbyNotes filters notes within radius and sorts closest first', () {
      final now = DateTime.now();

      // User location: 30.0444, 31.2357 (Tahrir)
      final userLat = 30.0444;
      final userLon = 31.2357;

      final closeNote = Note(
        id: 1,
        title: 'Close Note (100m)',
        body: 'Around the corner',
        createdAt: now,
        updatedAt: now,
        latitude: 30.0447,
        longitude: 31.2365,
      );

      final mediumNote = Note(
        id: 2,
        title: 'Medium Note (300m)',
        body: 'Down the street',
        createdAt: now,
        updatedAt: now,
        latitude: 30.0465,
        longitude: 31.2370,
      );

      final farNote = Note(
        id: 3,
        title: 'Far Note (2000m)',
        body: 'Far away',
        createdAt: now,
        updatedAt: now,
        latitude: 30.0600,
        longitude: 31.2500,
      );

      final noLocationNote = Note(
        id: 4,
        title: 'No GPS Note',
        body: 'No coordinates',
        createdAt: now,
        updatedAt: now,
      );

      final notes = [farNote, mediumNote, noLocationNote, closeNote];

      // Query notes within 500m radius
      final nearby = service.getNearbyNotes(
        userLatitude: userLat,
        userLongitude: userLon,
        notes: notes,
        radiusInMeters: 500,
      );

      // Only closeNote and mediumNote should be within 500m
      expect(nearby.length, equals(2));
      // Sorted closest first
      expect(nearby[0].note.id, equals(1));
      expect(nearby[1].note.id, equals(2));
      expect(nearby[0].distanceInMeters, lessThan(nearby[1].distanceInMeters));
    });

    test('getNearbyNotes returns empty list when no notes are within radius', () {
      final now = DateTime.now();
      final farNote = Note(
        id: 1,
        title: 'Far Note',
        body: '',
        createdAt: now,
        updatedAt: now,
        latitude: 40.7128, // New York
        longitude: -74.0060,
      );

      final nearby = service.getNearbyNotes(
        userLatitude: 30.0444, // Cairo
        userLongitude: 31.2357,
        notes: [farNote],
        radiusInMeters: 500,
      );

      expect(nearby, isEmpty);
    });
  });
}
