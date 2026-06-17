import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'edit_student_screen.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late Future<Map<String, dynamic>> report;
  String selectedRange = "day";
  DateTime selectedDate = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    report = ApiService.getStudentReport(widget.studentId);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool _matchesSelectedRange(DateTime date) {
    if (selectedRange == "day") {
      return date.year == selectedDate.year &&
          date.month == selectedDate.month &&
          date.day == selectedDate.day;
    }
    if (selectedRange == "month") {
      return date.year == selectedYear && date.month == selectedMonth;
    }
    return date.year == selectedYear;
  }

  List<Map<String, dynamic>> _filteredTimeline(List<dynamic> timeline) {
    return timeline.where((item) {
      if (item is! Map<String, dynamic>) return false;
      final rawDate = item["attendanceDate"]?.toString();
      if (rawDate == null || rawDate.isEmpty) return false;
      try {
        final parsed = DateTime.parse(rawDate).toLocal();
        return _matchesSelectedRange(parsed);
      } catch (_) {
        return false;
      }
    }).cast<Map<String, dynamic>>().toList();
  }

  Map<String, int> _attendanceCounts(List<Map<String, dynamic>> records) {
    int present = 0;
    int absent = 0;
    for (final record in records) {
      final status = record["status"]?.toString().toLowerCase().trim();
      if (status == "present") {
        present++;
      } else if (status == "absent") {
        absent++;
      }
    }
    return {"present": present, "absent": absent};
  }

  String _formatSelectedLabel() {
    if (selectedRange == "month") {
      return DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    }
    if (selectedRange == "year") {
      return selectedYear.toString();
    }
    return DateFormat('dd MMM yyyy').format(selectedDate);
  }

  Widget _legendItem(Color color, String title, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$title: $count',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: report,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("No Data Found"),
            );
          }

          final data = snapshot.data!;

          if (data["success"] != true) {
            return Center(
              child: Text(
                data["message"]?.toString() ?? "Failed to load student",
              ),
            );
          }

          final student = data["student"];
          if (student == null) {
            return const Center(
              child: Text("Student data is null"),
            );
          }

          final List<dynamic> timeline =
              (data["timeline"] as List<dynamic>?) ?? [];

          final double percentage =
              double.tryParse(data["percentage"]?.toString() ?? "0") ?? 0;

          final String name = student["name"]?.toString() ?? "N/A";
          final String email = student["email"]?.toString() ?? "N/A";
          final String rollNo = student["rollNo"]?.toString() ?? "N/A";
          final String department = student["department"]?.toString() ?? "N/A";
          final String semester = student["semester"]?.toString() ?? "N/A";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: student["registeredImages"] != null &&
                        (student["registeredImages"] as List).isNotEmpty
                    ? Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.indigo,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "${ApiService.baseUrl}/${student["registeredImages"][0]}"
                                .replaceAll("\\", "/"),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 80,
                              );
                            },
                          ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 70,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text("Roll No"),
                        trailing: Text(rollNo),
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text("Department"),
                        trailing: Text(department),
                      ),
                      ListTile(
                        leading: const Icon(Icons.class_),
                        title: const Text("Semester / Class"),
                        trailing: Text(semester),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditStudentScreen(
                            student: student,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      try {
                        await ApiService.deleteStudent(widget.studentId);
                        if (!mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Attendance Percentage",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 12,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${percentage.toStringAsFixed(2)}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                  title: const Text("Present Days"),
                  trailing: Text("${data["present"] ?? 0}"),
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  title: const Text("Absent Days"),
                  trailing: Text("${data["absent"] ?? 0}"),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Attendance Report",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedRange,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Range",
                              ),
                              items: const [
                                DropdownMenuItem(value: "day", child: Text("Daily")),
                                DropdownMenuItem(value: "month", child: Text("Monthly")),
                                DropdownMenuItem(value: "year", child: Text("Yearly")),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  selectedRange = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (selectedRange == "day")
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickDate(context),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Date",
                                  ),
                                  child: Text(
                                    DateFormat('dd MMM yyyy').format(selectedDate),
                                  ),
                                ),
                              ),
                            ),
                          if (selectedRange == "month")
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: selectedMonth,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Month",
                                ),
                                items: List.generate(
                                  12,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text(months[index]),
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    selectedMonth = value;
                                  });
                                },
                              ),
                            ),
                          if (selectedRange == "year")
                            Expanded(
                              child: TextFormField(
                                initialValue: selectedYear.toString(),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Year",
                                ),
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (value) {
                                  final year = int.tryParse(value);
                                  if (year == null) return;
                                  setState(() {
                                    selectedYear = year;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filtered: ${_formatSelectedLabel()}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Total: ${_filteredTimeline(timeline).length}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final filtered = _filteredTimeline(timeline);
                  final counts = _attendanceCounts(filtered);
                  final presentCount = counts["present"] ?? 0;
                  final absentCount = counts["absent"] ?? 0;
                  final hasData = presentCount + absentCount > 0;

                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Attendance Breakdown",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!hasData)
                            const Center(
                              child: Text("No records for selected range."),
                            )
                          else
                            SizedBox(
                              height: 220,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: presentCount.toDouble(),
                                      title: presentCount > 0 ? "$presentCount" : "",
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.redAccent,
                                      value: absentCount.toDouble(),
                                      title: absentCount > 0 ? "$absentCount" : "",
                                      radius: 80,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _legendItem(Colors.green, "Present", presentCount),
                              _legendItem(Colors.redAccent, "Absent", absentCount),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}