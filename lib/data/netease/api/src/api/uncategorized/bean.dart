// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import '../../../src/api/bean.dart';
import '../../../src/api/event/bean.dart';
import '../../../src/api/play/bean.dart';
import '../../../src/api/user/bean.dart';
import '../../../src/dio_ext.dart';

part 'bean.g.dart';

/// BannerItem。
@JsonSerializable()
class BannerItem {
  /// bannerId。
  String? bannerId;

  /// pic。
  late String pic;

  /// targetId。
  late int targetId;

  /// targetType。
  late int targetType;

  /// titleColor。
  String? titleColor;

  /// typeTitle。
  late String typeTitle;

  /// url。
  String? url;

  /// adurlV2。
  String? adurlV2;

  /// exclusive。
  late bool exclusive;

  /// encodeId。
  String? encodeId;

  /// song。
  Song2? song;

  /// alg。
  String? alg;

  /// scm。
  String? scm;

  /// requestId。
  String? requestId;

  /// showAdTag。
  bool? showAdTag;

  /// 创建 BannerItem。
  BannerItem();

  /// 创建 BannerItem。
  factory BannerItem.fromJson(Map<String, dynamic> json) =>
      _$BannerItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$BannerItemToJson(this);
}

/// BannerListWrap。
@JsonSerializable()
class BannerListWrap extends ServerStatusBean {
  /// banners。
  late List<BannerItem> banners;

  /// 创建 BannerListWrap。
  BannerListWrap();

  /// 创建 BannerListWrap。
  factory BannerListWrap.fromJson(Map<String, dynamic> json) =>
      _$BannerListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BannerListWrapToJson(this);
}

/// BannerListWrap2。
@JsonSerializable()
class BannerListWrap2 extends ServerStatusBean {
  /// data。
  late List<BannerItem> data;

  /// 创建 BannerListWrap2。
  BannerListWrap2();

  /// 创建 BannerListWrap2。
  factory BannerListWrap2.fromJson(Map<String, dynamic> json) =>
      _$BannerListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BannerListWrap2ToJson(this);
}

/// PageConfig。
@JsonSerializable()
class PageConfig {
  /// title。
  String? title;

  /// refreshToast。
  String? refreshToast;

  /// nodataToast。
  String? nodataToast;

  /// refreshInterval。
  int? refreshInterval;

  /// songLabelMarkLimit。
  int? songLabelMarkLimit;

  /// fullscreen。
  bool? fullscreen;

  /// songLabelMarkPriority。
  late List<String> songLabelMarkPriority;

  /// abtest。
  late List<String> abtest;

  /// 创建 PageConfig。
  PageConfig();

  /// 创建 PageConfig。
  factory PageConfig.fromJson(Map<String, dynamic> json) =>
      _$PageConfigFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}

/// HomeBlockPageUiElementTitle。
@JsonSerializable()
class HomeBlockPageUiElementTitle {
  /// title。
  String? title;

  /// 创建 HomeBlockPageUiElementTitle。
  HomeBlockPageUiElementTitle();

  /// 创建 HomeBlockPageUiElementTitle。
  factory HomeBlockPageUiElementTitle.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementTitleFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementTitleToJson(this);
}

/// HomeBlockPageUiElementButton。
@JsonSerializable()
class HomeBlockPageUiElementButton {
  /// action。
  String? action;

  /// actionType。
  String? actionType;

  /// text。
  String? text;

  /// iconUrl。
  String? iconUrl;

  /// 创建 HomeBlockPageUiElementButton。
  HomeBlockPageUiElementButton();

  /// 创建 HomeBlockPageUiElementButton。
  factory HomeBlockPageUiElementButton.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementButtonFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementButtonToJson(this);
}

/// HomeBlockPageUiElementImage。
@JsonSerializable()
class HomeBlockPageUiElementImage {
  /// imageUrl。
  late String imageUrl;

  /// 创建 HomeBlockPageUiElementImage。
  HomeBlockPageUiElementImage();

