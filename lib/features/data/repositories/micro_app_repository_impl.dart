import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import '../../domain/repositories/micro_app_repository.dart';
import '../datasources/micro_app_data_source.dart';

class MicroAppRepositoryImpl implements MicroAppRepository {

  final MicroAppRemoteDataSource remoteDataSource;

  MicroAppRepositoryImpl({
    @required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> getMicroAppUrl(String microAppId) async {
    var zippedFile = await remoteDataSource.getZip(microAppId);
    print('file obtained');
    await unarchiveAndSave(zippedFile);
    print('file unarchived');

    //Access to content
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String appDocumentsPath = appDocumentsDirectory.path;
    String filePath = '$appDocumentsPath/$microAppId/index.html';
    print('filePath:: $filePath');

    final uri = Uri.directory(filePath);
    final uriString = uri.toString().substring(0, uri.toString().length - 1); /// Remove final slash symbol*/

    return Right(uriString);
  }

  unarchiveAndSave(var zippedFile) async {
    String _dir = (await getApplicationDocumentsDirectory()).path;
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);

        print('File:: ' + outFile.path);

        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
        print('File written');
      }
    }
  }
}
