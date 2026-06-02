import 'package:flutter/material.dart';
import '../widgets/weather_icon.dart';
import 'search_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLandscape = width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima Actual'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isLandscape
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _content(context),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: _buildTemperatureSection()),
        const SizedBox(width: 32),
        Expanded(child: _buildInfoSection(context)),
      ],
    );
  }

  List<Widget> _content(BuildContext context) {
    return [
      _buildTemperatureSection(),
      const SizedBox(height: 32),
      _buildInfoSection(context),
    ];
  }

  Widget _buildTemperatureSection() {
    return const Column(
      children: [
        Text(
          '24°C',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Santiago de Querétaro',
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        WeatherIcon(condition: 'cloudy', size: 120),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Humedad: 65% | Viento: 12 km/h',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
          child: const Text('Buscar Ciudades'),
        ),
      ],
    );
  }
}
