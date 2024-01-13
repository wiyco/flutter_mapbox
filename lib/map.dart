import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as g;

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key, required this.mapboxPublicToken});

  final String mapboxPublicToken;

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {
  g.Position? currentPosition;
  late MapboxMap _mapboxMap;
  late StreamSubscription<g.Position> _currentPositionStream;

  final _locationSettings = const g.LocationSettings(
    accuracy: g.LocationAccuracy.high,
    distanceFilter: 10,
  );

  final _cameraOptions = CameraOptions(
    center: Point(coordinates: Position(0, 0)).toJson(),
    zoom: 1,
  );

  @override
  void initState() {
    super.initState();

    _requestPermissions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _showCurrentLocation();
    _currentPositionStream =
        g.Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen((g.Position? position) {
      currentPosition = position;
      _updateCameraPosition();
    });
  }

  void _requestPermissions() async {
    PermissionStatus permissionLocation = await Permission.location.status;
    if (permissionLocation.isDenied || permissionLocation.isPermanentlyDenied) {
      await Permission.location.request();
    }
  }

  void _showCurrentLocation() async {
    await _mapboxMap.location.updateSettings(LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ));
  }

  void _updateCameraPosition() {
    _currentPositionStream.onData((g.Position position) {
      _mapboxMap.easeTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                position.longitude,
                position.latitude,
              ),
            ).toJson(),
            zoom: 13.5,
          ),
          MapAnimationOptions(
            duration: 1000,
            startDelay: 0,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Mapbox'),
      ),
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        resourceOptions: ResourceOptions(accessToken: widget.mapboxPublicToken),
        cameraOptions: _cameraOptions,
        onMapCreated: _onMapCreated,
        onCameraChangeListener: (cameraChangedEventData) =>
            _updateCameraPosition(),
      ),
    );
  }
}
