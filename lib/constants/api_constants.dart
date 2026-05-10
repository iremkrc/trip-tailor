import 'package:flutter_dotenv/flutter_dotenv.dart';

String get openWeatherAPIKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';
String get placesAPIKey => dotenv.env['PLACES_API_KEY'] ?? '';
String get cityImageAPIKey => dotenv.env['CITY_IMAGE_API_KEY'] ?? '';
String get removeBgApiKey => dotenv.env['REMOVEBG_API_KEY'] ?? '';

String buildForecastUrl({
  required double latitude,
  required double longitude,
  required String startDate,
  required String endDate,
}) {
  return 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,cloud_cover,rain,snowfall,weather_code,precipitation_probability&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max&start_date=$startDate&end_date=$endDate&time_mode=time_interval';
}

String buildCityLocationUrl({
  required String cityName,
}) {
  return 'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$openWeatherAPIKey';
}
