// ignore_for_file: overridden_fields

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../../netease_music_api.dart';
import '../../../src/api/bean.dart';

part 'bean.g.dart';

/// CommentThread。
@JsonSerializable()
class CommentThread {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// resourceType。
  int? resourceType;

  /// commentCount。
  int? commentCount;

  /// likedCount。
  int? likedCount;

  /// shareCount。
  int? shareCount;

  /// hotCount。
  int? hotCount;

  /// resourceId。
  int? resourceId;

  /// resourceOwnerId。
  int? resourceOwnerId;

  /// resourceTitle。
  String? resourceTitle;

  /// 创建 CommentThread。
  CommentThread();

  /// 创建 CommentThread。
  factory CommentThread.fromJson(Map<String, dynamic> json) =>
      _$CommentThreadFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentThreadToJson(this);
}

/// EventItemInfo。
@JsonSerializable()
class EventItemInfo {
  /// threadId。
  late String threadId;

  /// resourceId。
  int? resourceId;

  /// resourceType。
  int? resourceType;

  /// liked。
  bool? liked;

  /// commentCount。
  int? commentCount;

  /// likedCount。
  int? likedCount;

  /// shareCount。
  int? shareCount;

  /// commentThread。
  late CommentThread commentThread;

  /// 创建 EventItemInfo。
  EventItemInfo();

  /// 创建 EventItemInfo。
  factory EventItemInfo.fromJson(Map<String, dynamic> json) =>
      _$EventItemInfoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$EventItemInfoToJson(this);
}

/// EventItem。
@JsonSerializable()
class EventItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// actName。
  String? actName;

  /// json。
  String? json;

  /// type。
  int? type;

  /// actId。
  int? actId;

  /// eventTime。
  int? eventTime;

  /// expireTime。
  int? expireTime;

  /// showTime。
  int? showTime;

  /// forwardCount。
  int? forwardCount;

  /// sic。
  int? sic;

  /// insiteForwardCount。
  late int insiteForwardCount;

  /// topEvent。
  bool? topEvent;

  /// user。
  late NeteaseAccountProfile user;

  /// info。
  late EventItemInfo info;

  /// 创建 EventItem。
  EventItem();

  /// 创建 EventItem。
  factory EventItem.fromJson(Map<String, dynamic> json) =>
      _$EventItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$EventItemToJson(this);
}

/// EventListWrap。
@JsonSerializable()
class EventListWrap extends ServerStatusBean {
  /// events。
  List<EventItem>? events;

  /// lasttime。
  int? lasttime;

  /// 创建 EventListWrap。
  EventListWrap();

  /// 创建 EventListWrap。
  factory EventListWrap.fromJson(Map<String, dynamic> json) =>
      _$EventListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EventListWrapToJson(this);
}

/// EventListWrap2。
@JsonSerializable()
class EventListWrap2 extends ServerStatusBean {
  /// event。
  List<EventItem>? event;

  /// lasttime。
  int? lasttime;

  /// 创建 EventListWrap2。
  EventListWrap2();

  /// 创建 EventListWrap2。
  factory EventListWrap2.fromJson(Map<String, dynamic> json) =>
      _$EventListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EventListWrap2ToJson(this);
}

/// EventSingleWrap。
@JsonSerializable()
class EventSingleWrap extends ServerStatusBean {
  /// event。
  late EventItem event;

  /// 创建 EventSingleWrap。
  EventSingleWrap();

  /// 创建 EventSingleWrap。
  factory EventSingleWrap.fromJson(Map<String, dynamic> json) =>
      _$EventSingleWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EventSingleWrapToJson(this);
}

/// CommentItemBase。
@JsonSerializable()
class CommentItemBase {
  /// commentId。
  @JsonKey(fromJson: dynamicToString)
  late String commentId;

  /// parentCommentId。
  @JsonKey(fromJson: dynamicToString)
  String? parentCommentId;

  /// user。
  late NeteaseUserInfo user;

