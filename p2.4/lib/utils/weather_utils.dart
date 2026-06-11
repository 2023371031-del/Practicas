import 'package:flutter/material.dart';

String formatTemperature(double temp, String unit) {
  return '${temp.toInt()}°$unit';
}

IconData getWeatherIcon(String condition) {
  switch (condition.toLowerCase()) {
    case 'sunny':
      return Icons.sunny;
    case 'rainy':
      return Icons.water_drop;
    case 'cloudy':
      return Icons.cloud;
    case 'stormy':
      return Icons.thunderstorm;
    case 'snowy':
      return Icons.ac_unit;
    default:
      return Icons.cloud;
  }
}