  /// 创建 HomeBlockPageUiElementImage。
  factory HomeBlockPageUiElementImage.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementImageFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementImageToJson(this);
}

/// HomeBlockPageUiElement。
@JsonSerializable()
class HomeBlockPageUiElement {
  /// mainTitle。
  HomeBlockPageUiElementTitle? mainTitle;

  /// subTitle。
  HomeBlockPageUiElementTitle? subTitle;

  /// button。
  HomeBlockPageUiElementButton? button;

  /// image。
  HomeBlockPageUiElementImage? image;

  /// labelTexts。
  List<String>? labelTexts;

  /// 创建 HomeBlockPageUiElement。
  HomeBlockPageUiElement();

  /// 创建 HomeBlockPageUiElement。
  factory HomeBlockPageUiElement.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageUiElementFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageUiElementToJson(this);
}

/// HomeBlockPageResourceExt。
@JsonSerializable()
class HomeBlockPageResourceExt {
  /// artists。
  List<Artist>? artists;

  /// songData。
  Song? songData;

  /// songPrivilege。
  Privilege? songPrivilege;

  /// commentSimpleData。
  CommentSimple? commentSimpleData;

  /// highQuality。
  bool? highQuality;

  /// playCount。
  int? playCount;

  /// 创建 HomeBlockPageResourceExt。
  HomeBlockPageResourceExt();

  /// 创建 HomeBlockPageResourceExt。
  factory HomeBlockPageResourceExt.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageResourceExtFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageResourceExtToJson(this);
}

/// HomeBlockPageResource。
@JsonSerializable()
class HomeBlockPageResource {
  /// resourceType。
  String? resourceType;

  /// resourceId。
  String? resourceId;

  /// resourceUrl。
  String? resourceUrl;

  /// action。
  String? action;

  /// actionType。
  String? actionType;

  /// uiElement。
  late HomeBlockPageUiElement uiElement;

  /// resourceExtInfo。
  late HomeBlockPageResourceExt resourceExtInfo;

  /// alg。
  String? alg;

  /// valid。
  bool? valid;

  /// 创建 HomeBlockPageResource。
  HomeBlockPageResource();

  /// 创建 HomeBlockPageResource。
  factory HomeBlockPageResource.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageResourceFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageResourceToJson(this);
}

/// HomeBlockPageCreative。
@JsonSerializable()
class HomeBlockPageCreative {
  /// creativeType。
  String? creativeType;

  /// creativeId。
  String? creativeId;

  /// action。
  String? action;

  /// actionType。
  String? actionType;

  /// uiElement。
  late HomeBlockPageUiElement uiElement;

  /// resources。
  late List<HomeBlockPageResource> resources;

  /// alg。
  String? alg;

  /// position。
  int? position;

  /// 创建 HomeBlockPageCreative。
  HomeBlockPageCreative();

  /// 创建 HomeBlockPageCreative。
  factory HomeBlockPageCreative.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageCreativeFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageCreativeToJson(this);
}

/// HomeBlockPageItem。
@JsonSerializable()
class HomeBlockPageItem {
  /// blockCode。
  String? blockCode;

  // HOMEPAGE_SLIDE_PLAYLIST  HOMEPAGE_SLIDE_SONGLIST_ALIGN
  /// showType。
  String? showType;

  /// uiElement。
  late HomeBlockPageUiElement uiElement;

  /// creatives。
  List<HomeBlockPageCreative>? creatives;

  /// extInfo。
  dynamic extInfo;

  // orpheus://playlistCollection?referLog=HOMEPAGE_BLOCK_PLAYLIST_RCMD
  /// action。
  String? action;

  // scheme
  /// actionType。
  String? actionType;

  /// canClose。
  bool? canClose;

  /// 创建 HomeBlockPageItem。
  HomeBlockPageItem();

  /// 创建 HomeBlockPageItem。
  factory HomeBlockPageItem.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageItemToJson(this);
}