  /// beReplied。
  List<BeRepliedCommentItem>? beReplied;

  /// content。
  String? content;

  /// time。
  int? time;

  /// timeStr。
  String? timeStr;

  /// likedCount。
  int? likedCount;

  /// replyCount。
  int? replyCount;

  /// liked。
  bool? liked;

  // beReplied

  /// status。
  int? status;

  /// commentLocationType。
  int? commentLocationType;

  /// 创建 CommentItemBase。
  CommentItemBase();

  /// 创建 CommentItemBase。
  factory CommentItemBase.fromJson(Map<String, dynamic> json) =>
      _$CommentItemBaseFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentItemBaseToJson(this);
}

/// CommentItem。
@JsonSerializable()
class CommentItem extends CommentItemBase {
  @override
  List<BeRepliedCommentItem>? beReplied;

  /// 创建 CommentItem。
  CommentItem();

  /// 创建 CommentItem。
  factory CommentItem.fromJson(Map<String, dynamic> json) =>
      _$CommentItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentItemToJson(this);
}

/// BeRepliedCommentItem。
@JsonSerializable()
class BeRepliedCommentItem extends CommentItemBase {
  /// beRepliedCommentId。
  @JsonKey(fromJson: dynamicToString)
  String? beRepliedCommentId;

  /// 创建 BeRepliedCommentItem。
  BeRepliedCommentItem();

  /// 创建 BeRepliedCommentItem。
  factory BeRepliedCommentItem.fromJson(Map<String, dynamic> json) =>
      _$BeRepliedCommentItemFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BeRepliedCommentItemToJson(this);
}

/// CommentListWrap。
@JsonSerializable()
class CommentListWrap extends ServerStatusListBean {
  /// moreHot。
  bool? moreHot;

  /// cnum。
  int? cnum;

  /// isMusician。
  bool? isMusician;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// topComments。
  List<CommentItem>? topComments;

  /// hotComments。
  List<CommentItem>? hotComments;

  /// comments。
  List<CommentItem>? comments;

  /// 创建 CommentListWrap。
  CommentListWrap();

  /// 创建 CommentListWrap。
  factory CommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentListWrapToJson(this);
}

/// CommentHistoryData。
@JsonSerializable()
class CommentHistoryData {
  /// hasMore。
  bool? hasMore;

  /// reminder。
  bool? reminder;

  /// commentCount。
  int? commentCount;

  /// hotComments。
  List<CommentItem>? hotComments;

  /// comments。
  List<CommentItem>? comments;

  /// 创建 CommentHistoryData。
  CommentHistoryData();

  /// 创建 CommentHistoryData。
  factory CommentHistoryData.fromJson(Map<String, dynamic> json) =>
      _$CommentHistoryDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentHistoryDataToJson(this);
}

/// CommentHistoryWrap。
@JsonSerializable()
class CommentHistoryWrap extends ServerStatusBean {
  /// data。
  late CommentHistoryData data;

  /// 创建 CommentHistoryWrap。
  CommentHistoryWrap();

  /// 创建 CommentHistoryWrap。
  factory CommentHistoryWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentHistoryWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentHistoryWrapToJson(this);
}

/// CommentList2DataSortType。
@JsonSerializable()
class CommentList2DataSortType {
  /// sortType。
  int? sortType;

  /// sortTypeName。
  String? sortTypeName;

  /// target。
  String? target;

  /// 创建 CommentList2DataSortType。
  CommentList2DataSortType();

  /// 创建 CommentList2DataSortType。
  factory CommentList2DataSortType.fromJson(Map<String, dynamic> json) =>
      _$CommentList2DataSortTypeFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentList2DataSortTypeToJson(this);
}

/// CommentList2Data。
@JsonSerializable()
class CommentList2Data {
  /// hasMore。
  bool? hasMore;

  /// cursor。
  String? cursor;

  /// totalCount。
  int? totalCount;

  /// sortType。
  int? sortType;

