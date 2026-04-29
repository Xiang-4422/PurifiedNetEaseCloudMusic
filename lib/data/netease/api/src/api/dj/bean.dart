import 'package:json_annotation/json_annotation.dart';

import '../../../src/api/bean.dart';
import '../../../src/netease_bean.dart';

part 'bean.g.dart';

/// Dj。
@JsonSerializable()
class Dj {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// nickName。
  String? nickName;

  /// avatarUrl。
  String? avatarUrl;

  /// userType。
  int? userType;

  /// rank。
  int? rank;

  /// lastRank。
  int? lastRank;

  /// score。
  int? score;

  /// 创建 Dj。
  Dj();

  /// 创建 Dj。
  factory Dj.fromJson(Map<String, dynamic> json) => _$DjFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjToJson(this);
}

/// DjRadio。
@JsonSerializable()
class DjRadio {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  late String name;

  /// dj。
  NeteaseAccountProfile? dj;

  /// picUrl。
  late String picUrl;

  /// desc。
  String? desc;

  /// subCount。
  late int subCount;

  /// commentCount。
  int? commentCount;

  /// programCount。
  late int programCount;

  /// shareCount。
  int? shareCount;

  /// likedCount。
  int? likedCount;

  /// createTime。
  int? createTime;

  /// categoryId。
  int? categoryId;

  /// category。
  String? category;

  /// radioFeeType。
  late int radioFeeType;

  /// feeScope。
  late int feeScope;

  /// buyed。
  bool? buyed;

  /// finished。
  bool? finished;

  /// underShelf。
  bool? underShelf;

  /// purchaseCount。
  int? purchaseCount;

  /// price。
  int? price;

  /// originalPrice。
  int? originalPrice;

  /// lastProgramCreateTime。
  int? lastProgramCreateTime;

  /// lastProgramName。
  String? lastProgramName;

  /// lastProgramId。
  int? lastProgramId;

  /// composeVideo。
  bool? composeVideo;

  /// alg。
  String? alg;

  /// 创建 DjRadio。
  DjRadio();

  /// 创建 DjRadio。
  factory DjRadio.fromJson(Map<String, dynamic> json) =>
      _$DjRadioFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjRadioToJson(this);
}

/// DjProgram。
@JsonSerializable()
class DjProgram {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// programDesc。
  String? programDesc;

  /// coverUrl。
  String? coverUrl;

  /// blurCoverUrl。
  String? blurCoverUrl;

  /// description。
  String? description;

  /// alg。
  String? alg;

  /// commentThreadId。
  String? commentThreadId;

  /// mainTrackId。
  int? mainTrackId;

  /// pubStatus。
  int? pubStatus;

  /// bdAuditStatus。
  late int bdAuditStatus;

  /// serialNum。
  int? serialNum;

  /// duration。
  int? duration;

  /// auditStatus。
  int? auditStatus;

  /// score。
  int? score;

  /// createTime。
  int? createTime;

  /// feeScope。
  int? feeScope;

  /// listenerCount。
  int? listenerCount;

  /// subscribedCount。
  int? subscribedCount;

  /// programFeeType。
  int? programFeeType;

  /// trackCount。
  int? trackCount;

  /// smallLanguageAuditStatus。
  int? smallLanguageAuditStatus;

  /// shareCount。
  int? shareCount;

  /// likedCount。
  int? likedCount;

  /// commentCount。
  int? commentCount;

  /// buyed。
  bool? buyed;

  /// isPublish。
  late bool isPublish;

  /// subscribed。
  bool? subscribed;

  /// canReward。
  bool? canReward;

  /// reward。
  bool? reward;

  /// radio。
  late DjRadio radio;

  /// mainSong。
  late Song mainSong;

  /// dj。
  late NeteaseAccountProfile dj;

  /// 创建 DjProgram。
  DjProgram();

  /// 创建 DjProgram。
  factory DjProgram.fromJson(Map<String, dynamic> json) =>
      _$DjProgramFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjProgramToJson(this);
}

/// DjRadioCategory。
@JsonSerializable()
class DjRadioCategory {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  late String name;

  /// picMacUrl。
  late String picMacUrl;

  /// picWebUrl。
  late String picWebUrl;

  /// picUWPUrl。
  late String picUWPUrl;

  /// picIPadUrl。
  late String picIPadUrl;

  /// picPCBlackUrl。
  late String picPCBlackUrl;

  /// picPCWhiteUrl。
  late String picPCWhiteUrl;

  /// pic56x56Url。
  late String pic56x56Url;

  /// pic84x84IdUrl。
  late String pic84x84IdUrl;

  /// pic96x96Url。
  late String pic96x96Url;

  /// 创建 DjRadioCategory。
  DjRadioCategory();

  /// 创建 DjRadioCategory。
  factory DjRadioCategory.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjRadioCategoryToJson(this);
}

/// DjRadioCategory2。
@JsonSerializable()
class DjRadioCategory2 {
  /// categoryId。
  @JsonKey(fromJson: dynamicToString)
  late String categoryId;

