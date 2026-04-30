// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../common/bean.dart';
import '../login/bean.dart';
import '../play/bean.dart';
import '../user/bean.dart';

part 'bean.g.dart';

@JsonSerializable()

/// 动态或评论资源的评论线程统计信息。
class CommentThread {
  /// 评论线程 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 评论线程关联的资源类型。
  int? resourceType;

  /// 评论数量。
  int? commentCount;

  /// 点赞数量。
  int? likedCount;

  /// 分享数量。
  int? shareCount;

  /// 热评数量。
  int? hotCount;

  /// 评论线程关联的资源 id。
  int? resourceId;

  /// 资源拥有者用户 id。
  int? resourceOwnerId;

  /// 资源标题。
  String? resourceTitle;

  /// 创建评论线程统计信息。
  CommentThread();

  /// 从 JSON 构建评论线程统计信息。
  factory CommentThread.fromJson(Map<String, dynamic> json) =>
      _$CommentThreadFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentThreadToJson(this);
}

@JsonSerializable()

/// 动态条目的交互统计信息。
class EventItemInfo {
  /// 动态评论线程 id。
  late String threadId;

  /// 动态关联资源 id。
  int? resourceId;

  /// 动态关联资源类型。
  int? resourceType;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 评论数量。
  int? commentCount;

  /// 点赞数量。
  int? likedCount;

  /// 分享数量。
  int? shareCount;

  /// 评论线程详情。
  late CommentThread commentThread;

  /// 创建动态交互统计信息。
  EventItemInfo();

  /// 从 JSON 构建动态交互统计信息。
  factory EventItemInfo.fromJson(Map<String, dynamic> json) =>
      _$EventItemInfoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$EventItemInfoToJson(this);
}

@JsonSerializable()

/// 用户动态条目。
class EventItem {
  /// 动态 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 活动名称。
  String? actName;

  /// 动态业务内容的原始 JSON 字符串。
  String? json;

  /// 动态类型。
  int? type;

  /// 活动 id。
  int? actId;

  /// 动态发布时间。
  int? eventTime;

  /// 动态过期时间。
  int? expireTime;

  /// 动态展示时间。
  int? showTime;

  /// 转发数量。
  int? forwardCount;

  /// 服务端扩展统计值。
  int? sic;

  /// 站内转发数量。
  late int insiteForwardCount;

  /// 是否为置顶动态。
  bool? topEvent;

  /// 发布动态的用户。
  late NeteaseAccountProfile user;

  /// 动态交互统计信息。
  late EventItemInfo info;

  /// 创建用户动态条目。
  EventItem();

  /// 从 JSON 构建用户动态条目。
  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$EventItemToJson(this);
}

@JsonSerializable()

/// 动态列表响应，使用 events 字段承载列表。
class EventListWrap extends ServerStatusBean {
  /// 动态条目列表。
  List<EventItem>? events;

  /// 下一页时间游标。
  int? lasttime;

  /// 创建动态列表响应。
  EventListWrap();

  /// 从 JSON 构建动态列表响应。
  factory EventListWrap.fromJson(Map<String, dynamic> json) =>
      _$EventListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$EventListWrapToJson(this);
}

@JsonSerializable()

/// 动态列表响应，使用 event 字段承载列表。
class EventListWrap2 extends ServerStatusBean {
  /// 动态条目列表。
  List<EventItem>? event;

  /// 下一页时间游标。
  int? lasttime;

  /// 创建动态列表响应。
  EventListWrap2();

  /// 从 JSON 构建动态列表响应。
  factory EventListWrap2.fromJson(Map<String, dynamic> json) =>
      _$EventListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$EventListWrap2ToJson(this);
}

@JsonSerializable()

/// 单条动态详情响应。
class EventSingleWrap extends ServerStatusBean {
  /// 动态详情。
  late EventItem event;

  /// 创建单条动态详情响应。
  EventSingleWrap();

  /// 从 JSON 构建单条动态详情响应。
  factory EventSingleWrap.fromJson(Map<String, dynamic> json) =>
      _$EventSingleWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$EventSingleWrapToJson(this);
}

@JsonSerializable()

/// 评论条目的基础字段。
class CommentItemBase {
  /// 评论 id。
  @JsonKey(fromJson: dynamicToString)
  late String commentId;

  /// 父评论 id。
  @JsonKey(fromJson: dynamicToString)
  String? parentCommentId;

