import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/weather_service.dart';
import '../core/storage/storage_service.dart';

class WeatherState {
  final WeatherData? current;
  final List<ForecastDay> forecast;
  final bool loading;
  final String city;

  const WeatherState({
    this.current,
    this.forecast = const [],
    this.loading = false,
    this.city = 'Sasolburg,ZA',
  });

  WeatherState copyWith({
    WeatherData? current,
    List<ForecastDay>? forecast,
    bool? loading,
    String? city,
  }) =>
      WeatherState(
        current: current ?? this.current,
        forecast: forecast ?? this.forecast,
        loading: loading ?? this.loading,
        city: city ?? this.city,
      );
}

class WeatherNotifier extends Notifier<WeatherState> {
  late final WeatherService _service;

  @override
  WeatherState build() {
    _service = WeatherService();
    final savedCity = StorageService.getString(StorageKeys.location);
    final city = savedCity ?? 'Sasolburg,ZA';
    // Kick off fetch without awaiting
    Future.microtask(() => fetch(city));
    return WeatherState(city: city);
  }

  Future<void> fetch(String city) async {
    state = state.copyWith(loading: true, city: city);
    final current = await _service.fetchCurrent(city);
    final forecast = await _service.fetchForecast(city);
    state = state.copyWith(current: current, forecast: forecast, loading: false);
  }

  Future<void> updateCity(String city) async {
    await StorageService.setString(StorageKeys.location, city);
    await fetch(city);
  }

  void resetCity() => updateCity('Sasolburg,ZA');
}

final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

// Energy level provider (persisted)
class EnergyNotifier extends Notifier<String?> {
  @override
  String? build() => StorageService.getString(StorageKeys.energy);

  Future<void> set(String? energy) async {
    state = energy;
    if (energy != null) {
      await StorageService.setString(StorageKeys.energy, energy);
    } else {
      await StorageService.remove(StorageKeys.energy);
    }
  }
}

final energyProvider = NotifierProvider<EnergyNotifier, String?>(
  EnergyNotifier.new,
);
