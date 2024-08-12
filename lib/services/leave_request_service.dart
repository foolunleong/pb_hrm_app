import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRequestService {
  final String baseUrl = 'https://demo-application-api.flexiflows.co';

  Future<void> addLeaveRequest(Map<String, dynamic> leaveRequestData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/leave-type'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(leaveRequestData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit leave request');
    }
  }
}