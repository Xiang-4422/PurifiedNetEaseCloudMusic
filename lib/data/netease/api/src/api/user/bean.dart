import 'package:json_annotation/json_annotation.dart';

import '../../../src/api/bean.dart';
import '../../../src/api/login/bean.dart';
import '../../../src/api/play/bean.dart';

part 'bean.g.dart';

/// UserSetting。
@JsonSerializable()
class UserSetting {
  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// profileSetting。
  int? profileSetting;

  /// ageSetting。
  int? ageSetting;

  /// areaSetting。
  int? areaSetting;

  /// collegeSetting。
  int? collegeSetting;

  /// villageAgeSetting。
  int? villageAgeSetting;

  /// followSingerSetting。
  int? followSingerSetting;

  /// personalServiceSetting。
  int? personalServiceSetting;

  /// concertSetting。
  int? concertSetting;

  /// socialSetting。
  int? socialSetting;

  /// shareSetting。
  int? shareSetting;

  /// playRecordSetting。
  int? playRecordSetting;

  /// broadcastSetting。
  int? broadcastSetting;

  /// commentSetting。
  int? commentSetting;

  //newSongDiskSetting

  /// phoneFriendSetting。
  bool? phoneFriendSetting;

  /// allowFollowedCanSeeMyPlayRecord。
  bool? allowFollowedCanSeeMyPlayRecord;

  /// finishedFollowGuide。
  bool? finishedFollowGuide;

  /// allowOfflinePrivateMessageNotify。
  bool? allowOfflinePrivateMessageNotify;

  /// allowOfflineForwardNotify。
  bool? allowOfflineForwardNotify;

  /// allowOfflineCommentNotify。
  bool? allowOfflineCommentNotify;

  /// allowOfflineCommentReplyNotify。
  bool? allowOfflineCommentReplyNotify;

  /// allowOfflineNotify。
  bool? allowOfflineNotify;

  /// allowVideoSubscriptionNotify。
  bool? allowVideoSubscriptionNotify;

  /// sendMiuiMsg。
  bool? sendMiuiMsg;

  /// allowImportDoubanPlaylist。
  bool? allowImportDoubanPlaylist;

  /// importedDoubanPlaylist。
  late bool importedDoubanPlaylist;

  /// importedXiamiPlaylist。
  late bool importedXiamiPlaylist;

  /// allowImportXiamiPlaylist。
  bool? allowImportXiamiPlaylist;

  /// allowSubscriptionNotify。
  bool? allowSubscriptionNotify;

  /// allowLikedNotify。
  bool? allowLikedNotify;

  /// allowNewFollowerNotify。
  bool? allowNewFollowerNotify;

  /// needRcmdEvent。
  bool? needRcmdEvent;

  /// allowPlaylistShareNotify。
  bool? allowPlaylistShareNotify;

  /// allowDJProgramShareNotify。
  bool? allowDJProgramShareNotify;

  /// allowDJRadioSubscriptionNotify。
  bool? allowDJRadioSubscriptionNotify;

  /// allowPeopleCanSeeMyPlaynNotify。
  bool? allowPeopleCanSeeMyPlaynNotify;

  /// peopleNearbyCanSeeMe。
  bool? peopleNearbyCanSeeMe;

  /// allowDJProgramSubscriptionNotify。
  bool? allowDJProgramSubscriptionNotify;

  /// 创建 UserSetting。
  UserSetting();

  /// 创建 UserSetting。
  factory UserSetting.fromJson(Map<String, dynamic> json) =>
      _$UserSettingFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$UserSettingToJson(this);
}

/// UserSettingWrap。
@JsonSerializable()
class UserSettingWrap extends ServerStatusBean {
  /// setting。
  late UserSetting setting;

  /// 创建 UserSettingWrap。
  UserSettingWrap();

  /// 创建 UserSettingWrap。
  factory UserSettingWrap.fromJson(Map<String, dynamic> json) =>
      _$UserSettingWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserSettingWrapToJson(this);
}

/// NeteaseSimpleUserInfo。
@JsonSerializable()
class NeteaseSimpleUserInfo {
  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// nickname。
  String? nickname;

