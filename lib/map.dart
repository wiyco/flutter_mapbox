import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key, required this.mapboxPublicToken});

  final String mapboxPublicToken;

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {
  MapboxMap? mapboxMap;
  Position currentPosition = Position(0, 0);

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    await _getPermissions();
    await _showLocation2D();
    currentPosition = _getCurrentPosition();
  }

  _showLocation2D() {
    mapboxMap?.location.updateSettings(LocationComponentSettings(
      enabled: true,
      puckBearingEnabled: true,
      pulsingEnabled: true,
      showAccuracyRing: true,
    ));
  }

  _getPermissions() async {
    await Permission.location.request();
  }

  _getCurrentPosition() async {
    final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);
    return Position(position.longitude, position.latitude);
  }

  _setCameraPosition() async {
    final position = await _getCurrentPosition();
    mapboxMap?.easeTo(
      CameraOptions(
        center: position,
        zoom: 16,
        bearing: 0,
        pitch: 3,
      ),
      MapAnimationOptions(duration: 2000, startDelay: 0),
    );
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
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
