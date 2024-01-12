import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapboxPage extends StatelessWidget {
  const MapboxPage({super.key, required this.mapboxPublicToken});

  final String mapboxPublicToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Mapbox'),
        ),
        body: MapWidget(
            resourceOptions: ResourceOptions(accessToken: mapboxPublicToken)));
  }
}
