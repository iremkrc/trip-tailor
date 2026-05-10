import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/constants/api_constants.dart';
import 'package:project/page/POI_page.dart';
import 'package:project/page/new_trip_page.dart';
import 'package:project/page/trip_detail_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  _TripPageState createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  List<Map<String, dynamic>> popularLocations = [];
  List<Map<String, dynamic>> myTrips = [];
  List<Map<String, dynamic>> upcomingTrips = [];
  List<Map<String, dynamic>> pastTrips = [];
  bool isLoadingTrips = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTrips();
    _fetchPopularLocations();
  }

  Future<void> _fetchMyTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseDatabase.instance.ref('users/${user.uid}/trips').get();
      if (snapshot.exists) {
        final tripsData = Map<String, dynamic>.from(snapshot.value as Map);
        final List<Map<String, dynamic>> tempUpcomingTrips = [];
        final List<Map<String, dynamic>> tempPastTrips = [];
        DateTime now = DateTime.now();

        for (final tripId in tripsData.keys) {
          final tripSnapshot =
              await FirebaseDatabase.instance.ref('trips/$tripId').get();
          if (tripSnapshot.exists) {
            final tripInfo =
                Map<String, dynamic>.from(tripSnapshot.value as Map);
            DateTime startDate = DateTime.parse(tripInfo['startDate']);
            String imageUrl = await _fetchCityImage(tripInfo['city'] ?? 'City');
            Map<String, dynamic> tripDetails = {
              'tripId': tripId,
              'destination':
                  tripInfo['city'] ?? tripInfo['state'] ?? tripInfo['country'],
              'dateRange':
                  '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(DateTime.parse(tripInfo['endDate']))}',
              'image': imageUrl,
            };

            if (startDate.isAfter(now)) {
              tempUpcomingTrips.add(tripDetails);
            } else {
              tempPastTrips.add(tripDetails);
            }
          }
        }
        tempUpcomingTrips.sort((a, b) =>
            DateTime.parse(a['dateRange'].split(' to ')[0])
                .compareTo(DateTime.parse(b['dateRange'].split(' to ')[0])));
        tempPastTrips.sort((a, b) =>
            DateTime.parse(b['dateRange'].split(' to ')[0])
                .compareTo(DateTime.parse(a['dateRange'].split(' to ')[0])));
        setState(() {
          upcomingTrips = tempUpcomingTrips;
          pastTrips = tempPastTrips;
          isLoadingTrips = false;
        });
      } else {
        setState(() {
          isLoadingTrips = false;
        });
      }
    }
  }

  void refreshPopularLocations() {
    _fetchPopularLocations();
  }

  Future<String> _fetchCityImage(String city) async {
    if (city.toLowerCase() == 'unknown' || city.isEmpty) {
      return 'assets/icon/travel.png';
    }
    final response = await http.get(
      Uri.parse(
          'https://api.unsplash.com/search/photos?query=$city&client_id=$cityImageAPIKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]['urls']['small'];
      }
    }
    return 'assets/icon/travel.png';
  }

  double calculateAverageRating(List<double> ratings) {
    if (ratings.isEmpty) return 0.0;
    double sum = 0.0;
    for (double rating in ratings) {
      sum += rating;
    }
    return sum / ratings.length;
  }

  Future<void> _fetchPopularLocations() async {
    final snapshot = await FirebaseDatabase.instance.ref('trips').get();
    if (snapshot.exists && snapshot.value != null) {
      Map<String, List<double>> cityRatings = {};
      Map<String, String> cityImages = {};
      Map<String, String> cityTripIds = {};
      Map snapshotData = snapshot.value as Map;
      await Future.forEach(snapshotData.entries, (MapEntry entry) async {
        var city = entry.value['city'] as String? ?? 'unknown';
        if (city.toLowerCase() == 'unknown') {
          return; //skip
        }
        var rating = ((entry.value['rating'] is double) ||
                (entry.value['rating'] is int))
            ? entry.value['rating'].toDouble()
            : 0.0;
        if (rating > 0) {
          //check rating apart from 0
          cityRatings.putIfAbsent(city, () => []).add(rating);
        }
        if (!cityImages.containsKey(city) && rating > 0) {
          cityImages[city] = await _fetchCityImage(city);
          cityTripIds[city] = entry.key;
        }
      });
      List<Map<String, dynamic>> loadedPopularLocations = [];
      cityRatings.forEach((city, ratings) {
        if (ratings.isNotEmpty) {
          //only show cities with ratings
          double avgRating = calculateAverageRating(ratings);
          loadedPopularLocations.add({
            'name': city,
            'rating': avgRating,
            'image': cityImages[city],
            'tripId': cityTripIds[city],
          });
        }
      });
      loadedPopularLocations.sort(
          (a, b) => b['rating'].compareTo(a['rating'])); //sort by descending
      setState(() {
        popularLocations =
            loadedPopularLocations.where((loc) => loc['rating'] > 0).toList();
      });
    }
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return SizedBox(
      width: 160.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => POIPage(
                  destination: location['name'],
                  tripId: location['tripId'],
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                location['image'],
                fit: BoxFit.cover,
                height: 100.0,
                width: 160.0,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/icon/travel.png',
                    fit: BoxFit.cover,
                    height: 100.0,
                    width: 160.0,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(location['name'],
                        style: const TextStyle(fontSize: 16.0)),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.star, size: 14.0, color: Colors.amber),
                        Text(location['rating'].toStringAsFixed(1),
                            style: const TextStyle(fontSize: 14.0)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip, bool isPastTrip) {
    return SizedBox(
      width: 160.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailPage(
                    trip: trip,
                    isPastTrip: isPastTrip,
                    onTripDeleted: () {
                      _fetchMyTrips();
                    },
                    onUpdatePopularLocations: () {
                      refreshPopularLocations();
                    }),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              trip['image'] != null
                  ? Image.network(
                      trip['image'],
                      fit: BoxFit.cover,
                      height: 100.0,
                      width: 160.0,
                    )
                  : Container(
                      height: 100.0,
                      width: 160.0,
                      color: Colors.grey[300],
                      child: Icon(Icons.image,
                          size: 50.0, color: Colors.grey[600]),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      trip['destination'] ?? 'Unknown Destination',
                      style: const TextStyle(fontSize: 16.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'From: ${trip['dateRange'].split(' to ')[0]}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          'To: ${trip['dateRange'].split(' to ')[1]}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewTripPage(
          onTripAdded: () {
            _fetchMyTrips();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Next Trip'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoadingTrips
          ? Center(
        child: CircularProgressIndicator(),) :SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Popular Locations',
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 220.0,
              child: ListView.builder(
                itemCount: popularLocations.length,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 16.0,
                        right: index == popularLocations.length - 1 ? 16.0 : 0),
                    child: _buildLocationCard(popularLocations[index]),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Upcoming Trips',
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            _buildTripList(upcomingTrips, true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Past Trips',
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            _buildTripList(pastTrips, false),
          ],
        ),
      ),
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips, bool isUpcoming) {
    return SizedBox(
      height: 220.0,
      child: ListView.builder(
        itemCount: trips.length + (isUpcoming ? 1 : 0),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemBuilder: (BuildContext context, int index) {
          if (isUpcoming && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0),
              child: _buildAddNewTripCard(),
            );
          }
          final adjustedIndex = isUpcoming ? index - 1 : index;
          return Padding(
            padding: EdgeInsets.only(
                left: isUpcoming && index == 1 ? 8.0 : 16.0,
                right: adjustedIndex == trips.length - 1 ? 16.0 : 8.0),
            child: _buildTripCard(trips[adjustedIndex], !isUpcoming),
          );
        },
      ),
    );
  }

  Widget _buildAddNewTripCard() {
    return SizedBox(
      width: 160.0,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4.0,
        child: InkWell(
          onTap: _addNewTrip,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.add,
                  size: 40.0, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8.0),
              const Text(
                'Add New Trip',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