  /// sortTypeList。
  List<CommentList2DataSortType>? sortTypeList;

  /// comments。
  List<CommentItem>? comments;

  /// currentComment。
  CommentItem? currentComment;

  /// 创建 CommentList2Data。
  CommentList2Data();

  /// 创建 CommentList2Data。
  factory CommentList2Data.fromJson(Map<String, dynamic> json) =>
      _$CommentList2DataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentList2DataToJson(this);
}

/// CommentList2Wrap。
@JsonSerializable()
class CommentList2Wrap extends ServerStatusBean {
  /// data。
  late CommentList2Data data;

  /// 创建 CommentList2Wrap。
  CommentList2Wrap();

  /// 创建 CommentList2Wrap。
  factory CommentList2Wrap.fromJson(Map<String, dynamic> json) =>
      _$CommentList2WrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentList2WrapToJson(this);
}

/// HugComment。
@JsonSerializable()
class HugComment {
  /// user。
  late NeteaseUserInfo user;

  /// hugContent。
  String? hugContent;

  /// 创建 HugComment。
  HugComment();

  /// 创建 HugComment。
  factory HugComment.fromJson(Map<String, dynamic> json) =>
      _$HugCommentFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HugCommentToJson(this);
}

/// HugCommentListData。
@JsonSerializable()
class HugCommentListData {
  /// hasMore。
  bool? hasMore;

  /// cursor。
  String? cursor;

  /// idCursor。
  int? idCursor;

  /// hugTotalCounts。
  int? hugTotalCounts;

  /// hugComments。
  List<HugComment>? hugComments;

  /// currentComment。
  late CommentItem currentComment;

  /// 创建 HugCommentListData。
  HugCommentListData();

  /// 创建 HugCommentListData。
  factory HugCommentListData.fromJson(Map<String, dynamic> json) =>
      _$HugCommentListDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HugCommentListDataToJson(this);
}

/// HugCommentListWrap。
@JsonSerializable()
class HugCommentListWrap extends ServerStatusBean {
  /// data。
  late HugCommentListData data;

  /// 创建 HugCommentListWrap。
  HugCommentListWrap();

  /// 创建 HugCommentListWrap。
  factory HugCommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$HugCommentListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HugCommentListWrapToJson(this);
}

/// FloorCommentDetail。
@JsonSerializable()
class FloorCommentDetail {
  /// comments。
  List<CommentItem>? comments;

  /// hasMore。
  bool? hasMore;

  /// totalCount。
  int? totalCount;

  /// time。
  int? time;

  /// ownerComment。
  late CommentItem ownerComment;

  /// 创建 FloorCommentDetail。
  FloorCommentDetail();

  /// 创建 FloorCommentDetail。
  factory FloorCommentDetail.fromJson(Map<String, dynamic> json) =>
      _$FloorCommentDetailFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$FloorCommentDetailToJson(this);
}

/// FloorCommentDetailWrap。
@JsonSerializable()
class FloorCommentDetailWrap extends ServerStatusBean {
  /// data。
  late FloorCommentDetail data;

  /// 创建 FloorCommentDetailWrap。
  FloorCommentDetailWrap();

  /// 创建 FloorCommentDetailWrap。
  factory FloorCommentDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$FloorCommentDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$FloorCommentDetailWrapToJson(this);
}

/// EventForwardRet。
@JsonSerializable()
class EventForwardRet {
  /// msg。
  String? msg;

  /// eventId。
  late int eventId;

  /// eventTime。
  int? eventTime;

  /// 创建 EventForwardRet。
  EventForwardRet();

  /// 创建 EventForwardRet。
  factory EventForwardRet.fromJson(Map<String, dynamic> json) =>
      _$EventForwardRetFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$EventForwardRetToJson(this);
}

/// EventForwardRetWrap。
@JsonSerializable()
class EventForwardRetWrap extends ServerStatusBean {
  /// data。
  EventForwardRet? data;

  /// 创建 EventForwardRetWrap。
  EventForwardRetWrap();