  /// avatar。
  String? avatar;

  /// followed。
  bool? followed;

  /// 创建 NeteaseSimpleUserInfo。
  NeteaseSimpleUserInfo();

  /// 创建 NeteaseSimpleUserInfo。
  factory NeteaseSimpleUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NeteaseSimpleUserInfoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$NeteaseSimpleUserInfoToJson(this);
}

/// NeteaseUserInfo。
@JsonSerializable()
class NeteaseUserInfo {
  /// userId。
  @JsonKey(fromJson: dynamicToString)
  late String userId;

  /// nickname。
  String? nickname;

  /// avatarUrl。
  String? avatarUrl;

  /// backgroundUrl。
  String? backgroundUrl;

  /// signature。
  String? signature;

  /// description。
  String? description;

  /// detailDescription。
  String? detailDescription;

  /// recommendReason。
  String? recommendReason;

  //性别 0:保密 1:男性 2:女性
  /// gender。
  int? gender;

  /// authority。
  int? authority;

  //出生日期,时间戳 unix timestamp
  /// birthday。
  int? birthday;

  /// city。
  int? city;

  /// province。
  int? province;

  /// vipType。
  int? vipType;

  /// authenticationTypes。
  int? authenticationTypes;

  /// authStatus。
  int? authStatus;

  /// djStatus。
  int? djStatus;

  /// accountStatus。
  int? accountStatus;

  /// expertTags。
  List<String>? expertTags;

  /// alg。
  String? alg;

  /// followed。
  bool? followed;

  /// mutual。
  bool? mutual;

  /// anchor。
  bool? anchor;

  /// defaultAvatar。
  bool? defaultAvatar;

  /// 创建 NeteaseUserInfo。
  NeteaseUserInfo();

  /// 创建 NeteaseUserInfo。
  factory NeteaseUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserInfoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$NeteaseUserInfoToJson(this);
}

/// NeteaseUserDetail。
@JsonSerializable()
class NeteaseUserDetail extends ServerStatusBean {
  /// createTime。
  int? createTime;

  /// createDays。
  int? createDays;

  /// profile。
  late NeteaseAccountProfile profile;

  /// 创建 NeteaseUserDetail。
  NeteaseUserDetail();

  /// 创建 NeteaseUserDetail。
  factory NeteaseUserDetail.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserDetailFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseUserDetailToJson(this);
}

/// NeteaseUserSubcount。
@JsonSerializable()
class NeteaseUserSubcount extends ServerStatusBean {
  /// programCount。
  int? programCount;

  /// djRadioCount。
  int? djRadioCount;

  /// mvCount。
  int? mvCount;

  /// artistCount。
  int? artistCount;

  /// newProgramCount。
  int? newProgramCount;

  /// createDjRadioCount。
  int? createDjRadioCount;

  /// createdPlaylistCount。
  int? createdPlaylistCount;

  /// subPlaylistCount。
  int? subPlaylistCount;

  /// 创建 NeteaseUserSubcount。
  NeteaseUserSubcount();

  /// 创建 NeteaseUserSubcount。
  factory NeteaseUserSubcount.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserSubcountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseUserSubcountToJson(this);
}

/// NeteaseUserLevel。
@JsonSerializable()
class NeteaseUserLevel {
  /// info。
  late String info;

  /// progress。
  double? progress;

  /// nextPlayCount。
  int? nextPlayCount;

  /// nextLoginCount。
  int? nextLoginCount;

  /// nowPlayCount。
  int? nowPlayCount;

  /// nowLoginCount。
  int? nowLoginCount;

  /// level。
  int? level;

  /// 创建 NeteaseUserLevel。
  NeteaseUserLevel();

  /// 创建 NeteaseUserLevel。
  factory NeteaseUserLevel.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserLevelFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$NeteaseUserLevelToJson(this);
}

/// NeteaseUserLevelWrap。
@JsonSerializable()
class NeteaseUserLevelWrap extends ServerStatusBean {
  /// full。
  bool? full;

  /// data。
  late NeteaseUserLevel data;

  /// 创建 NeteaseUserLevelWrap。
  NeteaseUserLevelWrap();

