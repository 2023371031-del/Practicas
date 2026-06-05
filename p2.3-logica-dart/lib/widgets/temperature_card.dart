import 'package:flutter/material.dart';
import 'weather_icon.dart';

class TemperatureCard extends StatelessWidget {
  final String temperature;
  final String city;
  final String condition;

  const TemperatureCard({
    super.key,
    required this.temperature,
    required this.city,
    this.condition = 'cloudy',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              temperature,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              city,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            WeatherIcon(condition: condition, size: 80),
          ],
        ),
      ),
    );
  }
}
