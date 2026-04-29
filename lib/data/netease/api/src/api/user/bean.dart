import 'package:json_annotation/json_annotation.dart';

import '../../../src/api/bean.dart';
import '../../../src/api/login/bean.dart';
import '../../../src/api/play/bean.dart';

part 'bean.g.dart';

/// 用户隐私和通知设置。
@JsonSerializable()
class UserSetting {
  /// 用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 资料可见性设置。
  int? profileSetting;

  /// 年龄可见性设置。
  int? ageSetting;

  /// 地区可见性设置。
  int? areaSetting;

  /// 学校可见性设置。
  int? collegeSetting;

  /// 同村年龄可见性设置。
  int? villageAgeSetting;

  /// 关注歌手可见性设置。
  int? followSingerSetting;

  /// 个性化服务设置。
  int? personalServiceSetting;

  /// 演出通知设置。
  int? concertSetting;

  /// 社交设置。
  int? socialSetting;

  /// 分享设置。
  int? shareSetting;

  /// 听歌排行可见性设置。
  int? playRecordSetting;

  /// 广播设置。
  int? broadcastSetting;

  /// 评论设置。
  int? commentSetting;

  //newSongDiskSetting

  /// 是否允许通过手机通讯录发现好友。
  bool? phoneFriendSetting;

  /// 是否允许关注者查看听歌排行。
  bool? allowFollowedCanSeeMyPlayRecord;

  /// 是否已完成关注引导。
  bool? finishedFollowGuide;

  /// 是否允许离线私信通知。
  bool? allowOfflinePrivateMessageNotify;

  /// 是否允许离线转发通知。
  bool? allowOfflineForwardNotify;

  /// 是否允许离线评论通知。
  bool? allowOfflineCommentNotify;

  /// 是否允许离线评论回复通知。
  bool? allowOfflineCommentReplyNotify;

  /// 是否允许离线通知。
  bool? allowOfflineNotify;

  /// 是否允许视频订阅通知。
  bool? allowVideoSubscriptionNotify;

  /// 是否发送 MIUI 推送。
  bool? sendMiuiMsg;

  /// 是否允许导入豆瓣歌单。
  bool? allowImportDoubanPlaylist;

  /// 是否已导入豆瓣歌单。
  late bool importedDoubanPlaylist;

  /// 是否已导入虾米歌单。
  late bool importedXiamiPlaylist;

  /// 是否允许导入虾米歌单。
  bool? allowImportXiamiPlaylist;

  /// 是否允许订阅通知。
  bool? allowSubscriptionNotify;

  /// 是否允许喜欢通知。
  bool? allowLikedNotify;

  /// 是否允许新粉丝通知。
  bool? allowNewFollowerNotify;

  /// 是否需要推荐动态。
  bool? needRcmdEvent;

  /// 是否允许歌单分享通知。
  bool? allowPlaylistShareNotify;

  /// 是否允许播客节目分享通知。
  bool? allowDJProgramShareNotify;

  /// 是否允许播客订阅通知。
  bool? allowDJRadioSubscriptionNotify;

  /// 是否允许别人查看播放通知。
  bool? allowPeopleCanSeeMyPlaynNotify;

  /// 附近的人是否可以看到我。
  bool? peopleNearbyCanSeeMe;

  /// 是否允许播客节目订阅通知。
  bool? allowDJProgramSubscriptionNotify;

  /// 创建用户设置。
  UserSetting();

  /// 从 JSON 构建用户设置。
  factory UserSetting.fromJson(Map<String, dynamic> json) =>
      _$UserSettingFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$UserSettingToJson(this);
}

/// 用户设置响应。
@JsonSerializable()
class UserSettingWrap extends ServerStatusBean {
  /// 用户设置数据。
  late UserSetting setting;

  /// 创建用户设置响应。
  UserSettingWrap();

  /// 从 JSON 构建用户设置响应。
  factory UserSettingWrap.fromJson(Map<String, dynamic> json) =>
      _$UserSettingWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserSettingWrapToJson(this);
}

/// 简化用户资料。
@JsonSerializable()
class NeteaseSimpleUserInfo {
  /// 用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 用户昵称。
  String? nickname;

  /// 用户头像地址。
  String? avatar;

  /// 当前登录用户是否已关注该用户。
  bool? followed;

  /// 创建简化用户资料。
  NeteaseSimpleUserInfo();

