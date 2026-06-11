import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/weather.dart';
import '../services/ble_service.dart';

class WeatherProvider extends ChangeNotifier {
  final BLEService _bleService = BLEService();

  Weather _weather = const Weather(
    city: 'Santiago de Querétaro',
    temp: 24,
    condition: 'cloudy',
    unit: 'C',
  );

  Weather get weather => _weather;

  final List<Map<String, String>> availableCities = [
    {'name': 'Santiago', 'temp': '24', 'condition': 'cloudy'},
    {'name': 'Querétaro', 'temp': '22', 'condition': 'sunny'},
    {'name': 'México', 'temp': '20', 'condition': 'rainy'},
    {'name': 'Monterrey', 'temp': '30', 'condition': 'sunny'},
    {'name': 'Guadalajara', 'temp': '26', 'condition': 'cloudy'},
  ];

  List<ScanResult> _scanResults = [];
  List<ScanResult> get scanResults => _scanResults;

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String _bleStatus = 'Sin conexión BLE';
  String get bleStatus => _bleStatus;

  String _bleServicesInfo = '';
  String get bleServicesInfo => _bleServicesInfo;

  String _bleReadMessage = '';
  String get bleReadMessage => _bleReadMessage;

  String? get lastDeviceId => _lastDeviceId;
  String? _lastDeviceId;
  StreamSubscription<BluetoothConnectionState>? _deviceStateSubscription;
  bool _manualDisconnect = false;
  bool _isAutoReconnecting = false;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  void startScan() {
    _scanResults = [];
    _isScanning = true;
    _bleStatus = 'Escaneando...';
    notifyListeners();

    _scanSubscription = _bleService.scanForDevices().listen((results) {
      _scanResults = results;
      notifyListeners();
    }, onError: (error) {
      _bleStatus = 'Error: $error';
      _isScanning = false;
      notifyListeners();
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (_isScanning) stopScan();
    });
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _bleService.stopScan();
    _isScanning = false;
    _bleStatus = _isConnected ? 'Conectado' : 'Sin conexión BLE';
    notifyListeners();
  }

  Future<void> connectToDevice(String deviceId) async {
    _manualDisconnect = false;
    _isConnecting = true;
    _bleStatus = 'Conectando...';
    notifyListeners();

    final success = await _bleService.connect(deviceId);
    if (success) {
      await _handleConnectionSuccess(deviceId);
    } else {
      _isConnecting = false;
      _bleStatus = 'Error de conexión';
      notifyListeners();
    }
  }

  Future<void> reconnectToLastDevice({bool auto = false}) async {
    if (_lastDeviceId == null || _isConnecting) return;

    _isAutoReconnecting = auto;
    _isConnecting = true;
    _bleStatus = auto ? 'Reconectando automáticamente...' : 'Reconectando...';
    notifyListeners();

    final success = await _bleService.reconnect();
    if (success) {
      await _handleConnectionSuccess(_lastDeviceId!);
    } else {
      _isConnecting = false;
      _bleStatus = auto ? 'Reconexión automática fallida' : 'Error de reconexión';
      _isAutoReconnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnectDevice() async {
    _manualDisconnect = true;
    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    await _bleService.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _bleStatus = 'Sin conexión BLE';
    _bleServicesInfo = '';
    _bleReadMessage = '';
    notifyListeners();
  }

  Future<String?> _readWeatherFromDevice() async {
    String? errorMessage;

    final tempStr = await _bleService.readTemperature();
    if (tempStr != null) {
      final temp = double.tryParse(tempStr);
      if (temp != null && Weather.isValidTemp(temp)) {
        _weather = _weather.copyWith(temp: temp);
      } else {
        errorMessage = 'Temperatura no válida';
      }
    } else {
      errorMessage = (errorMessage == null ? '' : '$errorMessage y ') + 'Temperatura no leída';
    }

    final city = await _bleService.readCity();
    if (city != null) {
      if (Weather.isValidCity(city)) {
        _weather = _weather.copyWith(city: city);
      } else {
        errorMessage = (errorMessage == null ? '' : '$errorMessage y ') + 'Ciudad no válida';
      }
    } else {
      errorMessage = (errorMessage == null ? '' : '$errorMessage y ') + 'Ciudad no leída';
    }

    _bleReadMessage = errorMessage ?? '';
    notifyListeners();
    return _bleReadMessage.isEmpty ? null : _bleReadMessage;
  }

  Future<void> _handleConnectionSuccess(String deviceId) async {
    _isConnected = true;
    _isConnecting = false;
    _isAutoReconnecting = false;
    _lastDeviceId = deviceId;
    _bleServicesInfo = _bleService.getServicesInfo();
    _subscribeToDeviceState();

    final readError = await _readWeatherFromDevice();
    _bleStatus = 'Conectado';
    if (readError != null) {
      _bleStatus = 'Conectado | $readError';
    }

    notifyListeners();
  }

  void _subscribeToDeviceState() {
    _deviceStateSubscription?.cancel();
    final stream = _bleService.deviceState;
    if (stream == null) return;

    _deviceStateSubscription = stream.listen((state) async {
      if (state == BluetoothConnectionState.disconnected && !_manualDisconnect) {
        _isConnected = false;
        _bleStatus = 'Se desconectó BLE';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 2));
        await reconnectToLastDevice(auto: true);
      }
    }, onError: (_) {
      // Ignorar errores de estado del dispositivo.
    });
  }

  void setWeather(Weather weather) {
    _weather = weather;
    notifyListeners();
  }

  void updateCity(String city) {
    if (!Weather.isValidCity(city)) return;
    _weather = _weather.copyWith(city: city.trim());
    notifyListeners();
  }

  void updateTemperature(double temp) {
    if (!Weather.isValidTemp(temp)) return;
    _weather = _weather.copyWith(temp: temp);
    notifyListeners();
  }

  void updateCondition(String condition) {
    _weather = _weather.copyWith(condition: condition);
    notifyListeners();
  }

  void selectCity(String name, String tempStr, String condition) {
    final temp = double.tryParse(tempStr) ?? 20;
    if (!Weather.isValidCity(name) || !Weather.isValidTemp(temp)) return;
    _weather = Weather(city: name, temp: temp, condition: condition, unit: _weather.unit);
    notifyListeners();
  }

  void toggleUnit() {
    final newUnit = _weather.unit == 'C' ? 'F' : 'C';
    final newTemp = newUnit == 'F'
        ? _weather.temp * 9 / 5 + 32
        : (_weather.temp - 32) * 5 / 9;
    _weather = Weather(
      city: _weather.city,
      temp: double.parse(newTemp.toStringAsFixed(1)),
      condition: _weather.condition,
      unit: newUnit,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _deviceStateSubscription?.cancel();
    _bleService.disconnect();
    super.dispose();
  }
}
