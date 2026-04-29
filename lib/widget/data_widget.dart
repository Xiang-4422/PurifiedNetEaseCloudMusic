import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

/// RequestChildBuilder。
typedef RequestChildBuilder<T> = Widget Function(T data);

/// DataWidget。
class DataWidget<T> extends StatefulWidget {
  /// builder。
  final AsyncWidgetBuilder<T> builder;

  /// future。
  final Future<T>? future;

  /// 创建 DataWidget。
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

/// DataView。
class DataView<T> extends StatefulWidget {
  /// snapshot。
  final AsyncSnapshot<T> snapshot;

  /// childBuilder。
  final Widget childBuilder;

  /// emptyView。
  final Widget? emptyView;

  /// errorView。
  final Widget? errorView;

  /// loadingView。
  final Widget? loadingView;

  /// 创建 DataView。
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

/// LoadingView。
class LoadingView extends StatelessWidget {
  /// tips。
  final String? tips;

  /// 创建 LoadingView。
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

/// EmptyView。
class EmptyView extends StatelessWidget {
  /// 创建 EmptyView。
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

/// ErrorView。
class ErrorView extends StatelessWidget {
  /// 创建 ErrorView。
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
