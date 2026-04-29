/// 二维码创建结果。
class QrCodeCreationResult {
  /// 创建二维码创建结果。
  const QrCodeCreationResult({
    required this.success,
    required this.unikey,
    this.message,
  });

  /// 创建是否成功。
  final bool success;

  /// 二维码登录 key。
  final String unikey;

  /// 结果消息。
  final String? message;
}

/// 二维码登录状态结果。
class QrCodeStatusResult {
  /// 创建二维码登录状态结果。
  const QrCodeStatusResult({
    required this.code,
    this.message,
  });

  /// 登录状态码。
  final int code;

  /// 状态消息。
  final String? message;
}
