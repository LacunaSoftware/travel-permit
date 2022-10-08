import 'dart:io';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as sysPaths;
import 'package:permission_handler/permission_handler.dart';

class FileUtil {
  static Future<File> downloadFile(Response download, String defaultName,
      {bool public = false}) async {
    if (public) {
      await askForPermissions();
    }

    final folder =
        await (public ? getDownloadDir() : sysPaths.getTemporaryDirectory());

    final name =
        getFilenameFromHeader(download.headers['content-disposition']) ??
            defaultName;

    String path = p.join(folder.path, name);
    if (public) {
      path = await getFileUniquePath(path);
    }

    return await File(path).writeAsBytes(download.bodyBytes, flush: true);
  }

  static String getFilenameFromHeader(String header) {
    final splits = header.split('filename');
    switch (splits.length) {
      case 2:
        return splits[1].split('"')[1];
      case 3:
        final typeName = splits[2].substring(2).split("''");
        return typeName[0] == "UTF-8"
            ? Uri.decodeFull(typeName[1])
            : splits[1].split('"')[1];
      default:
        return null;
    }
  }

  static Future<File> moveToPublic(File pdf) async {
    await askForPermissions();

    final downloadPath = (await getDownloadDir()).path;
    if (p.dirname(pdf.path) != downloadPath) {
      final newPath =
          await getFileUniquePath(p.join(downloadPath, p.basename(pdf.path)));
      final publicPdf = await pdf.copy(newPath);
      await pdf.delete();
      pdf = publicPdf;
    }

    return pdf;
  }

  static Future askForPermissions() async {
    if (!await Permission.storage.status.isGranted) {
      await Permission.storage.request();
    }
  }

  static Future<Directory> getDownloadDir() async {
    Directory directory;

    if (Platform.isIOS) {
      directory = await sysPaths.getApplicationDocumentsDirectory();
    } else {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await sysPaths.getExternalStorageDirectory();
      }
    }

    return directory;
  }

  static Future<String> getFileUniquePath(String path) async {
    final dirPlusName =
        p.join(p.dirname(path), p.basenameWithoutExtension(path));
    final ext = p.extension(path);

    int counter = 1;
    while (await File(path).exists()) {
      path = '$dirPlusName (${counter++})$ext';
    }

    return path;
  }
}