  /// 评论用户。
  late NeteaseUserInfo user;

  /// 被回复的评论列表。
  List<BeRepliedCommentItem>? beReplied;

  /// 评论正文。
  String? content;

  /// 评论时间戳。
  int? time;

  /// 评论时间展示文案。
  String? timeStr;

  /// 点赞数量。
  int? likedCount;

  /// 回复数量。
  int? replyCount;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 评论状态。
  int? status;

  /// 评论位置类型。
  int? commentLocationType;

  /// 创建评论基础条目。
  CommentItemBase();

  /// 从 JSON 构建评论基础条目。
  factory CommentItemBase.fromJson(Map<String, dynamic> json) =>
      _$CommentItemBaseFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentItemBaseToJson(this);
}

@JsonSerializable()

/// 评论列表中的普通评论条目。
class CommentItem extends CommentItemBase {
  /// 被回复的评论列表。
  @override
  List<BeRepliedCommentItem>? beReplied;

  /// 创建普通评论条目。
  CommentItem();

  /// 从 JSON 构建普通评论条目。
  factory CommentItem.fromJson(Map<String, dynamic> json) =>
      _$CommentItemFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CommentItemToJson(this);
}

@JsonSerializable()

/// 被回复评论条目。
class BeRepliedCommentItem extends CommentItemBase {
  /// 被回复评论 id。
  @JsonKey(fromJson: dynamicToString)
  String? beRepliedCommentId;

  /// 创建被回复评论条目。
  BeRepliedCommentItem();

  /// 从 JSON 构建被回复评论条目。
  factory BeRepliedCommentItem.fromJson(Map<String, dynamic> json) =>
      _$BeRepliedCommentItemFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$BeRepliedCommentItemToJson(this);
}

@JsonSerializable()

/// 旧版评论列表响应。
class CommentListWrap extends ServerStatusListBean {
  /// 是否还有更多热评。
  bool? moreHot;

  /// 评论总量。
  int? cnum;

  /// 资源作者是否为音乐人。
  bool? isMusician;

  /// 当前用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 置顶评论列表。
  List<CommentItem>? topComments;

  /// 热评列表。
  List<CommentItem>? hotComments;

  /// 普通评论列表。
  List<CommentItem>? comments;

  /// 创建旧版评论列表响应。
  CommentListWrap();

  /// 从 JSON 构建旧版评论列表响应。
  factory CommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CommentListWrapToJson(this);
}

@JsonSerializable()

/// 历史评论数据。
class CommentHistoryData {
  /// 是否还有更多历史评论。
  bool? hasMore;

  /// 是否存在提醒信息。
  bool? reminder;

  /// 评论总量。
  int? commentCount;

  /// 历史热评列表。
  List<CommentItem>? hotComments;

  /// 历史普通评论列表。
  List<CommentItem>? comments;

  /// 创建历史评论数据。
  CommentHistoryData();

  /// 从 JSON 构建历史评论数据。
  factory CommentHistoryData.fromJson(Map<String, dynamic> json) =>
      _$CommentHistoryDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentHistoryDataToJson(this);
}

@JsonSerializable()

/// 历史评论响应。
class CommentHistoryWrap extends ServerStatusBean {
  /// 历史评论数据。
  late CommentHistoryData data;

  /// 创建历史评论响应。
  CommentHistoryWrap();

  /// 从 JSON 构建历史评论响应。
  factory CommentHistoryWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentHistoryWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CommentHistoryWrapToJson(this);
}

@JsonSerializable()

/// 新版评论列表的排序类型。
class CommentList2DataSortType {
  /// 排序类型值。
  int? sortType;

  /// 排序类型展示名。
  String? sortTypeName;

  /// 排序目标标识。
  String? target;

  /// 创建新版评论排序类型。
  CommentList2DataSortType();

  /// 从 JSON 构建新版评论排序类型。
  factory CommentList2DataSortType.fromJson(Map<String, dynamic> json) =>
      _$CommentList2DataSortTypeFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentList2DataSortTypeToJson(this);
}

@JsonSerializable()

/// 新版评论列表数据。
class CommentList2Data {
  /// 是否还有更多评论。
  bool? hasMore;

  /// 下一页游标。
  String? cursor;

  /// 评论总量。
  int? totalCount;

  /// 当前排序类型。
  int? sortType;

