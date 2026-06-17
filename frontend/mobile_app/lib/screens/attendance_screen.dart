import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState
    extends State<AttendanceScreen> {
  bool loading = false;

  Future<void> takeAttendance() async {
    final picker = ImagePicker();

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) return;

    setState(() {
      loading = true;
    });

    try {
      final response =
          await ApiService.recognizeFace(
        image.path,
      );

      final body =
          await response.stream.bytesToString();

      debugPrint(body);

      final data = jsonDecode(body);

      if (!mounted) return;

      if (data["success"] != true) {
        _showFailureDialog(
          data["message"] ??
              "Face recognition failed",
        );
        return;
      }

      final student =
          data["student"] ?? {};

      final String name =
          student["name"] ??
              "Unknown Student";

      final double confidence =
          ((data["confidence"] ?? 0)
                  as num)
              .toDouble();

      _showSuccessDialog(
        name,
        confidence,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Error: $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(
    String name,
    double confidence,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        title: Column(
          children: const [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 10),
            Text(
              "Attendance Marked",
            ),
          ],
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              name,
              style:
                  const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Confidence: ${(confidence * 100).toStringAsFixed(2)}%",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context),
            child:
                const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _showFailureDialog(
    String message,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            20,
          ),
        ),
        title: Column(
          children: const [
            Icon(
              Icons.cancel,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 10),
            Text(
              "Recognition Failed",
            ),
          ],
        ),
        content: Text(
          message,
          textAlign:
              TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                    context),
            child:
                const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Smart Attendance",
        ),
        centerTitle: true,
      ),
      body: Center(
        child: loading
            ? Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    "Recognizing Face...",
                  ),
                ],
              )
            : ElevatedButton.icon(
                onPressed:
                    takeAttendance,
                icon: const Icon(
                  Icons.camera_alt,
                ),
                label: const Text(
                  "Take Attendance",
                ),
                style:
                    ElevatedButton
                        .styleFrom(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
      ),
    );
  }
}