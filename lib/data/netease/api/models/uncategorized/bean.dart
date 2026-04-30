// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import '../common/bean.dart';
import '../event/bean.dart';
import '../play/bean.dart';
import '../user/bean.dart';
import '../../client/dio_ext.dart';

part 'bean.g.dart';

@JsonSerializable()

/// 首页轮播图接口返回的单个广告或歌曲入口。
class BannerItem {
  /// 轮播项在服务端的业务 id。
  String? bannerId;

  /// 轮播图图片地址。
  late String pic;

  /// 点击目标的资源 id。
  late int targetId;

  /// 点击目标的资源类型。
  late int targetType;

  /// 标题色值标识。
  String? titleColor;

  /// 轮播角标文案。
  late String typeTitle;

  /// 外链跳转地址。
  String? url;

  /// 广告落地页地址。
  String? adurlV2;

  /// 是否为独家内容。
  late bool exclusive;

  /// 资源的编码 id。
  String? encodeId;

  /// 轮播关联的歌曲数据。
  Song2? song;

  /// 推荐算法标识。
  String? alg;

  /// 推荐追踪 scm 参数。
  String? scm;

  /// 推荐请求 id。
  String? requestId;

  /// 是否展示广告标识。
  bool? showAdTag;

  /// 创建首页轮播项。
  BannerItem();

  /// 从 JSON 构建首页轮播项。
  factory BannerItem.fromJson(Map<String, dynamic> json) =>
      _$BannerItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$BannerItemToJson(this);
}

@JsonSerializable()

/// 首页轮播图列表响应。
class BannerListWrap extends ServerStatusBean {
  /// 轮播图条目列表。
  late List<BannerItem> banners;

  /// 创建首页轮播图列表响应。
  BannerListWrap();

  /// 从 JSON 构建首页轮播图列表响应。
  factory BannerListWrap.fromJson(Map<String, dynamic> json) =>
      _$BannerListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$BannerListWrapToJson(this);
}

@JsonSerializable()

/// 使用 data 字段承载的首页轮播图列表响应。
class BannerListWrap2 extends ServerStatusBean {
  /// 轮播图条目列表。
  late List<BannerItem> data;

  /// 创建 data 包装的首页轮播图列表响应。
  BannerListWrap2();

  /// 从 JSON 构建 data 包装的首页轮播图列表响应。
  factory BannerListWrap2.fromJson(Map<String, dynamic> json) =>
      _$BannerListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$BannerListWrap2ToJson(this);
}

@JsonSerializable()

/// 首页区块分页接口的页面配置。
class PageConfig {
  /// 页面标题。
  String? title;

  /// 刷新成功提示文案。
  String? refreshToast;

  /// 无数据提示文案。
  String? nodataToast;

  /// 推荐刷新间隔，单位由服务端返回决定。
  int? refreshInterval;

  /// 歌曲标签展示数量限制。
  int? songLabelMarkLimit;

  /// 是否全屏展示。
  bool? fullscreen;

  /// 歌曲标签展示优先级。
  late List<String> songLabelMarkPriority;

  /// 命中的 AB 实验标识列表。
  late List<String> abtest;

  /// 创建首页页面配置。
  PageConfig();

  /// 从 JSON 构建首页页面配置。
  factory PageConfig.fromJson(Map<String, dynamic> json) =>
      _$PageConfigFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}

@JsonSerializable()

/// 首页区块 UI 标题元素。
class HomeBlockPageUiElementTitle {
  /// 标题展示文本。
  String? title;

  /// 创建首页区块标题元素。
  HomeBlockPageUiElementTitle();

  /// 从 JSON 构建首页区块标题元素。
  factory HomeBlockPageUiElementTitle.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementTitleFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementTitleToJson(this);
}

@JsonSerializable()

/// 首页区块 UI 按钮元素。
class HomeBlockPageUiElementButton {
  /// 按钮点击行为地址。
  String? action;

  /// 按钮点击行为类型。
  String? actionType;

  /// 按钮展示文案。
  String? text;

  /// 按钮图标地址。
  String? iconUrl;

  /// 创建首页区块按钮元素。
  HomeBlockPageUiElementButton();

  /// 从 JSON 构建首页区块按钮元素。
  factory HomeBlockPageUiElementButton.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementButtonFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementButtonToJson(this);
}

@JsonSerializable()

