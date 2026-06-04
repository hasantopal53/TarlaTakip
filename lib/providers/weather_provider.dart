import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';
import '../models/field_model.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  WeatherStatus _status = WeatherStatus.initial;
  CurrentWeather? _currentWeather;
  List<WeatherForecast> _forecast = [];
  Map<String, CurrentWeather> _fieldWeather = {}; // FieldId -> Weather
  String _errorMessage = '';
  double _lat = 39.9208; // Varsayılan: Ankara
  double _lon = 32.8541;
  String? _selectedFieldId;
  String? _homeFieldName;
  bool _loadInProgress = false;

  WeatherStatus get status => _status;
  CurrentWeather? get currentWeather => _currentWeather;
  List<WeatherForecast> get forecast => _forecast;
  Map<String, CurrentWeather> get fieldWeather => _fieldWeather;
  String get errorMessage => _errorMessage;
  double get lat => _lat;
  double get lon => _lon;
  String? get selectedFieldId => _selectedFieldId;
  /// Ana sayfa kartında gösterilen tarla adı (GPS yerine tarla konumu).
  String? get homeFieldName => _homeFieldName;

  /// Koordinatsız tarla / tarla yokken varsayılan (Fethiye civarı).
  static const double _defaultLat = 36.6526;
  static const double _defaultLon = 29.1264;

  /// Ana sayfa: seçili veya ilk koordinatlı tarlanın havası; yoksa Fethiye civarı.
  Future<void> loadWeatherForHome(List<Field> fields) async {
    if (_loadInProgress) return;
    _loadInProgress = true;
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      Field? target = _findSelectedField(fields);
      target ??= _firstFieldWithCoords(fields);
      target ??= fields.isNotEmpty ? fields.first : null;

      _applyFieldCoords(target);
      await _fetchWeatherByCoords(_lat, _lon);
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherStatus.error;
    } finally {
      _loadInProgress = false;
    }

    notifyListeners();
  }

  /// Ana sayfa kartından tarla seçildiğinde.
  Future<void> selectHomeField(Field field) async {
    _loadInProgress = false;
    _selectedFieldId = field.id;
    _homeFieldName = field.name;
    _applyFieldCoords(field);
    await loadWeatherForHome([field]);
  }

  Field? _findSelectedField(List<Field> fields) {
    if (_selectedFieldId == null) return null;
    for (final field in fields) {
      if (field.id == _selectedFieldId) return field;
    }
    return null;
  }

  Field? _firstFieldWithCoords(List<Field> fields) {
    for (final field in fields) {
      if (field.latitude != 0 || field.longitude != 0) return field;
    }
    return null;
  }

  void _applyFieldCoords(Field? field) {
    if (field != null &&
        (field.latitude != 0 || field.longitude != 0)) {
      _selectedFieldId = field.id;
      _homeFieldName = field.name;
      _lat = field.latitude;
      _lon = field.longitude;
    } else if (field != null) {
      _selectedFieldId = field.id;
      _homeFieldName = field.name;
      _lat = _defaultLat;
      _lon = _defaultLon;
    } else {
      _selectedFieldId = null;
      _homeFieldName = null;
      _lat = _defaultLat;
      _lon = _defaultLon;
    }
  }

  /// GPS kullanmaz; seçili koordinatlardan yeniler.
  Future<void> loadWeather() async {
    _status = WeatherStatus.loading;
    notifyListeners();
    try {
      await _fetchWeatherByCoords(_lat, _lon);
    } catch (e) {
      _errorMessage = e.toString();
      _status = WeatherStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadWeatherForFields(List<Field> fields) async {
    if (fields.isEmpty) return;
    
    // Sadece koordinatı olan tarlalar için hava durumu çek
    for (var field in fields) {
      if (field.latitude != 0 && field.longitude != 0) {
        try {
          final weather = await WeatherService.getCurrentWeather(field.latitude, field.longitude);
          _fieldWeather[field.id] = weather;
        } catch (e) {
          debugPrint('Tarla hava durumu alınamadı (${field.name}): $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> selectFieldWeather(Field field) async {
    await selectHomeField(field);
  }

  Future<void> loadWeatherByCity(String city) async {
    _status = WeatherStatus.loading;
    notifyListeners();

    try {
      final current = await WeatherService.getWeatherByCity(city);
      _currentWeather = current;
      if (current.lat != null && current.lon != null) {
        _lat = current.lat!;
        _lon = current.lon!;
      }

      _forecast = await WeatherService.getForecast(_lat, _lon);
      _status = WeatherStatus.loaded;
    } catch (e) {
      _errorMessage = 'Şehir bulunamadı veya bir hata oluştu.';
      _status = WeatherStatus.error;
    }

    notifyListeners();
  }

  Future<void> _fetchWeatherByCoords(double lat, double lon) async {
    _currentWeather =
        await WeatherService.getCurrentWeather(lat, lon);
    try {
      _forecast = await WeatherService.getForecast(lat, lon);
    } catch (e) {
      debugPrint('Tahmin alınamadı: $e');
      _forecast = [];
    }
    _status = WeatherStatus.loaded;
    _errorMessage = '';
  }

  void updateLocation(double lat, double lon) {
    _lat = lat;
    _lon = lon;
    loadWeather();
  }
}
