import 'dart:convert';
import 'package:http/http.dart' as http;

// OpenWeatherMap ücretsiz API key - https://openweathermap.org/api adresinden alın
const String _apiKey = 'OPENWEATHER_API_KEY';
const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final String description;
  final String iconCode;
  final String cityName;
  final double tempMin;
  final double tempMax;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.iconCode,
    required this.cityName,
    required this.tempMin,
    required this.tempMax,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'] as String,
      iconCode: json['weather'][0]['icon'] as String,
      cityName: json['name'] as String,
      tempMin: (json['main']['temp_min'] as num).toDouble(),
      tempMax: (json['main']['temp_max'] as num).toDouble(),
    );
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get irrigationSuggestion {
    if (temperature > 32 && humidity < 40) {
      return '🌡️ Çok sıcak ve kuru! Bugün mutlaka sulama yapın.';
    } else if (temperature > 27 && humidity < 55) {
      return '☀️ Sıcak hava, sulama önerilir.';
    } else if (humidity > 80) {
      return '💧 Nem yüksek, sulama gerekmeyebilir.';
    } else if (description.contains('yağmur') || description.contains('rain')) {
      return '☔ Yağmur bekleniyor, sulama gerekmez.';
    } else {
      return '✅ Normal sulama programınızı sürdürün.';
    }
  }
}

class WeatherForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double humidity;
  final double precipitation;
  final String iconCode;
  final String description;
  final double pop; // probability of precipitation

  WeatherForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.precipitation,
    required this.iconCode,
    required this.description,
    required this.pop,
  });

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$iconCode@2x.png';
}

class WeatherService {
  static Future<CurrentWeather> getCurrentWeather(
      double lat, double lon) async {
    final url =
        '$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=tr';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Hava durumu alınamadı: ${response.statusCode}');
  }

  static Future<List<WeatherForecast>> getForecast(
      double lat, double lon) async {
    final url =
        '$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&lang=tr';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Tahmin alınamadı: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final list = data['list'] as List<dynamic>;

    // Her 3 saatlik veriyi günlük gruplara böl
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          ((item['dt'] as int) * 1000));
      final dayKey =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dayKey, () => []);
      grouped[dayKey]!.add(item as Map<String, dynamic>);
    }

    final forecasts = <WeatherForecast>[];
    final sortedKeys = grouped.keys.toList()..sort();

    for (final key in sortedKeys.take(7)) {
      final dayData = grouped[key]!;
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      double totalHumidity = 0;
      double totalPrecipitation = 0;
      double maxPop = 0;
      String iconCode = dayData[0]['weather'][0]['icon'] as String;
      String description = dayData[0]['weather'][0]['description'] as String;

      for (final item in dayData) {
        final temp = (item['main']['temp'] as num).toDouble();
        final humidity = (item['main']['humidity'] as num).toDouble();
        final pop = (item['pop'] as num? ?? 0).toDouble();
        final rain =
            (item['rain']?['3h'] as num? ?? 0).toDouble();

        if (temp < minTemp) minTemp = temp;
        if (temp > maxTemp) maxTemp = temp;
        totalHumidity += humidity;
        totalPrecipitation += rain;
        if (pop > maxPop) {
          maxPop = pop;
          iconCode = item['weather'][0]['icon'] as String;
          description = item['weather'][0]['description'] as String;
        }
      }

      final dateParts = key.split('-');
      forecasts.add(WeatherForecast(
        date: DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]),
            int.parse(dateParts[2])),
        minTemp: minTemp,
        maxTemp: maxTemp,
        humidity: totalHumidity / dayData.length,
        precipitation: totalPrecipitation,
        iconCode: iconCode,
        description: description,
        pop: maxPop,
      ));
    }

    return forecasts;
  }
}
