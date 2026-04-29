class ImageUrlNormalizer {
  const ImageUrlNormalizer._();

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