  /// 从 JSON 构建简化用户资料。
  factory NeteaseSimpleUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NeteaseSimpleUserInfoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$NeteaseSimpleUserInfoToJson(this);
}

/// 网易云用户资料。
@JsonSerializable()
class NeteaseUserInfo {
  /// 用户 id。
  @JsonKey(fromJson: dynamicToString)
  late String userId;

  /// 用户昵称。
  String? nickname;

  /// 用户头像地址。
  String? avatarUrl;

  /// 用户主页背景地址。
  String? backgroundUrl;

  /// 用户签名。
  String? signature;

  /// 用户描述。
  String? description;

  /// 用户详细描述。
  String? detailDescription;

  /// 推荐原因文案。
  String? recommendReason;

  /// 性别；0 保密，1 男性，2 女性。
  int? gender;

  /// 用户权限等级。
  int? authority;

  /// 出生日期时间戳。
  int? birthday;

  /// 城市编码。
  int? city;

  /// 省份编码。
  int? province;

  /// VIP 类型。
  int? vipType;

  /// 认证类型列表标记。
  int? authenticationTypes;

  /// 认证状态。
  int? authStatus;

  /// 主播状态。
  int? djStatus;

  /// 账号状态。
  int? accountStatus;

  /// 专家标签。
  List<String>? expertTags;

  /// 推荐算法标识。
  String? alg;

  /// 当前登录用户是否已关注。
  bool? followed;

  /// 是否互相关注。
  bool? mutual;

  /// 是否为主播。
  bool? anchor;

  /// 是否使用默认头像。
  bool? defaultAvatar;

  /// 创建网易云用户资料。
  NeteaseUserInfo();

  /// 从 JSON 构建网易云用户资料。
  factory NeteaseUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserInfoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$NeteaseUserInfoToJson(this);
}

/// 用户详情响应。
@JsonSerializable()
class NeteaseUserDetail extends ServerStatusBean {
  /// 用户创建时间戳。
  int? createTime;

  /// 用户创建天数。
  int? createDays;

  /// 用户资料。
  late NeteaseAccountProfile profile;

  /// 创建用户详情响应。
  NeteaseUserDetail();

  /// 从 JSON 构建用户详情响应。
  factory NeteaseUserDetail.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserDetailFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseUserDetailToJson(this);
}

/// 用户内容计数响应。
@JsonSerializable()
class NeteaseUserSubcount extends ServerStatusBean {
  /// 节目数量。
  int? programCount;

  /// 播客数量。
  int? djRadioCount;

  /// MV 数量。
  int? mvCount;

  /// 收藏歌手数量。
  int? artistCount;

  /// 新节目数量。
  int? newProgramCount;

  /// 创建的播客数量。
  int? createDjRadioCount;

  /// 创建的歌单数量。
  int? createdPlaylistCount;

  /// 收藏的歌单数量。
  int? subPlaylistCount;

  /// 创建用户内容计数响应。
  NeteaseUserSubcount();

  /// 从 JSON 构建用户内容计数响应。
  factory NeteaseUserSubcount.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserSubcountFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseUserSubcountToJson(this);
}

/// 用户等级信息。
@JsonSerializable()
class NeteaseUserLevel {
  /// 等级说明文案。
  late String info;

  /// 当前等级进度。
  double? progress;

  /// 下一级需要的听歌数量。
  int? nextPlayCount;

  /// 下一级需要的登录天数。
  int? nextLoginCount;

  /// 当前听歌数量。
  int? nowPlayCount;

  /// 当前登录天数。
  int? nowLoginCount;

  /// 当前等级。
  int? level;

  /// 创建用户等级信息。
  NeteaseUserLevel();

  /// 从 JSON 构建用户等级信息。
  factory NeteaseUserLevel.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserLevelFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$NeteaseUserLevelToJson(this);
}

/// 用户等级响应。
@JsonSerializable()
class NeteaseUserLevelWrap extends ServerStatusBean {
  /// 等级信息是否完整。
  bool? full;

  /// 用户等级数据。
  late NeteaseUserLevel data;

  /// 创建用户等级响应。
  NeteaseUserLevelWrap();

  /// 从 JSON 构建用户等级响应。
  factory NeteaseUserLevelWrap.fromJson(Map<String, dynamic> json) =>
      _$NeteaseUserLevelWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$NeteaseUserLevelWrapToJson(this);
}

