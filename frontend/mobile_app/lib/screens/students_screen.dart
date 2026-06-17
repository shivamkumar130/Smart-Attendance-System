import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../utils/pdf_generator.dart';
import 'student_details_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() =>
      _StudentsScreenState();
}

class _StudentsScreenState
    extends State<StudentsScreen> {
  late Future<List<dynamic>> students;

  @override
  void initState() {
    super.initState();
    students = ApiService.getStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students"),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export Students PDF',
            onPressed: () async {
              final data = await students;
              await PdfGenerator.generateStudentListReport(
                data,
                "Student List Report - ${DateFormat('dd MMM yyyy').format(DateTime.now())}",
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: students,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Students Found",
              ),
            );
          }

          final studentsList = snapshot.data!;

          return ListView.builder(
            itemCount: studentsList.length,
            itemBuilder: (context, index) {
              final student =
                  studentsList[index];

              final List<dynamic>
                  registeredImages =
                  student["registeredImages"] ??
                      [];

              final bool hasImage =
                  registeredImages.isNotEmpty;

              final String imageUrl =
                  hasImage
                      ? "${ApiService.baseUrl}/${registeredImages[0].toString().replaceAll("\\", "/")}"
                      : "";

              return Card(
                margin:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage:
                        hasImage
                            ? NetworkImage(
                                imageUrl,
                              )
                            : null,
                    child: !hasImage
                        ? Text(
                            student["name"] !=
                                        null &&
                                    student["name"]
                                        .toString()
                                        .isNotEmpty
                                ? student["name"][0]
                                    .toUpperCase()
                                : "?",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          )
                        : null,
                  ),

                  title: Text(
                    student["name"] ??
                        "Unknown",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Roll No: ${student["rollNo"] ?? "N/A"}",
                      ),
                      Text(
                        "Department: ${student["department"] ?? "N/A"}",
                      ),
                    ],
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StudentDetailsScreen(
                          studentId:
                              student["_id"],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}