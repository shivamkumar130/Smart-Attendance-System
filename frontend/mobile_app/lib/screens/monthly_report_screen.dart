import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String selectedDepartment = "All";
  String selectedClassName = "All";

  late Future<List<dynamic>> reportFuture;
  late Future<List<dynamic>> studentsFuture;

  final List<String> months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  List<String> departmentItems = ["All"];
  List<String> classItems = ["All"];

  @override
  void initState() {
    super.initState();
    reportFuture = _fetchReport();
    studentsFuture = ApiService.getStudents();
    _loadDropdownValues();
  }

  Future<void> _loadDropdownValues() async {
    try {
      final students = await ApiService.getStudents();

      final departments = <String>{"All"};
      final classes = <String>{"All"};

      for (final item in students) {
        if (item is Map<String, dynamic>) {
          final dept = _getMeta(item, ["department", "dept", "branch"]);
          final cls = _getMeta(
            item,
            ["semester", "semesterOrClass", "className", "class", "section", "std"],
          );

          if (dept.isNotEmpty) departments.add(dept);
          if (cls.isNotEmpty) classes.add(cls);
        }
      }

      if (!mounted) return;
      setState(() {
        departmentItems = departments.toList()..sort();
        classItems = classes.toList()..sort();
        if (!departmentItems.contains(selectedDepartment)) {
          selectedDepartment = "All";
        }
        if (!classItems.contains(selectedClassName)) {
          selectedClassName = "All";
        }
      });
    } catch (_) {}
  }

  Future<List<dynamic>> _fetchReport() {
    return ApiService.getMonthlyReport(
      selectedMonth,
      selectedYear,
      selectedDepartment,
    );
  }

  void _reloadReport() {
    setState(() {
      reportFuture = _fetchReport();
    });
  }

  String _formatSelectedMonthYear() {
    return DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
  }

  String _getMeta(Map<String, dynamic> item, List<String> keys, [String defaultValue = ""]) {
    for (final key in keys) {
      final value = item[key];
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return defaultValue;
  }

  String _extractValue(Map<String, dynamic> item, List<String> keys) {
    return _getMeta(item, keys, "");
  }

  String _getName(Map<String, dynamic> item) {
    final name = _extractValue(item, ["name", "studentName", "fullName", "student_name"]);
    return name.isEmpty ? "Unknown" : name;
  }

  String _getRoll(Map<String, dynamic> item) {
    final roll = _extractValue(item, ["rollNo", "roll", "rollNumber", "roll_no"]);
    return roll.isEmpty ? "N/A" : roll;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final report = await ApiService.getMonthlyReport(
                selectedMonth,
                selectedYear,
                selectedDepartment,
              );
              await PdfGenerator.generateAttendanceReport(
                report,
                "Attendance for ${DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth))}",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatSelectedMonthYear(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Department",
                  ),
                  items: departmentItems
                      .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedDepartment = value);
                    _reloadReport();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedClassName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Semester / Class",
                  ),
                  items: classItems
                      .map((cls) => DropdownMenuItem(
                            value: cls,
                            child: Text(cls),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedClassName = value);
                    _reloadReport();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedMonth,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Month",
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
                    setState(() => selectedMonth = value);
                    _reloadReport();
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: selectedYear.toString(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Year",
                  ),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (value) {
                    final year = int.tryParse(value);
                    if (year == null) return;
                    setState(() => selectedYear = year);
                    _reloadReport();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final report = snapshot.data ?? [];
                if (report.isEmpty) {
                  return const Center(child: Text("No Records Found"));
                }

                final filteredReport = report.where((item) {
                  if (item is! Map<String, dynamic>) return false;

                  final dept = _getMeta(item, ["department", "dept", "branch"]);
                  final cls = _getMeta(
                    item,
                    ["semester", "semesterOrClass", "className", "class", "section", "std"],
                  );

                  final deptOk = selectedDepartment == "All" || dept == selectedDepartment;
                  final classOk = selectedClassName == "All" || cls == selectedClassName;

                  return deptOk && classOk;
                }).toList();

                if (filteredReport.isEmpty) {
                  return const Center(child: Text("No Matching Records Found"));
                }

                return ListView.builder(
                  itemCount: filteredReport.length,
                  itemBuilder: (context, index) {
                    final item = filteredReport[index] as Map<String, dynamic>;
                    final name = _getName(item);
                    final roll = _getRoll(item);
                    final dept = _getMeta(item, ["department", "dept", "branch"], "Unknown Dept");
                    final cls = _getMeta(
                      item,
                      ["semester", "semesterOrClass", "className", "class", "section", "std"],
                      "Unknown Class",
                    );
                    final days = item["totalPresent"]?.toString() ??
                        item["presentDays"]?.toString() ??
                        item["daysPresent"]?.toString() ??
                        "0";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : "?"),
                        ),
                        title: Text(name),
                        subtitle: Text(
                          "Roll No: $roll\nDept: $dept | Semester/Class: $cls",
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          "$days Days",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}