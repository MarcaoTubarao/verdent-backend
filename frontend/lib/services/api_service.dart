import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl =
      "https://verdent-backend-production-a592.up.railway.app";

  static Future<Map<String, dynamic>> getPortfolio() async {
    final res = await http.get(Uri.parse("$baseUrl/portfolio"));
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> getAllocation() async {
    final res = await http.get(Uri.parse("$baseUrl/allocation"));
    return json.decode(res.body);
  }

  static Future<List<dynamic>> getAssets() async {
    final res = await http.get(Uri.parse("$baseUrl/assets"));
    return json.decode(res.body);
  }

  static Future<List<dynamic>> getSignals() async {
    final res = await http.get(Uri.parse("$baseUrl/signals"));
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> addAsset(String ticker) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assets/add"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"ticker": ticker}),
    );
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> deleteAsset(String ticker) async {
    final res = await http.delete(Uri.parse("$baseUrl/assets/$ticker"));
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> syncAssets() async {
    final res = await http.post(Uri.parse("$baseUrl/assets/sync"));
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> bulkAddAssets(
      List<String> tickers) async {
    final res = await http.post(
      Uri.parse("$baseUrl/assets/bulk-add"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"tickers": tickers}),
    );
    return json.decode(res.body);
  }
}
