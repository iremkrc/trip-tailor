import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewTripPage extends StatefulWidget {
  final VoidCallback? onTripAdded;

  const NewTripPage({super.key, this.onTripAdded});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _startDate;
  DateTime? _endDate;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final List<String> _selectedTripTypes = [];
  final Map<String, IconData> _tripTypes = {
    'Business': Icons.work,
    'Leisure': Icons.beach_access,
    'Adventure': Icons.hiking,
    'Cultural': Icons.museum,
    'Romantic': Icons.favorite,
    'Family': Icons.family_restroom,
    'Sports': Icons.sports_soccer,
    'Relaxation': Icons.spa,
    'Exploration': Icons.explore,
  };

  final _database = FirebaseDatabase.instance.ref();
  final _auth = FirebaseAuth.instance;

  Future<void> _addTrip() async {
    final user = _auth.currentUser;
    if (user != null) {
      final tripData = {
        'userID': user.uid,
        'country': _selectedCountry,
        'state': _selectedState,
        'city': _selectedCity,
        'startDate': _startDate?.toIso8601String(),
        'endDate': _endDate?.toIso8601String(),
        'tripTypes': _selectedTripTypes,
        'packingList': {},
        'clothingList': {},
      };
      final newTripRef = _database.child('trips').push();
      final tripId = newTripRef.key;
      if (tripId != null) {
        await newTripRef.set(tripData);
        await _database.child('users/${user.uid}/trips/$tripId').set(tripData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trip successfully added'),
              duration: Duration(seconds: 2),
            ),
          );
          widget.onTripAdded?.call();
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to generate a unique trip identifier'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Where is your trip?',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              CSCPicker(
                onCountryChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                'When is your trip?',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DateTimeField(
                format: _dateFormat,
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _startDate = date;
                    });
                  }
                  return date;
                },
                decoration: const InputDecoration(
                  labelText: 'Start Date',
                  hintText: 'Select a start date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DateTimeField(
                format: _dateFormat,
                onShowPicker: (context, currentValue) async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: _startDate ?? DateTime.now(),
                    initialDate: currentValue ?? (_startDate ?? DateTime.now()),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _endDate = date;
                    });
                  }
                  return date;
                },
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  hintText: 'Select an end date',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select your trip type/s',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _tripTypes.entries.map((entry) {
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(entry.value, size: 16),
                        const SizedBox(width: 4),
                        Text(entry.key),
                      ],
                    ),
                    selected: _selectedTripTypes.contains(entry.key),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedTripTypes.add(entry.key);
                        } else {
                          _selectedTripTypes.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _addTrip();
                    Navigator.pop(context);
                  },
                  child: const Text('Add Trip'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
