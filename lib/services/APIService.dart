// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  final String baseUrl; // ej: https://absolute-live-sheepdog.ngrok-free.app
  final String apiKey; // ej: rexy
  APIService({required this.baseUrl, required this.apiKey});

  Future<Map<String, dynamic>> runIngest() async {
    final uri = Uri.parse(
      "$baseUrl/ingest/run",
    ).replace(queryParameters: {"api_key": apiKey});
    final res = await http.post(uri, headers: {"accept": "application/json"});
    if (res.statusCode != 200) {
      throw Exception("Ingest ${res.statusCode}: ${res.body}");
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> fetchQueue() async {
    final uri = Uri.parse(
      "$baseUrl/queue",
    ).replace(queryParameters: {"api_key": apiKey});
    final res = await http.get(uri, headers: {"accept": "application/json"});
    print(res.request);
    if (res.statusCode != 200) {
      print(res.body);
      throw Exception("Queue ${res.statusCode}: ${res.body}");
    }
    final body = jsonDecode(res.body);
    print(body);
    if (body is Map && body["queue"] is List) {
      print("Queue items: ${body["queue"]}");
      return (body["queue"] as List).cast<Map<String, dynamic>>();
    } else if (body is List) {
      print("Queue items: $body");
      return body.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<bool> processAuto(String itemId) async {
    final uri = Uri.parse(
      "$baseUrl/process/$itemId/auto",
    ).replace(queryParameters: {"api_key": apiKey});
    final res = await http.post(uri, headers: {"accept": "application/json"});
    print(res.request);

    if (res.statusCode != 200) return false;
    final body = jsonDecode(res.body);
    return body is Map && body["ok"] == true;
  }
}
