import 'package:json_annotation/json_annotation.dart';

import '../../../netease_music_api.dart';
import '../../../src/api/bean.dart';

part 'bean.g.dart';

/// NeteaseAccount。
@JsonSerializable()
class NeteaseAccount {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// userName。
  String? userName;

  /// type。
  int? type;

  /// status。
  int? status;

  /// createTime。
  int? createTime;

  /// vipType。
  int? vipType;

  /// viptypeVersion。
  int? viptypeVersion;

  /// anonimousUser。
  bool? anonimousUser;

  /// 创建 NeteaseAccount。
  NeteaseAccount();

  /// 创建 NeteaseAccount。
  factory NeteaseAccount.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$NeteaseAccountToJson(this);
}

/// NeteaseAccountProfile。
@JsonSerializable()
class NeteaseAccountProfile extends NeteaseUserInfo {
  /// follows。
  int? follows;

  /// playlistCount。
  int? playlistCount;

  /// followeds。
  int? followeds;

  /// 创建 NeteaseAccountProfile。
  NeteaseAccountProfile();

  /// 创建 NeteaseAccountProfile。
  factory NeteaseAccountProfile.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountProfileFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountProfileToJson(this);
}

/// NeteaseAccountInfoWrap。
@JsonSerializable()
class NeteaseAccountInfoWrap extends ServerStatusBean {
  /// loginType。
  int? loginType;

  /// account。
  NeteaseAccount? account;

  /// profile。
  NeteaseAccountProfile? profile;

  /// 创建 NeteaseAccountInfoWrap。
  NeteaseAccountInfoWrap();

  /// 创建 NeteaseAccountInfoWrap。
  factory NeteaseAccountInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountInfoWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountInfoWrapToJson(this);
}

/// NeteaseAccountBinding。
@JsonSerializable()
class NeteaseAccountBinding {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// tokenJsonStr。
  String? tokenJsonStr;

  /// url。
  String? url;

  /// type。
  int? type;

  /// expiresIn。
  int? expiresIn;

  /// refreshTime。
  int? refreshTime;

  /// bindingTime。
  int? bindingTime;

  /// expired。
  bool? expired;

  /// 创建 NeteaseAccountBinding。
  NeteaseAccountBinding();

  /// 创建 NeteaseAccountBinding。
  factory NeteaseAccountBinding.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountBindingFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$NeteaseAccountBindingToJson(this);
}

/// NeteaseAccountBindingWrap。
@JsonSerializable()
class NeteaseAccountBindingWrap extends ServerStatusBean {
  /// bindings。
  late List<NeteaseAccountBinding> bindings;

  /// 创建 NeteaseAccountBindingWrap。
  NeteaseAccountBindingWrap();

  /// 创建 NeteaseAccountBindingWrap。
  factory NeteaseAccountBindingWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseAccountBindingWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseAccountBindingWrapToJson(this);
}

/// CellPhoneCheckExistenceRet。
@JsonSerializable()
class CellPhoneCheckExistenceRet extends ServerStatusBean {
  // 1: 存在   -1: 不存在
  /// exist。
  int? exist;

  /// nickname。
  String? nickname;

  /// hasPassword。
  bool? hasPassword;

  /// 账号不存在 或者 没有密码 需要短信登录
  bool get needUseSms => exist != 1 || !(hasPassword ?? true);

  /// 创建 CellPhoneCheckExistenceRet。
  CellPhoneCheckExistenceRet();

  /// 创建 CellPhoneCheckExistenceRet。
  factory CellPhoneCheckExistenceRet.fromJson(Map<String, dynamic> json) =>
      _$CellPhoneCheckExistenceRetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CellPhoneCheckExistenceRetToJson(this);
}

/// AnonimousLoginRet。
@JsonSerializable()
class AnonimousLoginRet extends ServerStatusBean {
  /// userId。
  @JsonKey(fromJson: dynamicToString)
  late String userId;

  /// 创建 AnonimousLoginRet。
  AnonimousLoginRet();

  /// 创建 AnonimousLoginRet。
  factory AnonimousLoginRet.fromJson(Map<String, dynamic> json) =>
      _$AnonimousLoginRetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AnonimousLoginRetToJson(this);
}

/// QrCodeLoginKey。
@JsonSerializable()
class QrCodeLoginKey extends ServerStatusBean {
  /// unikey。
  late String unikey;

  /// 创建 QrCodeLoginKey。
  QrCodeLoginKey();

  /// 创建 QrCodeLoginKey。
  factory QrCodeLoginKey.fromJson(Map<String, dynamic> json) =>
      _$QrCodeLoginKeyFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$QrCodeLoginKeyToJson(this);
}