  /// 创建 EventForwardRetWrap。
  factory EventForwardRetWrap.fromJson(Map<String, dynamic> json) =>
      _$EventForwardRetWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EventForwardRetWrapToJson(this);
}

/// TopicContent。
@JsonSerializable()
class TopicContent {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// type。
  int? type;

  /// content。
  String? content;

  /// 创建 TopicContent。
  TopicContent();

  /// 创建 TopicContent。
  factory TopicContent.fromJson(Map<String, dynamic> json) =>
      _$TopicContentFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopicContentToJson(this);
}

/// Topic。
@JsonSerializable()
class Topic {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// content。
  List<TopicContent>? content;

  /// title。
  String? title;

  /// wxTitle。
  String? wxTitle;

  /// mainTitle。
  String? mainTitle;

  /// startText。
  String? startText;

  /// summary。
  String? summary;

  /// adInfo。
  late String adInfo;

  /// recomdTitle。
  String? recomdTitle;

  /// recomdContent。
  String? recomdContent;

  /// addTime。
  late int addTime;

  /// pubTime。
  int? pubTime;

  /// updateTime。
  int? updateTime;

  /// cover。
  int? cover;

  /// headPic。
  int? headPic;

  /// status。
  int? status;

  /// seriesId。
  int? seriesId;

  /// categoryId。
  int? categoryId;

  /// hotScore。
  double? hotScore;

  /// auditor。
  String? auditor;

  /// auditTime。
  int? auditTime;

  /// auditStatus。
  int? auditStatus;

  /// delReason。
  String? delReason;

  /// number。
  int? number;

  /// readCount。
  int? readCount;

  /// rectanglePic。
  int? rectanglePic;

  /// tags。
  List<String>? tags;

  /// reward。
  bool? reward;

  /// fromBackend。
  bool? fromBackend;

  /// showRelated。
  bool? showRelated;

  /// showComment。
  bool? showComment;

  /// pubImmidiatly。
  bool? pubImmidiatly;

  /// 创建 Topic。
  Topic();

  /// 创建 Topic。
  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

/// TopicItem2。
@JsonSerializable()
class TopicItem2 {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// topic。
  late Topic topic;

  /// creator。
  late NeteaseUserInfo creator;

  /// number。
  int? number;

  /// shareCount。
  int? shareCount;

  /// commentCount。
  int? commentCount;

  /// likedCount。
  int? likedCount;

  /// readCount。
  int? readCount;

  /// rewardCount。
  int? rewardCount;

  /// rewardMoney。
  double? rewardMoney;

  /// rectanglePicUrl。
  String? rectanglePicUrl;

  /// coverUrl。
  String? coverUrl;

  /// seriesId。
  int? seriesId;

  /// categoryId。
  int? categoryId;

  /// categoryName。
  String? categoryName;

  /// url。
  String? url;

  /// wxTitle。
  String? wxTitle;

  /// mainTitle。
  String? mainTitle;

  /// title。
  String? title;

  /// summary。
  String? summary;

  /// shareContent。
  String? shareContent;

  /// recmdTitle。
  String? recmdTitle;

  /// recmdContent。
  String? recmdContent;

  /// tags。
  List<String>? tags;

  /// addTime。
  late int addTime;

  /// commentThreadId。
  String? commentThreadId;

  /// showRelated。
  bool? showRelated;

  /// showComment。
  bool? showComment;

  /// reward。
  bool? reward;

  /// liked。
  bool? liked;

  /// 创建 TopicItem2。
  TopicItem2();

  /// 创建 TopicItem2。
  factory TopicItem2.fromJson(Map<String, dynamic> json) =>
      _$TopicItem2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopicItem2ToJson(this);
}

/// TopicItem。
@JsonSerializable()
class TopicItem {
  /// actId。
  @JsonKey(fromJson: dynamicToString)
  late String actId;

  /// title。
  String? title;

  /// text。
  List<String>? text;

