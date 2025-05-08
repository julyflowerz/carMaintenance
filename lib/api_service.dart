import 'dart:convert';
import 'package:http/http.dart' as http;
import 'maintenance_record.dart';

class ApiService {
  // Chrome version ONLY
  static const String baseUrl = "http://localhost:5047/api/maintenance";

  // Fetches all maintenance records from the backend
  static Future<List<MaintenanceRecord>> fetchRecords() async {
    // Sends a GET request to the backend
    final response = await http.get(Uri.parse(baseUrl));

    // If the server returns a success response (HTTP 200)
    if (response.statusCode == 200) {
      // Decode the JSON array into a dynamic List
      final List data = jsonDecode(response.body);

      // Convert each JSON object into a MaintenanceRecord and return the list
      return data.map((e) => MaintenanceRecord.fromJson(e)).toList();
    } else {
      // If response status isn't 200, throw an error
      throw Exception("Failed to load maintenance records");
    }
  }

  // Sends a new maintenance record to the backend
  static Future<void> addRecord(MaintenanceRecord record) async {
    // Sends a POST request with the record data encoded as JSON
    final response = await http.post(
      Uri.parse(baseUrl), // Target URL for the POST
      headers: {
        "Content-Type": "application/json", // Tells the server to expect JSON
      },
      body: jsonEncode(record.toJson()), // Converts Dart object to JSON
    );

    // If server doesn't return success, throw an error
    if (response.statusCode != 200) {
      throw Exception("Failed to add record");
    }
  }
}
