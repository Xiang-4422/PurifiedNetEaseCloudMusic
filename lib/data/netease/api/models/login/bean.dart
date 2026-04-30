import 'package:json_annotation/json_annotation.dart';

import '../common/bean.dart';
import '../user/bean.dart';

part 'bean.g.dart';

/// 网易云账号基础信息。
@JsonSerializable()
class NeteaseAccount {
  /// 账号 id，接口可能返回数字或字符串。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 账号用户名。
  String? userName;

  /// 账号类型。
  int? type;

  /// 账号状态。
  int? status;

  /// 账号创建时间戳，单位为毫秒。
  int? createTime;

  /// VIP 类型。
  int? vipType;

  /// VIP 类型版本。
  int? viptypeVersion;

  /// 是否为匿名账号。
  bool? anonimousUser;

  /// 创建账号基础信息。
  NeteaseAccount();

  /// 从 JSON 构建账号基础信息。
  factory NeteaseAccount.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$NeteaseAccountToJson(this);
}

/// 当前登录账号的用户资料。
@JsonSerializable()
class NeteaseAccountProfile extends NeteaseUserInfo {
  /// 当前账号关注数量。
  int? follows;

  /// 当前账号创建或收藏的歌单数量。
  int? playlistCount;

  /// 当前账号粉丝数量。
  int? followeds;

  /// 创建当前登录账号用户资料。
  NeteaseAccountProfile();

  /// 从 JSON 构建当前登录账号用户资料。
  factory NeteaseAccountProfile.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountProfileFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountProfileToJson(this);
}

/// 登录账号信息接口响应。
@JsonSerializable()
class NeteaseAccountInfoWrap extends ServerStatusBean {
  /// 登录方式类型。
  int? loginType;

  /// 账号基础信息。
  NeteaseAccount? account;

  /// 账号用户资料。
  NeteaseAccountProfile? profile;

  /// 创建登录账号信息响应。
  NeteaseAccountInfoWrap();

  /// 从 JSON 构建登录账号信息响应。
  factory NeteaseAccountInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountInfoWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountInfoWrapToJson(this);
}

/// 账号绑定的第三方平台信息。
@JsonSerializable()
class NeteaseAccountBinding {
  /// 绑定记录 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 绑定所属用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 绑定 token 原始 JSON 字符串。
  String? tokenJsonStr;

  /// 绑定平台跳转地址。
  String? url;

  /// 绑定平台类型。
  int? type;

  /// token 有效期，单位由接口返回决定。
  int? expiresIn;

  /// 绑定刷新时间戳。
  int? refreshTime;

  /// 绑定创建时间戳。
  int? bindingTime;

  /// 绑定是否已过期。
  bool? expired;

  /// 创建账号绑定信息。
  NeteaseAccountBinding();

  /// 从 JSON 构建账号绑定信息。
  factory NeteaseAccountBinding.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountBindingFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$NeteaseAccountBindingToJson(this);
}

/// 账号绑定信息列表响应。
@JsonSerializable()
class NeteaseAccountBindingWrap extends ServerStatusBean {
  /// 当前账号的绑定平台列表。
  late List<NeteaseAccountBinding> bindings;

  /// 创建账号绑定信息列表响应。
  NeteaseAccountBindingWrap();

  /// 从 JSON 构建账号绑定信息列表响应。
  factory NeteaseAccountBindingWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountBindingWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountBindingWrapToJson(this);
}

/// 手机号存在性检查响应。
@JsonSerializable()
class CellPhoneCheckExistenceRet extends ServerStatusBean {
  /// 手机号是否存在；1 表示存在，-1 表示不存在。
  int? exist;

  /// 已存在账号的昵称。
  String? nickname;

  /// 已存在账号是否设置了密码。
  bool? hasPassword;

  /// 账号不存在 或者 没有密码 需要短信登录
  bool get needUseSms => exist != 1 || !(hasPassword ?? true);

  /// 创建手机号存在性检查响应。
  CellPhoneCheckExistenceRet();

  /// 从 JSON 构建手机号存在性检查响应。
  factory CellPhoneCheckExistenceRet.fromJson(Map<String, dynamic> json) =>
      _$CellPhoneCheckExistenceRetFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CellPhoneCheckExistenceRetToJson(this);
}

/// 匿名登录响应。
@JsonSerializable()
class AnonimousLoginRet extends ServerStatusBean {
  /// 匿名账号用户 id。
  @JsonKey(fromJson: dynamicToString)
  late String userId;

  /// 创建匿名登录响应。
  AnonimousLoginRet();

  /// 从 JSON 构建匿名登录响应。
  factory AnonimousLoginRet.fromJson(Map<String, dynamic> json) =>
      _$AnonimousLoginRetFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AnonimousLoginRetToJson(this);
}

/// 二维码登录 key 响应。
@JsonSerializable()
class QrCodeLoginKey extends ServerStatusBean {
  /// 二维码登录唯一 key。
  late String unikey;

  /// 创建二维码登录 key 响应。
  QrCodeLoginKey();

  /// 从 JSON 构建二维码登录 key 响应。
  factory QrCodeLoginKey.fromJson(Map<String, dynamic> json) =>
      _$QrCodeLoginKeyFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$QrCodeLoginKeyToJson(this);
}
