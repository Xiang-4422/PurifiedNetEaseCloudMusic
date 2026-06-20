/// 应用关键性能指标定义。
class AppPerformanceMetric {
  /// 创建关键性能指标定义。
  const AppPerformanceMetric({
    required this.key,
    required this.eventName,
    required this.label,
    required this.targetMs,
    required this.description,
  });

  /// 稳定指标键，用于文档、测试和外部统计对齐。
  final String key;

  /// 日志事件名。
  final String eventName;

  /// 中文指标名。
  final String label;

  /// 当前阶段的目标耗时，单位毫秒。
  final int targetMs;

  /// 指标说明。
  final String description;

  /// 构建指标耗时日志详情。
  String elapsedDetails({
    required int elapsedMs,
    String details = '',
  }) {
    final budgetMs = targetMs - elapsedMs;
    final budgetDetails = budgetMs >= 0 ? 'status=ok remaining=${budgetMs}ms' : 'status=slow over=${-budgetMs}ms';
    final metricDetails = 'metric=$key target=${targetMs}ms $budgetDetails';
    if (details.isEmpty) {
      return metricDetails;
    }
    return '$metricDetails $details';
  }
}

/// 应用必须长期跟踪的关键性能指标。
class AppPerformanceMetrics {
  AppPerformanceMetrics._();

  /// 冷启动到首个可交互页面。
  static const coldStartInteractive = AppPerformanceMetric(
    key: 'cold_start_interactive',
    eventName: 'app.startup.interactive',
    label: '冷启动到可交互',
    targetMs: 1500,
    description: '从进程启动到首页或恢复页可以响应用户操作。',
  );

  /// 已缓存歌单打开耗时。
  static const cachedPlaylistOpen = AppPerformanceMetric(
    key: 'cached_playlist_open',
    eventName: 'page.loadInitial.total',
    label: '打开已有缓存歌单',
    targetMs: 500,
    description: '歌单页读取本地缓存并完成首屏列表展示。',
  );

  /// 用户切歌到播放源替换完成。
  static const trackSwitch = AppPerformanceMetric(
    key: 'track_switch',
    eventName: 'switch.total',
    label: '切歌响应',
    targetMs: 300,
    description: '从用户切歌意图到播放器确认新播放源。',
  );

  /// 搜索首批结果可展示耗时。
  static const searchFirstResults = AppPerformanceMetric(
    key: 'search_first_results',
    eventName: 'search.firstResults.total',
    label: '搜索首批结果',
    targetMs: 800,
    description: '从提交搜索词到首批搜索结果状态写入控制器。',
  );

  /// mini player 控制反馈耗时。
  static const miniPlayerFeedback = AppPerformanceMetric(
    key: 'mini_player_feedback',
    eventName: 'miniPlayer.feedback.total',
    label: 'mini player 控制反馈',
    targetMs: 120,
    description: '播放、暂停等高频控制命令完成反馈。',
  );

  /// 当前核心指标集合。
  static const all = <AppPerformanceMetric>[
    coldStartInteractive,
    cachedPlaylistOpen,
    trackSwitch,
    searchFirstResults,
    miniPlayerFeedback,
  ];

  /// 按 key 查找指标。
  static AppPerformanceMetric byKey(String key) {
    return all.firstWhere((metric) => metric.key == key);
  }
}
