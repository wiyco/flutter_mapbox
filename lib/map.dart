import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxPage extends StatefulWidget {
  const MapboxPage({super.key, required this.mapboxPublicToken});

  final String mapboxPublicToken;

  @override
  State<MapboxPage> createState() => _MapboxPageState();
}

class _MapboxPageState extends State<MapboxPage> {
  MapboxMap? mapboxMap;

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
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