  /// 可选排序类型列表。
  List<CommentList2DataSortType>? sortTypeList;

  /// 评论列表。
  List<CommentItem>? comments;

  /// 当前楼层主评论。
  CommentItem? currentComment;

  /// 创建新版评论列表数据。
  CommentList2Data();

  /// 从 JSON 构建新版评论列表数据。
  factory CommentList2Data.fromJson(Map<String, dynamic> json) =>
      _$CommentList2DataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentList2DataToJson(this);
}

@JsonSerializable()

/// 新版评论列表响应。
class CommentList2Wrap extends ServerStatusBean {
  /// 新版评论列表数据。
  late CommentList2Data data;

  /// 创建新版评论列表响应。
  CommentList2Wrap();

  /// 从 JSON 构建新版评论列表响应。
  factory CommentList2Wrap.fromJson(Map<String, dynamic> json) =>
      _$CommentList2WrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CommentList2WrapToJson(this);
}

@JsonSerializable()

/// 抱抱评论用户条目。
class HugComment {
  /// 发送抱抱的用户。
  late NeteaseUserInfo user;

  /// 抱抱附带文案。
  String? hugContent;

  /// 创建抱抱评论用户条目。
  HugComment();

  /// 从 JSON 构建抱抱评论用户条目。
  factory HugComment.fromJson(Map<String, dynamic> json) =>
      _$HugCommentFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HugCommentToJson(this);
}

@JsonSerializable()

/// 抱抱评论列表数据。
class HugCommentListData {
  /// 是否还有更多抱抱评论。
  bool? hasMore;

  /// 下一页游标。
  String? cursor;

  /// 数值型游标。
  int? idCursor;

  /// 抱抱总数。
  int? hugTotalCounts;

  /// 抱抱评论列表。
  List<HugComment>? hugComments;

  /// 当前评论。
  late CommentItem currentComment;

  /// 创建抱抱评论列表数据。
  HugCommentListData();

  /// 从 JSON 构建抱抱评论列表数据。
  factory HugCommentListData.fromJson(Map<String, dynamic> json) =>
      _$HugCommentListDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HugCommentListDataToJson(this);
}

@JsonSerializable()

/// 抱抱评论列表响应。
class HugCommentListWrap extends ServerStatusBean {
  /// 抱抱评论列表数据。
  late HugCommentListData data;

  /// 创建抱抱评论列表响应。
  HugCommentListWrap();

  /// 从 JSON 构建抱抱评论列表响应。
  factory HugCommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$HugCommentListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$HugCommentListWrapToJson(this);
}

@JsonSerializable()

/// 楼层评论详情数据。
class FloorCommentDetail {
  /// 楼层回复评论列表。
  List<CommentItem>? comments;

  /// 是否还有更多楼层回复。
  bool? hasMore;

  /// 楼层回复总数。
  int? totalCount;

  /// 分页时间游标。
  int? time;

  /// 楼层主评论。
  late CommentItem ownerComment;

  /// 创建楼层评论详情数据。
  FloorCommentDetail();

  /// 从 JSON 构建楼层评论详情数据。
  factory FloorCommentDetail.fromJson(Map<String, dynamic> json) =>
      _$FloorCommentDetailFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$FloorCommentDetailToJson(this);
}

@JsonSerializable()

/// 楼层评论详情响应。
class FloorCommentDetailWrap extends ServerStatusBean {
  /// 楼层评论详情数据。
  late FloorCommentDetail data;

  /// 创建楼层评论详情响应。
  FloorCommentDetailWrap();

  /// 从 JSON 构建楼层评论详情响应。
  factory FloorCommentDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$FloorCommentDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$FloorCommentDetailWrapToJson(this);
}

@JsonSerializable()

/// 动态转发结果。
class EventForwardRet {
  /// 服务端返回消息。
  String? msg;

  /// 转发后生成的动态 id。
  late int eventId;

  /// 转发动态时间。
  int? eventTime;

  /// 创建动态转发结果。
  EventForwardRet();

  /// 从 JSON 构建动态转发结果。
  factory EventForwardRet.fromJson(Map<String, dynamic> json) =>
      _$EventForwardRetFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$EventForwardRetToJson(this);
}

@JsonSerializable()

/// 动态转发响应。
class EventForwardRetWrap extends ServerStatusBean {
  /// 动态转发结果。
  EventForwardRet? data;

