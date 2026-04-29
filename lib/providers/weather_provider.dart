import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  WeatherStatus _status = WeatherStatus.initial;
  CurrentWeather? _currentWeather;
  List<WeatherForecast> _forecast = [];
  String _errorMessage = '';
  double _lat = 39.9208; // Varsayılan: Ankara
  double _lon = 32.8541;

  WeatherStatus get status => _status;
  CurrentWeather? get currentWeather => _currentWeather;
  List<WeatherForecast> get forecast => _forecast;
  String get errorMessage => _errorMessage;
  double get lat => _lat;
  double get lon => _lon;

  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      // GPS konumunu al
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        _lat = position.latitude;
        _lon = position.longitude;
      }

      // Paralel API çağrıları
      final results = await Future.wait([
        WeatherService.getCurrentWeather(_lat, _lon),
        WeatherService.getForecast(_lat, _lon),
      ]);

      _currentWeather = results[0] as CurrentWeather;
      _forecast = results[1] as List<WeatherForecast>;
      _status = WeatherStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }

  void updateLocation(double lat, double lon) {
    _lat = lat;
    _lon = lon;
    loadWeather();
  }
}
