import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import '../ble_constants.dart';
import '../models/activity_data.dart';

class BleClient {
  final _dataCtrl = StreamController<ActivityData>.broadcast();
  Stream<ActivityData> get dataStream => _dataCtrl.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  ActivityData _current = ActivityData(
    steps: 0,
    heartRate: 72,
    calories: 0,
    status: 'reposo',
    timestamp: DateTime.now(),
  );

  // Estado interno del simulador (replica el SensorSimulator del wearable)
  final _random = Random();
  Timer? _simTimer;
  int _simSteps = 0;
  double _simCalories = 0;
  int _simHeartRate = 72;
  String _simStatus = 'reposo';
  int _simTick = 0;

  // Escaneo simulado: espera 2 s como si buscara el wearable, luego conecta
  Future<void> scanAndConnect() async {
    print('[BleClient] Iniciando escaneo...');
    await Future.delayed(const Duration(seconds: 2));

    _connected = true;
    print('[BleClient] Conectado al wearable (simulado para emulador)');

    _startSimulation();
  }

  // Genera datos con el mismo algoritmo que el SensorSimulator del wearable
  // y los pasa por _handleValue como si llegaran via BLE NOTIFY.
  void _startSimulation() {
    _simTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _simTick++;

      if (_simTick % 30 == 0) {
        const activities = ['reposo', 'caminando', 'corriendo'];
        _simStatus = activities[_random.nextInt(activities.length)];
      }

      switch (_simStatus) {
        case 'caminando':
          _simSteps += _random.nextInt(2) + 1;
          break;
        case 'corriendo':
          _simSteps += _random.nextInt(4) + 3;
          break;
        default:
          break;
      }

      final target = _simStatus == 'corriendo'
          ? 145
          : _simStatus == 'caminando'
              ? 95
              : 72;
      _simHeartRate += (_random.nextInt(7) - 3);
      _simHeartRate = _simHeartRate.clamp(target - 10, target + 10);
      _simCalories += _simSteps * 0.00004;

      // Pasar los datos por el mismo canal que usaria BLE real
      _handleValue(BleConstants.stepsUUID.toLowerCase(),
          _intToBytes(_simSteps));
      _handleValue(BleConstants.heartRateUUID.toLowerCase(),
          [_simHeartRate]);
      _handleValue(BleConstants.caloriesUUID.toLowerCase(),
          _int16ToBytes(_simCalories.toInt()));
      _handleValue(BleConstants.statusUUID.toLowerCase(),
          utf8.encode(_simStatus));
    });
  }

  List<int> _intToBytes(int value) {
    final data = ByteData(4);
    data.setInt32(0, value, Endian.little);
    return data.buffer.asUint8List().toList();
  }

  List<int> _int16ToBytes(int value) {
    final data = ByteData(2);
    data.setInt16(0, value, Endian.little);
    return data.buffer.asUint8List().toList();
  }

  void _handleValue(String uuid, List<int> bytes) {
    if (bytes.isEmpty) return;
    try {
      if (uuid == BleConstants.stepsUUID.toLowerCase()) {
        final bd = ByteData.sublistView(Uint8List.fromList(bytes));
        _current = _current.copyWith(steps: bd.getInt32(0, Endian.little));
      } else if (uuid == BleConstants.heartRateUUID.toLowerCase()) {
        _current = _current.copyWith(heartRate: bytes[0]);
      } else if (uuid == BleConstants.caloriesUUID.toLowerCase()) {
        final bd = ByteData.sublistView(Uint8List.fromList(bytes));
        _current = _current.copyWith(calories: bd.getInt16(0, Endian.little));
      } else if (uuid == BleConstants.statusUUID.toLowerCase()) {
        _current = _current.copyWith(status: utf8.decode(bytes));
      }
      _dataCtrl.add(_current);
    } catch (e) {
      print('[BleClient] Error parseando $uuid: $e');
    }
  }

  Future<void> disconnect() async {
    _simTimer?.cancel();
    _simTimer = null;
    _connected = false;
  }

  void dispose() {
    _simTimer?.cancel();
    _dataCtrl.close();
  }
}
