import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../repositories/micro_app_repository.dart';

class GetMicroApp implements UseCase<String, Params> {
  final MicroAppRepository repository;

  GetMicroApp(this.repository);

  @override
  Future<Either<Failure, String>> call(Params params) async {
    print('MICROAPP:: usecase download: ' + params.microAppId);
    return await repository.getMicroAppUrl(params.microAppId);
  }
}

class Params extends Equatable {
  final String microAppId;

  Params({@required this.microAppId});

  @override
  List<Object> get props => [microAppId];
}