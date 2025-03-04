import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

class StorageService {
  static const String cloudName = 'deegjkzbd';
  static const String uploadPreset = 'letien3012';
  static const String apiUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';
  Future<String?> uploadFile(File file, String type) async {
    try {
      File uploadFile = file;
      if (type == 'video') {
        final compressVideo = await VideoCompress.compressVideo(
          file.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: false,
        );
        if (compressVideo != null) {
          uploadFile = File(compressVideo.path!);
          print("Kích thước video sau nén ${compressVideo.filesize}");
        } else {
          throw Exception('Không thể nén video');
        }
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files
          .add(await http.MultipartFile.fromPath('file', uploadFile.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var json = jsonDecode(responseData.body);
        String downloadUrl = json['secure_url'];
        print('URl $type: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception("'Lỗi tải $type: ${response.statusCode}");
      }
    } catch (e) {
      print('Lỗi $e');
      return null;
    }
  }
}
