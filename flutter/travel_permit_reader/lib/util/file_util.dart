import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart' as sysPaths;

class FileUtil {
  static Future<File> writeFile(
      Future<Uint8List> Function() getFileBytes, String name) async {
    final folder = await sysPaths.getTemporaryDirectory();
    final file = File('${folder.path}/$name');
    if (!await file.exists()) {
      await file.writeAsBytes(await getFileBytes(), flush: true);
    }

    return file;
  }
}