  /// 创建动态转发响应。
  EventForwardRetWrap();

  /// 从 JSON 构建动态转发响应。
  factory EventForwardRetWrap.fromJson(Map<String, dynamic> json) =>
      _$EventForwardRetWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$EventForwardRetWrapToJson(this);
}

@JsonSerializable()

/// 话题正文内容片段。
class TopicContent {
  /// 内容片段 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 内容片段类型。
  int? type;

  /// 内容文本。
  String? content;

  /// 创建话题正文内容片段。
  TopicContent();

  /// 从 JSON 构建话题正文内容片段。
  factory TopicContent.fromJson(Map<String, dynamic> json) =>
      _$TopicContentFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopicContentToJson(this);
}

@JsonSerializable()

/// 话题详情数据。
class Topic {
  /// 话题 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 创建用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 话题正文内容片段列表。
  List<TopicContent>? content;

  /// 话题标题。
  String? title;

  /// 微信分享标题。
  String? wxTitle;

  /// 主标题。
  String? mainTitle;

  /// 开始提示文案。
  String? startText;

  /// 话题摘要。
  String? summary;

  /// 广告信息。
  late String adInfo;

  /// 推荐标题。
  String? recomdTitle;

  /// 推荐文案。
  String? recomdContent;

  /// 添加时间。
  late int addTime;

  /// 发布时间。
  int? pubTime;

  /// 更新时间。
  int? updateTime;

  /// 封面资源 id。
  int? cover;

  /// 头像图片资源 id。
  int? headPic;

  /// 话题状态。
  int? status;

  /// 系列 id。
  int? seriesId;

  /// 分类 id。
  int? categoryId;

  /// 热度分。
  double? hotScore;

  /// 审核人。
  String? auditor;

  /// 审核时间。
  int? auditTime;

  /// 审核状态。
  int? auditStatus;

  /// 删除原因。
  String? delReason;

  /// 话题序号。
  int? number;

  /// 阅读数量。
  int? readCount;

  /// 矩形封面资源 id。
  int? rectanglePic;

  /// 话题标签列表。
  List<String>? tags;

  /// 是否开启赞赏。
  bool? reward;

  /// 是否来自后台配置。
  bool? fromBackend;

  /// 是否展示相关内容。
  bool? showRelated;

  /// 是否展示评论。
  bool? showComment;

  /// 是否立即发布。
  bool? pubImmidiatly;

  /// 创建话题详情数据。
  Topic();

  /// 从 JSON 构建话题详情数据。
  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

@JsonSerializable()

/// 话题广场内容条目。
class TopicItem2 {
  /// 条目 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 话题详情。
  late Topic topic;

  /// 创建者用户。
  late NeteaseUserInfo creator;

  /// 条目序号。
  int? number;

  /// 分享数量。
  int? shareCount;

  /// 评论数量。
  int? commentCount;

  /// 点赞数量。
  int? likedCount;

  /// 阅读数量。
  int? readCount;

  /// 赞赏数量。
  int? rewardCount;

  /// 赞赏金额。
  double? rewardMoney;

  /// 矩形封面地址。
  String? rectanglePicUrl;

  /// 封面地址。
  String? coverUrl;

  /// 系列 id。
  int? seriesId;

  /// 分类 id。
  int? categoryId;

  /// 分类名称。
  String? categoryName;

  /// 话题链接。
  String? url;

  /// 微信分享标题。
  String? wxTitle;

  /// 主标题。
  String? mainTitle;

  /// 标题。
  String? title;

  /// 摘要。
  String? summary;

  /// 分享文案。
  String? shareContent;

  /// 推荐标题。
  String? recmdTitle;

  /// 推荐文案。
  String? recmdContent;

  /// 标签列表。
  List<String>? tags;

  /// 添加时间。
  late int addTime;

  /// 评论线程 id。
  String? commentThreadId;

  /// 是否展示相关内容。
  bool? showRelated;

  /// 是否展示评论。
  bool? showComment;

  /// 是否开启赞赏。
  bool? reward;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 创建话题广场内容条目。
  TopicItem2();

  /// 从 JSON 构建话题广场内容条目。
  factory TopicItem2.fromJson(Map<String, dynamic> json) =>
      _$TopicItem2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopicItem2ToJson(this);
}

@JsonSerializable()

/// 热门话题条目。
class TopicItem {
  /// 活动话题 id。
  @JsonKey(fromJson: dynamicToString)
  late String actId;

