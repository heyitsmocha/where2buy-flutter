// Reference: https://docs.flutter.dev/app-architecture/design-patterns/result

sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success;

  factory Result.error(String errorMessage, {int? statusCode}) = Failure;
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String errorMessage;
  final int? statusCode;

  const Failure(this.errorMessage, {this.statusCode});

  @override
  String toString() => errorMessage;
}