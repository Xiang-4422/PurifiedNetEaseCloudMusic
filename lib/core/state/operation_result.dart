/// 通用操作结果。
class OperationResult {
  /// 创建操作结果。
  const OperationResult({
    required this.success,
    this.message,
  });

  /// 操作是否成功。
  final bool success;

  /// 操作结果提示信息。
  final String? message;
}
