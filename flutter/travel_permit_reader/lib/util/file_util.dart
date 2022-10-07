import 'dart:io';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart' as sysPaths;

class FileUtil {
  static Future<File> downloadTempFile(
      Future<Response> Function() download, String defaultName) async {
    final folder = await sysPaths.getTemporaryDirectory();

    final response = await download();
    final name =
        getFilenameFromHeader(response.headers['content-disposition']) ??
            defaultName;

    return await File('${folder.path}/$name')
        .writeAsBytes(response.bodyBytes, flush: true);
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
}
