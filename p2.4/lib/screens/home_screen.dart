import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_utils.dart';
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
        title: const Text('Clima + BLE'),
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
      children: [..._content(context), const SizedBox(height: 16), _buildBLESection(context)],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTemperatureSection(context)),
            const SizedBox(width: 32),
            Expanded(child: _buildInfoSection(context)),
          ],
        ),
        const SizedBox(height: 16),
        _buildBLESection(context),
      ],
    );
  }

  List<Widget> _content(BuildContext context) {
    return [
      _buildTemperatureSection(context),
      const SizedBox(height: 32),
      _buildInfoSection(context),
    ];
  }

  Widget _buildTemperatureSection(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    return Column(
      children: [
        Text(
          formatTemperature(weather.temp, weather.unit),
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          weather.city,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        WeatherIcon(condition: weather.condition, size: 120),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final weather = context.watch<WeatherProvider>().weather;
    return Column(
      children: [
        Text(
          'Unidad: ${weather.unit} | Condición: ${weather.condition}',
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Consumer<WeatherProvider>(
          builder: (context, wp, _) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => wp.toggleUnit(),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambiar °C/°F'),
                ),
                ElevatedButton.icon(
                  onPressed: () => wp.updateTemperature(15),
                  icon: const Icon(Icons.ac_unit),
                  label: const Text('Temp 15°'),
                ),
                ElevatedButton.icon(
                  onPressed: () => wp.updateTemperature(30),
                  icon: const Icon(Icons.whatshot),
                  label: const Text('Temp 30°'),
                ),
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
                  label: const Text('Buscar Ciudades'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBLESection(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, wp, _) {
        return Column(
          children: [
            Text(
              wp.bleStatus,
              style: TextStyle(
                fontSize: 16,
                color: wp.isConnected ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (!wp.isConnected)
              ElevatedButton.icon(
                onPressed: wp.isScanning ? null : () => wp.startScan(),
                icon: wp.isScanning
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(wp.isScanning ? 'Escaneando...' : 'Buscar dispositivos BLE'),
              ),
            if (!wp.isConnected && wp.lastDeviceId != null && !wp.isScanning)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => wp.reconnectToLastDevice(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reconectar último dispositivo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ),
            if (wp.isScanning && wp.scanResults.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: wp.scanResults.length,
                  itemBuilder: (context, index) {
                    final result = wp.scanResults[index];
                    final deviceId = result.device.remoteId.toString();
                    final advName = result.advertisementData.advName;
                    final displayName = advName.isNotEmpty ? advName : deviceId;
                    return ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(displayName),
                      subtitle: Text('$deviceId • RSSI: ${result.rssi}'),
                      trailing: wp.isConnecting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.link),
                      onTap: wp.isConnecting ? null : () => wp.connectToDevice(deviceId),
                    );
                  },
                ),
              ),
            if (wp.isConnected)
              ElevatedButton.icon(
                onPressed: () => wp.disconnectDevice(),
                icon: const Icon(Icons.bluetooth_disabled),
                label: const Text('Desconectar'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        );
      },
    );
  }
}
