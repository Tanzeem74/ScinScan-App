import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HFService {
  HFService({this.hfToken});

  static const String _baseUrl =
      'https://amyy77-skin-disease-api.hf.space/gradio_api/call/predict';

  final String? hfToken;

  Future<List<Map<String, dynamic>>> predictSkinDiseaseFromBytes(
    Uint8List imageBytes, {
    String mimeType = 'image/png',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return _predict(imageReference: dataUrl, mimeType: mimeType, size: imageBytes.length);
  }

  Future<List<Map<String, dynamic>>> predictSkinDiseaseFromUrl(
    String imageUrl,
  ) async {
    return _predict(imageReference: imageUrl);
  }

  Future<List<Map<String, dynamic>>> _predict({
    required String imageReference,
    String? mimeType,
    int? size,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (hfToken != null && hfToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $hfToken';
    }

    final postResponse = await http
        .post(
          Uri.parse(_baseUrl),
          headers: headers,
          body: jsonEncode({
            'data': [
              _buildFilePayload(imageReference, mimeType: mimeType, size: size),
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (postResponse.statusCode != 200) {
      throw Exception(
        'HF POST Error ${postResponse.statusCode}: ${postResponse.body}',
      );
    }

    final eventId = (jsonDecode(postResponse.body)['event_id'] as String?) ?? '';
    if (eventId.isEmpty) {
      throw Exception('No event_id received from API: ${postResponse.body}');
    }

    final getResponse = await http
        .get(
          Uri.parse('$_baseUrl/$eventId'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 90));

    if (getResponse.statusCode != 200) {
      throw Exception(
        'HF GET Error ${getResponse.statusCode}: ${getResponse.body}',
      );
    }

    return _parseSseResponse(getResponse.body);
  }

  Map<String, dynamic> _buildFilePayload(
    String ref, {
    String? mimeType,
    int? size,
  }) {
    final isHttp = ref.startsWith('http://') || ref.startsWith('https://');

    final payload = <String, dynamic>{
      if (isHttp) 'path': ref else 'url': ref,
      'meta': {'_type': 'gradio.FileData'},
    };

    if (!isHttp) {
      if (mimeType != null) payload['mime_type'] = mimeType;
      if (size != null) payload['size'] = size;
      payload['orig_name'] = 'upload.${(mimeType ?? 'image/png').split('/').last}';
      payload['is_stream'] = false;
    }

    return payload;
  }

  List<Map<String, dynamic>> _parseSseResponse(String sseBody) {
    final lines = sseBody.split('\n');
    List<dynamic>? resultData;

    for (final line in lines) {
      if (!line.startsWith('data: ')) continue;

      final jsonStr = line.substring(6).trim();
      if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

      try {
        final eventData = jsonDecode(jsonStr);
        if (eventData is List && eventData.isNotEmpty) {
          resultData = eventData;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (resultData == null || resultData.isEmpty) {
      throw Exception('No valid data found in SSE stream');
    }

    final firstResult = resultData.first;
    if (firstResult is Map && firstResult['confidences'] is List) {
      final predictions = (firstResult['confidences'] as List)
          .map<Map<String, dynamic>>((item) {
        if (item is Map && item['label'] != null && item['confidence'] != null) {
          return {
            'label': item['label'].toString(),
            'score': (item['confidence'] as num).toDouble(),
          };
        }
        return {};
      }).where((p) => p.isNotEmpty).toList();

      predictions.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double),
      );

      return predictions;
    }

    throw Exception('Unexpected HF response format: $resultData');
  }
}
