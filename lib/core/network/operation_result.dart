class OperationResult {
  const OperationResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;
}