/// 用户关注列表响应。
@JsonSerializable()
class UserFollowListWrap extends ServerStatusBean {
  /// 关注用户列表。
  late List<NeteaseAccountProfile> follow;

  /// 创建用户关注列表响应。
  UserFollowListWrap();

  /// 从 JSON 构建用户关注列表响应。
  factory UserFollowListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserFollowListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserFollowListWrapToJson(this);
}

/// 用户粉丝列表响应。
@JsonSerializable()
class UserFollowedListWrap extends ServerStatusBean {
  /// 粉丝用户列表。
  late List<NeteaseAccountProfile> followeds;

  /// 创建用户粉丝列表响应。
  UserFollowedListWrap();

  /// 从 JSON 构建用户粉丝列表响应。
  factory UserFollowedListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserFollowedListWrapToJson(this);
}

/// 用户搜索列表响应。
@JsonSerializable()
class UserListWrap extends ServerStatusBean {
  /// 用户资料列表。
  late List<NeteaseUserInfo> userprofiles;

  /// 创建用户搜索列表响应。
  UserListWrap();

  /// 从 JSON 构建用户搜索列表响应。
  factory UserListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserListWrapToJson(this);
}

/// 收藏歌手列表响应。
@JsonSerializable()
class ArtistsSubListWrap extends ServerStatusListBean {
  /// 收藏歌手列表。
  late List<Artist> data;

  /// 创建收藏歌手列表响应。
  ArtistsSubListWrap();

  /// 从 JSON 构建收藏歌手列表响应。
  factory ArtistsSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsSubListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistsSubListWrapToJson(this);
}

/// 收藏 MV 列表响应。
@JsonSerializable()
class MvSubListWrap extends ServerStatusListBean {
  /// 收藏 MV 列表。
  late List<Mv2> data;

  /// 创建收藏 MV 列表响应。
  MvSubListWrap();

  /// 从 JSON 构建收藏 MV 列表响应。
  factory MvSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$MvSubListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvSubListWrapToJson(this);
}

/// 收藏专辑列表响应。
@JsonSerializable()
class AlbumSubListWrap extends ServerStatusListBean {
  /// 收藏专辑列表。
  late List<Album> data;

  /// 已购专辑数量。
  int? paidCount;

  /// 创建收藏专辑列表响应。
  AlbumSubListWrap();

  /// 从 JSON 构建收藏专辑列表响应。
  factory AlbumSubListWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumSubListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AlbumSubListWrapToJson(this);
}

/// 用户播放记录条目。
@JsonSerializable()
class PlayRecordItem {
  /// 播放次数。
  int? playCount;

  /// 听歌得分。
  int? score;

  /// 歌曲信息。
  late Song song;

  /// 创建用户播放记录条目。
  PlayRecordItem();

  /// 从 JSON 构建用户播放记录条目。
  factory PlayRecordItem.fromJson(Map<String, dynamic> json) =>
      _$PlayRecordItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlayRecordItemToJson(this);
}

/// 用户播放记录列表响应。
@JsonSerializable()
class PlayRecordListWrap extends ServerStatusBean {
  /// 全量播放记录列表。
  late List<PlayRecordItem> allData;

  /// 创建用户播放记录列表响应。
  PlayRecordListWrap();

  /// 从 JSON 构建用户播放记录列表响应。
  factory PlayRecordListWrap.fromJson(Map<String, dynamic> json) =>
      _$PlayRecordListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlayRecordListWrapToJson(this);
}

/// 创建歌单响应。
@JsonSerializable()
class PlaylistCreateWrap extends ServerStatusBean {
  /// 新建歌单 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 新建歌单数据。
  late PlayList playlist;

  /// 创建歌单响应。
  PlaylistCreateWrap();

  /// 从 JSON 构建创建歌单响应。
  factory PlaylistCreateWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCreateWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlaylistCreateWrapToJson(this);
}

/// 歌单收藏者列表响应。
@JsonSerializable()
class PlaylistSubscribersWrap extends ServerStatusBean {
  /// 歌单收藏者列表。
  late List<NeteaseUserInfo> subscribers;

  /// 创建歌单收藏者列表响应。
  PlaylistSubscribersWrap();

  /// 从 JSON 构建歌单收藏者列表响应。
  factory PlaylistSubscribersWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistSubscribersWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlaylistSubscribersWrapToJson(this);
}
