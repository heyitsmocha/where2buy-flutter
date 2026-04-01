// Reference: https://docs.flutter.dev/app-architecture/design-patterns/result

sealed class Result<T> {
  const Result();

  factory Result.success(T value) = Success;

  factory Result.error(Exception error) = Failure;
}

class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final Exception error;

  const Failure(this.error);
}