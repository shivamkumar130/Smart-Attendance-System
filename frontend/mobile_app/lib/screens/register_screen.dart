import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final rollController = TextEditingController();
  final emailController = TextEditingController();
  final departmentController = TextEditingController();
  final semesterController = TextEditingController();

  bool loading = false;

  Future<void> registerFace() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      final email = emailController.text.trim();
      final student = await ApiService.registerStudent(
        name: nameController.text.trim(),
        rollNo: rollController.text.trim(),
        email: email.isEmpty ? null : email,
        department: departmentController.text.trim(),
        semester: int.tryParse(semesterController.text.trim()) ?? 0,
      );

      if (student["success"] != true) {
        throw Exception(student["message"] ?? "Registration failed");
      }

      final studentId = student["student"]["_id"];

      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final upload = await ApiService.uploadFace(studentId, image.path);
      if (upload["success"] != true) {
        throw Exception(upload["message"] ?? "Face upload failed");
      }

      final enroll = await ApiService.enrollFace(studentId);
      if (enroll["success"] != true) {
        throw Exception(enroll["message"] ?? "Face enrollment failed");
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Success",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          content: const Text("Face registered successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                nameController.clear();
                rollController.clear();
                emailController.clear();
                departmentController.clear();
                semesterController.clear();
                setState(() {});
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    emailController.dispose();
    departmentController.dispose();
    semesterController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Register Student",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Enter student details and register face",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person_rounded,
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: rollController,
                          label: "Roll Number",
                          icon: Icons.badge_rounded,
                          keyboardType: TextInputType.text,
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? "Roll number is required" : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: emailController,
                          label: "Email Address (optional)",
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return null;
                            if (!value.contains("@")) return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: departmentController,
                          label: "Department",
                          icon: Icons.business_rounded,
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? "Department is required" : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: semesterController,
                          label: "Semester / Class",
                          icon: Icons.school_rounded,
                          validator: (value) =>
                              value == null || value.trim().isEmpty ? "Semester/Class is required" : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: loading ? null : registerFace,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Register Face",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}