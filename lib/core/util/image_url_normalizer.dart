/// 图片地址规整工具。
class ImageUrlNormalizer {
  /// 禁止实例化图片地址规整工具类。
  const ImageUrlNormalizer._();

  /// 移除网易云图片地址中的尺寸参数，保留原始图片地址。
  static String normalize(String? url) {
    if (url == null || url.isEmpty || !isRemoteHttpUrl(url)) {
      return url ?? '';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.queryParameters.containsKey('param')) {
      return url;
    }
    final nextQueryParameters = Map<String, String>.from(uri.queryParameters)..remove('param');
    return uri
        .replace(
          queryParameters: nextQueryParameters.isEmpty ? null : nextQueryParameters,
        )
        .toString();
  }

  /// 判断地址是否为远程 HTTP(S) 图片地址。
  ///
  /// URI scheme 本身大小写不敏感；这里统一按解析后的 scheme 判断，避免
  /// `HTTPS://` 这类地址被误认为本地路径。
  static bool isRemoteHttpUrl(String? url) {
    final trimmedUrl = url?.trim() ?? '';
    if (trimmedUrl.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(trimmedUrl);
    final scheme = uri?.scheme.toLowerCase();
    return (scheme == 'http' || scheme == 'https') && uri?.hasAuthority == true;
  }
}
