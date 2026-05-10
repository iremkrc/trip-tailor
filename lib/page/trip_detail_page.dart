import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/page/POI_page.dart';
import 'package:project/page/map_view_page.dart';
import 'package:project/page/packing_page.dart';
import 'package:project/page/notes_page.dart';
import 'package:project/services/google_calendar_service.dart';
import 'package:share_plus/share_plus.dart';

class TripDetailPage extends StatelessWidget {
  final Map<String, dynamic> trip;
  final bool isPastTrip;
  final VoidCallback? onTripDeleted;
  final VoidCallback? onUpdatePopularLocations;

  const TripDetailPage({
    super.key,
    required this.trip,
    required this.isPastTrip,
    this.onTripDeleted,
    this.onUpdatePopularLocations,
  });

  void _deleteTrip(BuildContext context, String tripId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text('Are you sure you want to delete this trip?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  FirebaseDatabase.instance.ref('trips/$tripId').remove();
                  FirebaseDatabase.instance
                      .ref('users/${user.uid}/trips/$tripId')
                      .remove();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  if (onTripDeleted != null) onTripDeleted!();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${trip['destination']} (${trip['dateRange']})'),
      ),
      body: Expanded(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: <Widget>[
            _buildFunctionButton(context, Icons.map, 'City Map'),
            _buildFunctionButton(context, Icons.luggage, 'Packing List'),
            _buildFunctionButton(context, Icons.schedule, 'Itinerary'),
            if (isPastTrip)
              _buildFunctionButton(context, Icons.star, 'Rate Your Trip',
                  () => _showRatingDialog(context)),
            _buildFunctionButton(context, Icons.note_add, 'Add Notes'),
            _buildFunctionButton(context, Icons.share, 'Post on Social Media'),
            _buildFunctionButton(
                context, Icons.calendar_today, 'Add to Google Calendar', () {
              GoogleCalendarService.addEventToGoogleCalendar(trip['tripId']);
            }),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: InkWell(
          onTap: () => _deleteTrip(context, trip['tripId']),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete Trip'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> _fetchAddedPOIs() async {
    final DatabaseReference ref =
        FirebaseDatabase.instance.ref('trips/${trip['tripId']}/poi');
    DataSnapshot snapshot =
        await ref.orderByChild('isAdded').equalTo(true).get();

    List<String> addedPOIs = [];
    if (snapshot.exists) {
      for (var poi in snapshot.children) {
        addedPOIs.add(poi.child('name').value as String);
      }
    }
    return addedPOIs;
  }

  Future<String> _createShareMessage() async {
    List<String> addedPOIs = await _fetchAddedPOIs();
    String poiList = addedPOIs.join(', ');
    return 'Check out my trip to ${trip['destination']} from ${trip['dateRange']}! I visited places like $poiList. Check it here: our app store #travel #adventure';
  }

  void _shareTrip(BuildContext context) async {
    try {
      String message = await _createShareMessage();
      Share.share(message);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to share trip. Please try again later.')));
    }
  }

  Widget _buildFunctionButton(BuildContext context, IconData icon, String title,
      [VoidCallback? onTap]) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap ??
            () {
              if (title == 'Packing List') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PackingPage(tripId: trip['tripId']),
                  ),
                );
              } else if (title == 'Itinerary') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => POIPage(
                        destination: trip['destination'],
                        tripId: trip['tripId']),
                  ),
                );
              } else if (title == 'City Map') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapViewPage(tripId: trip['tripId']),
                  ),
                );
              } else if (title == 'Rate Your Trip') {
                _showRatingDialog(context);
              } else if (title == 'Add Notes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotesPage(tripId: trip['tripId']),
                  ),
                );
              } else if (title == "Post on Social Media") {
                _shareTrip(context);
              }
            },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30.0),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Your Trip'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  selectedRating = index + 1;
                  Navigator.of(context).pop();
                  _saveRatingToFirebase(selectedRating);
                },
              );
            }),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _saveRatingToFirebase(int rating) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && trip['tripId'] != null) {
      String tripId = trip['tripId'];
      FirebaseDatabase.instance
          .ref('users/${user.uid}/trips/$tripId/rating')
          .set(rating);
      FirebaseDatabase.instance.ref('trips/$tripId/rating').set(rating);
      if (onUpdatePopularLocations != null) {
        onUpdatePopularLocations!();
      }
    }
  }
}
