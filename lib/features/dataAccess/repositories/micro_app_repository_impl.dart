import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/repositories/micro_app_repository.dart';
import '../datasources/micro_app_data_source.dart';

class MicroAppRepositoryImpl implements MicroAppRepository {
  final MicroAppRemoteDataSource remoteDataSource;
  String _dir;

  MicroAppRepositoryImpl({
    @required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> getMicroAppUrl(String microAppId) async {
    _dir = (await getApplicationDocumentsDirectory()).path;

    var zippedFile = await remoteDataSource.getZip(microAppId);
    await unarchiveAndSave(zippedFile);
    String filePath = '$_dir/$microAppId/index.html';

    final uri = Uri.directory(filePath);
    final uriString = uri.toString().substring(0, uri.toString().length - 1);
    return Right(filePath);
  }

  unarchiveAndSave(var zippedFile) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);
    for (var file in archive) {
      var fileName = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(fileName);
        try {
          outFile = await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content);
        } on Exception catch (e) {
          print(e);
        }
      }
    }
  }
}