/// HomeBlockPageCursor。
@JsonSerializable()
class HomeBlockPageCursor {
  /// offset。
  int? offset;

  /// blockCodeOrderList。
  late List<String> blockCodeOrderList;

  /// 创建 HomeBlockPageCursor。
  HomeBlockPageCursor();

  /// 创建 HomeBlockPageCursor。
  factory HomeBlockPageCursor.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageCursorFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageCursorToJson(this);
}

/// HomeBlockPage。
@JsonSerializable()
class HomeBlockPage {
  /// hasMore。
  bool? hasMore;

  /// cursor。
  @JsonKey(fromJson: _stringToHomeBlockPageCursor)
  HomeBlockPageCursor? cursor;

  /// pageConfig。
  late PageConfig pageConfig;

  /// blocks。
  late List<HomeBlockPageItem> blocks;

  /// 创建 HomeBlockPage。
  HomeBlockPage();

  /// 创建 HomeBlockPage。
  factory HomeBlockPage.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeBlockPageToJson(this);
}

HomeBlockPageCursor _stringToHomeBlockPageCursor(String value) =>
    HomeBlockPageCursor?.fromJson(json.decode(value));

/// HomeBlockPageWrap。
@JsonSerializable()
class HomeBlockPageWrap extends ServerStatusBean {
  /// data。
  late HomeBlockPage data;

  /// 创建 HomeBlockPageWrap。
  HomeBlockPageWrap();

  /// 创建 HomeBlockPageWrap。
  factory HomeBlockPageWrap.fromJson(Map<String, dynamic> json) =>
      _$HomeBlockPageWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HomeBlockPageWrapToJson(this);
}

/// HomeDragonBallItem。
@JsonSerializable()
class HomeDragonBallItem {
  /// id。
  late int id;

  /// name。
  String? name;

  /// iconUrl。
  late String iconUrl;

  /// url。
  String? url;

  /// skinSupport。
  bool? skinSupport;

  /// 创建 HomeDragonBallItem。
  HomeDragonBallItem();

  /// 创建 HomeDragonBallItem。
  factory HomeDragonBallItem.fromJson(Map<String, dynamic> json) =>
      _$HomeDragonBallItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$HomeDragonBallItemToJson(this);
}

/// HomeDragonBallWrap。
@JsonSerializable()
class HomeDragonBallWrap extends ServerStatusBean {
  /// data。
  late List<HomeDragonBallItem> data;

  /// 创建 HomeDragonBallWrap。
  HomeDragonBallWrap();

  /// 创建 HomeDragonBallWrap。
  factory HomeDragonBallWrap.fromJson(Map<String, dynamic> json) =>
      _$HomeDragonBallWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HomeDragonBallWrapToJson(this);
}

/// CountriesCodeItem。
@JsonSerializable()
class CountriesCodeItem {
  /// zh。
  String? zh;

  /// en。
  String? en;

  /// locale。
  String? locale;

  /// code。
  String? code;

  /// 创建 CountriesCodeItem。
  CountriesCodeItem();

  /// 创建 CountriesCodeItem。
  factory CountriesCodeItem.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CountriesCodeItemToJson(this);
}

/// CountriesCodeIndex。
@JsonSerializable()
class CountriesCodeIndex {
  /// label。
  String? label;

  /// countryList。
  late List<CountriesCodeItem> countryList;

  /// 创建 CountriesCodeIndex。
  CountriesCodeIndex();

  /// 创建 CountriesCodeIndex。
  factory CountriesCodeIndex.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeIndexFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CountriesCodeIndexToJson(this);
}

/// CountriesCodeListWrap。
@JsonSerializable()
class CountriesCodeListWrap extends ServerStatusBean {
  /// data。
  late List<CountriesCodeIndex> data;

  /// 创建 CountriesCodeListWrap。
  CountriesCodeListWrap();

  /// 创建 CountriesCodeListWrap。
  factory CountriesCodeListWrap.fromJson(Map<String, dynamic> json) =>
      _$CountriesCodeListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CountriesCodeListWrapToJson(this);
}

