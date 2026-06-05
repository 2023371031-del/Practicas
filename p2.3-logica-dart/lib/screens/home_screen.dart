import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false)
          .loadWeather('Santiago');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Climate')),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProv, _) {
          if (weatherProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (weatherProv.errorMessage != null) {
            return Center(child: Text('Error: ${weatherProv.errorMessage}'));
          }
          if (weatherProv.weather == null) {
            return const Center(child: Text('No data'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${weatherProv.weather!.temperature}${weatherProv.temperatureUnit}',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weatherProv.weather!.city,
                  style: const TextStyle(fontSize: 24),
                ),
                WeatherIcon(
                  condition: weatherProv.weather!.condition,
                  size: 80,
                ),
                Text('Humidity: ${weatherProv.weather!.humidity}%'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => weatherProv.toggleTemperatureUnit(),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Cambiar unidad'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