  /// reason。
  String? reason;

  /// participateCount。
  int? participateCount;

  /// isDefaultImg。
  late bool isDefaultImg;

  //featured TopicQualityScore
  /// alg。
  String? alg;

  /// startTime。
  int? startTime;

  /// endTime。
  int? endTime;

  /// resourceType。
  int? resourceType;

  /// videoType。
  int? videoType;

  /// topicType。
  int? topicType;

  /// meetingBeginTime。
  int? meetingBeginTime;

  /// meetingEndTime。
  int? meetingEndTime;

  /// coverPCLongUrl。
  String? coverPCLongUrl;

  /// sharePicUrl。
  String? sharePicUrl;

  /// coverPCUrl。
  String? coverPCUrl;

  /// coverMobileUrl。
  String? coverMobileUrl;

  /// coverPCListUrl。
  String? coverPCListUrl;

  /// 创建 TopicItem。
  TopicItem();

  /// 创建 TopicItem。
  factory TopicItem.fromJson(Map<String, dynamic> json) =>
      _$TopicItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopicItemToJson(this);
}

/// TopicHotListWrap。
@JsonSerializable()
class TopicHotListWrap extends ServerStatusBean {
  /// hot。
  List<TopicItem>? hot;

  /// 创建 TopicHotListWrap。
  TopicHotListWrap();

  /// 创建 TopicHotListWrap。
  factory TopicHotListWrap.fromJson(Map<String, dynamic> json) =>
      _$TopicHotListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TopicHotListWrapToJson(this);
}

/// TopicDetailWrap。
@JsonSerializable()
class TopicDetailWrap extends ServerStatusBean {
  /// act。
  late TopicItem act;

  /// needBeginNotify。
  bool? needBeginNotify;

  /// 创建 TopicDetailWrap。
  TopicDetailWrap();

  /// 创建 TopicDetailWrap。
  factory TopicDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$TopicDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TopicDetailWrapToJson(this);
}

/// SimpleResourceInfo。
@JsonSerializable()
class SimpleResourceInfo {
  /// songId。
  @JsonKey(fromJson: dynamicToString)
  String? songId;

  /// threadId。
  String? threadId;

  /// songCoverUrl。
  String? songCoverUrl;

  /// name。
  String? name;

  /// song。
  late Song song;

  /// 创建 SimpleResourceInfo。
  SimpleResourceInfo();

  /// 创建 SimpleResourceInfo。
  factory SimpleResourceInfo.fromJson(Map<String, dynamic> json) =>
      _$SimpleResourceInfoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SimpleResourceInfoToJson(this);
}

/// HotwallCommentItem。
@JsonSerializable()
class HotwallCommentItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// threadId。
  String? threadId;

  /// content。
  String? content;

  /// time。
  int? time;

  /// liked。
  bool? liked;

  /// likedCount。
  int? likedCount;

  /// replyCount。
  int? replyCount;

  /// simpleUserInfo。
  late NeteaseSimpleUserInfo simpleUserInfo;

  /// simpleResourceInfo。
  late SimpleResourceInfo simpleResourceInfo;

  /// 创建 HotwallCommentItem。
  HotwallCommentItem();

  /// 创建 HotwallCommentItem。
  factory HotwallCommentItem.fromJson(Map<String, dynamic> json) =>
      _$HotwallCommentItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HotwallCommentItemToJson(this);
}

/// HotwallCommentListWrap。
@JsonSerializable()
class HotwallCommentListWrap extends ServerStatusBean {
  /// data。
  List<HotwallCommentItem>? data;

  /// 创建 HotwallCommentListWrap。
  HotwallCommentListWrap();

  /// 创建 HotwallCommentListWrap。
  factory HotwallCommentListWrap.fromJson(Map<String, dynamic> json) =>
      _$HotwallCommentListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HotwallCommentListWrapToJson(this);
}

/// CommentSimple。
@JsonSerializable()
class CommentSimple {
  /// commentId。
  @JsonKey(fromJson: dynamicToString)
  String? commentId;

