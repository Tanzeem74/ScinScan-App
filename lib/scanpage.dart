import 'dart:io';
import 'dart:typed_data';
import 'package:final_project/hf_servcie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  Uint8List? _webImage;

  bool _isLoading = false;
  List<dynamic>? _results;

  final HFService _hfService = HFService();

  // 📸 Pick image
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _webImage = bytes;
        _image = null;
        _results = null;
      });
    } else {
      setState(() {
        _image = File(pickedFile.path);
        _webImage = null;
        _results = null;
      });
    }
  }

  // 🧠 Analyze image
  Future<void> _analyzeImage() async {
    if (_image == null && _webImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Uint8List imageBytes = kIsWeb
          ? _webImage!
          : await _image!.readAsBytes();

      final results = await _hfService.predictSkinDiseaseFromBytes(imageBytes);

      if (results.isEmpty) {
        throw Exception("No prediction found");
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Skin Analysis"),
        backgroundColor: const Color(0xFF008080),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🖼 Image preview
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal),
              ),
              child: (_image != null || _webImage != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: kIsWeb
                          ? Image.memory(_webImage!, fit: BoxFit.cover)
                          : Image.file(_image!, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.add_a_photo_outlined,
                      size: 80,
                      color: Colors.teal,
                    ),
            ),

            const SizedBox(height: 20),

            // 📸 Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: kIsWeb
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🔍 Analyze button
            if ((_image != null || _webImage != null) && !_isLoading)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _analyzeImage,
                  child: const Text(
                    "ANALYZE SKIN",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 30),

            if (_results != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  // 📊 Result card
  Widget _buildResultCard() {
    final result = _results!.first;
    final label = result['label'];
    final score = (result['score'] * 100).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text(
            "Detection Result",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Confidence: $score%"),
          const SizedBox(height: 10),
          const Text(
            "⚠️ AI prediction only. Consult a dermatologist.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
