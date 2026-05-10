import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:project/constants/api_constants.dart';
import 'package:project/model/weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:project/services/city_location_service.dart';

class WeatherAPIService {
  final CityLocationService _cityLocationService = CityLocationService();

  Future<WeatherModel> getWeather(double latitude, double longitude,
      String startDate, String endDate) async {
    final url = Uri.parse(buildForecastUrl(
        latitude: latitude,
        longitude: longitude,
        startDate: startDate,
        endDate: endDate));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      WeatherModel weatherResponse =
          WeatherModel.fromJson(jsonDecode(response.body));
      return weatherResponse;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> fetchWeather(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherAPIKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['weather'][0]['main'];
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<dynamic> fetchWeatherData(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherAPIKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<String> fetchWeatherDegree(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherAPIKey&units=metric'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['main']['temp'].toString();
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<WeatherModel> fetchCityDegree(
      String cityName, String startDate, String endDate) async {
    try {
      final location = await _cityLocationService.getCityLocation(cityName);
      final latitude = location[0];
      final longitude = location[1];
      final weatherData = getWeather(
        latitude,
        longitude,
        startDate,
        endDate,
      );
      return weatherData;
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  Future<Image> fetchWeatherIcon(double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$openWeatherAPIKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final icon = data['weather'][0]['icon'].toString();
      return Image.network('https://openweathermap.org/img/wn/$icon.png',
          width: 32.0, height: 32.0);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
