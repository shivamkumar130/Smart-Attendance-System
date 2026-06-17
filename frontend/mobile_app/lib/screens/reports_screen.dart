import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Future<Map<String, dynamic>> report;
  String selectedRange = "day";
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    report = _fetchReport();
  }

  Future<void> _exportDashboardPdf() async {
    try {
      final data = await report;
      await PdfGenerator.generateDashboardReport(
        data,
        "Attendance Dashboard for ${_formatSelectedRangeLabel()}",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export PDF: $e")),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchReport() {
    return ApiService.getAttendanceAnalytics(
      range: selectedRange,
      year: selectedYear,
      month: selectedMonth,
      date: DateFormat('yyyy-MM-dd').format(selectedDate),
    );
  }

  Future<void> _refreshReport() async {
    setState(() {
      report = _fetchReport();
    });
    await report;
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
        report = _fetchReport();
      });
    }
  }

  String _formatSelectedRangeLabel() {
    if (selectedRange == "month") {
      return DateFormat('MMMM yyyy').format(DateTime(selectedYear, selectedMonth));
    }
    if (selectedRange == "year") {
      return selectedYear.toString();
    }
    return DateFormat('dd MMM yyyy').format(selectedDate);
  }

  Map<String, int> calculateTodayStats(Map<String, dynamic> data) {
    final List<dynamic> timeline =
        (data["timeline"] as List<dynamic>?) ??
        (data["attendanceTimeline"] as List<dynamic>?) ??
        (data["records"] as List<dynamic>?) ??
        [];

    final String today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    int presentCount = 0;
    int absentCount = 0;

    for (final item in timeline) {
      final record = item as Map<String, dynamic>;
      final String attendanceDate = record["attendanceDate"]?.toString() ?? "";

      DateTime? date;
      try {
        date = DateTime.parse(attendanceDate).toLocal();
      } catch (_) {
        continue;
      }

      final String dateKey = DateFormat("yyyy-MM-dd").format(date);

      if (dateKey == today) {
        final String status = record["status"]?.toString().toLowerCase().trim() ?? "";
        if (status == "present") {
          presentCount++;
        } else if (status == "absent") {
          absentCount++;
        }
      }
    }

    return {
      "present": presentCount,
      "absent": absentCount,
    };
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
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
          "$title: $count",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _errorView(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            "Error: $error",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshReport, child: const Text("Retry")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportDashboardPdf,
            tooltip: 'Export Dashboard PDF',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: report,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      "Loading reports...",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError) {
              return _errorView(snapshot.error);
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No report data found",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            final int totalStudents = data["totalStudents"] ?? 0;
            final int presentCount = data["present"] ?? 0;
            final int absentCount = data["absent"] ?? 0;
            final double percentage =
                double.tryParse(data["attendancePercentage"]?.toString() ?? "0") ?? 0;
            final int totalRecords = data["totalRecords"] ?? (presentCount + absentCount);
            final String reportLabel = data["label"]?.toString() ?? "Report";

            return RefreshIndicator(
              onRefresh: _refreshReport,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: -20,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Reports Dashboard",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Attendance analytics & insights",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _formatSelectedRangeLabel(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedRange,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Report Type",
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
                                      report = _fetchReport();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                        child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        selectedMonth = value;
                                        report = _fetchReport();
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
                                        report = _fetchReport();
                                      });
                                    },
                                  ),
                                ),
                              if (selectedRange == "day")
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _pickDate(context),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: "Date",
                                      ),
                                      child: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.92,
                            children: [
                              statCard(
                                "Total Students",
                                totalStudents.toString(),
                                Icons.people_alt_rounded,
                                Colors.blueAccent,
                              ),
                              statCard(
                                "Present",
                                presentCount.toString(),
                                Icons.check_circle_rounded,
                                Colors.green,
                              ),
                              statCard(
                                "Absent",
                                absentCount.toString(),
                                Icons.cancel_rounded,
                                Colors.redAccent,
                              ),
                              statCard(
                                "Total Records",
                                totalRecords.toString(),
                                Icons.receipt_long_rounded,
                                Colors.orangeAccent,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.trending_up_rounded,
                                        color: Colors.blueAccent,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Today's Attendance",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: LinearProgressIndicator(
                                            value: percentage / 100,
                                            minHeight: 16,
                                            backgroundColor: Colors.grey.shade200,
                                            color: percentage >= 80
                                                ? Colors.green
                                                : percentage >= 50
                                                    ? Colors.blueAccent
                                                    : Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${percentage.toStringAsFixed(1)}%",
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w800,
                                                    color: percentage >= 80
                                                        ? Colors.green
                                                        : percentage >= 50
                                                            ? Colors.blueAccent
                                                            : Colors.redAccent,
                                                  ),
                                                ),
                                                const Text(
                                                  "Attendance Rate",
                                                  style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "$presentCount Present",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.cancel,
                                                      color: Colors.redAccent,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "$absentCount Absent",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                          Card(
                            elevation: 3,
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
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 280,
                                    child: Column(
                                      children: [
                                        Expanded(
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
                                              ].where((section) => section.value > 0).toList(),
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}