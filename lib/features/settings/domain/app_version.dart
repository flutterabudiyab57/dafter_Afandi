import 'package:equatable/equatable.dart';

final class AppVersion extends Equatable {
  const AppVersion({required this.name, required this.build});

  final String name;
  final String build;

  /// `1.0.0 (1)`. Always Latin digits (FR-011).
  String get display => '$name ($build)';

  @override
  List<Object?> get props => [name, build];
}

abstract interface class AppVersionSource {
  Future<AppVersion> read();
}
