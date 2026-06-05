import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';

class DetailScreen extends StatelessWidget {
  final String city;

  const DetailScreen({
    super.key,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('$city - Detalle'),
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProv, _) {
          if (weatherProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weatherProv.weather == null) {
            return const Center(child: Text('No data'));
          }
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeatherIcon(
                    condition: weatherProv.weather!.condition,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${weatherProv.weather!.temperature}${weatherProv.temperatureUnit}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weatherProv.weather!.city,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Condición: ${weatherProv.weather!.condition}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Humedad: ${weatherProv.weather!.humidity}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
