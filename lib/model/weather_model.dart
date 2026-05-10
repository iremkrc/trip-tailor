class WeatherModel {
  double? latitude;
  double? longitude;
  double? generationtimeMs;
  int? utcOffsetSeconds;
  String? timezone;
  String? timezoneAbbreviation;
  double? elevation;
  HourlyUnits? hourlyUnits;
  Hourly? hourly;
  DailyUnits? dailyUnits;
  Daily? daily;

  WeatherModel(
      {this.latitude,
      this.longitude,
      this.generationtimeMs,
      this.utcOffsetSeconds,
      this.timezone,
      this.timezoneAbbreviation,
      this.elevation,
      this.hourlyUnits,
      this.hourly,
      this.dailyUnits,
      this.daily});

  WeatherModel.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    generationtimeMs = json['generationtime_ms'];
    utcOffsetSeconds = json['utc_offset_seconds'];
    timezone = json['timezone'];
    timezoneAbbreviation = json['timezone_abbreviation'];
    elevation = json['elevation'];
    hourlyUnits = json['hourly_units'] != null
        ? HourlyUnits.fromJson(json['hourly_units'])
        : null;
    hourly = json['hourly'] != null ? Hourly.fromJson(json['hourly']) : null;
    dailyUnits = json['daily_units'] != null
        ? DailyUnits.fromJson(json['daily_units'])
        : null;
    daily = json['daily'] != null ? Daily.fromJson(json['daily']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['generationtime_ms'] = generationtimeMs;
    data['utc_offset_seconds'] = utcOffsetSeconds;
    data['timezone'] = timezone;
    data['timezone_abbreviation'] = timezoneAbbreviation;
    data['elevation'] = elevation;
    if (hourlyUnits != null) {
      data['hourly_units'] = hourlyUnits!.toJson();
    }
    if (hourly != null) {
      data['hourly'] = hourly!.toJson();
    }
    if (dailyUnits != null) {
      data['daily_units'] = dailyUnits!.toJson();
    }
    if (daily != null) {
      data['daily'] = daily!.toJson();
    }
    return data;
  }
}

class HourlyUnits {
  String? time;
  String? temperature2m;
  String? cloudCover;
  String? rain;
  String? snowfall;
  String? weatherCode;
  String? precipitationProbability;

  HourlyUnits(
      {this.time,
      this.temperature2m,
      this.cloudCover,
      this.rain,
      this.snowfall,
      this.weatherCode,
      this.precipitationProbability});

  HourlyUnits.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    temperature2m = json['temperature_2m'];
    cloudCover = json['cloud_cover'];
    rain = json['rain'];
    snowfall = json['snowfall'];
    weatherCode = json['weather_code'];
    precipitationProbability = json['precipitation_probability'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['temperature_2m'] = temperature2m;
    data['cloud_cover'] = cloudCover;
    data['rain'] = rain;
    data['snowfall'] = snowfall;
    data['weather_code'] = weatherCode;
    data['precipitation_probability'] = precipitationProbability;
    return data;
  }
}

class Hourly {
  List<String>? time;
  List<double>? temperature2m;
  List<int>? cloudCover;
  List<double>? rain;
  List<int>? snowfall;
  List<int>? weatherCode;
  List<int>? precipitationProbability;

  Hourly(
      {this.time,
      this.temperature2m,
      this.cloudCover,
      this.rain,
      this.snowfall,
      this.weatherCode,
      this.precipitationProbability});

  Hourly.fromJson(Map<String, dynamic> json) {
    time = json['time'].cast<String>();
    temperature2m = json['temperature_2m'].cast<double>();
    cloudCover = json['cloud_cover'].cast<int>();
    rain = json['rain'].cast<double>();
    snowfall = json['snowfall'].cast<int>();
    weatherCode = json['weather_code'].cast<int>();
    precipitationProbability = json['precipitation_probability'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['temperature_2m'] = temperature2m;
    data['cloud_cover'] = cloudCover;
    data['rain'] = rain;
    data['snowfall'] = snowfall;
    data['weather_code'] = weatherCode;
    data['precipitation_probability'] = precipitationProbability;
    return data;
  }
}

class DailyUnits {
  String? time;
  String? weatherCode;
  String? temperature2mMax;
  String? temperature2mMin;
  String? precipitationSum;
  String? precipitationProbabilityMax;

  DailyUnits(
      {this.time,
      this.weatherCode,
      this.temperature2mMax,
      this.temperature2mMin,
      this.precipitationSum,
      this.precipitationProbabilityMax});

  DailyUnits.fromJson(Map<String, dynamic> json) {
    time = json['time'];
    weatherCode = json['weather_code'];
    temperature2mMax = json['temperature_2m_max'];
    temperature2mMin = json['temperature_2m_min'];
    precipitationSum = json['precipitation_sum'];
    precipitationProbabilityMax = json['precipitation_probability_max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['weather_code'] = weatherCode;
    data['temperature_2m_max'] = temperature2mMax;
    data['temperature_2m_min'] = temperature2mMin;
    data['precipitation_sum'] = precipitationSum;
    data['precipitation_probability_max'] = precipitationProbabilityMax;
    return data;
  }
}

class Daily {
  List<String>? time;
  List<int>? weatherCode;
  List<double>? temperature2mMax;
  List<double>? temperature2mMin;
  List<double>? precipitationSum;
  List<int>? precipitationProbabilityMax;

  Daily(
      {this.time,
      this.weatherCode,
      this.temperature2mMax,
      this.temperature2mMin,
      this.precipitationSum,
      this.precipitationProbabilityMax});

  Daily.fromJson(Map<String, dynamic> json) {
    time = json['time'].cast<String>();
    weatherCode = json['weather_code'].cast<int>();
    temperature2mMax = json['temperature_2m_max'].cast<double>();
    temperature2mMin = json['temperature_2m_min'].cast<double>();
    precipitationSum = json['precipitation_sum'].cast<double>();
    precipitationProbabilityMax =
        json['precipitation_probability_max'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['time'] = time;
    data['weather_code'] = weatherCode;
    data['temperature_2m_max'] = temperature2mMax;
    data['temperature_2m_min'] = temperature2mMin;
    data['precipitation_sum'] = precipitationSum;
    data['precipitation_probability_max'] = precipitationProbabilityMax;
    return data;
  }
}