/// 首页区块 UI 图片元素。
class HomeBlockPageUiElementImage {
  /// 图片地址。
  late String imageUrl;

  /// 创建首页区块图片元素。
  HomeBlockPageUiElementImage();

  /// 从 JSON 构建首页区块图片元素。
  factory HomeBlockPageUiElementImage.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementImageFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementImageToJson(this);
}

@JsonSerializable()

/// 首页区块的 UI 元素组合。
class HomeBlockPageUiElement {
  /// 主标题元素。
  HomeBlockPageUiElementTitle? mainTitle;

  /// 副标题元素。
  HomeBlockPageUiElementTitle? subTitle;

  /// 操作按钮元素。
  HomeBlockPageUiElementButton? button;

  /// 图片元素。
  HomeBlockPageUiElementImage? image;

  /// 标签文本列表。
  List<String>? labelTexts;

  /// 创建首页区块 UI 元素组合。
  HomeBlockPageUiElement();

  /// 从 JSON 构建首页区块 UI 元素组合。
  factory HomeBlockPageUiElement.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementToJson(this);
}

@JsonSerializable()

/// 首页区块资源的扩展信息。
class HomeBlockPageResourceExt {
  /// 资源关联歌手列表。
  List<Artist>? artists;

  /// 资源关联歌曲数据。
  Song? songData;

  /// 资源关联歌曲权限。
  Privilege? songPrivilege;

  /// 资源关联评论摘要。
  CommentSimple? commentSimpleData;

  /// 是否为高品质内容。
  bool? highQuality;

  /// 播放次数。
  int? playCount;

  /// 创建首页区块资源扩展信息。
  HomeBlockPageResourceExt();

  /// 从 JSON 构建首页区块资源扩展信息。
  factory HomeBlockPageResourceExt.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageResourceExtFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageResourceExtToJson(this);
}

@JsonSerializable()

/// 首页区块中的单个资源。
class HomeBlockPageResource {
  /// 资源类型。
  String? resourceType;

  /// 资源 id。
  String? resourceId;

  /// 资源链接地址。
  String? resourceUrl;

  /// 点击行为地址。
  String? action;

  /// 点击行为类型。
  String? actionType;

  /// 资源展示元素。
  late HomeBlockPageUiElement uiElement;

  /// 资源扩展信息。
  late HomeBlockPageResourceExt resourceExtInfo;

  /// 推荐算法标识。
  String? alg;

  /// 资源是否有效。
  bool? valid;

  /// 创建首页区块资源。
  HomeBlockPageResource();

  /// 从 JSON 构建首页区块资源。
  factory HomeBlockPageResource.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageResourceFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageResourceToJson(this);
}

@JsonSerializable()

/// 首页区块中的创意卡片。
class HomeBlockPageCreative {
  /// 创意类型。
  String? creativeType;

  /// 创意 id。
  String? creativeId;

  /// 点击行为地址。
  String? action;

  /// 点击行为类型。
  String? actionType;

  /// 创意展示元素。
  late HomeBlockPageUiElement uiElement;

  /// 创意包含的资源列表。
  late List<HomeBlockPageResource> resources;

  /// 推荐算法标识。
  String? alg;

  /// 创意在区块内的位置。
  int? position;

  /// 创建首页创意卡片。
  HomeBlockPageCreative();

  /// 从 JSON 构建首页创意卡片。
  factory HomeBlockPageCreative.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageCreativeFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageCreativeToJson(this);
}

@JsonSerializable()

/// 首页分页中的单个区块。
class HomeBlockPageItem {
  /// 区块编码。
  String? blockCode;

  /// 区块展示类型，例如 HOMEPAGE_SLIDE_PLAYLIST。
  String? showType;

  /// 区块 UI 元素。
  late HomeBlockPageUiElement uiElement;

  /// 区块内创意卡片列表。
  List<HomeBlockPageCreative>? creatives;

  /// 区块扩展数据，结构随区块类型变化。
  dynamic extInfo;

  /// 区块点击行为地址，例如 orpheus scheme。
  String? action;

  /// 区块点击行为类型。
  String? actionType;

  /// 区块是否允许关闭。
  bool? canClose;

  /// 创建首页区块。
  HomeBlockPageItem();

  /// 从 JSON 构建首页区块。
  factory HomeBlockPageItem.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageItemToJson(this);
}

@JsonSerializable()

