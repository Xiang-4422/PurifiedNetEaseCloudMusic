import 'package:json_annotation/json_annotation.dart';

import '../../client/netease_bean.dart';

part 'bean.g.dart';

/// 通用接口状态响应。
@JsonSerializable()
class ServerStatusBean {
  /// 接口状态码。
  @JsonKey(fromJson: dynamicToInt)
  late int code;

  /// 接口返回的完整提示信息。
  String? message;

  /// 接口返回的短提示信息。
  String? msg;

  /// 状态码对应的归一化枚举。
  RetCode get codeEnum {
    return valueOfCode(code);
  }

  /// 优先从 [message] 读取、再退回 [msg] 的提示文案。
  String get realMsg {
    return message ?? msg ?? '';
  }

  /// 创建通用接口状态响应。
  ServerStatusBean();

  /// 从 JSON 构建通用接口状态响应。
  factory ServerStatusBean.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusBeanFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ServerStatusBeanToJson(this);
}

/// 带分页字段的通用接口状态响应。
@JsonSerializable()
class ServerStatusListBean extends ServerStatusBean {
  /// 接口返回的下一页标记。
  bool? more;

  /// 部分接口使用的下一页标记。
  bool? hasMore;

  /// 当前页数量或总数。
  int? count;

  /// 总数量。
  int? total;

  /// 归一化后的下一页标记。
  bool get realMore {
    return more ?? hasMore ?? false;
  }

  /// 创建带分页字段的通用接口状态响应。
  ServerStatusListBean();

  /// 从 JSON 构建带分页字段的通用接口状态响应。
  factory ServerStatusListBean.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusListBeanFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ServerStatusListBeanToJson(this);
}

/// 将动态值转换为字符串。
String dynamicToString(dynamic value) => value?.toString() ?? '';

/// 将动态值转换为整数，兼容字符串和 double。
int dynamicToInt(dynamic value) {
  if (value is double) {
    return value.toInt();
  } else if (value is String) {
    return int.parse(value);
  }
  return value ?? 0;
}
