import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project/model/weather_model.dart';
import 'package:project/services/location_service.dart';
import 'package:project/services/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  Future<WeatherModel>? weatherFuture;

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _cityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFormField(
              controller: _latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _startDateController,
              decoration: const InputDecoration(
                labelText: 'Start Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _endDateController,
              decoration: const InputDecoration(
                labelText: 'End Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _cityNameController,
              decoration: const InputDecoration(
                labelText: 'City Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchWeatherForCity,
              child: const Text('Get Weather For City'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? latitude =
                    double.tryParse(_latitudeController.text);
                final double? longitude =
                    double.tryParse(_longitudeController.text);
                final String startDate = _startDateController.text;
                final String endDate = _endDateController.text;

                if (latitude != null &&
                    longitude != null &&
                    startDate.isNotEmpty &&
                    endDate.isNotEmpty) {
                  setState(() {
                    weatherFuture = WeatherAPIService().getWeather(
                      latitude,
                      longitude,
                      startDate,
                      endDate,
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid data.'),
                    ),
                  );
                }
              },
              child: const Text('Get Weather'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchWeatherWithLocation,
              child: const Text('Use My Location'),
            ),
            if (weatherFuture != null) ...[
              const SizedBox(height: 10),
              FutureBuilder<WeatherModel>(
                future: weatherFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.daily!.time!.length,
                      itemBuilder: (context, index) => ListTile(
                        title:
                            Text(snapshot.data!.daily!.time![index].toString()),
                        subtitle: Text(snapshot
                            .data!.daily!.temperature2mMax![index]
                            .toString()),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return const Text('No weather data available.');
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _fetchWeatherForCity() async {
    try {
      final cityName = _cityNameController.text;
      if (cityName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a city name.'),
          ),
        );
        return;
      }

      setState(() {
        weatherFuture = WeatherAPIService().fetchCityDegree(
          cityName,
          _startDateController.text,
          _endDateController.text,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get weather for the city: $e'),
        ),
      );
    }
  }

  void _fetchWeatherWithLocation() async {
    try {
      Position position = await LocationService().getCurrentLocation();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      _startDateController.text = DateTime.now().toString().substring(0, 10);
      _endDateController.text = DateTime.now()
          .add(const Duration(days: 3))
          .toString()
          .substring(0, 10);

      setState(() {
        weatherFuture = WeatherAPIService().getWeather(
          position.latitude,
          position.longitude,
          _startDateController.text,
          _endDateController.text,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
        ),
      );
    }
  }
}