/// 首页分页游标。
class HomeBlockPageCursor {
  /// 下一页偏移量。
  int? offset;

  /// 区块编码顺序列表。
  late List<String> blockCodeOrderList;

  /// 创建首页分页游标。
  HomeBlockPageCursor();

  /// 从 JSON 构建首页分页游标。
  factory HomeBlockPageCursor.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageCursorFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageCursorToJson(this);
}

@JsonSerializable()

/// 首页区块分页数据。
class HomeBlockPage {
  /// 是否还有下一页。
  bool? hasMore;

  /// 下一页游标，接口以 JSON 字符串形式返回。
  @JsonKey(fromJson: _stringToHomeBlockPageCursor)
  HomeBlockPageCursor? cursor;

  /// 页面配置。
  late PageConfig pageConfig;

  /// 当前页区块列表。
  late List<HomeBlockPageItem> blocks;

  /// 创建首页区块分页数据。
  HomeBlockPage();

  /// 从 JSON 构建首页区块分页数据。
  factory HomeBlockPage.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeBlockPageToJson(this);
}

HomeBlockPageCursor _stringToHomeBlockPageCursor(String value) =>
    HomeBlockPageCursor?.fromJson(json.decode(value));

@JsonSerializable()

/// 首页区块分页响应。
class HomeBlockPageWrap extends ServerStatusBean {
  /// 首页区块分页数据。
  late HomeBlockPage data;

  /// 创建首页区块分页响应。
  HomeBlockPageWrap();

  /// 从 JSON 构建首页区块分页响应。
  factory HomeBlockPageWrap.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$HomeBlockPageWrapToJson(this);
}

@JsonSerializable()

/// 首页金刚区入口。
class HomeDragonBallItem {
  /// 入口 id。
  late int id;

  /// 入口名称。
  String? name;

  /// 入口图标地址。
  late String iconUrl;

  /// 入口跳转地址。
  String? url;

  /// 是否支持皮肤适配。
  bool? skinSupport;

  /// 创建首页金刚区入口。
  HomeDragonBallItem();

  /// 从 JSON 构建首页金刚区入口。
  factory HomeDragonBallItem.fromJson(Map<String, dynamic> json) =>
      _$HomeDragonBallItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HomeDragonBallItemToJson(this);
}

@JsonSerializable()

/// 首页金刚区入口响应。
class HomeDragonBallWrap extends ServerStatusBean {
  /// 金刚区入口列表。
  late List<HomeDragonBallItem> data;

  /// 创建首页金刚区入口响应。
  HomeDragonBallWrap();

  /// 从 JSON 构建首页金刚区入口响应。
  factory HomeDragonBallWrap.fromJson(Map<String, dynamic> json) =>
      _$HomeDragonBallWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$HomeDragonBallWrapToJson(this);
}

@JsonSerializable()

/// 国家或地区区号条目。
class CountriesCodeItem {
  /// 中文名称。
  String? zh;

  /// 英文名称。
  String? en;

  /// 区域 locale 标识。
  String? locale;

  /// 电话区号。
  String? code;

  /// 创建国家或地区区号条目。
  CountriesCodeItem();

  /// 从 JSON 构建国家或地区区号条目。
  factory CountriesCodeItem.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CountriesCodeItemToJson(this);
}

@JsonSerializable()

/// 国家或地区区号索引分组。
class CountriesCodeIndex {
  /// 分组标签。
  String? label;

  /// 分组下的国家或地区列表。
  late List<CountriesCodeItem> countryList;

  /// 创建国家或地区区号索引分组。
  CountriesCodeIndex();

  /// 从 JSON 构建国家或地区区号索引分组。
  factory CountriesCodeIndex.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeIndexFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CountriesCodeIndexToJson(this);
}

@JsonSerializable()

/// 国家或地区区号列表响应。
class CountriesCodeListWrap extends ServerStatusBean {
  /// 区号索引分组列表。
  late List<CountriesCodeIndex> data;

  /// 创建国家或地区区号列表响应。
  CountriesCodeListWrap();

  /// 从 JSON 构建国家或地区区号列表响应。
  factory CountriesCodeListWrap.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CountriesCodeListWrapToJson(this);
}

@JsonSerializable()

/// 私人内容推荐条目。
class PersonalizedPrivateContentItem {
  /// 内容 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 内容名称。
  String? name;