/// PersonalizedPrivateContentItem。
@JsonSerializable()
class PersonalizedPrivateContentItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// picUrl。
  String? picUrl;

  /// sPicUrl。
  String? sPicUrl;

  /// copywriter。
  String? copywriter;

  /// alg。
  String? alg;

  /// type。
  int? type;

  /// 创建 PersonalizedPrivateContentItem。
  PersonalizedPrivateContentItem();

  /// 创建 PersonalizedPrivateContentItem。
  factory PersonalizedPrivateContentItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPrivateContentItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PersonalizedPrivateContentItemToJson(this);
}

/// PersonalizedPrivateContentListWrap。
@JsonSerializable()
class PersonalizedPrivateContentListWrap extends ServerStatusBean {
  /// result。
  late List<PersonalizedPrivateContentItem> result;

  /// 创建 PersonalizedPrivateContentListWrap。
  PersonalizedPrivateContentListWrap();

  /// 创建 PersonalizedPrivateContentListWrap。
  factory PersonalizedPrivateContentListWrap.fromJson(
          Map<String, dynamic> json) =>
      _$PersonalizedPrivateContentListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$PersonalizedPrivateContentListWrapToJson(this);
}

/// TopListTrack。
@JsonSerializable()
class TopListTrack {
  /// first。
  String? first;

  /// second。
  String? second;

  /// 创建 TopListTrack。
  TopListTrack();

  /// 创建 TopListTrack。
  factory TopListTrack.fromJson(Map<String, dynamic> json) =>
      _$TopListTrackFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopListTrackToJson(this);
}

/// TopList。
@JsonSerializable()
class TopList {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// subscribers。
  late List<NeteaseUserInfo> subscribers;

  /// tracks。
  List<TopListTrack>? tracks;

  /// name。
  String? name;

  /// englishTitle。
  String? englishTitle;

  /// titleImageUrl。
  String? titleImageUrl;

  /// updateFrequency。
  String? updateFrequency;

  /// backgroundCoverUrl。
  String? backgroundCoverUrl;

  /// coverImgUrl。
  String? coverImgUrl;

  /// description。
  String? description;

  /// commentThreadId。
  String? commentThreadId;

  /// ToplistType。
  String? ToplistType;

  /// adType。
  late int adType;

  /// status。
  int? status;

  /// privacy。
  int? privacy;

  /// subscribedCount。
  int? subscribedCount;

  /// playCount。
  int? playCount;

  /// createTime。
  int? createTime;

  /// updateTime。
  int? updateTime;

  /// totalDuration。
  int? totalDuration;

  /// specialType。
  int? specialType;

  /// cloudTrackCount。
  int? cloudTrackCount;

  /// trackNumberUpdateTime。
  int? trackNumberUpdateTime;

  /// trackUpdateTime。
  int? trackUpdateTime;

  /// trackCount。
  int? trackCount;

  /// opRecommend。
  bool? opRecommend;

  /// recommendInfo。
  String? recommendInfo;

  /// ordered。
  bool? ordered;

  /// highQuality。
  bool? highQuality;

  /// newImported。
  bool? newImported;

  /// anonimous。
  bool? anonimous;

  /// tags。
  late List<String> tags;

  /// 创建 TopList。
  TopList();

  /// 创建 TopList。
  factory TopList.fromJson(Map<String, dynamic> json) =>
      _$TopListFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$TopListToJson(this);
}

/// ArtistTopListArtists。
@JsonSerializable()
class ArtistTopListArtists {
  /// first。
  String? first;

  /// second。
  String? second;

  /// third。
  int? third;

  /// 创建 ArtistTopListArtists。
  ArtistTopListArtists();

  /// 创建 ArtistTopListArtists。
  factory ArtistTopListArtists.fromJson(Map<String, dynamic> json) =>
      _$ArtistTopListArtistsFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistTopListArtistsToJson(this);
}