  /// 话题标题。
  String? title;

  /// 话题说明文本列表。
  List<String>? text;

  /// 推荐理由。
  String? reason;

  /// 参与人数。
  int? participateCount;

  /// 是否使用默认图片。
  late bool isDefaultImg;

  /// 推荐算法或质量评分标识。
  String? alg;

  /// 开始时间。
  int? startTime;

  /// 结束时间。
  int? endTime;

  /// 资源类型。
  int? resourceType;

  /// 视频类型。
  int? videoType;

  /// 话题类型。
  int? topicType;

  /// 会议开始时间。
  int? meetingBeginTime;

  /// 会议结束时间。
  int? meetingEndTime;

  /// PC 长封面地址。
  String? coverPCLongUrl;

  /// 分享图片地址。
  String? sharePicUrl;

  /// PC 封面地址。
  String? coverPCUrl;

  /// 移动端封面地址。
  String? coverMobileUrl;

  /// PC 列表封面地址。
  String? coverPCListUrl;

  /// 创建热门话题条目。
  TopicItem();

  /// 从 JSON 构建热门话题条目。
  factory TopicItem.fromJson(Map<String, dynamic> json) =>
      _$TopicItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TopicItemToJson(this);
}

@JsonSerializable()

/// 热门话题列表响应。
class TopicHotListWrap extends ServerStatusBean {
  /// 热门话题列表。
  List<TopicItem>? hot;

  /// 创建热门话题列表响应。
  TopicHotListWrap();

  /// 从 JSON 构建热门话题列表响应。
  factory TopicHotListWrap.fromJson(Map<String, dynamic> json) =>
      _$TopicHotListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$TopicHotListWrapToJson(this);
}

@JsonSerializable()

/// 话题详情响应。
class TopicDetailWrap extends ServerStatusBean {
  /// 话题详情。
  late TopicItem act;

  /// 是否需要开始提醒。
  bool? needBeginNotify;

  /// 创建话题详情响应。
  TopicDetailWrap();

  /// 从 JSON 构建话题详情响应。
  factory TopicDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$TopicDetailWrapToJson(this);
}

@JsonSerializable()

/// 热评墙评论关联的歌曲资源摘要。
class SimpleResourceInfo {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  String? songId;

  /// 评论线程 id。
  String? threadId;

  /// 歌曲封面地址。
  String? songCoverUrl;

  /// 歌曲名称。
  String? name;

  /// 歌曲详情。
  late Song song;

  /// 创建歌曲资源摘要。
  SimpleResourceInfo();

  /// 从 JSON 构建歌曲资源摘要。
  factory SimpleResourceInfo.fromJson(Map<String, dynamic> json) =>
      _$SimpleResourceInfoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SimpleResourceInfoToJson(this);
}

@JsonSerializable()

/// 热评墙评论条目。
class HotwallCommentItem {
  /// 热评墙评论 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 评论线程 id。
  String? threadId;

  /// 评论正文。
  String? content;

  /// 评论时间戳。
  int? time;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 点赞数量。
  int? likedCount;

  /// 回复数量。
  int? replyCount;

  /// 评论用户摘要。
  late NeteaseSimpleUserInfo simpleUserInfo;

  /// 评论关联资源摘要。
  late SimpleResourceInfo simpleResourceInfo;

  /// 创建热评墙评论条目。
  HotwallCommentItem();

  /// 从 JSON 构建热评墙评论条目。
  factory HotwallCommentItem.fromJson(Map<String, dynamic> json) =>
      _$HotwallCommentItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$HotwallCommentItemToJson(this);
}

@JsonSerializable()

/// 热评墙评论列表响应。
class HotwallCommentListWrap extends ServerStatusBean {
  /// 热评墙评论列表。
  List<HotwallCommentItem>? data;

  /// 创建热评墙评论列表响应。
  HotwallCommentListWrap();

  /// 从 JSON 构建热评墙评论列表响应。
  factory HotwallCommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$HotwallCommentListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$HotwallCommentListWrapToJson(this);
}

@JsonSerializable()

/// 评论摘要信息。
class CommentSimple {
  /// 评论 id。
  @JsonKey(fromJson: dynamicToString)
  String? commentId;

  /// 评论正文。
  String? content;

