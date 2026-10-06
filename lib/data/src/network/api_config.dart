import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  ApiConfig._();

  static const String caloriesBaseUrl = 'https://api.api-ninjas.com/v1/';

  static String get apiNinjasKey => dotenv.maybeGet('API_NINJAS_KEY') ?? '';

  static bool get hasKey => apiNinjasKey.isNotEmpty;
}