  /// content。
  String? content;

  /// threadId。
  String? threadId;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// userName。
  String? userName;

  /// 创建 CommentSimple。
  CommentSimple();

  /// 创建 CommentSimple。
  factory CommentSimple.fromJson(Map<String, dynamic> json) =>
      _$CommentSimpleFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentSimpleToJson(this);
}

/// Comment。
@JsonSerializable()
class Comment {
  /// commentId。
  @JsonKey(fromJson: dynamicToString)
  late String commentId;

  /// user。
  late NeteaseUserInfo user;

  /// beRepliedUser。
  NeteaseUserInfo? beRepliedUser;

  /// expressionUrl。
  String? expressionUrl;

  /// commentLocationType。
  int? commentLocationType;

  /// time。
  int? time;

  /// content。
  String? content;

  /// 创建 Comment。
  Comment();

  /// 创建 Comment。
  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

/// CommentWrap。
@JsonSerializable()
class CommentWrap extends ServerStatusBean {
  /// comment。
  Comment? comment;

  /// 创建 CommentWrap。
  CommentWrap();

  /// 创建 CommentWrap。
  factory CommentWrap.fromJson(Map<String, dynamic> json) =>
      _$CommentWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommentWrapToJson(this);
}

/// MsgPromotion。
@JsonSerializable()
class MsgPromotion {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// title。
  String? title;

  /// coverUrl。
  String? coverUrl;

  /// text。
  String? text;

  /// url。
  String? url;

  /// addTime。
  late int addTime;

  /// 创建 MsgPromotion。
  MsgPromotion();

  /// 创建 MsgPromotion。
  factory MsgPromotion.fromJson(Map<String, dynamic> json) =>
      _$MsgPromotionFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MsgPromotionToJson(this);
}

/// MsgGeneral。
@JsonSerializable()
class MsgGeneral {
  /// title。
  String? title;

  /// subTitle。
  String? subTitle;

  /// tag。
  String? tag;

  /// subTag。
  String? subTag;

  /// noticeMsg。
  String? noticeMsg;

  /// inboxBriefContent。
  late String inboxBriefContent;

  /// webUrl。
  String? webUrl;

  /// nativeUrl。
  String? nativeUrl;

  /// cover。
  String? cover;

  /// resName。
  String? resName;

  /// channel。
  int? channel;

  /// subType。
  int? subType;

  /// canPlay。
  bool? canPlay;

  /// 创建 MsgGeneral。
  MsgGeneral();

  /// 创建 MsgGeneral。
  factory MsgGeneral.fromJson(Map<String, dynamic> json) =>
      _$MsgGeneralFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MsgGeneralToJson(this);
}

/// MsgContent。
@JsonSerializable()
class MsgContent {
  /// msg。
  String? msg;

  /// title。
  String? title;

  /// pushMsg。
  String? pushMsg;

  /// type。
  int? type;

  /// resType。
  int? resType;

  /// newPub。
  bool? newPub;

  // type={6} ~

  //type={12}
  /// promotionUrl。
  MsgPromotion? promotionUrl;

  //type={23}
  /// generalMsg。
  MsgGeneral? generalMsg;

  //type={7}
  /// mv。
  Mv3? mv;

  /// 创建 MsgContent。
  MsgContent();

  /// 创建 MsgContent。
  factory MsgContent.fromJson(Map<String, dynamic> json) =>
      _$MsgContentFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MsgContentToJson(this);
}

/// Msg。
@JsonSerializable()
class Msg {
  /// fromUser。
  late NeteaseUserInfo fromUser;

  /// toUser。
  late NeteaseUserInfo toUser;

  /// lastMsg。
  String? lastMsg;

  /// noticeAccountFlag。
  bool? noticeAccountFlag;

  /// lastMsgTime。
  int? lastMsgTime;

  /// newMsgCount。
  int? newMsgCount;

