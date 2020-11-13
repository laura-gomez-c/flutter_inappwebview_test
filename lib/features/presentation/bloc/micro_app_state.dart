import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class MicroAppState extends Equatable {
  @override
  List<Object> get props => [];
}

class Empty extends MicroAppState {}

class Loading extends MicroAppState {}

class Loaded extends MicroAppState {
  final String url;

  Loaded({@required this.url});

  @override
  List<Object> get props => [url];
}

class Error extends MicroAppState {
  final String message;

  Error({@required this.message});

  @override
  List<Object> get props => [message];
}
