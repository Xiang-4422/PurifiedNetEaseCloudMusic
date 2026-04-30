import 'package:json_annotation/json_annotation.dart';

import '../../../src/api/bean.dart';
import '../../../src/netease_bean.dart';

part 'bean.g.dart';

/// 播客主播排行榜条目。
@JsonSerializable()
class Dj {
  /// 主播用户 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 主播昵称。
  String? nickName;

  /// 主播头像地址。
  String? avatarUrl;

  /// 用户类型。
  int? userType;

  /// 当前排名。
  int? rank;

  /// 上一次排名。
  int? lastRank;

  /// 榜单分数。
  int? score;

  /// 创建播客主播排行榜条目。
  Dj();

  /// 从 JSON 构建播客主播排行榜条目。
  factory Dj.fromJson(Map<String, dynamic> json) => _$DjFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjToJson(this);
}

/// 播客电台信息。
@JsonSerializable()
class DjRadio {
  /// 播客 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 播客名称。
  late String name;

  /// 播客主播资料。
  NeteaseAccountProfile? dj;

  /// 播客封面地址。
  late String picUrl;

  /// 播客简介。
  String? desc;

  /// 订阅数量。
  late int subCount;

  /// 评论数量。
  int? commentCount;

  /// 节目数量。
  late int programCount;

  /// 分享数量。
  int? shareCount;

  /// 点赞数量。
  int? likedCount;

  /// 创建时间戳。
  int? createTime;

  /// 分类 id。
  int? categoryId;

  /// 分类名称。
  String? category;

  /// 付费类型。
  late int radioFeeType;

  /// 付费范围。
  late int feeScope;

  /// 当前用户是否已购买。
  bool? buyed;

  /// 播客是否已完结。
  bool? finished;

  /// 播客是否已下架。
  bool? underShelf;

  /// 购买数量。
  int? purchaseCount;

  /// 当前价格。
  int? price;

  /// 原价。
  int? originalPrice;

  /// 最新节目创建时间戳。
  int? lastProgramCreateTime;

  /// 最新节目名称。
  String? lastProgramName;

  /// 最新节目 id。
  int? lastProgramId;

  /// 是否包含视频内容。
  bool? composeVideo;

  /// 推荐算法标识。
  String? alg;

  /// 创建播客电台信息。
  DjRadio();

  /// 从 JSON 构建播客电台信息。
  factory DjRadio.fromJson(Map<String, dynamic> json) =>
      _$DjRadioFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjRadioToJson(this);
}

/// 播客节目详情。
@JsonSerializable()
class DjProgram {
  /// 节目 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 节目名称。
  String? name;

  /// 节目简介。
  String? programDesc;

  /// 节目封面地址。
  String? coverUrl;

  /// 模糊封面地址。
  String? blurCoverUrl;

  /// 节目描述。
  String? description;

  /// 推荐算法标识。
  String? alg;

  /// 评论 thread id。
  String? commentThreadId;

  /// 主音轨 id。
  int? mainTrackId;

  /// 发布状态。
  int? pubStatus;

  /// 百度审核状态。
  late int bdAuditStatus;

  /// 节目序号。
  int? serialNum;

  /// 节目时长，单位为毫秒。
  int? duration;

  /// 审核状态。
  int? auditStatus;

  /// 节目分数。
  int? score;

  /// 创建时间戳。
  int? createTime;

  /// 付费范围。
  int? feeScope;

  /// 收听数量。
  int? listenerCount;

  /// 订阅数量。
  int? subscribedCount;

  /// 节目付费类型。
  int? programFeeType;

  /// 音轨数量。
  int? trackCount;

  /// 小语种审核状态。
  int? smallLanguageAuditStatus;

  /// 分享数量。
  int? shareCount;

  /// 点赞数量。
  int? likedCount;

  /// 评论数量。
  int? commentCount;

  /// 当前用户是否已购买。
  bool? buyed;

  /// 节目是否已发布。
  late bool isPublish;

