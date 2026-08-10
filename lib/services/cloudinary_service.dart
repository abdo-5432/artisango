import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  // Use your Cloudinary credentials
  final String cloudName = 'dsfzifcue'; // your cloud name
  final String uploadPreset = 'craftly_preset'; // your preset name

  Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final result = json.decode(String.fromCharCodes(responseData));

      if (response.statusCode == 200) {
        return result['secure_url']; // the image URL
      } else {
        print('Cloudinary error: ${result['error']}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
