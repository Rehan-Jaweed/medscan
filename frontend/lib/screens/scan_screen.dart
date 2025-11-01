import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class ScanScreen extends StatefulWidget {
  final String modelName;
  const ScanScreen({super.key, required this.modelName});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedFile;
  String? _result;
  bool _loading = false;

  String getModelEndpoint() {
    if (widget.modelName.contains("Pneumonia")) return "pneumonia_detector";
    if (widget.modelName.contains("Brain")) return "tumor_detector";
    if (widget.modelName.contains("Lung")) return "lung_detector";
    return "";
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _result = null;
      });
    }
  }

  Future<void> _uploadAndPredict() async {
    if (_selectedFile == null) return;

    setState(() {
      _loading = true;
    });

    final modelEndpoint = getModelEndpoint();
    final uri = Uri.parse("http://192.168.137.245:5001/predict/$modelEndpoint");

    try {
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = responseData.body;
        setState(() {
          final decoded = jsonDecode(responseData.body);
          _result = decoded["label"];
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modelName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal, width: 2),
                ),
                child: _selectedFile == null
                    ? const Center(
                  child: Text(
                    "Tap or drag & drop an image here",
                    style: TextStyle(fontSize: 16),
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_selectedFile!, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _uploadAndPredict,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("Upload & Predict"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_result != null && !_loading)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}