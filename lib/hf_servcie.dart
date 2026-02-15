import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HFService {
  static const String _apiUrl =
      "https://huggingface.co/spaces/amyy77/skin-disease-api";

  Future<List<Map<String, dynamic>>> predictSkinDiseaseFromBytes(
    Uint8List bytes,
  ) async {
    final base64Image = base64Encode(bytes);

    final response = await http
        .post(
          Uri.parse(_apiUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "data": [base64Image],
          }),
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      throw Exception("HF Error ${response.statusCode}: ${response.body}");
    }

    final decoded = jsonDecode(response.body);
    final data = decoded["data"];
    /*
      Your Gradio output:
      gr.Label(num_top_classes=3)

      Response format:
      {
        "data": [
          {
            "Acne": 0.87,
            "Eczema": 0.08,
            "Moles": 0.05
          }
        ]
      }
    */

    if (data is List && data.isNotEmpty && data[0] is Map) {
      final Map<String, dynamic> predictions = Map<String, dynamic>.from(
        data[0],
      );

      // Sort by highest confidence
      final sorted = predictions.entries.toList()
        ..sort((a, b) => (b.value as num).compareTo(a.value as num));

      return sorted
          .map((e) => {"label": e.key, "score": (e.value as num).toDouble()})
          .toList();
    }

    throw Exception("Unexpected HF response format: $data");
  }
}
