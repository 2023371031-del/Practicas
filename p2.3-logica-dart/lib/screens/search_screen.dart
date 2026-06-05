import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<String> cities = ['Santiago', 'Querétaro', 'México', 'Guadalajara'];
  List<String> filteredCities = [];

  void filterCities(String query) {
    setState(() {
      searchQuery = query;
      filteredCities = cities
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
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
              onChanged: filterCities,
              decoration: const InputDecoration(
                hintText: 'Busca una ciudad...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredCities.isEmpty
                ? const Center(
                    child: Text('No encontradas'),
                  )
                : ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredCities[index]),
                        onTap: () {
                          context
                              .read<WeatherProvider>()
                              .loadWeather(filteredCities[index]);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                city: filteredCities[index],
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
