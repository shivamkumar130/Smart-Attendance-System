import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.29.101:5000";

  // ATTENDANCE
  static Future<http.StreamedResponse> recognizeFace(String imagePath) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/attendance/recognize-live"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("image", imagePath),
    );

    request.fields["subject"] = "Software Engineering";

    return request.send();
  }

  // REGISTER STUDENT
  static Future<Map<String, dynamic>> registerStudent({
    required String name,
    required String rollNo,
    String? email,
    required String department,
    required int semester,
  }) async {
    final body = {
      "name": name,
      "rollNo": rollNo,
      "department": department,
      "semester": semester,
    };
    if (email != null && email.isNotEmpty) {
      body["email"] = email;
    }
    final response = await http.post(
      Uri.parse("$baseUrl/api/students/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // UPLOAD FACE
  static Future<Map<String, dynamic>> uploadFace(
    String studentId,
    String imagePath,
  ) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/students/upload-face/$studentId"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("image", imagePath),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    return jsonDecode(body) as Map<String, dynamic>;
  }

  // ENROLL FACE
  static Future<Map<String, dynamic>> enrollFace(String studentId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/students/enroll-face/$studentId"),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getStudents() async {
    final response = await http.get(Uri.parse("$baseUrl/api/students"));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data["students"] as List<dynamic>?) ?? [];
  }

  static Future<List<dynamic>> getAttendance() async {
    final response = await http.get(Uri.parse("$baseUrl/api/attendance"));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data["attendance"] as List<dynamic>?) ?? [];
  }

  static Future<Map<String, dynamic>> getReport() async {
    final response = await http.get(Uri.parse("$baseUrl/api/attendance/report"));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getStudentReport(String studentId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/students/report/$studentId"),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getAttendanceSummary() async {
    final response =
        await http.get(Uri.parse("$baseUrl/api/attendance/summary"));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data["summary"] as List<dynamic>?) ?? [];
  }

  static Future<Map<String, dynamic>> getDashboardReport() async {
    final response = await http.get(Uri.parse("$baseUrl/api/attendance/report"));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getAttendanceAnalytics({
    String range = "day",
    int? year,
    int? month,
    String? date,
  }) async {
    final queryParameters = <String, String>{
      "range": range,
      if (year != null) "year": year.toString(),
      if (month != null) "month": month.toString(),
      if (date != null) "date": date,
    };

    final uri = Uri.parse("$baseUrl/api/attendance/analytics")
        .replace(queryParameters: queryParameters);

    final response = await http.get(uri);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<void> deleteStudent(String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/students/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  static Future<void> updateStudent({
    required String id,
    required String name,
    required String email,
    required String rollNo,
    required String department,
    required int semester,
  }) async {
    final response = await http.put(
      Uri.parse("$baseUrl/api/students/$id"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "rollNo": rollNo,
        "department": department,
        "semester": semester,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
  static Future<void> deleteAttendance(
    String attendanceId,
  ) async {

    final response = await http.delete(
      Uri.parse(
        "$baseUrl/api/attendance/$attendanceId",
      ),
    );

    print(response.statusCode);
    print(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        "Failed to delete attendance",
      );
    }
  }
  static Future<List<dynamic>>
  getRecentAttendance() async {

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/attendance/recent",
      ),
    );

    final data =
        jsonDecode(
          response.body,
        );

    return data["records"];
  }
  static Future<List<dynamic>>
  getAttendanceByDate(
    String date,
  ) async {

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/attendance/date/$date",
      ),
    );

    final data =
        jsonDecode(
          response.body,
        );

    return data["attendance"];
  }
  static Future<List<dynamic>>
  getMonthlyReport(
    int month,
    int year,
    String department,
  ) async {

    final response =
        await http.get(
      Uri.parse(
        "$baseUrl/api/attendance/monthly-report?month=$month&year=$year&department=$department",
      ),
    );

    final data =
        jsonDecode(response.body);

    return data["report"];
  }
}