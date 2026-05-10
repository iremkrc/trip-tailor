import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as google_calendar;
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleCalendarService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [google_calendar.CalendarApi.calendarScope],
  );

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      return await _googleSignIn.signIn();
    } catch (error) {
      return null;
    }
  }

  static Future<void> addEventToGoogleCalendar(String tripId) async {
    final tripDetails = await fetchTripDetails(tripId);
    if (tripDetails == null) {
      return;
    }
    final account = await signInWithGoogle();
    if (account == null) {
      return;
    }
    final authHeaders = await account.authHeaders;
    final authenticateClient = AuthenticatedClient(authHeaders);
    final calendar = google_calendar.CalendarApi(authenticateClient);
    String locationDescription = 'Unknown Location';
    if (tripDetails['city'] != null && tripDetails['city'].isNotEmpty) {
      locationDescription = tripDetails['city'];
    } else if (tripDetails['state'] != null &&
        tripDetails['state'].isNotEmpty) {
      locationDescription = tripDetails['state'];
    } else if (tripDetails['country'] != null &&
        tripDetails['country'].isNotEmpty) {
      locationDescription = tripDetails['country'];
    }
    DateTime startDate = DateTime.parse(tripDetails['startDate']);
    DateTime endDate =
        DateTime.parse(tripDetails['endDate']).add(const Duration(days: 1));
    final event = google_calendar.Event(
      summary: 'Trip to $locationDescription',
      description:
          'Enjoy your trip to $locationDescription from ${tripDetails['startDate']} to ${tripDetails['endDate']}',
      start: google_calendar.EventDateTime(
          dateTime: startDate, timeZone: 'GMT+00:00'),
      end: google_calendar.EventDateTime(
          dateTime: endDate, timeZone: 'GMT+00:00'),
    );
    try {
      await calendar.events.insert(event, 'primary');
      openGoogleCalendar();
    } catch (e) {}
  }

  static Future<Map<String, dynamic>?> fetchTripDetails(String tripId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('trips/$tripId');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> openGoogleCalendar() async {
    const url = 'https://calendar.google.com/calendar/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}

class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> headers;
  final http.Client _client = http.Client();
  AuthenticatedClient(this.headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(headers));
  }
}
