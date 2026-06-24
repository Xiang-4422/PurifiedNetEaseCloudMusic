/// 应用静态资源路径索引。
class AppAssets {
  AppAssets._();

  /// 图片资源目录。
  static const String imagesDirectory = 'assets/images/';

  /// Lottie 动画资源目录。
  static const String lottieDirectory = 'assets/lottie/';

  /// 应用 Logo 资源路径。
  static const String imagesLogo = '${imagesDirectory}logo.png';

  /// 通用图片占位资源路径。
  static const String imagesPlaceholder = '${imagesDirectory}placeholder.png';

  /// 通用加载动画资源路径。
  static const String lottieLoading = '${lottieDirectory}loading.json';

  /// 音乐播放状态动画资源路径。
  static const String lottieMusicPlaying = '${lottieDirectory}music_playing.json';
}