  /// 评论线程 id。
  String? threadId;

  /// 评论用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 评论用户名称。
  String? userName;

  /// 创建评论摘要信息。
  CommentSimple();

  /// 从 JSON 构建评论摘要信息。
  factory CommentSimple.fromJson(Map<String, dynamic> json) =>
      _$CommentSimpleFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentSimpleToJson(this);
}

@JsonSerializable()

/// 评论发布或回复结果。
class Comment {
  /// 评论 id。
  @JsonKey(fromJson: dynamicToString)
  late String commentId;

  /// 评论用户。
  late NeteaseUserInfo user;

  /// 被回复用户。
  NeteaseUserInfo? beRepliedUser;

  /// 表情图片地址。
  String? expressionUrl;

  /// 评论位置类型。
  int? commentLocationType;

  /// 评论时间戳。
  int? time;

  /// 评论正文。
  String? content;

  /// 创建评论结果。
  Comment();

  /// 从 JSON 构建评论结果。
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()

/// 评论发布或回复响应。
class CommentWrap extends ServerStatusBean {
  /// 评论结果。
  Comment? comment;

  /// 创建评论响应。
  CommentWrap();

  /// 从 JSON 构建评论响应。
  factory CommentWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CommentWrapToJson(this);
}

@JsonSerializable()

/// 私信中的推广消息。
class MsgPromotion {
  /// 推广 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 推广标题。
  String? title;

  /// 推广封面地址。
  String? coverUrl;

  /// 推广正文。
  String? text;

  /// 推广跳转地址。
  String? url;

  /// 添加时间。
  late int addTime;

  /// 创建推广消息。
  MsgPromotion();

  /// 从 JSON 构建推广消息。
  factory MsgPromotion.fromJson(Map<String, dynamic> json) =>
      _$MsgPromotionFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MsgPromotionToJson(this);
}

@JsonSerializable()

/// 私信中的通用资源消息。
class MsgGeneral {
  /// 消息标题。
  String? title;

  /// 消息副标题。
  String? subTitle;

  /// 主标签。
  String? tag;

  /// 子标签。
  String? subTag;

  /// 通知文案。
  String? noticeMsg;

  /// 收件箱摘要文案。
  late String inboxBriefContent;

  /// Web 跳转地址。
  String? webUrl;

  /// 原生跳转地址。
  String? nativeUrl;

  /// 封面地址。
  String? cover;

  /// 资源名称。
  String? resName;

  /// 频道类型。
  int? channel;

  /// 子类型。
  int? subType;

  /// 是否可播放。
  bool? canPlay;

  /// 创建通用资源消息。
  MsgGeneral();

  /// 从 JSON 构建通用资源消息。
  factory MsgGeneral.fromJson(Map<String, dynamic> json) =>
      _$MsgGeneralFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MsgGeneralToJson(this);
}

@JsonSerializable()

/// 私信内容体。
class MsgContent {
  /// 消息正文。
  String? msg;

  /// 消息标题。
  String? title;

  /// 推送文案。
  String? pushMsg;

  /// 消息类型。
  int? type;

  /// 资源类型。
  int? resType;

  /// 是否为新发布内容。
  bool? newPub;

  /// 类型 12 的推广消息。
  MsgPromotion? promotionUrl;

  /// 类型 23 的通用资源消息。
  MsgGeneral? generalMsg;

  /// 类型 7 的 MV 消息。
  Mv3? mv;

  /// 创建私信内容体。
  MsgContent();

  /// 从 JSON 构建私信内容体。
  factory MsgContent.fromJson(Map<String, dynamic> json) =>
      _$MsgContentFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MsgContentToJson(this);
}

@JsonSerializable()

/// 私信会话摘要。
class Msg {
  /// 发送方用户。
  late NeteaseUserInfo fromUser;

  /// 接收方用户。
  late NeteaseUserInfo toUser;

  /// 最近一条消息的原始 JSON 字符串。
  String? lastMsg;

  /// 是否为通知账号。
  bool? noticeAccountFlag;

  /// 最近一条消息时间。
  int? lastMsgTime;

  /// 新消息数量。
  int? newMsgCount;

  /// 解析后的最近一条消息内容。
  MsgContent get msgObj {
    return MsgContent.fromJson(jsonDecode(lastMsg ?? ''));
  }

  /// 创建私信会话摘要。
  Msg();