  /// categoryName。
  late String categoryName;

  /// radios。
  late List<DjRadio> radios;

  /// 创建 DjRadioCategory2。
  DjRadioCategory2();

  /// 创建 DjRadioCategory2。
  factory DjRadioCategory2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategory2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjRadioCategory2ToJson(this);
}

/// DjRadioCategoryWrap。
@JsonSerializable()
class DjRadioCategoryWrap extends ServerStatusBean {
  /// categories。
  late List<DjRadioCategory> categories;

  /// 创建 DjRadioCategoryWrap。
  DjRadioCategoryWrap();

  /// 创建 DjRadioCategoryWrap。
  factory DjRadioCategoryWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrapToJson(this);
}

/// DjRadioCategoryWrap2。
@JsonSerializable()
class DjRadioCategoryWrap2 extends ServerStatusBean {
  /// data。
  late List<DjRadioCategory2> data;

  /// 创建 DjRadioCategoryWrap2。
  DjRadioCategoryWrap2();

  /// 创建 DjRadioCategoryWrap2。
  factory DjRadioCategoryWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrap2ToJson(this);
}

/// DjRadioCategoryWrap3。
@JsonSerializable()
class DjRadioCategoryWrap3 extends ServerStatusBean {
  /// data。
  late List<DjRadioCategory> data;

  /// 创建 DjRadioCategoryWrap3。
  DjRadioCategoryWrap3();

  /// 创建 DjRadioCategoryWrap3。
  factory DjRadioCategoryWrap3.fromJson(Map<String, dynamic> json) =>
      _$DjRadioCategoryWrap3FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioCategoryWrap3ToJson(this);
}

/// DjRadioListWrap。
@JsonSerializable()
class DjRadioListWrap extends ServerStatusListBean {
  /// djRadios。
  late List<DjRadio> djRadios;

  /// name。
  String? name;

  /// subCount。
  int? subCount;

  /// 创建 DjRadioListWrap。
  DjRadioListWrap();

  /// 创建 DjRadioListWrap。
  factory DjRadioListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioListWrapToJson(this);
}

/// DjRadioListWrap2。
@JsonSerializable()
class DjRadioListWrap2 extends ServerStatusBean {
  /// data。
  late List<DjRadio> data;

  /// 创建 DjRadioListWrap2。
  DjRadioListWrap2();

  /// 创建 DjRadioListWrap2。
  factory DjRadioListWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioListWrap2ToJson(this);
}

/// DjTopListListWrap。
@JsonSerializable()
class DjTopListListWrap {
  /// list。
  late List<Dj> list;

  /// total。
  int? total;

  /// updateTime。
  int? updateTime;

  /// 创建 DjTopListListWrap。
  DjTopListListWrap();

  /// 创建 DjTopListListWrap。
  factory DjTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjTopListListWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjTopListListWrapToJson(this);
}

/// DjTopListListWrapX。
@JsonSerializable()
class DjTopListListWrapX extends ServerStatusBean {
  /// data。
  late DjTopListListWrap data;

  /// 创建 DjTopListListWrapX。
  DjTopListListWrapX();

  /// 创建 DjTopListListWrapX。
  factory DjTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjTopListListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjTopListListWrapXToJson(this);
}

/// DjRadioTopListItem。
@JsonSerializable()
class DjRadioTopListItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// picUrl。
  String? picUrl;

  /// creatorName。
  String? creatorName;

  /// rank。
  int? rank;

  /// lastRank。
  int? lastRank;

  /// score。
  int? score;

  // [djRadioPayGiftTopList] 这个api独有数据
  /// rcmdText。
  String? rcmdText;

  /// radioFeeType。
  int? radioFeeType;

  /// feeScope。
  int? feeScope;

  /// programCount。
  int? programCount;

  /// originalPrice。
  int? originalPrice;

  /// alg。
  String? alg;

  /// lastProgramName。
  String? lastProgramName;

  /// 创建 DjRadioTopListItem。
  DjRadioTopListItem();

  /// 创建 DjRadioTopListItem。
  factory DjRadioTopListItem.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjRadioTopListItemToJson(this);
}

/// DjRadioTopListListWrap。
@JsonSerializable()
class DjRadioTopListListWrap {
  /// list。
  late List<DjRadioTopListItem> list;

  /// total。
  int? total;

  /// updateTime。
  int? updateTime;

  /// 创建 DjRadioTopListListWrap。
  DjRadioTopListListWrap();

  /// 创建 DjRadioTopListListWrap。
  factory DjRadioTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapToJson(this);
}

/// DjRadioTopListListWrapX。
@JsonSerializable()
class DjRadioTopListListWrapX extends ServerStatusBean {
  /// data。
  late DjRadioTopListListWrap data;

  /// 创建 DjRadioTopListListWrapX。
  DjRadioTopListListWrapX();