/// ArtistTopList。
@JsonSerializable()
class ArtistTopList {
  /// position。
  int? position;

  /// coverUrl。
  String? coverUrl;

  /// name。
  String? name;

  /// upateFrequency。
  String? upateFrequency;

  /// updateFrequency。
  String? updateFrequency;

  /// artists。
  List<ArtistTopListArtists>? artists;

  /// 创建 ArtistTopList。
  ArtistTopList();

  /// 创建 ArtistTopList。
  factory ArtistTopList.fromJson(Map<String, dynamic> json) =>
      _$ArtistTopListFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistTopListToJson(this);
}

/// RewardTopList。
@JsonSerializable()
class RewardTopList {
  /// position。
  int? position;

  /// coverUrl。
  String? coverUrl;

  /// songs。
  late List<Song> songs;

  /// 创建 RewardTopList。
  RewardTopList();

  /// 创建 RewardTopList。
  factory RewardTopList.fromJson(Map<String, dynamic> json) =>
      _$RewardTopListFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$RewardTopListToJson(this);
}

/// TopListWrap。
@JsonSerializable()
class TopListWrap extends ServerStatusBean {
  /// list。
  late List<TopList> list;

  /// artistToplist。
  late ArtistTopList artistToplist;

  /// 创建 TopListWrap。
  TopListWrap();

  /// 创建 TopListWrap。
  factory TopListWrap.fromJson(Map<String, dynamic> json) =>
      _$TopListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TopListWrapToJson(this);
}

/// TopListDetailWrap。
@JsonSerializable()
class TopListDetailWrap extends ServerStatusBean {
  /// list。
  late List<TopList> list;

  /// artistToplist。
  late ArtistTopList artistToplist;

  /// rewardToplist。
  late RewardTopList rewardToplist;

  /// 创建 TopListDetailWrap。
  TopListDetailWrap();

  /// 创建 TopListDetailWrap。
  factory TopListDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$TopListDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TopListDetailWrapToJson(this);
}

/// McalendarDetailEvent。
@JsonSerializable()
class McalendarDetailEvent {
  /// id。
  late String id;

  /// eventType。
  String? eventType;

  /// onlineTime。
  int? onlineTime;

  /// offlineTime。
  int? offlineTime;

  /// imgUrl。
  late String imgUrl;

  /// targetUrl。
  String? targetUrl;

  /// tag。
  String? tag;

  /// title。
  String? title;

  /// canRemind。
  bool? canRemind;

  /// reminded。
  bool? reminded;

  /// remindText。
  String? remindText;

  /// resourceId。
  String? resourceId;

  /// resourceType。
  String? resourceType;

  /// eventStatus。
  String? eventStatus;

  /// remindedText。
  String? remindedText;

  /// 创建 McalendarDetailEvent。
  McalendarDetailEvent();

  /// 创建 McalendarDetailEvent。
  factory McalendarDetailEvent.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailEventFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$McalendarDetailEventToJson(this);
}

/// McalendarDetail。
@JsonSerializable()
class McalendarDetail {
  /// calendarEvents。
  late List<McalendarDetailEvent> calendarEvents;

  /// 创建 McalendarDetail。
  McalendarDetail();

  /// 创建 McalendarDetail。
  factory McalendarDetail.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$McalendarDetailToJson(this);
}

/// McalendarDetailWrap。
@JsonSerializable()
class McalendarDetailWrap extends ServerStatusBean {
  /// data。
  late McalendarDetail data;

  /// 创建 McalendarDetailWrap。
  McalendarDetailWrap();

  /// 创建 McalendarDetailWrap。
  factory McalendarDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$McalendarDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$McalendarDetailWrapToJson(this);
}

/// AudioMatchResult。
@JsonSerializable()
class AudioMatchResult {
  /// startTime。
  int? startTime;

  /// song。
  late Song song;

  /// 创建 AudioMatchResult。
  AudioMatchResult();

