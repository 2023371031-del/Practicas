import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_icon.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late List<Map<String, String>> _filtered;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WeatherProvider>();
    _filtered = List.from(provider.availableCities);
  }

  void _filterCities(String query) {
    final provider = context.read<WeatherProvider>();
    setState(() {
      _filtered = provider.availableCities
          .where((c) =>
              c['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Ciudades')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filterCities,
              decoration: const InputDecoration(
                hintText: 'Busca una ciudad...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final city = _filtered[index];
                return ListTile(
                  leading: WeatherIcon(
                    condition: city['condition']!,
                    size: 40,
                  ),
                  title: Text(city['name']!),
                  subtitle: Text('${city['temp']}°C'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.read<WeatherProvider>().selectCity(
                      city['name']!,
                      city['temp']!,
                      city['condition']!,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          city: city['name']!,
                          condition: city['condition']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
