// Reference: https://docs.flutter.dev/app-architecture/design-patterns/result

sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success;

  factory Result.error(String errorMessage, {int? statusCode}) = Failure;
}

/// Represents a successful result containing a value of type T as [value].
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

/// Represents a failed result containing an error message and an optional status code. with [errorMessage] and [statusCode].
class Failure<T> extends Result<T> {
  final String errorMessage;
  final int? statusCode;

  const Failure(this.errorMessage, {this.statusCode});

  @override
  String toString() => errorMessage;
}