  /// 创建 DjRadioTopListListWrapX。
  factory DjRadioTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapXToJson(this);
}

/// DjRadioDetail。
@JsonSerializable()
class DjRadioDetail extends ServerStatusBean {
  /// data。
  late DjRadio data;

  /// 创建 DjRadioDetail。
  DjRadioDetail();

  /// 创建 DjRadioDetail。
  factory DjRadioDetail.fromJson(Map<String, dynamic> json) =>
      _$DjRadioDetailFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioDetailToJson(this);
}

/// DjRadioTopListListWrapX2。
@JsonSerializable()
class DjRadioTopListListWrapX2 extends ServerStatusBean {
  /// toplist。
  late List<DjRadio> toplist;

  /// updateTime。
  int? updateTime;

  /// 创建 DjRadioTopListListWrapX2。
  DjRadioTopListListWrapX2();

  /// 创建 DjRadioTopListListWrapX2。
  factory DjRadioTopListListWrapX2.fromJson(Map<String, dynamic> json) =>
      _$DjRadioTopListListWrapX2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjRadioTopListListWrapX2ToJson(this);
}

/// DjProgramListWrap。
@JsonSerializable()
class DjProgramListWrap extends ServerStatusListBean {
  /// programs。
  late List<DjProgram> programs;

  /// name。
  String? name;

  /// 创建 DjProgramListWrap。
  DjProgramListWrap();

  /// 创建 DjProgramListWrap。
  factory DjProgramListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjProgramListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjProgramListWrapToJson(this);
}

/// DjProgramTopListItem。
@JsonSerializable()
class DjProgramTopListItem {
  /// program。
  late DjProgram program;

  /// rank。
  int? rank;

  /// lastRank。
  int? lastRank;

  /// score。
  int? score;

  /// programFeeType。
  int? programFeeType;

  /// 创建 DjProgramTopListItem。
  DjProgramTopListItem();

  /// 创建 DjProgramTopListItem。
  factory DjProgramTopListItem.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjProgramTopListItemToJson(this);
}

/// DjProgramTopListListWrap2。
@JsonSerializable()
class DjProgramTopListListWrap2 extends ServerStatusBean {
  /// toplist。
  late List<DjProgramTopListItem> toplist;

  /// updateTime。
  int? updateTime;

  /// 创建 DjProgramTopListListWrap2。
  DjProgramTopListListWrap2();

  /// 创建 DjProgramTopListListWrap2。
  factory DjProgramTopListListWrap2.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrap2ToJson(this);
}

/// PersonalizedDjProgramItem。
@JsonSerializable()
class PersonalizedDjProgramItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// copywriter。
  String? copywriter;

  /// picUrl。
  String? picUrl;

  /// canDislike。
  bool? canDislike;

  /// type。
  int? type;

  /// program。
  late DjProgram program;

  /// 创建 PersonalizedDjProgramItem。
  PersonalizedDjProgramItem();

  /// 创建 PersonalizedDjProgramItem。
  factory PersonalizedDjProgramItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedDjProgramItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PersonalizedDjProgramItemToJson(this);
}

/// DjProgramTopListListWrap。
@JsonSerializable()
class DjProgramTopListListWrap {
  /// list。
  late List<DjProgramTopListItem> list;

  /// total。
  int? total;

  /// updateTime。
  int? updateTime;

  /// 创建 DjProgramTopListListWrap。
  DjProgramTopListListWrap();

  /// 创建 DjProgramTopListListWrap。
  factory DjProgramTopListListWrap.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrapToJson(this);
}

/// DjProgramTopListListWrapX。
@JsonSerializable()
class DjProgramTopListListWrapX extends ServerStatusBean {
  /// data。
  late DjProgramTopListListWrap data;

  /// 创建 DjProgramTopListListWrapX。
  DjProgramTopListListWrapX();

  /// 创建 DjProgramTopListListWrapX。
  factory DjProgramTopListListWrapX.fromJson(Map<String, dynamic> json) =>
      _$DjProgramTopListListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjProgramTopListListWrapXToJson(this);
}

/// PersonalizedDjProgramListWrap。
@JsonSerializable()
class PersonalizedDjProgramListWrap extends ServerStatusBean {
  /// category。
  int? category;

  /// result。
  late List<PersonalizedDjProgramItem> result;

  /// 创建 PersonalizedDjProgramListWrap。
  PersonalizedDjProgramListWrap();

  /// 创建 PersonalizedDjProgramListWrap。
  factory PersonalizedDjProgramListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedDjProgramListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonalizedDjProgramListWrapToJson(this);
}

/// DjProgramDetail。
@JsonSerializable()
class DjProgramDetail extends ServerStatusBean {
  /// program。
  late DjProgram program;

  /// 创建 DjProgramDetail。
  DjProgramDetail();

  /// 创建 DjProgramDetail。
  factory DjProgramDetail.fromJson(Map<String, dynamic> json) =>
      _$DjProgramDetailFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DjProgramDetailToJson(this);
}