  /// msgObj。
  MsgContent get msgObj {
    return MsgContent.fromJson(jsonDecode(lastMsg ?? ''));
  }

  /// 创建 Msg。
  Msg();

  /// 创建 Msg。
  factory Msg.fromJson(Map<String, dynamic> json) => _$MsgFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MsgToJson(this);
}

/// Msg2。
@JsonSerializable()
class Msg2 {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// fromUser。
  late NeteaseUserInfo fromUser;

  /// toUser。
  late NeteaseUserInfo toUser;

  /// msg。
  String? msg;

  /// time。
  int? time;

  /// batchId。
  int? batchId;

  /// msgObj。
  MsgContent get msgObj {
    return MsgContent.fromJson(jsonDecode(msg ?? ''));
  }

  /// 创建 Msg2。
  Msg2();

  /// 创建 Msg2。
  factory Msg2.fromJson(Map<String, dynamic> json) => _$Msg2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Msg2ToJson(this);
}

/// UsersMsgListWrap。
@JsonSerializable()
class UsersMsgListWrap extends ServerStatusBean {
  /// msgs。
  List<Msg>? msgs;

  /// 创建 UsersMsgListWrap。
  UsersMsgListWrap();

  /// 创建 UsersMsgListWrap。
  factory UsersMsgListWrap.fromJson(Map<String, dynamic> json) =>
      _$UsersMsgListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UsersMsgListWrapToJson(this);
}

/// RecentContactUsersData。
@JsonSerializable()
class RecentContactUsersData {
  /// follow。
  List<NeteaseAccountProfile>? follow;

  /// 创建 RecentContactUsersData。
  RecentContactUsersData();

  /// 创建 RecentContactUsersData。
  factory RecentContactUsersData.fromJson(Map<String, dynamic> json) =>
      _$RecentContactUsersDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$RecentContactUsersDataToJson(this);
}

/// RecentContactUsersWrap。
@JsonSerializable()
class RecentContactUsersWrap extends ServerStatusBean {
  /// data。
  late RecentContactUsersData data;

  /// 创建 RecentContactUsersWrap。
  RecentContactUsersWrap();

  /// 创建 RecentContactUsersWrap。
  factory RecentContactUsersWrap.fromJson(Map<String, dynamic> json) =>
      _$RecentContactUsersWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecentContactUsersWrapToJson(this);
}

/// UserMsgListWrap。
@JsonSerializable()
class UserMsgListWrap extends ServerStatusBean {
  /// msgs。
  List<Msg2>? msgs;

  /// isArtist。
  late bool isArtist;

  /// isSubed。
  late bool isSubed;

  /// more。
  bool? more;

  /// 创建 UserMsgListWrap。
  UserMsgListWrap();

  /// 创建 UserMsgListWrap。
  factory UserMsgListWrap.fromJson(Map<String, dynamic> json) =>
      _$UserMsgListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserMsgListWrapToJson(this);
}

/// UserMsgListWrap2。
@JsonSerializable()
class UserMsgListWrap2 extends ServerStatusBean {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// newMsgs。
  List<Msg2>? newMsgs;

  //sendblacklist
  //blacklist

  /// 创建 UserMsgListWrap2。
  UserMsgListWrap2();

  /// 创建 UserMsgListWrap2。
  factory UserMsgListWrap2.fromJson(Map<String, dynamic> json) =>
      _$UserMsgListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserMsgListWrap2ToJson(this);
}

/// Cover。
@JsonSerializable()
class Cover {
  /// width。
  int? width;

  /// height。
  int? height;

  /// url。
  String? url;

  /// 创建 Cover。
  Cover();

  /// 创建 Cover。
  factory Cover.fromJson(Map<String, dynamic> json) => _$CoverFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CoverToJson(this);
}

/// Talk。
@JsonSerializable()
class Talk {
  /// talkId。
  @JsonKey(fromJson: dynamicToString)
  String? talkId;

  /// talkName。
  String? talkName;