  /// 封面图片地址。
  String? picUrl;

  /// 小尺寸封面图片地址。
  String? sPicUrl;

  /// 推荐文案。
  String? copywriter;

  /// 推荐算法标识。
  String? alg;

  /// 内容类型。
  int? type;

  /// 创建私人内容推荐条目。
  PersonalizedPrivateContentItem();

  /// 从 JSON 构建私人内容推荐条目。
  factory PersonalizedPrivateContentItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPrivateContentItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PersonalizedPrivateContentItemToJson(this);
}

@JsonSerializable()

/// 私人内容推荐列表响应。
class PersonalizedPrivateContentListWrap extends ServerStatusBean {
  /// 推荐条目列表。
  late List<PersonalizedPrivateContentItem> result;

  /// 创建私人内容推荐列表响应。
  PersonalizedPrivateContentListWrap();

  /// 从 JSON 构建私人内容推荐列表响应。
  factory PersonalizedPrivateContentListWrap.fromJson(
          Map<String, dynamic> json) =>
      _$PersonalizedPrivateContentListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() =>
      _$PersonalizedPrivateContentListWrapToJson(this);
}

@JsonSerializable()

/// 榜单中的歌曲摘要。
class TopListTrack {
  /// 歌曲标题或第一行文案。
  String? first;

  /// 歌手或第二行文案。
  String? second;

  /// 创建榜单歌曲摘要。
  TopListTrack();

  /// 从 JSON 构建榜单歌曲摘要。
  factory TopListTrack.fromJson(Map<String, dynamic> json) =>
      _$TopListTrackFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopListTrackToJson(this);
}

@JsonSerializable()

/// 音乐榜单信息。
class TopList {
  /// 榜单 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 榜单创建用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 榜单订阅用户列表。
  late List<NeteaseUserInfo> subscribers;

  /// 榜单歌曲摘要列表。
  List<TopListTrack>? tracks;

  /// 榜单名称。
  String? name;

  /// 榜单英文标题。
  String? englishTitle;

  /// 标题图片地址。
  String? titleImageUrl;

  /// 更新频率文案。
  String? updateFrequency;

  /// 背景封面地址。
  String? backgroundCoverUrl;

  /// 封面图片地址。
  String? coverImgUrl;

  /// 榜单描述。
  String? description;

  /// 评论线程 id。
  String? commentThreadId;

  /// 榜单类型标识。
  String? ToplistType;

  /// 广告类型。
  late int adType;

  /// 榜单状态。
  int? status;

  /// 隐私状态。
  int? privacy;

  /// 订阅数量。
  int? subscribedCount;

  /// 播放次数。
  int? playCount;

  /// 创建时间戳。
  int? createTime;

  /// 更新时间戳。
  int? updateTime;

  /// 总时长。
  int? totalDuration;

  /// 特殊榜单类型。
  int? specialType;

  /// 云端歌曲数量。
  int? cloudTrackCount;

  /// 歌曲数量更新时间。
  int? trackNumberUpdateTime;

  /// 歌曲内容更新时间。
  int? trackUpdateTime;

  /// 歌曲数量。
  int? trackCount;

  /// 是否为运营推荐。
  bool? opRecommend;

  /// 推荐信息文案。
  String? recommendInfo;

  /// 是否有序。
  bool? ordered;

  /// 是否为高品质榜单。
  bool? highQuality;

  /// 是否为新导入榜单。
  bool? newImported;

  /// 是否匿名。
  bool? anonimous;

  /// 榜单标签列表。
  late List<String> tags;

  /// 创建音乐榜单信息。
  TopList();

  /// 从 JSON 构建音乐榜单信息。
  factory TopList.fromJson(Map<String, dynamic> json) =>
      _$TopListFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopListToJson(this);
}

@JsonSerializable()

/// 歌手榜单中的歌手摘要。
class ArtistTopListArtists {
  /// 歌手名称或第一行文案。
  String? first;

  /// 歌手补充文案。
  String? second;

  /// 排名变化或第三项数值。
  int? third;

  /// 创建歌手榜单摘要。
  ArtistTopListArtists();

  /// 从 JSON 构建歌手榜单摘要。
  factory ArtistTopListArtists.fromJson(Map<String, dynamic> json) =>
      _$ArtistTopListArtistsFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistTopListArtistsToJson(this);
}

@JsonSerializable()

