import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapboxPage extends ConsumerStatefulWidget {
  const MapboxPage({super.key});

  @override
  ConsumerState<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends ConsumerState<MapboxPage> {
  late MapboxMap _mapboxMap;
  late StreamSubscription<gl.Position> _currentPositionStream;
  static gl.Position? currentPosition;

  // Default geolocation settings
  final _locationSettings = const gl.LocationSettings(
    accuracy: gl.LocationAccuracy.best,
    distanceFilter: 10,
  );

  // Default map camera settings
  final _cameraOptions = CameraOptions(
    center: Point(coordinates: Position(0, 0)).toJson(),
    zoom: 1,
  );

  @override
  void initState() {
    super.initState();
    // https://pub.dev/packages/geolocator#listen-to-location-updates
    _currentPositionStream =
        gl.Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((gl.Position? position) {
      currentPosition = position;
      _updateCameraPosition(position ?? currentPosition!);
    });
  }

  @override
  void dispose() {
    _currentPositionStream.cancel();
    super.dispose();
  }

  // After the map is created, set the camera position to the current location
  // and show the current location on the map.
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _initCurrentLocation();
    _showCurrentLocation();
  }

  void _initCurrentLocation() async {
    // https://pub.dev/packages/permission_handler
    await Permission.location.request();
    // Get the current location
    currentPosition = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: gl.LocationAccuracy.high);
    // Set the camera position to the current location
    await _mapboxMap.setCamera(CameraOptions(
      center: Point(
        coordinates: Position(
          currentPosition!.longitude,
          currentPosition!.latitude,
        ),
      ).toJson(),
      zoom: 15,
    ));
  }

  void _showCurrentLocation() {
    // https://pub.dev/packages/mapbox_maps_flutter
    _mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ));
  }

  void _updateCameraPosition(gl.Position position) {
    // https://pub.dev/packages/mapbox_maps_flutter#camera-animations
    _mapboxMap.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(
              position.longitude,
              position.latitude,
            ),
          ).toJson(),
          zoom: 15,
        ),
        MapAnimationOptions(
          duration: 500,
          startDelay: 0,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Mapbox'),
      ),
      body: MapWidget(
        key: const ValueKey('mapWidget'),
        resourceOptions:
            ResourceOptions(accessToken: dotenv.get('MAPBOX_PUBLIC_TOKEN')),
        cameraOptions: _cameraOptions,
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => {},
          tooltip: 'Show current location',
          child: const Icon(Icons.note_add)),
    );
  }
}
