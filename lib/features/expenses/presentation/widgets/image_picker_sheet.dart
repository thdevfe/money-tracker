import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> showImagePickerSheet(BuildContext context) async {
  final picker = ImagePicker();

  return showModalBottomSheet<XFile?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () async {
                  final file =
                      await picker.pickImage(source: ImageSource.camera);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Library'),
                onTap: () async {
                  final file =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop(file);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
