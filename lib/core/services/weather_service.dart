import 'package:dio/dio.dart';

const _apiKey = 'c46ebbd261fd17b75909a3d88c68d515';
const _baseUrl = 'https://api.openweathermap.org/data/2.5';

class WeatherData {
  final String cityName;
  final double temp;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final int weatherId;
  final String main;
  final String description;
  final String icon;

  const WeatherData({
    required this.cityName,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.weatherId,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final mainData = json['main'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    return WeatherData(
      cityName: json['name'] as String,
      temp: (mainData['temp'] as num).toDouble(),
      feelsLike: (mainData['feels_like'] as num).toDouble(),
      humidity: mainData['humidity'] as int,
      pressure: mainData['pressure'] as int,
      weatherId: weather['id'] as int,
      main: weather['main'] as String,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
    );
  }

  // Fallback when API is unavailable
  static const fallback = WeatherData(
    cityName: 'Unknown',
    temp: 22,
    feelsLike: 22,
    humidity: 50,
    pressure: 1013,
    weatherId: 800,
    main: 'Clear',
    description: 'clear sky',
    icon: '01d',
  );
}

class ForecastDay {
  final DateTime date;
  final double temp;
  final int weatherId;
  final String description;

  const ForecastDay({
    required this.date,
    required this.temp,
    required this.weatherId,
    required this.description,
  });
}

class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  Future<WeatherData> fetchCurrent(String city) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': city,
          'units': 'metric',
          'appid': _apiKey,
        },
      );
      return WeatherData.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return WeatherData.fallback;
    }
  }

  /// Returns up to 5 forecast days (one reading per day, 11:00–15:00 window).
  Future<List<ForecastDay>> fetchForecast(String city) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'q': city,
          'units': 'metric',
          'cnt': 40,
          'appid': _apiKey,
        },
      );

      final list = (response.data['list'] as List).cast<Map<String, dynamic>>();
      final today = DateTime.now();
      final Map<String, ForecastDay> byDay = {};

      for (final item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
        if (dt.day == today.day) continue; // skip today
        if (dt.hour < 11 || dt.hour > 15) continue;
        final key = '${dt.year}-${dt.month}-${dt.day}';
        if (!byDay.containsKey(key)) {
          final weather = (item['weather'] as List).first as Map<String, dynamic>;
          byDay[key] = ForecastDay(
            date: dt,
            temp: (item['main']['temp'] as num).toDouble(),
            weatherId: weather['id'] as int,
            description: weather['description'] as String,
          );
        }
      }

      return byDay.values.take(5).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (_) {
      return [];
    }
  }
}