/// 歌手榜单信息。
class ArtistTopList {
  /// 榜单位置。
  int? position;

  /// 封面地址。
  String? coverUrl;

  /// 榜单名称。
  String? name;

  /// 服务端拼写错误的更新频率字段。
  String? upateFrequency;

  /// 更新频率文案。
  String? updateFrequency;

  /// 榜单内歌手摘要列表。
  List<ArtistTopListArtists>? artists;

  /// 创建歌手榜单信息。
  ArtistTopList();

  /// 从 JSON 构建歌手榜单信息。
  factory ArtistTopList.fromJson(Map<String, dynamic> json) =>
      _$ArtistTopListFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistTopListToJson(this);
}

@JsonSerializable()

/// 赞赏榜单信息。
class RewardTopList {
  /// 榜单位置。
  int? position;

  /// 封面地址。
  String? coverUrl;

  /// 榜单歌曲列表。
  late List<Song> songs;

  /// 创建赞赏榜单信息。
  RewardTopList();

  /// 从 JSON 构建赞赏榜单信息。
  factory RewardTopList.fromJson(Map<String, dynamic> json) =>
      _$RewardTopListFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$RewardTopListToJson(this);
}

@JsonSerializable()

/// 榜单列表响应。
class TopListWrap extends ServerStatusBean {
  /// 音乐榜单列表。
  late List<TopList> list;

  /// 歌手榜单信息。
  late ArtistTopList artistToplist;

  /// 创建榜单列表响应。
  TopListWrap();

  /// 从 JSON 构建榜单列表响应。
  factory TopListWrap.fromJson(Map<String, dynamic> json) =>
      _$TopListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$TopListWrapToJson(this);
}

@JsonSerializable()

/// 榜单详情响应。
class TopListDetailWrap extends ServerStatusBean {
  /// 音乐榜单列表。
  late List<TopList> list;

  /// 歌手榜单信息。
  late ArtistTopList artistToplist;

  /// 赞赏榜单信息。
  late RewardTopList rewardToplist;

  /// 创建榜单详情响应。
  TopListDetailWrap();

  /// 从 JSON 构建榜单详情响应。
  factory TopListDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$TopListDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$TopListDetailWrapToJson(this);
}

@JsonSerializable()

/// 音乐日历事件。
class McalendarDetailEvent {
  /// 日历事件 id。
  late String id;

  /// 事件类型。
  String? eventType;

  /// 上线时间戳。
  int? onlineTime;

  /// 下线时间戳。
  int? offlineTime;

  /// 事件图片地址。
  late String imgUrl;

  /// 点击目标地址。
  String? targetUrl;

  /// 事件标签。
  String? tag;

  /// 事件标题。
  String? title;

  /// 是否可设置提醒。
  bool? canRemind;

  /// 是否已提醒。
  bool? reminded;

  /// 提醒按钮文案。
  String? remindText;

  /// 关联资源 id。
  String? resourceId;

  /// 关联资源类型。
  String? resourceType;

  /// 事件状态。
  String? eventStatus;

  /// 已提醒状态文案。
  String? remindedText;

  /// 创建音乐日历事件。
  McalendarDetailEvent();

  /// 从 JSON 构建音乐日历事件。
  factory McalendarDetailEvent.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailEventFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$McalendarDetailEventToJson(this);
}

@JsonSerializable()

/// 音乐日历详情。
class McalendarDetail {
  /// 日历事件列表。
  late List<McalendarDetailEvent> calendarEvents;

  /// 创建音乐日历详情。
  McalendarDetail();

  /// 从 JSON 构建音乐日历详情。
  factory McalendarDetail.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$McalendarDetailToJson(this);
}

@JsonSerializable()

/// 音乐日历详情响应。
class McalendarDetailWrap extends ServerStatusBean {
  /// 音乐日历详情数据。
  late McalendarDetail data;

  /// 创建音乐日历详情响应。
  McalendarDetailWrap();

  /// 从 JSON 构建音乐日历详情响应。
  factory McalendarDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$McalendarDetailWrapToJson(this);
}

@JsonSerializable()

/// 听歌识曲匹配结果。
class AudioMatchResult {
  /// 匹配开始时间。
  int? startTime;

  /// 匹配到的歌曲。
  late Song song;

  /// 创建听歌识曲匹配结果。
  AudioMatchResult();

