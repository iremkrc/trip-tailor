import 'dart:convert';

import 'package:project/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:project/model/city_location_model.dart';

class CityLocationService {
  Future<List<double>> getCityLocation(String cityName) async {
    final response = await http.get(Uri.parse(buildCityLocationUrl(
      cityName: cityName,
    )));

    if (response.statusCode == 200) {
      var jsonList = jsonDecode(response.body) as List;
      if (jsonList.isNotEmpty) {
        CityLocationModel cityResponse =
            CityLocationModel.fromJson(jsonList.first);
        return [cityResponse.lat!, cityResponse.lon!];
      } else {
        throw Exception('City not found');
      }
    } else {
      throw Exception('Failed to load city data');
    }
  }
}
