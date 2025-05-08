import 'dart:convert';
import 'package:http/http.dart' as http;
import 'maintenance_record.dart';

class ApiService {
// For Android emulator only
// static const String baseUrl = "http://10.0.2.2:5047/api/maintenance";

// For Flutter Web (Chrome):
  static const String baseUrl = "http://localhost:5047/api/maintenance";


  static Future<List<MaintenanceRecord>> fetchRecords() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MaintenanceRecord.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load maintenance records");
    }
  }

  static Future<void> addRecord(MaintenanceRecord record) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(record.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to add record");
    }
  }
}
