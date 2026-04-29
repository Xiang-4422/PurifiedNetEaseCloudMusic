/// 图片地址规整工具。
class ImageUrlNormalizer {
  /// 禁止实例化图片地址规整工具类。
  const ImageUrlNormalizer._();

  /// 移除网易云图片地址中的尺寸参数，保留原始图片地址。
  static String normalize(String? url) {
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      return url ?? '';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.queryParameters.containsKey('param')) {
      return url;
    }
    final nextQueryParameters = Map<String, String>.from(uri.queryParameters)
      ..remove('param');
    return uri
        .replace(
          queryParameters:
              nextQueryParameters.isEmpty ? null : nextQueryParameters,
        )
        .toString();
  }
}
