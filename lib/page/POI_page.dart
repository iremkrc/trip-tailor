import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:project/constants/api_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class POIPage extends StatefulWidget {
  final String destination;
  final String tripId;

  const POIPage({
    super.key,
    required this.destination,
    required this.tripId,
  });

  @override
  _POIPageState createState() => _POIPageState();
}

class _POIPageState extends State<POIPage> {
  List<Map<String, dynamic>> _poiData = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchPOIs();
  }

  Future<void> fetchPOIs() async {
    var savedPOIs = await fetchSavedPOIs();
    String requestUrlMobile =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=points+of+interest+in+${widget.destination}&key=$placesAPIKey';
    String requestUrlWeb =
        'https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/place/textsearch/json?query=points+of+interest+in+${widget.destination}&key=$placesAPIKey';
    var url = Uri.parse(
      kIsWeb ? requestUrlWeb : requestUrlMobile,
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['results'] != null) {
        var results = data['results'] as List;
        setState(() {
          _poiData = results.map((place) {
            bool isAdded = savedPOIs.any((saved) =>
                saved['name'] == place['name'] &&
                saved['location']['lat'] ==
                    place['geometry']['location']['lat'] &&
                saved['location']['lng'] ==
                    place['geometry']['location']['lng']);

            return {
              'name': place['name'],
              'location': place['geometry']['location'],
              'isAdded': isAdded,
              'rating': place['rating'] ?? 0.0,
              'photos': place['photos']
                      ?.map((photo) => photo['photo_reference'])
                      .toList() ??
                  ['No photos available'],
            };
          }).toList();
          _poiData.sort((a, b) {
            if (b['isAdded'] && !a['isAdded']) {
              return 1;
            } else if (!b['isAdded'] && a['isAdded']) {
              return -1;
            } else {
              return b['rating'].compareTo(a['rating']);
            }
          });
        });
      } else {
        throw Exception('No results found');
      }
    } else {
      throw Exception(
          'Failed to load POIs with status code: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSavedPOIs() async {
    DataSnapshot snapshot =
        await _database.child('trips/${widget.tripId}/poi').get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> pois = [];
      for (var poi in snapshot.children) {
        pois.add({
          'name': poi.child('name').value,
          'location': {
            'lat': poi.child('latitude').value,
            'lng': poi.child('longitude').value,
          }
        });
      }
      return pois;
    }
    return [];
  }

  void _togglePOI(int index) {
    var poi = _poiData[index];
    if (poi['isAdded']) {
      _database
          .child('trips/${widget.tripId}/poi')
          .orderByChild('name')
          .equalTo(poi['name'])
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          for (var child in snapshot.children) {
            if (child.child('latitude').value == poi['location']['lat'] &&
                child.child('longitude').value == poi['location']['lng']) {
              child.ref.remove().then((_) {
                setState(() {
                  _poiData[index]['isAdded'] = false;
                  sortPOIs();
                });
              });
            }
          }
        }
      }).catchError((error) {});
    } else {
      _database.child('trips/${widget.tripId}/poi').push().set({
        'name': poi['name'],
        'latitude': poi['location']['lat'],
        'longitude': poi['location']['lng'],
        'isAdded': true,
      }).then((_) {
        setState(() {
          _poiData[index]['isAdded'] = true;
          sortPOIs();
        });
      }).catchError((error) {});
    }
  }

  void sortPOIs() {
    _poiData.sort((a, b) {
      if (b['isAdded'] && !a['isAdded']) {
        return 1;
      } else if (!b['isAdded'] && a['isAdded']) {
        return -1;
      } else {
        return b['rating'].compareTo(a['rating']);
      }
    });
  }

  void _addToFirebase(int index) {
    var poi = _poiData[index];
    if (!poi['isAdded']) {
      _database.child('trips/${widget.tripId}/poi').push().set({
        'name': poi['name'],
        'latitude': poi['location']['lat'],
        'longitude': poi['location']['lng'],
        'isAdded': true,
      }).then((_) {
        setState(() {
          _poiData[index]['isAdded'] = true;
        });
      }).catchError((error) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> myPlaces =
        _poiData.where((poi) => poi['isAdded']).toList();
    List<Map<String, dynamic>> availablePlaces =
        _poiData.where((poi) => !poi['isAdded']).toList();
    List<Map<String, dynamic>> sortedPOIs = [
      {'label': 'My places to go'},
      ...myPlaces,
      {'label': 'Available places'},
      ...availablePlaces,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tourist Attractions in ${widget.destination}'),
      ),
      body: ListView.builder(
        itemCount: sortedPOIs.length,
        itemBuilder: (context, index) {
          var poi = sortedPOIs[index];
          if (poi.containsKey('label')) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                poi['label'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          var photoUrl = poi['photos'][0] != 'No photos available'
              ? "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${poi['photos'][0]}&key=$placesAPIKey"
              : 'https://via.placeholder.com/400';

          return ListTile(
            leading: IconButton(
              icon: Icon(poi['isAdded'] ? Icons.check : Icons.add),
              onPressed: () =>
                  _togglePOI(index - (index < myPlaces.length + 1 ? 1 : 2)),
            ),
            title: Text(poi['name']),
            subtitle: Text("Rating: ${poi['rating']}"),
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                photoUrl,
                width: 100,
                height: 100,
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }
}