  /// 创建 NeteaseUserLevelWrap。
  factory NeteaseUserLevelWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserLevelWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NeteaseUserLevelWrapToJson(this);
}

/// UserFollowListWrap。
@JsonSerializable()
class UserFollowListWrap extends ServerStatusBean {
  /// follow。
  late List<NeteaseAccountProfile> follow;

  /// 创建 UserFollowListWrap。
  UserFollowListWrap();

  /// 创建 UserFollowListWrap。
  factory UserFollowListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserFollowListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserFollowListWrapToJson(this);
}

/// UserFollowedListWrap。
@JsonSerializable()
class UserFollowedListWrap extends ServerStatusBean {
  /// followeds。
  late List<NeteaseAccountProfile> followeds;

  /// 创建 UserFollowedListWrap。
  UserFollowedListWrap();

  /// 创建 UserFollowedListWrap。
  factory UserFollowedListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserFollowedListWrapToJson(this);
}

/// UserListWrap。
@JsonSerializable()
class UserListWrap extends ServerStatusBean {
  /// userprofiles。
  late List<NeteaseUserInfo> userprofiles;

  /// 创建 UserListWrap。
  UserListWrap();

  /// 创建 UserListWrap。
  factory UserListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserListWrapToJson(this);
}

/// ArtistsSubListWrap。
@JsonSerializable()
class ArtistsSubListWrap extends ServerStatusListBean {
  /// data。
  late List<Artist> data;

  /// 创建 ArtistsSubListWrap。
  ArtistsSubListWrap();

  /// 创建 ArtistsSubListWrap。
  factory ArtistsSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsSubListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistsSubListWrapToJson(this);
}

/// MvSubListWrap。
@JsonSerializable()
class MvSubListWrap extends ServerStatusListBean {
  /// data。
  late List<Mv2> data;

  /// 创建 MvSubListWrap。
  MvSubListWrap();

  /// 创建 MvSubListWrap。
  factory MvSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$MvSubListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvSubListWrapToJson(this);
}

/// AlbumSubListWrap。
@JsonSerializable()
class AlbumSubListWrap extends ServerStatusListBean {
  /// data。
  late List<Album> data;

  /// paidCount。
  int? paidCount;

  /// 创建 AlbumSubListWrap。
  AlbumSubListWrap();

  /// 创建 AlbumSubListWrap。
  factory AlbumSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumSubListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlbumSubListWrapToJson(this);
}

/// PlayRecordItem。
@JsonSerializable()
class PlayRecordItem {
  /// playCount。
  int? playCount;

  /// score。
  int? score;

  /// song。
  late Song song;

  /// 创建 PlayRecordItem。
  PlayRecordItem();

  /// 创建 PlayRecordItem。
  factory PlayRecordItem.fromJson(Map<String, dynamic> json) =>
      _$PlayRecordItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlayRecordItemToJson(this);
}

/// PlayRecordListWrap。
@JsonSerializable()
class PlayRecordListWrap extends ServerStatusBean {
  /// allData。
  late List<PlayRecordItem> allData;

  /// 创建 PlayRecordListWrap。
  PlayRecordListWrap();

  /// 创建 PlayRecordListWrap。
  factory PlayRecordListWrap.fromJson(Map<String, dynamic> json) =>
      _$PlayRecordListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayRecordListWrapToJson(this);
}

/// PlaylistCreateWrap。
@JsonSerializable()
class PlaylistCreateWrap extends ServerStatusBean {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// playlist。
  late PlayList playlist;

  /// 创建 PlaylistCreateWrap。
  PlaylistCreateWrap();

  /// 创建 PlaylistCreateWrap。
  factory PlaylistCreateWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCreateWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaylistCreateWrapToJson(this);
}

/// PlaylistSubscribersWrap。
@JsonSerializable()
class PlaylistSubscribersWrap extends ServerStatusBean {
  /// subscribers。
  late List<NeteaseUserInfo> subscribers;

  /// 创建 PlaylistSubscribersWrap。
  PlaylistSubscribersWrap();

  /// 创建 PlaylistSubscribersWrap。
  factory PlaylistSubscribersWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSubscribersWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaylistSubscribersWrapToJson(this);
}