  /// 当前用户是否已订阅。
  bool? subscribed;

  /// 是否可打赏。
  bool? canReward;

  /// 当前用户是否已打赏。
  bool? reward;

  /// 所属播客电台。
  late DjRadio radio;

  /// 节目主歌曲。
  late Song mainSong;

  /// 节目主播资料。
  late NeteaseAccountProfile dj;

  /// 创建播客节目详情。
  DjProgram();

  /// 从 JSON 构建播客节目详情。
  factory DjProgram.fromJson(Map<String, dynamic> json) =>
      _$DjProgramFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjProgramToJson(this);
}

/// 播客分类信息。
@JsonSerializable()
class DjRadioCategory {
  /// 分类 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 分类名称。
  late String name;

  /// macOS 分类图标地址。
  late String picMacUrl;

  /// Web 分类图标地址。
  late String picWebUrl;

  /// UWP 分类图标地址。
  late String picUWPUrl;

  /// iPad 分类图标地址。
  late String picIPadUrl;

  /// PC 黑色主题分类图标地址。
  late String picPCBlackUrl;

  /// PC 白色主题分类图标地址。
  late String picPCWhiteUrl;

  /// 56x56 分类图标地址。
  late String pic56x56Url;

  /// 84x84 分类图标地址。
  late String pic84x84IdUrl;

  /// 96x96 分类图标地址。
  late String pic96x96Url;

  /// 创建播客分类信息。
  DjRadioCategory();

  /// 从 JSON 构建播客分类信息。
  factory DjRadioCategory.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjRadioCategoryToJson(this);
}

/// 推荐播客分类及其代表播客列表。
@JsonSerializable()
class DjRadioCategory2 {
  /// 分类 id。
  @JsonKey(fromJson: dynamicToString)
  late String categoryId;

  /// 分类名称。
  late String categoryName;

  /// 分类下推荐播客列表。
  late List<DjRadio> radios;

  /// 创建推荐播客分类。
  DjRadioCategory2();

  /// 从 JSON 构建推荐播客分类。
  factory DjRadioCategory2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategory2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjRadioCategory2ToJson(this);
}

/// 播客分类列表响应。
@JsonSerializable()
class DjRadioCategoryWrap extends ServerStatusBean {
  /// 播客分类列表。
  late List<DjRadioCategory> categories;

  /// 创建播客分类列表响应。
  DjRadioCategoryWrap();

  /// 从 JSON 构建播客分类列表响应。
  factory DjRadioCategoryWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrapToJson(this);
}

/// 推荐播客分类列表响应。
@JsonSerializable()
class DjRadioCategoryWrap2 extends ServerStatusBean {
  /// 推荐播客分类列表。
  late List<DjRadioCategory2> data;

  /// 创建推荐播客分类列表响应。
  DjRadioCategoryWrap2();

  /// 从 JSON 构建推荐播客分类列表响应。
  factory DjRadioCategoryWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrap2ToJson(this);
}

/// 排除热门后的播客分类列表响应。
@JsonSerializable()
class DjRadioCategoryWrap3 extends ServerStatusBean {
  /// 播客分类列表。
  late List<DjRadioCategory> data;

  /// 创建排除热门后的播客分类列表响应。
  DjRadioCategoryWrap3();

  /// 从 JSON 构建排除热门后的播客分类列表响应。
  factory DjRadioCategoryWrap3.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrap3FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrap3ToJson(this);
}

/// 播客列表分页响应。
@JsonSerializable()
class DjRadioListWrap extends ServerStatusListBean {
  /// 播客列表。
  late List<DjRadio> djRadios;

  /// 列表名称。
  String? name;

  /// 订阅数量。
  int? subCount;

  /// 创建播客列表分页响应。
  DjRadioListWrap();

  /// 从 JSON 构建播客列表分页响应。
  factory DjRadioListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioListWrapToJson(this);
}

/// 播客列表响应。
@JsonSerializable()
class DjRadioListWrap2 extends ServerStatusBean {
  /// 播客列表。
  late List<DjRadio> data;

