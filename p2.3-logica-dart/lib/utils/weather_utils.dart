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

class WeatherUtils {
  // Convierte Celsius a Fahrenheit
  static double celsiusToFahrenheit(int celsius) {
    return (celsius * 9 / 5) + 32;
  }

  // Convierte Fahrenheit a Celsius
  static int fahrenheitToCelsius(double fahrenheit) {
    return ((fahrenheit - 32) * 5 / 9).toInt();
  }

  // Obtiene ícono según condición
  static String getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return '☀️';
      case 'cloudy':
        return '☁️';
      case 'rainy':
        return '🌧️';
      case 'snowy':
        return '❄️';
      default:
        return '🌤️';
    }
  }

  // Valida temperatura (está en rango válido)
  static bool isValidTemperature(int temp) {
    return temp >= -50 && temp <= 60;
  }
}
