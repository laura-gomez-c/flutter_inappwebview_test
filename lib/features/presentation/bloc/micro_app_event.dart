import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MicroAppEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetUrlForMicroApp extends MicroAppEvent {
  final String microAppId;

  GetUrlForMicroApp(this.microAppId);

  @override
  List<Object> get props => [microAppId];
}
