import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter_test_app/features/data/datasources/micro_app_data_source.dart';
import 'package:flutter_test_app/features/data/repositories/micro_app_repository_impl.dart';
import 'package:flutter_test_app/features/domain/repositories/micro_app_repository.dart';
import 'package:flutter_test_app/features/domain/usecases/get_micro_app_url.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - MicroApp
  //Use case
  sl.registerLazySingleton(() => GetMicroApp(sl()));

  //Repository
  sl.registerLazySingleton<MicroAppRepository>(
      () => MicroAppRepositoryImpl(remoteDataSource: sl()));

  //Data sources
  sl.registerLazySingleton<MicroAppRemoteDataSource>(() => MicroAppRemoteDataSourceImpl(client: sl()));

  //External
  sl.registerLazySingleton(() => http.Client());
}
