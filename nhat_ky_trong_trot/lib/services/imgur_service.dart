import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImgurService {
  // Imgur Client ID - Replace with your own
  static const String clientId = '87e30c2bb5972ae';
  static const String apiUrl = 'https://api.imgur.com/3/image';

  // Upload image to Imgur and return the URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Convert image to base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Prepare the request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Client-ID $clientId',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'image': base64Image},
      );

      // Check response
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          // Return the URL of the uploaded image
          return jsonResponse['data']['link'];
        }
      }

      print('Imgur upload error: ${response.statusCode}, ${response.body}');
      return null;
    } catch (e) {
      print('Error uploading to Imgur: $e');
      return null;
    }
  }
}
