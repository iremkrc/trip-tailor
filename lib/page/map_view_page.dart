import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapViewPage extends StatefulWidget {
  final String tripId;

  const MapViewPage({super.key, required this.tripId});

  @override
  _MapViewPageState createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  List<Marker> _markers = [];
  final MapController _mapController = MapController();
  bool _isMarkerFound = false;

  @override
  void initState() {
    super.initState();
    _fetchPOIs();
  }

  Future<void> _fetchPOIs() async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref('trips/${widget.tripId}/poi');
    DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      var newMarkers = <Marker>[];
      for (var poi in snapshot.children) {
        double lat = double.parse(poi.child('latitude').value.toString());
        double lng = double.parse(poi.child('longitude').value.toString());
        String name = poi.child('name').value.toString();

        newMarkers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, lng),
            child: Tooltip(
              message: name,
              child:
                  const Icon(Icons.location_on, size: 40.0, color: Colors.red),
            ),
          ),
        );
      }
      setState(() {
        _markers = newMarkers;
        _isMarkerFound = true;
        if (_markers.isNotEmpty) {
          _mapController.move(_markers.first.point, 12.0);
        }
      });
    }
  }

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _markers.isNotEmpty
                  ? _markers.first.point
                  : const LatLng(53, 9),
              initialZoom: 12.0,
              onPositionChanged: (position, hasGesture) {
                if (!_isMarkerFound && _markers.isNotEmpty) {
                  _mapController.move(_markers.first.point, 12.0);
                }
              },
            ),
            children: [
              TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c']),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            right: 10.0,
            bottom: 50.0,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _zoomIn,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  heroTag: 'zoomInButton',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 6),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  heroTag: 'zoomOutButton',
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
