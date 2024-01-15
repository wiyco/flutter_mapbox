import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key, required this.mapboxPublicToken});

  final String mapboxPublicToken;

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {
  late MapboxMap _mapboxMap;
  late StreamSubscription<gl.Position> _currentPositionStream;
  gl.Position? _currentPosition;

  final _locationSettings = const gl.LocationSettings(
    accuracy: gl.LocationAccuracy.best,
    distanceFilter: 10,
  );

  final _cameraOptions = CameraOptions(
    center: Point(coordinates: Position(0, 0)).toJson(),
    zoom: 1,
  );

  @override
  void initState() {
    super.initState();

    _currentPositionStream =
        gl.Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((gl.Position? position) {
      if (position != null) {
        _currentPosition = position;
        _updateCameraPosition(position);
      }
    });
  }

  @override
  void dispose() {
    _currentPositionStream.cancel();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _initCurrentLocation();
    _showCurrentLocation();
  }

  void _initCurrentLocation() async {
    await Permission.location.request();
    _currentPosition = await gl.Geolocator.getCurrentPosition(
        desiredAccuracy: _locationSettings.accuracy);
    await _mapboxMap.setCamera(CameraOptions(
      center: Point(
        coordinates: Position(
          _currentPosition!.longitude,
          _currentPosition!.latitude,
        ),
      ).toJson(),
      zoom: 15,
    ));
  }

  void _showCurrentLocation() {
    _mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ));
  }

  void _updateCameraPosition(gl.Position position) {
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
        resourceOptions: ResourceOptions(accessToken: widget.mapboxPublicToken),
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
