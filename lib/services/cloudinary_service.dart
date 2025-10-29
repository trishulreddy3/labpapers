import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = 'dyudoronx';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET'; // You'll need to create this in Cloudinary
  static const String apiUrl = 'https://api.cloudinary.com/v1_1';
  static const String apiKey = '882295628834881';
  static const String apiSecret = 'NWbFJPvLTzB35j9wEig47qC-P4U';
  
  // Configure this in your Cloudinary dashboard
  static void configure() {
    // Configuration happens in upload
  }

  // Upload file to Cloudinary
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      // Use signed upload with API credentials
      final url = Uri.parse('$apiUrl/$cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url);
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
      request.fields['folder'] = 'question_papers';
      
      // Calculate signature for signed upload
      final timestamp = request.fields['timestamp']!;
      final signature = _calculateSignature(timestamp);
      request.fields['signature'] = signature;
      
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
      );
      
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'] as String;
      } else {
        debugPrint('Error uploading to Cloudinary: ${response.statusCode}');
        debugPrint('Response: $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Calculate signature for signed upload
  String _calculateSignature(String timestamp) {
    final params = 'folder=question_papers&timestamp=$timestamp$apiSecret';
    final bytes = utf8.encode(params);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate PDF thumbnail URL (if you want to show preview)
  String getThumbnailUrl(String pdfUrl, int page) {
    return pdfUrl
        .replaceAll('.pdf', '')
        .replaceAll('/raw/', '/image/')
        .replaceAll('/upload/', '/upload/page_$page/');
  }
}
