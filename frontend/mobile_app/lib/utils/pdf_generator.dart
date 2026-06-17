import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfGenerator {

  static Future<void>
      generateAttendanceReport(
    List<dynamic> report,
    String reportLabel,
  ) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [

          pw.Header(
            level: 0,
            child: pw.Text(
              "Monthly Attendance Report",
            ),
          ),
          pw.Paragraph(
            text: reportLabel,
          ),

          pw.TableHelper.fromTextArray(
            headers: [
              "Student Name",
              "Roll No",
              "Department",
              "Semester / Class",
              "Present Days",
            ],

            data: report.map(
              (item) {
                final name = item["name"]?.toString() ?? "Unknown";
                final roll = item["rollNo"]?.toString() ?? "N/A";
                final dept = item["department"]?.toString() ?? item["dept"]?.toString() ?? "Unknown";
                final sem = item["semester"]?.toString() ?? item["class"]?.toString() ?? item["semesterOrClass"]?.toString() ?? "Unknown";
                final present = item["totalPresent"]?.toString() ?? item["presentDays"]?.toString() ?? item["daysPresent"]?.toString() ?? "0";

                return [
                  name,
                  roll,
                  dept,
                  sem,
                  present,
                ];
              },
            ).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> generateDashboardReport(
    Map<String, dynamic> data,
    String reportLabel,
  ) async {
    final pdf = pw.Document();
    final int totalStudents = data["totalStudents"] ?? 0;
    final int presentCount = data["present"] ?? 0;
    final int absentCount = data["absent"] ?? 0;
    final double percentage = double.tryParse(
          data["attendancePercentage"]?.toString() ?? "0",
        ) ??
        0;
    final int totalRecords = data["totalRecords"] ?? (presentCount + absentCount);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Attendance Dashboard Report"),
          ),
          pw.Paragraph(text: reportLabel),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ["Metric", "Value"],
            data: [
              ["Total Students", totalStudents.toString()],
              ["Present", presentCount.toString()],
              ["Absent", absentCount.toString()],
              ["Total Records", totalRecords.toString()],
              ["Attendance Rate", "${percentage.toStringAsFixed(1)}%"],
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> generateAttendanceHistoryReport(
    List<dynamic> students,
    String reportLabel,
  ) async {
    final pdf = pw.Document();

    String _formatDate(String rawDate) {
      try {
        final date = DateTime.parse(rawDate).toLocal();
        return DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (_) {
        return rawDate;
      }
    }

    final rows = students.map((item) {
      final name = item["studentId"]?["name"]?.toString() ?? "Unknown";
      final roll = item["studentId"]?["rollNo"]?.toString() ?? "N/A";
      final status = item["status"]?.toString() ?? "Unknown";
      final rawDate = item["attendanceDate"]?.toString() ?? "Unknown";
      final date = _formatDate(rawDate);
      return [name, roll, status, date];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Attendance History Report"),
          ),
          pw.Paragraph(text: reportLabel),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ["Student Name", "Roll No", "Status", "Date"],
            data: rows,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> generateStudentListReport(
    List<dynamic> students,
    String reportLabel,
  ) async {
    final pdf = pw.Document();

    final rows = students.map((item) {
      final name = item["name"]?.toString() ?? "Unknown";
      final roll = item["rollNo"]?.toString() ?? "N/A";
      final dept = item["department"]?.toString() ?? "N/A";
      final semester = item["semester"]?.toString() ?? "N/A";
      return [name, roll, dept, semester];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Student List Report"),
          ),
          pw.Paragraph(text: reportLabel),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: ["Student Name", "Roll No", "Department", "Semester / Class"],
            data: rows,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}