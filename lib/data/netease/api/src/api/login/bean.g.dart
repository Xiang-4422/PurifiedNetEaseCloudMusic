// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NeteaseAccount _$NeteaseAccountFromJson(Map<String, dynamic> json) =>
    NeteaseAccount()
      ..id = dynamicToString(json['id'])
      ..userName = json['userName'] as String?
      ..type = (json['type'] as num?)?.toInt()
      ..status = (json['status'] as num?)?.toInt()
      ..createTime = (json['createTime'] as num?)?.toInt()
      ..vipType = (json['vipType'] as num?)?.toInt()
      ..viptypeVersion = (json['viptypeVersion'] as num?)?.toInt()
      ..anonimousUser = json['anonimousUser'] as bool?;

Map<String, dynamic> _$NeteaseAccountToJson(NeteaseAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'type': instance.type,
      'status': instance.status,
      'createTime': instance.createTime,
      'vipType': instance.vipType,
      'viptypeVersion': instance.viptypeVersion,
      'anonimousUser': instance.anonimousUser,
    };

NeteaseAccountProfile _$NeteaseAccountProfileFromJson(
        Map<String, dynamic> json) =>
    NeteaseAccountProfile()
      ..userId = dynamicToString(json['userId'])
      ..nickname = json['nickname'] as String?
      ..avatarUrl = json['avatarUrl'] as String?
      ..backgroundUrl = json['backgroundUrl'] as String?
      ..signature = json['signature'] as String?
      ..description = json['description'] as String?
      ..detailDescription = json['detailDescription'] as String?
      ..recommendReason = json['recommendReason'] as String?
      ..gender = (json['gender'] as num?)?.toInt()
      ..authority = (json['authority'] as num?)?.toInt()
      ..birthday = (json['birthday'] as num?)?.toInt()
      ..city = (json['city'] as num?)?.toInt()
      ..province = (json['province'] as num?)?.toInt()
      ..vipType = (json['vipType'] as num?)?.toInt()
      ..authenticationTypes = (json['authenticationTypes'] as num?)?.toInt()
      ..authStatus = (json['authStatus'] as num?)?.toInt()
      ..djStatus = (json['djStatus'] as num?)?.toInt()
      ..accountStatus = (json['accountStatus'] as num?)?.toInt()
      ..expertTags = (json['expertTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..alg = json['alg'] as String?
      ..followed = json['followed'] as bool?
      ..mutual = json['mutual'] as bool?
      ..anchor = json['anchor'] as bool?
      ..defaultAvatar = json['defaultAvatar'] as bool?
      ..follows = (json['follows'] as num?)?.toInt()
      ..playlistCount = (json['playlistCount'] as num?)?.toInt()
      ..followeds = (json['followeds'] as num?)?.toInt();

Map<String, dynamic> _$NeteaseAccountProfileToJson(
        NeteaseAccountProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'avatarUrl': instance.avatarUrl,
      'backgroundUrl': instance.backgroundUrl,
      'signature': instance.signature,
      'description': instance.description,
      'detailDescription': instance.detailDescription,
      'recommendReason': instance.recommendReason,
      'gender': instance.gender,
      'authority': instance.authority,
      'birthday': instance.birthday,
      'city': instance.city,
      'province': instance.province,
      'vipType': instance.vipType,
      'authenticationTypes': instance.authenticationTypes,
      'authStatus': instance.authStatus,
      'djStatus': instance.djStatus,
      'accountStatus': instance.accountStatus,
      'expertTags': instance.expertTags,
      'alg': instance.alg,
      'followed': instance.followed,
      'mutual': instance.mutual,
      'anchor': instance.anchor,
      'defaultAvatar': instance.defaultAvatar,
      'follows': instance.follows,
      'playlistCount': instance.playlistCount,
      'followeds': instance.followeds,
    };

NeteaseAccountInfoWrap _$NeteaseAccountInfoWrapFromJson(
        Map<String, dynamic> json) =>
    NeteaseAccountInfoWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..loginType = (json['loginType'] as num?)?.toInt()
      ..account = json['account'] == null
          ? null
          : NeteaseAccount.fromJson(json['account'] as Map<String, dynamic>)
      ..profile = json['profile'] == null
          ? null
          : NeteaseAccountProfile.fromJson(
              json['profile'] as Map<String, dynamic>);

Map<String, dynamic> _$NeteaseAccountInfoWrapToJson(
        NeteaseAccountInfoWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'loginType': instance.loginType,
      'account': instance.account,
      'profile': instance.profile,
    };

NeteaseAccountBinding _$NeteaseAccountBindingFromJson(
        Map<String, dynamic> json) =>
    NeteaseAccountBinding()
      ..id = dynamicToString(json['id'])
      ..userId = dynamicToString(json['userId'])
      ..tokenJsonStr = json['tokenJsonStr'] as String?
      ..url = json['url'] as String?
      ..type = (json['type'] as num?)?.toInt()
      ..expiresIn = (json['expiresIn'] as num?)?.toInt()
      ..refreshTime = (json['refreshTime'] as num?)?.toInt()
      ..bindingTime = (json['bindingTime'] as num?)?.toInt()
      ..expired = json['expired'] as bool?;

Map<String, dynamic> _$NeteaseAccountBindingToJson(
        NeteaseAccountBinding instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tokenJsonStr': instance.tokenJsonStr,
      'url': instance.url,
      'type': instance.type,
      'expiresIn': instance.expiresIn,
      'refreshTime': instance.refreshTime,
      'bindingTime': instance.bindingTime,
      'expired': instance.expired,
    };

NeteaseAccountBindingWrap _$NeteaseAccountBindingWrapFromJson(
        Map<String, dynamic> json) =>
    NeteaseAccountBindingWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..bindings = (json['bindings'] as List<dynamic>)
          .map((e) => NeteaseAccountBinding.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$NeteaseAccountBindingWrapToJson(
        NeteaseAccountBindingWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'bindings': instance.bindings,
    };

CellPhoneCheckExistenceRet _$CellPhoneCheckExistenceRetFromJson(
        Map<String, dynamic> json) =>
    CellPhoneCheckExistenceRet()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..exist = (json['exist'] as num?)?.toInt()
      ..nickname = json['nickname'] as String?
      ..hasPassword = json['hasPassword'] as bool?;

Map<String, dynamic> _$CellPhoneCheckExistenceRetToJson(
        CellPhoneCheckExistenceRet instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'exist': instance.exist,
      'nickname': instance.nickname,
      'hasPassword': instance.hasPassword,
    };

AnonimousLoginRet _$AnonimousLoginRetFromJson(Map<String, dynamic> json) =>
    AnonimousLoginRet()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..userId = dynamicToString(json['userId']);

Map<String, dynamic> _$AnonimousLoginRetToJson(AnonimousLoginRet instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'userId': instance.userId,
    };

QrCodeLoginKey _$QrCodeLoginKeyFromJson(Map<String, dynamic> json) =>
    QrCodeLoginKey()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..unikey = json['unikey'] as String;

Map<String, dynamic> _$QrCodeLoginKeyToJson(QrCodeLoginKey instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'unikey': instance.unikey,
    };
