import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final String cloudinaryUrl = dotenv.env['CLOUDINARY_URL'] ?? '';
  static final String uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static Future<Map<String, dynamic>?> uploadFile(
    File file, {
    String? resourceType,
  }) async {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final apiKey = uri.userInfo.split(':')[0];
      final apiSecret = uri.userInfo.split(':')[1];
      final cloudName = uri.host;

      var timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      var signature = generateUploadSignature(timestamp, apiSecret);

      var url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );
      var request = http.MultipartRequest("POST", url);

      request.fields['timestamp'] = timestamp;
      request.fields['api_key'] = apiKey;
      request.fields['signature'] = signature;
      request.fields['resource_type'] = resourceType ?? 'auto';
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return {"fileUrl": data["secure_url"], "publicId": data["public_id"]};
      } else {
        print("Upload error: ${data['error']['message']}");
        return null;
      }
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  /// 🔑 Generare semnătură
  static String generateUploadSignature(String timestamp, String apiSecret) {
    var toSign = "timestamp=$timestamp$apiSecret";
    return sha1.convert(utf8.encode(toSign)).toString();
  }

  /// 🚀 Delete file
  static Future<bool> deleteFile(String publicId) async {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final apiKey = uri.userInfo.split(':')[0];
      final apiSecret = uri.userInfo.split(':')[1];
      final cloudName = uri.host;

      var url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/destroy",
      );
      var timestamp =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      var signature = generateSignature(publicId, timestamp, apiSecret);

      var response = await http.post(
        url,
        body: {
          "public_id": publicId,
          "timestamp": timestamp,
          "api_key": apiKey,
          "signature": signature,
        },
      );

      var responseData = response.body;
      var data = jsonDecode(responseData);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return data["result"] == "ok";
      } else {
        print("Delete error: ${data['error']['message']}");
        return false;
      }
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }

  /// 🔄 Replace file (delete and upload a new one)
  static Future<Map<String, dynamic>?> replaceFile(
    File newFile,
    String? oldPublicId,
  ) async {
    // ✅ Verifică dacă există un fișier vechi înainte de a încerca să-l ștergi
    if (oldPublicId != null && oldPublicId.isNotEmpty) {
      bool deleted = await deleteFile(oldPublicId);
      if (!deleted) {
        print("Failed to delete old file");
        return null;
      }
    }

    // ✅ Uploadează noul fișier chiar dacă nu există unul vechi
    return await uploadFile(newFile);
  }

  /// 🔑 Generate signature for API
  static String generateSignature(
    String publicId,
    String timestamp,
    String apiSecret,
  ) {
    var toSign = "public_id=$publicId&timestamp=$timestamp$apiSecret";
    return sha1.convert(utf8.encode(toSign)).toString();
  }
}
