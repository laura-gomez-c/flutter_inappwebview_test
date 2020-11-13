import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';

abstract class MicroAppRepository {
  Future<Either<Failure, String>> getMicroAppUrl(String microAppId);
}