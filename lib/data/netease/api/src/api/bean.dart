import 'package:json_annotation/json_annotation.dart';

import '../../src/netease_bean.dart';

part 'bean.g.dart';

/// ServerStatusBean。
@JsonSerializable()
class ServerStatusBean {
  /// code。
  @JsonKey(fromJson: dynamicToInt)
  late int code;

  /// message。
  String? message;

  /// msg。
  String? msg;

  /// codeEnum。
  RetCode get codeEnum {
    return valueOfCode(code);
  }

  /// realMsg。
  String get realMsg {
    return message ?? msg ?? '';
  }

  /// 创建 ServerStatusBean。
  ServerStatusBean();

  /// 创建 ServerStatusBean。
  factory ServerStatusBean.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusBeanFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ServerStatusBeanToJson(this);
}

/// ServerStatusListBean。
@JsonSerializable()
class ServerStatusListBean extends ServerStatusBean {
  /// more。
  bool? more;

  /// hasMore。
  bool? hasMore;

  /// count。
  int? count;

  /// total。
  int? total;

  /// realMore。
  bool get realMore {
    return more ?? hasMore ?? false;
  }

  /// 创建 ServerStatusListBean。
  ServerStatusListBean();

  /// 创建 ServerStatusListBean。
  factory ServerStatusListBean.fromJson(Map<String, dynamic> json) =>
      _$ServerStatusListBeanFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ServerStatusListBeanToJson(this);
}

/// dynamicToString。
String dynamicToString(dynamic value) => value?.toString() ?? '';

/// dynamicToInt。
int dynamicToInt(dynamic value) {
  if (value is double) {
    return value.toInt();
  } else if (value is String) {
    return int.parse(value);
  }
  return value ?? 0;
}
