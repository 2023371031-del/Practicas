import 'package:flutter/foundation.dart';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
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
}
