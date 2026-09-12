import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalImageStorage {
  LocalImageStorage._();

  static const String _inventoryImageFolder = 'inventory_images';

  static Future<String?> pickAndStoreImage({
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      return null;
    }

    final sourceFile = File(pickedFile.path);
    if (!sourceFile.existsSync()) {
      return null;
    }

    final targetDirectory = await _inventoryImageDirectory();
    final extension = p.extension(sourceFile.path).toLowerCase();
    final fileExtension = extension.isEmpty ? '.jpg' : extension;

    final random = Random();
    final fileName =
        'inv_${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(1 << 32)}$fileExtension';

    final destinationFile = File(p.join(targetDirectory.path, fileName));
    final copied = await sourceFile.copy(destinationFile.path);
    return copied.path;
  }

  static Future<void> deleteIfManaged(String? filePath) async {
    final normalizedPath = (filePath ?? '').trim();
    if (normalizedPath.isEmpty) {
      return;
    }

    final file = File(normalizedPath);
    if (!file.existsSync()) {
      return;
    }

    final targetDirectory = await _inventoryImageDirectory();
    final managedPrefix = '${p.normalize(targetDirectory.path)}${p.separator}';
    final candidatePath = p.normalize(file.path);

    if (!candidatePath.startsWith(managedPrefix)) {
      return;
    }

    await file.delete();
  }

  static Future<Directory> _inventoryImageDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    final target = Directory(p.join(appDirectory.path, _inventoryImageFolder));
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }
    return target;
  }
}
