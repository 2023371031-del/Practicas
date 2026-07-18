import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const BleWearableApp());

class BleWearableApp extends StatelessWidget {
  const BleWearableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Wearable Link',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const BleInspectorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BleInspectorScreen extends StatefulWidget {
  const BleInspectorScreen({super.key});

  @override
  State<BleInspectorScreen> createState() => _BleInspectorScreenState();
}

class _BleInspectorScreenState extends State<BleInspectorScreen> {
  List<ScanResult> _scanResults = [];
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _discoveredServices = [];
  bool _isScanning = false;

  final String _batteryServiceUuid = "180f";
  final String _batteryCharUuid = "2a19";
  final String _heartRateServiceUuid = "180d";
  final String _heartRateCharUuid = "2a37";

  final Map<String, String> _serviceNames = {
    "180f": "Battery Service",
    "180d": "Heart Rate Service",
    "180a": "Device Information",
    "181a": "Environmental Sensing",
  };

  final Map<String, String> _charNames = {
    "2a19": "Battery Level",
    "2a37": "Heart Rate Measurement",
    "2a38": "Body Sensor Location",
    "2a39": "Heart Rate Control Point",
    "2a24": "Model Number",
    "2a25": "Serial Number",
    "2a26": "Firmware Revision",
    "2a27": "Hardware Revision",
    "2a28": "Software Revision",
    "2a29": "Manufacturer Name",
  };

  String _displayName(String uuid, Map<String, String> names, bool isService) {
    final key = uuid.toLowerCase().replaceAll("-", "");
    for (final entry in names.entries) {
      if (key.contains(entry.key)) return "${entry.value}\n$uuid";
    }
    final clean = key.replaceAll("0000", "").replaceAll("-", "");
    if (clean.length <= 4) return "Unknown ${isService ? "Service" : "Characteristic"}\n$uuid";
    return "Custom ${isService ? "Service" : "Characteristic"}\n$uuid";
  }

  @override
  void initState() {
    super.initState();
    _initBluetoothCheck();
  }

  void _initBluetoothCheck() {
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.off) {
        _showStatusBanner(
            "El Bluetooth está apagado. Por favor, actívalo.", Colors.orange);
      }
    });
  }

  void _startScan() async {
    setState(() {
      _scanResults.clear();
      _isScanning = true;
    });
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 7));
      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            _scanResults =
                results.where((r) => r.device.platformName.isNotEmpty).toList();
          });
        }
      });
      await FlutterBluePlus.isScanning
          .where((scanning) => scanning == false)
          .first;

      if (mounted) setState(() => _isScanning = false);
    } catch (e) {
      _showStatusBanner("Error al iniciar escaneo: $e", Colors.red);
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    _showStatusBanner(
        "Conectando a ${device.platformName}...", Colors.grey.shade700);
    try {
      await device.connect(
          autoConnect: false, license: License.nonprofit);
      setState(() {
        _connectedDevice = device;
      });
      _showStatusBanner("Conexión Exitosa!", Colors.green);
      _discoverServices(device);
    } catch (e) {
      _showStatusBanner("Error de conexión: $e", Colors.red);
    }
  }

  void _discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      setState(() {
        _discoveredServices = services;
      });
      _showStatusBanner(
          "Estructura interna mapeada correctamente.", Colors.teal);
    } catch (e) {
      _showStatusBanner("Error al mapear servicios: $e", Colors.red);
    }
  }

  void _subscribeToData(BluetoothService service) async {
    String sUuid = service.uuid.toString().toLowerCase();
    for (BluetoothCharacteristic char in service.characteristics) {
      String cUuid = char.uuid.toString().toLowerCase();

      if (sUuid.contains(_batteryServiceUuid) &&
          cUuid.contains(_batteryCharUuid)) {
        try {
          List<int> rawValue = await char.read();
          if (rawValue.isNotEmpty) {
            int nivelBateria = rawValue[0];
            _showStatusBanner(
                "Nivel de Batería del Wearable: $nivelBateria%", Colors.indigo);
          }
        } catch (e) {
          _showStatusBanner(
              "No se pudo leer la batería directamente: $e", Colors.red);
        }
      }

      if (sUuid.contains(_heartRateServiceUuid) &&
          cUuid.contains(_heartRateCharUuid)) {
        try {
          await char.setNotifyValue(true);
          char.lastValueStream.listen((value) {
            if (value.isNotEmpty && value.length > 1) {
              int bpm = value[1];
              _showStatusBanner(
                  "Frecuencia Cardíaca: $bpm BPM", Colors.redAccent);
            }
          });
          _showStatusBanner("Suscrito a los sensores de pulso.", Colors.green);
        } catch (e) {
          _showStatusBanner(
              "Sensor bloqueado o protegido por el fabricante.", Colors.orange);
        }
      }
    }
  }

  void _disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      setState(() {
        _connectedDevice = null;
        _discoveredServices.clear();
      });
      _showStatusBanner("Dispositivo desconectado.", Colors.blueGrey);
    }
  }

  void _showStatusBanner(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _connectedDevice == null ? 'Escáner BLE' : 'Panel del Wearable'),
        backgroundColor: Colors.teal.shade100,
        actions: [
          if (_connectedDevice != null)
            IconButton(
                icon: const Icon(Icons.power_settings_new, color: Colors.red),
                onPressed: _disconnect)
        ],
      ),
      body: _connectedDevice == null
          ? _buildScanView()
          : _buildDevicePanelView(),
      floatingActionButton: _connectedDevice == null
          ? FloatingActionButton(
              onPressed: _isScanning ? null : _startScan,
              backgroundColor: Colors.teal,
              child: Icon(
                  _isScanning ? Icons.refresh : Icons.search,
                  color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildScanView() {
    if (_scanResults.isEmpty) {
      return const Center(
          child: Text(
              "Presiona buscar para localizar tu Redmi Watch 3 Active."));
    }
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final device = _scanResults[index].device;
        return ListTile(
          leading: const Icon(Icons.watch),
          title: Text(device.platformName),
          subtitle: Text(device.remoteId.toString()),
          trailing: ElevatedButton(
            onPressed: () => _connectToDevice(device),
            child: const Text("Conectar"),
          ),
        );
      },
    );
  }

  Widget _buildDevicePanelView() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.teal.shade50,
          child: Text(
            "Conectado a: ${_connectedDevice!.platformName}\nMAC/ID: ${_connectedDevice!.remoteId}",
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Servicios y UUIDs Disponibles:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _discoveredServices.length,
            itemBuilder: (context, index) {
              final service = _discoveredServices[index];
              final uuidStr = service.uuid.toString().toLowerCase();
              bool isInteractive =
                  uuidStr.contains(_batteryServiceUuid) ||
                  uuidStr.contains(_heartRateServiceUuid);
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ExpansionTile(
                  title: Text(
                      _displayName(service.uuid.toString(), _serviceNames, true),
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("UUID: ${service.uuid}"),
                  trailing: isInteractive
                      ? IconButton(
                          icon: const Icon(Icons.play_circle_filled,
                              color: Colors.teal),
                          onPressed: () => _subscribeToData(service),
                        )
                      : null,
                  children: service.characteristics.map((char) {
                    return ListTile(
                      title: Text(
                          _displayName(char.uuid.toString(), _charNames, false),
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                          "UUID: ${char.uuid} | Read: ${char.properties.read} | Write: ${char.properties.write} | Notify: ${char.properties.notify}",
                          style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