  /// 创建播客列表响应。
  DjRadioListWrap2();

  /// 从 JSON 构建播客列表响应。
  factory DjRadioListWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioListWrap2ToJson(this);
}

/// 主播排行榜数据。
@JsonSerializable()
class DjTopListListWrap {
  /// 主播排行榜条目列表。
  late List<Dj> list;

  /// 榜单总数。
  int? total;

  /// 榜单更新时间戳。
  int? updateTime;

  /// 创建主播排行榜数据。
  DjTopListListWrap();

  /// 从 JSON 构建主播排行榜数据。
  factory DjTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjTopListListWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjTopListListWrapToJson(this);
}

/// 主播排行榜响应。
@JsonSerializable()
class DjTopListListWrapX extends ServerStatusBean {
  /// 主播排行榜数据。
  late DjTopListListWrap data;

  /// 创建主播排行榜响应。
  DjTopListListWrapX();

  /// 从 JSON 构建主播排行榜响应。
  factory DjTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjTopListListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjTopListListWrapXToJson(this);
}

/// 播客排行榜条目。
@JsonSerializable()
class DjRadioTopListItem {
  /// 播客 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 播客名称。
  String? name;

  /// 播客封面地址。
  String? picUrl;

  /// 创建者昵称。
  String? creatorName;

  /// 当前排名。
  int? rank;

  /// 上一次排名。
  int? lastRank;

  /// 榜单分数。
  int? score;

  // [djRadioPayGiftTopList] 这个api独有数据
  /// 推荐文案。
  String? rcmdText;

  /// 播客付费类型。
  int? radioFeeType;

  /// 付费范围。
  int? feeScope;

  /// 节目数量。
  int? programCount;

  /// 原价。
  int? originalPrice;

  /// 推荐算法标识。
  String? alg;

  /// 最新节目名称。
  String? lastProgramName;

  /// 创建播客排行榜条目。
  DjRadioTopListItem();

  /// 从 JSON 构建播客排行榜条目。
  factory DjRadioTopListItem.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjRadioTopListItemToJson(this);
}

/// 播客排行榜数据。
@JsonSerializable()
class DjRadioTopListListWrap {
  /// 播客排行榜条目列表。
  late List<DjRadioTopListItem> list;

  /// 榜单总数。
  int? total;

  /// 榜单更新时间戳。
  int? updateTime;

  /// 创建播客排行榜数据。
  DjRadioTopListListWrap();

  /// 从 JSON 构建播客排行榜数据。
  factory DjRadioTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapToJson(this);
}

/// 播客排行榜响应。
@JsonSerializable()
class DjRadioTopListListWrapX extends ServerStatusBean {
  /// 播客排行榜数据。
  late DjRadioTopListListWrap data;

  /// 创建播客排行榜响应。
  DjRadioTopListListWrapX();

  /// 从 JSON 构建播客排行榜响应。
  factory DjRadioTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapXToJson(this);
}

/// 播客详情响应。
@JsonSerializable()
class DjRadioDetail extends ServerStatusBean {
  /// 播客详情数据。
  late DjRadio data;

  /// 创建播客详情响应。
  DjRadioDetail();

  /// 从 JSON 构建播客详情响应。
  factory DjRadioDetail.fromJson(Map<String, dynamic> json) =>
      _$DjRadioDetailFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioDetailToJson(this);
}

/// 播客榜单列表响应。
@JsonSerializable()
class DjRadioTopListListWrapX2 extends ServerStatusBean {
  /// 播客榜单列表。
  late List<DjRadio> toplist;

  /// 榜单更新时间戳。
  int? updateTime;

  /// 创建播客榜单列表响应。
  DjRadioTopListListWrapX2();

  /// 从 JSON 构建播客榜单列表响应。
  factory DjRadioTopListListWrapX2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapX2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapX2ToJson(this);
}

