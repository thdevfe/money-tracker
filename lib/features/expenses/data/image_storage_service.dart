import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageStorageService {
  static const _uuid = Uuid();

  Future<String> saveImage(XFile picked) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${docsDir.path}/receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final ext = picked.path.split('.').last;
    final fileName = '${_uuid.v4()}.$ext';
    final destPath = '${receiptsDir.path}/$fileName';
    await File(picked.path).copy(destPath);
    return destPath;
  }

  Future<void> deleteImage(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