  /// 从 JSON 构建私信会话摘要。
  factory Msg.fromJson(Map<String, dynamic> json) => _$MsgFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MsgToJson(this);
}

@JsonSerializable()

/// 私信消息条目。
class Msg2 {
  /// 消息 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 发送方用户。
  late NeteaseUserInfo fromUser;

  /// 接收方用户。
  late NeteaseUserInfo toUser;

  /// 消息原始 JSON 字符串。
  String? msg;

  /// 消息时间。
  int? time;

  /// 批次 id。
  int? batchId;

  /// 解析后的消息内容。
  MsgContent get msgObj {
    return MsgContent.fromJson(jsonDecode(msg ?? ''));
  }

  /// 创建私信消息条目。
  Msg2();

  /// 从 JSON 构建私信消息条目。
  factory Msg2.fromJson(Map<String, dynamic> json) => _$Msg2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Msg2ToJson(this);
}

@JsonSerializable()

/// 私信会话列表响应。
class UsersMsgListWrap extends ServerStatusBean {
  /// 私信会话摘要列表。
  List<Msg>? msgs;

  /// 创建私信会话列表响应。
  UsersMsgListWrap();

  /// 从 JSON 构建私信会话列表响应。
  factory UsersMsgListWrap.fromJson(Map<String, dynamic> json) =>
      _$UsersMsgListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UsersMsgListWrapToJson(this);
}

@JsonSerializable()

/// 最近联系人数据。
class RecentContactUsersData {
  /// 最近关注联系人列表。
  List<NeteaseAccountProfile>? follow;

  /// 创建最近联系人数据。
  RecentContactUsersData();

  /// 从 JSON 构建最近联系人数据。
  factory RecentContactUsersData.fromJson(Map<String, dynamic> json) =>
      _$RecentContactUsersDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$RecentContactUsersDataToJson(this);
}

@JsonSerializable()

/// 最近联系人响应。
class RecentContactUsersWrap extends ServerStatusBean {
  /// 最近联系人数据。
  late RecentContactUsersData data;

  /// 创建最近联系人响应。
  RecentContactUsersWrap();

  /// 从 JSON 构建最近联系人响应。
  factory RecentContactUsersWrap.fromJson(Map<String, dynamic> json) =>
      _$RecentContactUsersWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$RecentContactUsersWrapToJson(this);
}

@JsonSerializable()

/// 与指定用户的私信消息列表响应。
class UserMsgListWrap extends ServerStatusBean {
  /// 私信消息列表。
  List<Msg2>? msgs;

  /// 对方是否为艺人。
  late bool isArtist;

  /// 当前用户是否已订阅对方。
  late bool isSubed;

  /// 是否还有更多消息。
  bool? more;

  /// 创建私信消息列表响应。
  UserMsgListWrap();

  /// 从 JSON 构建私信消息列表响应。
  factory UserMsgListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserMsgListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserMsgListWrapToJson(this);
}

@JsonSerializable()

/// 新私信消息列表响应。
class UserMsgListWrap2 extends ServerStatusBean {
  /// 新消息分组 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 新消息列表。
  List<Msg2>? newMsgs;

  /// 创建新私信消息列表响应。
  UserMsgListWrap2();

  /// 从 JSON 构建新私信消息列表响应。
  factory UserMsgListWrap2.fromJson(Map<String, dynamic> json) =>
      _$UserMsgListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$UserMsgListWrap2ToJson(this);
}

@JsonSerializable()

/// 图片封面信息。
class Cover {
  /// 图片宽度。
  int? width;

  /// 图片高度。
  int? height;

  /// 图片地址。
  String? url;

  /// 创建图片封面信息。
  Cover();

  /// 从 JSON 构建图片封面信息。
  factory Cover.fromJson(Map<String, dynamic> json) => _$CoverFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CoverToJson(this);
}

@JsonSerializable()

/// 云村话题信息。
class Talk {
  /// 话题 id。
  @JsonKey(fromJson: dynamicToString)
  String? talkId;

  /// 话题名称。
  String? talkName;

  /// 话题描述。
  String? talkDes;

  /// 分享封面。
  late Cover shareCover;

  /// 展示封面。
  late Cover showCover;

  /// 话题状态。
  int? status;

  /// Mlog 数量。
  int? mlogCount;

  /// 关注数量。
  int? follows;

