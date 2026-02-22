import 'dart:io';
import 'dart:typed_data';
import 'package:final_project/doctorListPage.dart';
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
  final Map<String, Map<String, dynamic>> diseaseSuggestions = {
    'Acne': {
      'suggestion':
          'Acne is caused by blocked pores. With consistent care, it usually improves over time.',
      'dos': [
        'Wash your face twice a day with a mild cleanser',
        'Drink plenty of water to stay hydrated',
      ],
      'donts': [
        'Do not squeeze or pop pimples',
        'Avoid heavy or oily makeup/cosmetics',
      ],
    },
    'Actinic_Keratosis': {
      'suggestion':
          'These are rough patches caused by years of sun exposure. Early treatment is vital.',
      'dos': [
        'Apply broad-spectrum sunscreen daily',
        'Wear protective clothing and hats',
      ],
      'donts': [
        'Do not pick or scratch the rough patches',
        'Avoid sun exposure during peak hours',
      ],
    },
    'Eczema': {
      'suggestion':
          'Eczema makes skin dry and itchy. Keeping the skin barrier hydrated is the key.',
      'dos': [
        'Apply a thick moisturizer right after bathing',
        'Wear loose, breathable cotton clothes',
      ],
      'donts': [
        'Avoid very hot showers as they dry out skin',
        'Do not use scented soaps or harsh detergents',
      ],
    },
    'Infestations_Bites': {
      'suggestion':
          'This appears to be a reaction to insect bites or parasites. Keep the area clean.',
      'dos': [
        'Wash the affected area with mild soap and water',
        'Use a cold compress to reduce swelling',
      ],
      'donts': [
        'Avoid scratching to prevent secondary infection',
        'Do not apply unknown creams without advice',
      ],
    },
    'Moles': {
      'suggestion':
          'Most moles are harmless, but watch for changes in shape, size, or color (ABCDE rule).',
      'dos': [
        'Check regularly for any new or changing spots',
        'Consult a doctor if a mole starts bleeding',
      ],
      'donts': [
        'Do not try to remove or cut a mole yourself',
        'Avoid using chemical "mole removers"',
      ],
    },
    'Sun_Sunlight_Damage': {
      'suggestion':
          'Your skin has been damaged by UV rays. It needs cooling and recovery time.',
      'dos': [
        'Apply pure Aloe Vera gel to soothe the skin',
        'Stay in the shade and use an umbrella',
      ],
      'donts': [
        'Avoid further sun exposure until healed',
        'Do not use exfoliating scrubs on damaged skin',
      ],
    },
  };

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
      _results = null;
    });

    print('=== Starting Skin Analysis ===');
    print('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

    try {
      final Uint8List imageBytes = kIsWeb
          ? _webImage!
          : await _image!.readAsBytes();

      print('Image size: ${imageBytes.length} bytes');

      if (kIsWeb) {
        print('Running on WEB - using polling approach');
      } else {
        print('Running on MOBILE - using SSE stream');
      }

      final results = await _hfService.predictSkinDiseaseFromBytes(imageBytes);

      if (results.isEmpty) {
        throw Exception("No prediction found");
      }

      print('✓ Got ${results.length} predictions');
      for (var pred in results) {
        print(
          '  - ${pred['label']}: ${(pred['score'] * 100).toStringAsFixed(2)}%',
        );
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Analysis complete!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });

      final errorMsg = e.toString();
      print('=== Analysis Error ===');
      print('Error: $errorMsg');
      print('Stack trace: $stackTrace');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${errorMsg.length > 100 ? errorMsg.substring(0, 100) + '...' : errorMsg}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _analyzeImage,
          ),
        ),
      );
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
    final scoreValue = result['score'];
    final score = (result['score'] * 100).toStringAsFixed(2);

    if (scoreValue < 0.50) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          border: Border.all(color: Colors.orangeAccent, width: 2),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            const Text(
              "Result Unclear",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "The AI is not confident enough ($score%) to give a proper diagnosis.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(height: 30),
            const Text(
              "Please try again with a clearer photo in better lighting, or consult a professional if the issue persists.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DoctorListPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: const Text("FIND SPECIALISTS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Fetching info from the English map
    final info =
        diseaseSuggestions[label] ??
        {
          'suggestion': 'Please maintain hygiene and consult a specialist.',
          'dos': ['Keep the area clean'],
          'donts': ['Avoid scratching'],
        };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Detection Result",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 25),

          Center(
            child: Column(
              children: [
                Text(
                  label.replaceAll(
                    '_',
                    ' ',
                  ), // Formatting: E.g. "Sun_Damage" to "Sun Damage"
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFF008080),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Confidence Score: $score%",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "💡 Primary Suggestion:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            info['suggestion'],
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),

          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "✅ Do's:",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...info['dos'].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "• $item",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "❌ Don'ts:",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ...info['donts'].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          "• $item",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("FIND SPECIALISTS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
