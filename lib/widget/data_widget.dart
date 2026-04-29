import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

/// 根据请求结果数据构建子组件。
typedef RequestChildBuilder<T> = Widget Function(T data);

/// FutureBuilder 的轻量封装。
class DataWidget<T> extends StatefulWidget {
  /// FutureBuilder 的 builder。
  final AsyncWidgetBuilder<T> builder;

  /// 需要监听的异步任务。
  final Future<T>? future;

  /// 创建异步数据组件。
  const DataWidget({Key? key, required this.builder, this.future})
      : super(key: key);

  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState<T> extends State<DataWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: widget.builder,
      future: widget.future,
    );
  }
}

/// 根据 AsyncSnapshot 展示加载、错误、空态或内容组件。
class DataView<T> extends StatefulWidget {
  /// 当前异步快照。
  final AsyncSnapshot<T> snapshot;

  /// 有数据时展示的内容。
  final Widget childBuilder;

  /// 空态组件。
  final Widget? emptyView;

  /// 错误态组件。
  final Widget? errorView;

  /// 加载态组件。
  final Widget? loadingView;

  /// 创建异步快照视图。
  const DataView(
      {Key? key,
      required this.snapshot,
      required this.childBuilder,
      this.emptyView,
      this.errorView,
      this.loadingView})
      : super(key: key);

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState<T> extends State<DataView<T>> {
  @override
  Widget build(BuildContext context) {
    var returnWidget = widget.loadingView ?? const LoadingView();
    if (widget.snapshot.connectionState == ConnectionState.done) {
      if (widget.snapshot.hasError ||
          widget.snapshot.error != null ||
          !widget.snapshot.hasData) {
        returnWidget = widget.errorView ?? const Text('错误');
      }
      returnWidget = widget.childBuilder;
    }
    return returnWidget;
  }
}

/// 通用加载态视图。
class LoadingView extends StatelessWidget {
  /// 加载提示文本。
  final String? tips;

  /// 创建加载态视图。
  const LoadingView({Key? key, this.tips}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Lottie.asset('assets/lottie/empty_status.json',
          height: MediaQuery.sizeOf(context).width / 3.5,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.low),
    );
  }
}

/// 通用空态视图。
class EmptyView extends StatelessWidget {
  /// 创建空态视图。
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SvgPicture.asset(AppIcons.loading,width: context.width/2.9,),
          Lottie.asset('assets/lottie/empty.json',
              height: size.width / 2,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.low),
          const Text('暂无数据...', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }
}

/// 通用错误态视图。
class ErrorView extends StatelessWidget {
  /// 创建错误态视图。
  const ErrorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // SvgPicture.asset(AppIcons.loading,width: context.width/2.9,),
          Lottie.asset('assets/lottie/no_internet_connection.json',
              height: size.width / 2.5,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.low),
          const Text('网络错误', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }
}
