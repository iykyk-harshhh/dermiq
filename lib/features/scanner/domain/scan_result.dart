import 'scan_failure.dart';

/// A lightweight Result/Either type: success ([Ok]) or failure ([Err]).
/// Keeps exceptions out of the presentation layer.
sealed class Result<T> {
  const Result();

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;

  /// The value if [Ok], else null.
  T? get valueOrNull => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>() => null,
      };

  /// The failure if [Err], else null.
  ScanFailure? get failureOrNull => switch (this) {
        Ok<T>() => null,
        Err<T>(:final failure) => failure,
      };

  R fold<R>(R Function(T value) onOk, R Function(ScanFailure failure) onErr) =>
      switch (this) {
        Ok<T>(:final value) => onOk(value),
        Err<T>(:final failure) => onErr(failure),
      };
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final ScanFailure failure;
  const Err(this.failure);
}
