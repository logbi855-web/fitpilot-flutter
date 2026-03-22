class WeatherIconMapper {
  /// Maps OWM weather condition code to emoji + short label
  static ({String emoji, String label}) map(int code) {
    if (code >= 200 && code < 300) return (emoji: '⛈', label: 'Thunderstorm');
    if (code >= 300 && code < 400) return (emoji: '🌦', label: 'Drizzle');
    if (code >= 500 && code < 600) return (emoji: '🌧', label: 'Rain');
    if (code >= 600 && code < 700) return (emoji: '❄️', label: 'Snow');
    if (code >= 700 && code < 800) return (emoji: '🌫', label: 'Fog');
    if (code == 800) return (emoji: '☀️', label: 'Clear');
    if (code == 801) return (emoji: '🌤', label: 'Few Clouds');
    if (code == 802) return (emoji: '⛅', label: 'Partly Cloudy');
    if (code >= 803) return (emoji: '☁️', label: 'Cloudy');
    return (emoji: '🌡', label: 'Unknown');
  }

  /// Intensity recommendation based on energy + temp
  static String intensityAdvice({required String? energy, required double temp}) {
    if (energy == 'low') return 'Low intensity recommended (20–30 min)';
    if (temp >= 18) return 'High intensity ready (45–60 min)';
    return 'Medium intensity recommended (30–45 min)';
  }
}
