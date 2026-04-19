enum LoadStatus {
  loading,
  data,
  empty,
  error,
}

class LoadState<T> {
  const LoadState._({
    required this.status,
    this.data,
    this.error,
    this.stackTrace,
  });

  final LoadStatus status;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const LoadState.loading() : this._(status: LoadStatus.loading);

  const LoadState.empty() : this._(status: LoadStatus.empty);

  const LoadState.data(T data)
      : this._(
          status: LoadStatus.data,
          data: data,
        );

  const LoadState.error(
    Object error, {
    StackTrace? stackTrace,
  }) : this._(
          status: LoadStatus.error,
          error: error,
          stackTrace: stackTrace,
        );

  bool get isLoading => status == LoadStatus.loading;

  bool get hasData => status == LoadStatus.data && data != null;

  bool get isEmpty => status == LoadStatus.empty;

  bool get hasError => status == LoadStatus.error;
}

class PagedState<T> {
  const PagedState({
    required this.items,
    required this.hasMore,
    this.initialLoading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.error,
    this.stackTrace,
  });

  final List<T> items;
  final bool initialLoading;
  final bool refreshing;
  final bool loadingMore;
  final bool hasMore;
  final Object? error;
  final StackTrace? stackTrace;

  static const Object _sentinel = Object();

  factory PagedState.initialLoading() {
    return const PagedState(
      items: [],
      hasMore: true,
      initialLoading: true,
    );
  }

  factory PagedState.data(
    List<T> items, {
    required bool hasMore,
  }) {
    return PagedState(
      items: items,
      hasMore: hasMore,
    );
  }

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

  bool get isEmpty =>
      !initialLoading && !refreshing && items.isEmpty && error == null;

  bool get hasInitialError => error != null && items.isEmpty;
}
