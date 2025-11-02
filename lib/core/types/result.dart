class Result<L, R> {
  final L? left;
  final R? right;
  final bool _ok; // <-- success flag independent of payload

  const Result._(this.left, this.right, this._ok);

  // Success; payload optional (ok() or ok(value))
  static Result<L, R> ok<L, R>([R? value]) => Result<L, R>._(null, value, true);

  // Failure; supply a left/failure
  static Result<L, R> err<L, R>(L failure) =>
      Result<L, R>._(failure, null, false);

  bool get isOk => _ok;
}