  /// talkDes。
  String? talkDes;

  /// shareCover。
  late Cover shareCover;

  /// showCover。
  late Cover showCover;

  /// status。
  int? status;

  /// mlogCount。
  int? mlogCount;

  /// follows。
  int? follows;

  /// participations。
  int? participations;

  /// showParticipations。
  int? showParticipations;

  /// isFollow。
  late bool isFollow;

  /// alg。
  String? alg;

  /// 创建 Talk。
  Talk();

  /// 创建 Talk。
  factory Talk.fromJson(Map<String, dynamic> json) => _$TalkFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TalkToJson(this);
}

/// MyLogBaseData。
@JsonSerializable()
class MyLogBaseData {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// pubTime。
  int? pubTime;

  /// type。
  int? type;

  /// coverUrl。
  String? coverUrl;

  /// coverWidth。
  int? coverWidth;

  /// coverHeight。
  int? coverHeight;

  /// coverColor。
  int? coverColor;

  /// talk。
  Talk? talk;

  /// text。
  String? text;

  /// 创建 MyLogBaseData。
  MyLogBaseData();

  /// 创建 MyLogBaseData。
  factory MyLogBaseData.fromJson(Map<String, dynamic> json) =>
      _$MyLogBaseDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MyLogBaseDataToJson(this);
}

/// MyLogResourceExt。
@JsonSerializable()
class MyLogResourceExt {
  /// likedCount。
  int? likedCount;

  /// commentCount。
  int? commentCount;

  /// 创建 MyLogResourceExt。
  MyLogResourceExt();

  /// 创建 MyLogResourceExt。
  factory MyLogResourceExt.fromJson(Map<String, dynamic> json) =>
      _$MyLogResourceExtFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MyLogResourceExtToJson(this);
}

/// MyLogResource。
@JsonSerializable()
class MyLogResource {
  /// mlogBaseData。
  late MyLogBaseData mlogBaseData;

  /// mlogExtVO。
  late MyLogResourceExt mlogExtVO;

  /// userProfile。
  NeteaseAccountProfile? userProfile;

  /// status。
  int? status;

  /// shareUrl。
  String? shareUrl;

  /// 创建 MyLogResource。
  MyLogResource();

  /// 创建 MyLogResource。
  factory MyLogResource.fromJson(Map<String, dynamic> json) =>
      _$MyLogResourceFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MyLogResourceToJson(this);
}

/// MyLog。
@JsonSerializable()
class MyLog {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// type。
  int? type;

  /// resource。
  late MyLogResource resource;

  /// alg。
  String? alg;

  /// reason。
  String? reason;

  /// matchField。
  int? matchField;

  /// matchFieldContent。
  String? matchFieldContent;

  /// sameCity。
  bool? sameCity;

  /// 创建 MyLog。
  MyLog();

  /// 创建 MyLog。
  factory MyLog.fromJson(Map<String, dynamic> json) => _$MyLogFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MyLogToJson(this);
}

/// MyLogMyLikeData。
@JsonSerializable()
class MyLogMyLikeData {
  /// feeds。
  List<MyLogResource>? feeds;

  /// time。
  int? time;

  /// more。
  bool? more;

  /// 创建 MyLogMyLikeData。
  MyLogMyLikeData();

  /// 创建 MyLogMyLikeData。
  factory MyLogMyLikeData.fromJson(Map<String, dynamic> json) =>
      _$MyLogMyLikeDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MyLogMyLikeDataToJson(this);
}

/// MyLogMyLikeWrap。
@JsonSerializable()
class MyLogMyLikeWrap extends ServerStatusBean {
  /// data。
  late MyLogMyLikeData data;

  /// 创建 MyLogMyLikeWrap。
  MyLogMyLikeWrap();

  /// 创建 MyLogMyLikeWrap。
  factory MyLogMyLikeWrap.fromJson(Map<String, dynamic> json) =>
      _$MyLogMyLikeWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MyLogMyLikeWrapToJson(this);
}
