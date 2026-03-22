import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/weather_provider.dart';
import '../../utils/weather_icon_mapper.dart';

class WeatherTab extends ConsumerStatefulWidget {
  const WeatherTab({super.key});

  @override
  ConsumerState<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends ConsumerState<WeatherTab> {
  late final TextEditingController _cityCtrl;

  @override
  void initState() {
    super.initState();
    _cityCtrl = TextEditingController(
      text: ref.read(weatherProvider).city,
    );
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    final energy = ref.watch(energyProvider);
    final current = weather.current;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current weather card
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: weather.loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        Text(
                          current != null
                              ? WeatherIconMapper.map(current.weatherId).emoji
                              : '🌡',
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          current != null
                              ? '${current.temp.round()}°C'
                              : '--',
                          style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 36,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          current?.description ?? '',
                          style: const TextStyle(
                              color: AppColors.muted, fontSize: 14),
                        ),
                        Text(
                          weather.city,
                          style: const TextStyle(
                              color: AppColors.muted2, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        if (current != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              WeatherIconMapper.intensityAdvice(
                                  energy: energy, temp: current.temp),
                              style: const TextStyle(
                                  color: AppColors.primary, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // 5-day forecast
          if (weather.forecast.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weather.forecast.length,
                itemBuilder: (context, i) {
                  final day = weather.forecast[i];
                  final icon = WeatherIconMapper.map(day.weatherId).emoji;
                  final dayLabel = _dayLabel(day.date);
                  return Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(dayLabel,
                            style: const TextStyle(
                                color: AppColors.muted, fontSize: 11)),
                        Text(icon, style: const TextStyle(fontSize: 22)),
                        Text('${day.temp.round()}°',
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // Energy level
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Energy Level',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _EnergyButton(
                          label: 'High',
                          value: 'high',
                          selected: energy == 'high'),
                      const SizedBox(width: 12),
                      _EnergyButton(
                          label: 'Low',
                          value: 'low',
                          selected: energy == 'low'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location input
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location',
                      style: TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cityCtrl,
                    style: const TextStyle(color: AppColors.text),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Sasolburg,ZA',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => ref
                            .read(weatherProvider.notifier)
                            .updateCity(_cityCtrl.text.trim()),
                        child: const Text('Update'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          _cityCtrl.text = 'Sasolburg,ZA';
                          ref.read(weatherProvider.notifier).resetCity();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

class _EnergyButton extends ConsumerWidget {
  final String label;
  final String value;
  final bool selected;

  const _EnergyButton({
    required this.label,
    required this.value,
    required this.selected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? AppColors.primary : AppColors.card2,
        foregroundColor: selected ? AppColors.bg : AppColors.text,
      ),
      onPressed: () =>
          ref.read(energyProvider.notifier).set(selected ? null : value),
      child: Text(label),
    );
  }
}
