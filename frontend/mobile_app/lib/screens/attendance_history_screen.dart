import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart';
import 'student_details_screen.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  bool isLoading = true;
  String searchQuery = "";
  DateTime selectedDate =DateTime.now();

  @override
  void initState() {
    super.initState();
    loadAttendanceByDate(
      DateTime.now(),
    );
  }

  Future<void> _exportAttendanceHistoryPdf() async {
    try {
      await PdfGenerator.generateAttendanceHistoryReport(
        students,
        "Attendance History for ${DateFormat('dd MMM yyyy').format(selectedDate)}",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export PDF: $e")),
      );
    }
  }

  Future<void>
  loadAttendanceByDate(
    DateTime date,
  ) async {

    try {

      setState(() {
        isLoading = true;
      });

      final data =
          await ApiService
              .getAttendanceByDate(
        date
            .toIso8601String()
            .split("T")[0],
      );

      setState(() {

        students = data;
        filteredStudents = data;
        selectedDate = date;
        isLoading = false;

      });

    } catch(e){

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  void searchStudent(String value) {
    setState(() {
      searchQuery = value;
      final query = value.toLowerCase().trim();

      filteredStudents = students.where((student) {
        final name =(student["studentId"]?["name"] ?? "").toString().toLowerCase();
        final rollNo =(student["studentId"]?["rollNo"] ?? "").toString().toLowerCase();
        return name.contains(query) || rollNo.contains(query);
      }).toList();
    });
  }

  String _safeText(dynamic value, [String fallback = "N/A"]) {
    final text = value?.toString().trim() ?? "";
    return text.isEmpty ? fallback : text;
  }

  String _formatAttendanceDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Attendance Summary"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export History PDF',
            onPressed: _exportAttendanceHistoryPdf,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>loadAttendanceByDate(selectedDate,),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                0,
              ),
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.calendar_month,
                ),
                label: Text(
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                ),
                onPressed: () async {

                  final picked =
                      await showDatePicker(
                    context: context,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    initialDate: selectedDate,
                  );

                  if (picked != null) {

                    setState(() {
                      selectedDate = picked;
                    });

                    final result =
                        await ApiService
                            .getAttendanceByDate(
                      picked
                          .toIso8601String()
                          .split("T")[0],
                    );

                    setState(() {
                      students = result;
                      filteredStudents = result;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                onChanged: searchStudent,
                decoration: InputDecoration(
                  hintText: "Search by name or roll no",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => searchStudent(""),
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredStudents.isEmpty
                      ? const Center(
                          child: Text(
                            "No Attendance Found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: filteredStudents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final student =
                                filteredStudents[index] as Map<String, dynamic>;
                            final name = _safeText(
                              student["studentId"]?["name"],
                            );

                            final rollNo = _safeText(
                              student["studentId"]?["rollNo"],
                            );

                            final status = _safeText(
                              student["status"],
                            );

                            final rawAttendanceDate = _safeText(
                              student["attendanceDate"],
                            );
                            final attendanceDate = _formatAttendanceDate(
                              rawAttendanceDate,
                            );

                            final studentId = _safeText(
                              student["studentId"]?["_id"],
                              "",
                            );

                            final avatarText =
                                name.isNotEmpty
                                    ? name[0].toUpperCase()
                                    : "?";
                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: studentId.isNotEmpty
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StudentDetailsScreen(
                                              studentId: studentId,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor:
                                            const Color(0xFFE0E7FF),
                                        child: Text(
                                          avatarText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Color(0xFF4338CA),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      999,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "status: $status",
                                                    style: TextStyle(
                                                      color: Colors.green[700],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text("Roll No: $rollNo"),
                                            const SizedBox(height: 2),
                                            Text("Status: $status",),
                                            const SizedBox(height: 2),
                                            Text("Date: $attendanceDate",),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

                                
                            