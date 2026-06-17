import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditStudentScreen extends StatefulWidget {

  final Map<String,dynamic> student;

  const EditStudentScreen({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentScreen> createState() =>
      _EditStudentScreenState();
}

class _EditStudentScreenState
    extends State<EditStudentScreen> {

  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController rollNo;
  late TextEditingController department;
  late TextEditingController semester;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(
      text: widget.student["name"],
    );

    email = TextEditingController(
      text: widget.student["email"],
    );

    rollNo = TextEditingController(
      text: widget.student["rollNo"],
    );

    department =
        TextEditingController(
      text:
          widget.student["department"],
    );

    semester =
        TextEditingController(
      text: widget.student["semester"]
          .toString(),
    );
  }

  Future<void> updateStudent() async {

    setState(() {
      loading = true;
    });

    try {

      await ApiService.updateStudent(
        id: widget.student["_id"],
        name: name.text,
        email: email.text,
        rollNo: rollNo.text,
        department: department.text,
        semester:
            int.parse(
              semester.text,
            ),
      );

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Edit Student"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: name,
              decoration:
                  const InputDecoration(
                labelText: "Name",
              ),
            ),

            TextField(
              controller: email,
              decoration:
                  const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: rollNo,
              decoration:
                  const InputDecoration(
                labelText: "Roll No",
              ),
            ),

            TextField(
              controller:
                  department,
              decoration:
                  const InputDecoration(
                labelText:
                    "Department",
              ),
            ),

            TextField(
              controller:
                  semester,
              decoration:
                  const InputDecoration(
                labelText:
                    "Semester",
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed:
                        updateStudent,
                    child: const Text(
                      "Update Student",
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}