import 'dart:async';
import 'dart:io';
import 'package:flutter_test_app/core/error/failures.dart';
import 'package:flutter_test_app/features/domain/usecases/get_micro_app_url.dart';
import 'package:flutter_test_app/features/presentation/bloc/micro_app_event.dart';
import 'package:flutter_test_app/features/presentation/bloc/micro_app_state.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

import './bloc.dart';

const String FAILURE_MESSAGE = 'Server Failure';

class MicroAppBloc extends Bloc<MicroAppEvent, MicroAppState> {
  final GetMicroApp getMicroApp;

  MicroAppBloc({
    @required GetMicroApp microApp,
  })  : assert(microApp != null),
        getMicroApp = microApp;

  @override
  MicroAppState get initialState => Empty();

  @override
  Stream<MicroAppState> mapEventToState(
    MicroAppEvent event,
  ) async* {
    print('aloo bloc');
    print('event..: $event');
    if (event is GetUrlForMicroApp) {
      final failureOrFile = await getMicroApp(Params(microAppId: 'microapp1'));
      yield* _eitherLoadedOrErrorState(failureOrFile);
      //final failureOrTrivia = await getConcreteNumberTrivia(Params(number: integer));
      //yield* _eitherLoadedOrErrorState(failureOrTrivia);
    }
  }

  Stream<MicroAppState> _eitherLoadedOrErrorState(
    Either<Failure, String> failureOrFile,
  ) async* {
    yield failureOrFile.fold(
      (failure) => Error(message: _mapFailureToMessage(failure)),
      (url) {
        print('MICROAPP:: either loaded.. url:: $url');
        _readFile(url);
        return Loaded(url: url);
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return FAILURE_MESSAGE;
      default:
        return 'Unexpected error';
    }
  }

  Future<void> _readFile(String path) async {
    //Access to content
    //Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    //String appDocumentsPath = appDocumentsDirectory.path;
    //String filePath = '$appDocumentsPath/microapp1/index.html';

    File file = File(path);
    String fileContent = await file.readAsString();

    print('MICROAPP:: File Content in bloc: $fileContent');
  }
}