  /// 创建 AudioMatchResult。
  factory AudioMatchResult.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$AudioMatchResultToJson(this);
}

/// AudioMatchResultData。
@JsonSerializable()
class AudioMatchResultData {
  /// type。
  int? type;

  /// result。
  late List<AudioMatchResult> result;

  /// 创建 AudioMatchResultData。
  AudioMatchResultData();

  /// 创建 AudioMatchResultData。
  factory AudioMatchResultData.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$AudioMatchResultDataToJson(this);
}

/// AudioMatchResultWrap。
@JsonSerializable()
class AudioMatchResultWrap extends ServerStatusBean {
  /// data。
  late AudioMatchResultData data;

  /// 创建 AudioMatchResultWrap。
  AudioMatchResultWrap();

  /// 创建 AudioMatchResultWrap。
  factory AudioMatchResultWrap.fromJson(Map<String, dynamic> json) =>
      _$AudioMatchResultWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AudioMatchResultWrapToJson(this);
}

/// ListenTogetherStatusData。
@JsonSerializable()
class ListenTogetherStatusData {
  /// inRoom。
  late bool inRoom;

  /// roomInfo。
  dynamic roomInfo;

  /// status。
  dynamic status;

  /// 创建 ListenTogetherStatusData。
  ListenTogetherStatusData();

  /// 创建 ListenTogetherStatusData。
  factory ListenTogetherStatusData.fromJson(Map<String, dynamic> json) =>
      _$ListenTogetherStatusDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ListenTogetherStatusDataToJson(this);
}

/// ListenTogetherStatusWrap。
@JsonSerializable()
class ListenTogetherStatusWrap extends ServerStatusBean {
  /// data。
  late ListenTogetherStatusData data;

  /// 创建 ListenTogetherStatusWrap。
  ListenTogetherStatusWrap();

  /// 创建 ListenTogetherStatusWrap。
  factory ListenTogetherStatusWrap.fromJson(Map<String, dynamic> json) =>
      _$ListenTogetherStatusWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ListenTogetherStatusWrapToJson(this);
}

/// UploadImageAlloc。
@JsonSerializable()
class UploadImageAlloc {
  /// bucket。
  late String bucket;

  /// docId。
  late String docId;

  /// objectKey。
  late String objectKey;

  /// token。
  late String token;

  /// 创建 UploadImageAlloc。
  UploadImageAlloc();

  /// 创建 UploadImageAlloc。
  factory UploadImageAlloc.fromJson(Map<String, dynamic> json) =>
      _$UploadImageAllocFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$UploadImageAllocToJson(this);
}

/// UploadImageAllocWrap。
@JsonSerializable()
class UploadImageAllocWrap extends ServerStatusBean {
  /// result。
  late UploadImageAlloc result;

  /// 创建 UploadImageAllocWrap。
  UploadImageAllocWrap();

  /// 创建 UploadImageAllocWrap。
  factory UploadImageAllocWrap.fromJson(Map<String, dynamic> json) =>
      _$UploadImageAllocWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UploadImageAllocWrapToJson(this);
}

/// UploadImageResult。
@JsonSerializable()
class UploadImageResult extends ServerStatusBean {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// url。
  String? url;

  /// 创建 UploadImageResult。
  UploadImageResult();

  /// 创建 UploadImageResult。
  factory UploadImageResult.fromJson(Map<String, dynamic> json) =>
      _$UploadImageResultFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UploadImageResultToJson(this);
}

/// BatchApiWrap。
class BatchApiWrap extends ServerStatusBean {
  /// data。
  late Map<String, dynamic> data;

  /// 创建 BatchApiWrap。
  BatchApiWrap();

  /// 公开成员。
  dynamic findResponseData<T>(DioMetaData metaData) {
    return data[metaData.uri.path];
  }

  /// 创建 BatchApiWrap。
  factory BatchApiWrap.fromJson(Map<String, dynamic> json) {
    return BatchApiWrap()
      ..code = json['code'] as int
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = json;
  }
}
