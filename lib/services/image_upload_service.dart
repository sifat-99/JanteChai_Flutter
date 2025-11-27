import 'dart:convert' show jsonDecode;
import 'dart:io';

import 'package:http/http.dart' as http;

class ImageUploadService {
  Future<String?> uploadImage(File file) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dna94svwy/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'jantechai'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      return jsonMap['url'];
    } catch (e) {
      rethrow;
    }
  }
}

final imageUploadService = ImageUploadService();
