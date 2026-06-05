class Weather {
  final String city;
  final double temp;
  final String condition;
  final String unit;

  const Weather({
    required this.city,
    required this.temp,
    required this.condition,
    this.unit = 'C',
  });

  Weather copyWith({
    String? city,
    double? temp,
    String? condition,
    String? unit,
  }) {
    return Weather(
      city: city ?? this.city,
      temp: temp ?? this.temp,
      condition: condition ?? this.condition,
      unit: unit ?? this.unit,
    );
  }

  static bool isValidCity(String city) => city.trim().isNotEmpty;

  static bool isValidTemp(double temp) => temp >= -60 && temp <= 60;
}
