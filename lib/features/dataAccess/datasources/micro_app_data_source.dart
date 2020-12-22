import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../../core/error/exceptions.dart';

abstract class MicroAppRemoteDataSource {
  Future<File> getZip(String fileZipName);
}

class MicroAppRemoteDataSourceImpl implements MicroAppRemoteDataSource {
  final http.Client client;

  MicroAppRemoteDataSourceImpl({@required this.client});

  @override
  Future<File> getZip(String fileZipName) => _downloadFile(fileZipName);

  Future<File> _downloadFile(String fileZipName) async {
    String _dir = (await getApplicationDocumentsDirectory()).path;
    var response = await client.get(Uri.parse(
        'https://github.com/laura-gomez-c/assets_flutter_test/blob/main/$fileZipName.zip?raw=true'));

    print('status code response:: ' + response.statusCode.toString());
    var file = File('$_dir/$fileZipName.zip');
    try {
      return file.writeAsBytes(response.bodyBytes);
    } on Exception catch (e) {
      print(e);
    }
  }
}
