import 'dart:convert';
import 'dart:io';
import 'package:cloudinary/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'package:video_compress/video_compress.dart';

class StorageService {
  static const String cloudName = 'deegjkzbd';
  static const String uploadPreset = 'letien3012';
  final cloudinary = Cloudinary.unsignedConfig(
    cloudName: cloudName,
  );

  static const String apiUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/auto/upload';
  Future<String?> uploadFile(
      File file, String type, String folder, String userId) async {
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
      String folderPath = '$userId/$type/$folder';
      final response = await cloudinary.unsignedUpload(
        uploadPreset: uploadPreset,
        file: uploadFile.path,
        resourceType: type == 'image'
            ? CloudinaryResourceType.image
            : CloudinaryResourceType.video,
        fileBytes: file.readAsBytesSync(),
        fileName: '${DateTime.now().millisecondsSinceEpoch}_image',
        folder: folderPath,
      );

      return response.secureUrl;
    } catch (e) {
      print('Lỗi $e');
      return null;
    }
  }
}
