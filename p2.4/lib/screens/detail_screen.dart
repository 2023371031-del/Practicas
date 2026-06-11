import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
import '../widgets/weather_icon.dart';

class DetailScreen extends StatelessWidget {
  final String city;
  final String condition;

  const DetailScreen({
    super.key,
    required this.city,
    this.condition = 'cloudy',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;
    final weather = context.watch<WeatherProvider>().weather;

    return Scaffold(
      appBar: AppBar(
        title: Text('$city - 5 Días'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              WeatherIcon(condition: condition, size: 80),
              const SizedBox(height: 8),
              Text(
                formatTemperature(weather.temp, weather.unit),
                style: const TextStyle(fontSize: 32, color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (isLandscape)
                _buildLandscapeForecast()
              else
                _buildPortraitForecast(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitForecast() {
    return Column(
      children: _forecastDays().map((day) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Text(
              day['day']!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              day['temp']!,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLandscapeForecast() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _forecastDays().map((day) {
        return Column(
          children: [
            Text(
              day['day']!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day['temp']!,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Map<String, String>> _forecastDays() {
    return [
      {'day': 'Lun', 'temp': '24°C'},
      {'day': 'Mar', 'temp': '26°C'},
      {'day': 'Mié', 'temp': '20°C'},
      {'day': 'Jue', 'temp': '25°C'},
      {'day': 'Vie', 'temp': '28°C'},
    ];
  }
}
