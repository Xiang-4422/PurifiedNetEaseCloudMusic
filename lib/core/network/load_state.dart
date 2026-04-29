/// 通用加载状态。
enum LoadStatus {
  /// 正在加载。
  loading,

  /// 已加载到数据。
  data,

  /// 加载完成但没有数据。
  empty,

  /// 加载失败。
  error,
}

/// 单次加载状态模型。
class LoadState<T> {
  /// 创建加载状态。
  const LoadState._({
    required this.status,
    this.data,
    this.error,
    this.stackTrace,
  });

  /// 当前加载状态。
  final LoadStatus status;

  /// 加载成功的数据。
  final T? data;

  /// 加载失败的错误。
  final Object? error;

  /// 加载失败的堆栈。
  final StackTrace? stackTrace;

  /// 创建加载中状态。
  const LoadState.loading() : this._(status: LoadStatus.loading);

  /// 创建空数据状态。
  const LoadState.empty() : this._(status: LoadStatus.empty);

  /// 创建数据状态。
  const LoadState.data(T data)
      : this._(
          status: LoadStatus.data,
          data: data,
        );

  /// 创建错误状态。
  const LoadState.error(
    Object error, {
    StackTrace? stackTrace,
  }) : this._(
          status: LoadStatus.error,
          error: error,
          stackTrace: stackTrace,
        );

  /// 是否正在加载。
  bool get isLoading => status == LoadStatus.loading;

  /// 是否存在有效数据。
  bool get hasData => status == LoadStatus.data && data != null;

  /// 是否为空数据状态。
  bool get isEmpty => status == LoadStatus.empty;

  /// 是否为错误状态。
  bool get hasError => status == LoadStatus.error;
}

/// 分页列表加载状态模型。
class PagedState<T> {
  /// 创建分页状态。
  const PagedState({
    required this.items,
    required this.hasMore,
    this.initialLoading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.error,
    this.stackTrace,
  });

  /// 当前已加载条目。
  final List<T> items;

  /// 是否处于首次加载。
  final bool initialLoading;

  /// 是否正在刷新。
  final bool refreshing;

  /// 是否正在加载更多。
  final bool loadingMore;

  /// 是否还有下一页。
  final bool hasMore;

  /// 当前错误。
  final Object? error;

  /// 当前错误堆栈。
  final StackTrace? stackTrace;

  static const Object _sentinel = Object();

  /// 创建首次加载状态。
  factory PagedState.initialLoading() {
    return const PagedState(
      items: [],
      hasMore: true,
      initialLoading: true,
    );
  }

  /// 创建分页数据状态。
  factory PagedState.data(
    List<T> items, {
    required bool hasMore,
  }) {
    return PagedState(
      items: items,
      hasMore: hasMore,
    );
  }

  /// 创建分页错误状态。
  factory PagedState.error(
    Object error, {
    StackTrace? stackTrace,
    List<T> items = const [],
    bool hasMore = true,
  }) {
    return PagedState(
      items: items,
      hasMore: hasMore,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// 复制分页状态并替换指定字段。
  PagedState<T> copyWith({
    List<T>? items,
    bool? initialLoading,
    bool? refreshing,
    bool? loadingMore,
    bool? hasMore,
    Object? error = _sentinel,
    Object? stackTrace = _sentinel,
  }) {
    return PagedState(
      items: items ?? this.items,
      initialLoading: initialLoading ?? this.initialLoading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: identical(error, _sentinel) ? this.error : error,
      stackTrace: identical(stackTrace, _sentinel)
          ? this.stackTrace
          : stackTrace as StackTrace?,
    );
  }

  /// 当前分页是否为空。
  bool get isEmpty =>
      !initialLoading && !refreshing && items.isEmpty && error == null;

  /// 是否是首次加载失败。
  bool get hasInitialError => error != null && items.isEmpty;
}
