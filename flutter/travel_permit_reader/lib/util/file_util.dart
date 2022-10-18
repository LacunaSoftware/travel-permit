import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as sysPaths;
import 'package:permission_handler/permission_handler.dart';
import 'package:travel_permit_reader/api/notification_api.dart';

class FileUtil {
  static Future<File> createFromResponse(
      Response download, String defaultName, bool isTemp) async {
    final name =
        getFilenameFromHeader(download.headers['content-disposition']) ??
            defaultName;

    return await createFromBytes(download.bodyBytes, name, isTemp);
  }

  static Future<File> createFromBytes(
      Uint8List bytes, String name, bool isTemp) async {
    final folder =
        await (isTemp ? sysPaths.getTemporaryDirectory() : getDownloadDir());

    String path = p.join(folder.path, name);
    if (!isTemp) {
      path = await getFileUniquePath(path);
    }

    return await File(path).writeAsBytes(bytes, flush: true);
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
    if (!await askForPermissions()) return null;

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

  static Future<bool> askForPermissions() async {
    final hasPerms = await Permission.storage.status.isGranted ||
        await Permission.storage.request().isGranted;

    if (!hasPerms)
      NotificationApi.showNotification(
          title: 'Permission failed.',
          body:
              'Failed to download file. The app doesn\'t have file managing privileges.');

    return hasPerms;
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