/// 播客节目列表响应。
@JsonSerializable()
class DjProgramListWrap extends ServerStatusListBean {
  /// 节目列表。
  late List<DjProgram> programs;

  /// 列表名称。
  String? name;

  /// 创建播客节目列表响应。
  DjProgramListWrap();

  /// 从 JSON 构建播客节目列表响应。
  factory DjProgramListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjProgramListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjProgramListWrapToJson(this);
}

/// 节目排行榜条目。
@JsonSerializable()
class DjProgramTopListItem {
  /// 节目详情。
  late DjProgram program;

  /// 当前排名。
  int? rank;

  /// 上一次排名。
  int? lastRank;

  /// 榜单分数。
  int? score;

  /// 节目付费类型。
  int? programFeeType;

  /// 创建节目排行榜条目。
  DjProgramTopListItem();

  /// 从 JSON 构建节目排行榜条目。
  factory DjProgramTopListItem.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjProgramTopListItemToJson(this);
}

/// 节目排行榜列表响应。
@JsonSerializable()
class DjProgramTopListListWrap2 extends ServerStatusBean {
  /// 节目排行榜条目列表。
  late List<DjProgramTopListItem> toplist;

  /// 榜单更新时间戳。
  int? updateTime;

  /// 创建节目排行榜列表响应。
  DjProgramTopListListWrap2();

  /// 从 JSON 构建节目排行榜列表响应。
  factory DjProgramTopListListWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrap2ToJson(this);
}

/// 个性化推荐节目条目。
@JsonSerializable()
class PersonalizedDjProgramItem {
  /// 推荐条目 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 推荐名称。
  String? name;

  /// 推荐文案。
  String? copywriter;

  /// 推荐封面地址。
  String? picUrl;

  /// 是否可点不感兴趣。
  bool? canDislike;

  /// 推荐类型。
  int? type;

  /// 推荐节目详情。
  late DjProgram program;

  /// 创建个性化推荐节目条目。
  PersonalizedDjProgramItem();

  /// 从 JSON 构建个性化推荐节目条目。
  factory PersonalizedDjProgramItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedDjProgramItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PersonalizedDjProgramItemToJson(this);
}

/// 节目排行榜数据。
@JsonSerializable()
class DjProgramTopListListWrap {
  /// 节目排行榜条目列表。
  late List<DjProgramTopListItem> list;

  /// 榜单总数。
  int? total;

  /// 榜单更新时间戳。
  int? updateTime;

  /// 创建节目排行榜数据。
  DjProgramTopListListWrap();

  /// 从 JSON 构建节目排行榜数据。
  factory DjProgramTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrapToJson(this);
}

/// 节目排行榜响应。
@JsonSerializable()
class DjProgramTopListListWrapX extends ServerStatusBean {
  /// 节目排行榜数据。
  late DjProgramTopListListWrap data;

  /// 创建节目排行榜响应。
  DjProgramTopListListWrapX();

  /// 从 JSON 构建节目排行榜响应。
  factory DjProgramTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrapXToJson(this);
}

/// 个性化推荐节目列表响应。
@JsonSerializable()
class PersonalizedDjProgramListWrap extends ServerStatusBean {
  /// 推荐分类。
  int? category;

  /// 推荐节目列表。
  late List<PersonalizedDjProgramItem> result;

  /// 创建个性化推荐节目列表响应。
  PersonalizedDjProgramListWrap();

  /// 从 JSON 构建个性化推荐节目列表响应。
  factory PersonalizedDjProgramListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedDjProgramListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PersonalizedDjProgramListWrapToJson(this);
}

/// 播客节目详情响应。
@JsonSerializable()
class DjProgramDetail extends ServerStatusBean {
  /// 节目详情。
  late DjProgram program;

  /// 创建播客节目详情响应。
  DjProgramDetail();

  /// 从 JSON 构建播客节目详情响应。
  factory DjProgramDetail.fromJson(Map<String, dynamic> json) =>
      _$DjProgramDetailFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$DjProgramDetailToJson(this);
}