  /// 参与数量。
  int? participations;

  /// 展示参与数量。
  int? showParticipations;

  /// 当前用户是否已关注。
  late bool isFollow;

  /// 推荐算法标识。
  String? alg;

  /// 创建云村话题信息。
  Talk();

  /// 从 JSON 构建云村话题信息。
  factory Talk.fromJson(Map<String, dynamic> json) => _$TalkFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$TalkToJson(this);
}

@JsonSerializable()

/// Mlog 基础内容数据。
class MyLogBaseData {
  /// Mlog id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 发布时间。
  int? pubTime;

  /// Mlog 类型。
  int? type;

  /// 封面地址。
  String? coverUrl;

  /// 封面宽度。
  int? coverWidth;

  /// 封面高度。
  int? coverHeight;

  /// 封面主色。
  int? coverColor;

  /// 关联云村话题。
  Talk? talk;

  /// 文本内容。
  String? text;

  /// 创建 Mlog 基础内容数据。
  MyLogBaseData();

  /// 从 JSON 构建 Mlog 基础内容数据。
  factory MyLogBaseData.fromJson(Map<String, dynamic> json) =>
      _$MyLogBaseDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MyLogBaseDataToJson(this);
}

@JsonSerializable()

/// Mlog 资源扩展统计。
class MyLogResourceExt {
  /// 点赞数量。
  int? likedCount;

  /// 评论数量。
  int? commentCount;

  /// 创建 Mlog 资源扩展统计。
  MyLogResourceExt();

  /// 从 JSON 构建 Mlog 资源扩展统计。
  factory MyLogResourceExt.fromJson(Map<String, dynamic> json) =>
      _$MyLogResourceExtFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MyLogResourceExtToJson(this);
}

@JsonSerializable()

/// Mlog 资源数据。
class MyLogResource {
  /// Mlog 基础内容数据。
  late MyLogBaseData mlogBaseData;

  /// Mlog 扩展统计。
  late MyLogResourceExt mlogExtVO;

  /// 发布者资料。
  NeteaseAccountProfile? userProfile;

  /// 资源状态。
  int? status;

  /// 分享地址。
  String? shareUrl;

  /// 创建 Mlog 资源数据。
  MyLogResource();

  /// 从 JSON 构建 Mlog 资源数据。
  factory MyLogResource.fromJson(Map<String, dynamic> json) =>
      _$MyLogResourceFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MyLogResourceToJson(this);
}

@JsonSerializable()

/// Mlog 推荐或搜索条目。
class MyLog {
  /// Mlog 条目 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 条目类型。
  int? type;

  /// Mlog 资源数据。
  late MyLogResource resource;

  /// 推荐算法标识。
  String? alg;

  /// 推荐原因。
  String? reason;

  /// 命中的搜索字段。
  int? matchField;

  /// 命中字段内容。
  String? matchFieldContent;

  /// 是否同城内容。
  bool? sameCity;

  /// 创建 Mlog 条目。
  MyLog();

  /// 从 JSON 构建 Mlog 条目。
  factory MyLog.fromJson(Map<String, dynamic> json) => _$MyLogFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MyLogToJson(this);
}

@JsonSerializable()

/// 我喜欢的 Mlog 列表数据。
class MyLogMyLikeData {
  /// Mlog 资源列表。
  List<MyLogResource>? feeds;

  /// 下一页时间游标。
  int? time;

  /// 是否还有更多数据。
  bool? more;

  /// 创建我喜欢的 Mlog 列表数据。
  MyLogMyLikeData();

  /// 从 JSON 构建我喜欢的 Mlog 列表数据。
  factory MyLogMyLikeData.fromJson(Map<String, dynamic> json) =>
      _$MyLogMyLikeDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MyLogMyLikeDataToJson(this);
}

@JsonSerializable()

/// 我喜欢的 Mlog 列表响应。
class MyLogMyLikeWrap extends ServerStatusBean {
  /// 我喜欢的 Mlog 列表数据。
  late MyLogMyLikeData data;

  /// 创建我喜欢的 Mlog 列表响应。
  MyLogMyLikeWrap();

  /// 从 JSON 构建我喜欢的 Mlog 列表响应。
  factory MyLogMyLikeWrap.fromJson(Map<String, dynamic> json) =>
      _$MyLogMyLikeWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MyLogMyLikeWrapToJson(this);
}
