class QrCodeCreationResult {
  const QrCodeCreationResult({
    required this.success,
    required this.unikey,
    this.message,
  });

  final bool success;
  final String unikey;
  final String? message;
}

class QrCodeStatusResult {
  const QrCodeStatusResult({
    required this.code,
    this.message,
  });

  final int code;
  final String? message;
}