  /// 从 JSON 构建听歌识曲匹配结果。
  factory AudioMatchResult.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$AudioMatchResultToJson(this);
}

@JsonSerializable()

/// 听歌识曲匹配结果数据。
class AudioMatchResultData {
  /// 匹配结果类型。
  int? type;

  /// 匹配结果列表。
  late List<AudioMatchResult> result;

  /// 创建听歌识曲匹配结果数据。
  AudioMatchResultData();

  /// 从 JSON 构建听歌识曲匹配结果数据。
  factory AudioMatchResultData.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$AudioMatchResultDataToJson(this);
}

@JsonSerializable()

/// 听歌识曲匹配结果响应。
class AudioMatchResultWrap extends ServerStatusBean {
  /// 听歌识曲匹配结果数据。
  late AudioMatchResultData data;

  /// 创建听歌识曲匹配结果响应。
  AudioMatchResultWrap();

  /// 从 JSON 构建听歌识曲匹配结果响应。
  factory AudioMatchResultWrap.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AudioMatchResultWrapToJson(this);
}

@JsonSerializable()

/// 一起听房间状态数据。
class ListenTogetherStatusData {
  /// 当前账号是否在一起听房间中。
  late bool inRoom;

  /// 房间信息，结构由服务端按房间类型返回。
  dynamic roomInfo;

  /// 一起听状态扩展数据。
  dynamic status;

  /// 创建一起听房间状态数据。
  ListenTogetherStatusData();

  /// 从 JSON 构建一起听房间状态数据。
  factory ListenTogetherStatusData.fromJson(Map<String, dynamic> json) =>
      _$ListenTogetherStatusDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ListenTogetherStatusDataToJson(this);
}

@JsonSerializable()

/// 一起听房间状态响应。
class ListenTogetherStatusWrap extends ServerStatusBean {
  /// 一起听房间状态数据。
  late ListenTogetherStatusData data;

  /// 创建一起听房间状态响应。
  ListenTogetherStatusWrap();

  /// 从 JSON 构建一起听房间状态响应。
  factory ListenTogetherStatusWrap.fromJson(Map<String, dynamic> json) =>
      _$ListenTogetherStatusWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ListenTogetherStatusWrapToJson(this);
}

@JsonSerializable()

/// 图片上传分配信息。
class UploadImageAlloc {
  /// 上传 bucket 名称。
  late String bucket;

  /// 上传文档 id。
  late String docId;

  /// 上传对象 key。
  late String objectKey;

  /// 上传授权 token。
  late String token;

  /// 创建图片上传分配信息。
  UploadImageAlloc();

  /// 从 JSON 构建图片上传分配信息。
  factory UploadImageAlloc.fromJson(Map<String, dynamic> json) =>
      _$UploadImageAllocFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$UploadImageAllocToJson(this);
}

@JsonSerializable()

/// 图片上传分配响应。
class UploadImageAllocWrap extends ServerStatusBean {
  /// 图片上传分配信息。
  late UploadImageAlloc result;

  /// 创建图片上传分配响应。
  UploadImageAllocWrap();

  /// 从 JSON 构建图片上传分配响应。
  factory UploadImageAllocWrap.fromJson(Map<String, dynamic> json) =>
      _$UploadImageAllocWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UploadImageAllocWrapToJson(this);
}

@JsonSerializable()

/// 图片上传完成后的资源信息。
class UploadImageResult extends ServerStatusBean {
  /// 上传图片资源 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 上传后的图片访问地址。
  String? url;

  /// 创建图片上传结果。
  UploadImageResult();

  /// 从 JSON 构建图片上传结果。
  factory UploadImageResult.fromJson(Map<String, dynamic> json) =>
      _$UploadImageResultFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UploadImageResultToJson(this);
}

/// 批量接口响应包装，按请求路径保存每个子接口结果。
class BatchApiWrap extends ServerStatusBean {
  /// 批量接口原始响应数据。
  late Map<String, dynamic> data;

  /// 创建批量接口响应包装。
  BatchApiWrap();

  /// 按接口元数据查找对应子响应数据。
  dynamic findResponseData<T>(DioMetaData metaData) {
    return data[metaData.uri.path];
  }

  /// 从 JSON 构建批量接口响应包装。
  factory BatchApiWrap.fromJson(Map<String, dynamic> json) {
    return BatchApiWrap()
      ..code = json['code'] as int
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = json;
  }
}
