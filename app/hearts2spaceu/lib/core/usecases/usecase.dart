/// Contract every use case implements: call it like a function.
///
/// [T] is the return type, [P] the input. Use [NoParams] when a use case
/// needs no input.
///
/// ```dart
/// class GetUser implements UseCase<User, GetUserParams> {
///   @override
///   Future<User> call(GetUserParams params) => repository.getUser(params.id);
/// }
/// ```
abstract class UseCase<T, P> {
  Future<T> call(P params);
}

/// Placeholder for use cases that take no arguments.
class NoParams {
  const NoParams();
}
