import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Asset or file missing / unreadable.
class NotFoundFailure extends Failure {
  const NotFoundFailure(String resource) : super('Not found: $resource');
}

/// Story JSON exists but is malformed or has broken node links.
class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
