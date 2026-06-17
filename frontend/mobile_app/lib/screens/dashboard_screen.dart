import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'register_screen.dart';
import 'attendance_screen.dart';
import 'students_screen.dart';
import 'attendance_history_screen.dart';
import 'reports_screen.dart';
import '../services/api_service.dart';
import 'monthly_report_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const List<DashboardItemData> itemsData = [
    DashboardItemData(
      icon: Icons.person_add_rounded,
      title: 'Register Student',
      screenType: ScreenType.register,
      color: Colors.blueAccent,
    ),
    DashboardItemData(
      icon: Icons.camera_alt_rounded,
      title: 'Take Attendance',
      screenType: ScreenType.attendance,
      color: Colors.purpleAccent,
    ),
    DashboardItemData(
      icon: Icons.people_rounded,
      title: 'Student List',
      screenType: ScreenType.students,
      color: Colors.tealAccent,
    ),
    DashboardItemData(
      icon: Icons.history_rounded,
      title: 'Attendance History',
      screenType: ScreenType.attendanceHistory,
      color: Colors.orangeAccent,
    ),
    DashboardItemData(
      icon: Icons.assessment_rounded,
      title: 'Reports',
      screenType: ScreenType.reports,
      color: Colors.greenAccent,
    ),
    DashboardItemData(
      icon: Icons.calendar_month,
      title: 'Monthly Report',
      screenType: ScreenType.monthlyReport,
      color: Colors.deepPurple,
    ),
  ];

  late Future<List<dynamic>> recentAttendance;

  @override
  void initState() {
    super.initState();
    recentAttendance = ApiService.getRecentAttendance();
  }

  void refreshRecentAttendance() {
    setState(() {
      recentAttendance = ApiService.getRecentAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Smart Attendance Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FutureBuilder<List<dynamic>>(
                future: recentAttendance,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('Failed to load recent attendance'),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text('No recent attendance found'),
                      ),
                    );
                  }

                  final records = snapshot.data!;
                  final recentRecords =
                      records.length > 2 ? records.sublist(0, 2) : records;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Recent Attendance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          ...recentRecords.map(
                            (record) {
                              String formattedDate = record["attendanceDate"]?.toString() ?? "";
                              try {
                                final date = DateTime.parse(formattedDate).toLocal();
                                formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
                              } catch (_) {}
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(record["studentId"]["name"]),
                                subtitle: Text(formattedDate),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: itemsData
                    .map(
                      (item) => _DashboardCard(
                        item: item,
                        onReturn: refreshRecentAttendance,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ScreenType {
  register,
  attendance,
  students,
  attendanceHistory,
  reports,
  monthlyReport,
}

class DashboardItemData {
  final IconData icon;
  final String title;
  final ScreenType screenType;
  final Color color;

  const DashboardItemData({
    required this.icon,
    required this.title,
    required this.screenType,
    required this.color,
  });

  Widget get screen {
    switch (screenType) {
      case ScreenType.register:
        return RegisterScreen();
      case ScreenType.attendance:
        return AttendanceScreen();
      case ScreenType.students:
        return StudentsScreen();
      case ScreenType.attendanceHistory:
        return AttendanceHistoryScreen();
      case ScreenType.reports:
        return ReportsScreen();
      case ScreenType.monthlyReport:
        return MonthlyReportScreen();
    }
  }
}

class _DashboardCard extends StatelessWidget {
  final DashboardItemData item;
  final VoidCallback onReturn;

  const _DashboardCard({
    required this.item,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => item.screen,
          ),
        );
        onReturn();
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                item.color.withOpacity(0.12),
                item.color.withOpacity(0.04),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 56,
                color: item.color,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}