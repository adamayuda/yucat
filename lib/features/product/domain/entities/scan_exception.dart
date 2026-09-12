/// A scan call that failed, with the callable's error code preserved.
///
/// `RemoteSearchDataSource` used to rethrow a plain `Exception('Failed to
/// fetch…: $e')`, which destroyed the `FirebaseFunctionsException` type — so
/// `HomeBloc` could only string-match on the message, offline scans surfaced as
/// "Something went wrong", and analytics reported every non-not-found failure
/// as `error_type: 'error'`.
///
/// [code] is the Firebase callable code (`deadline-exceeded`, `unavailable`,
/// `unauthenticated`, `resource-exhausted`, `invalid-argument`, `internal`, …)
/// or `unknown` for anything that was not a callable failure.
class ScanException implements Exception {
  final String code;
  final String? message;

  const ScanException({required this.code, this.message});

  static const unknownCode = 'unknown';

  @override
  String toString() =>
      'ScanException($code)${message != null ? ': $message' : ''}';
}
