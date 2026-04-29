// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import '../../../netease_music_api.dart';
import '../../../src/api/bean.dart';

part 'bean.g.dart';

/// Music。
@JsonSerializable()
class Music {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// size。
  int? size;

  /// extension。
  String? extension;

  /// sr。
  int? sr;

  /// dfsId。
  int? dfsId;

  /// bitrate。
  int? bitrate;

  /// playTime。
  int? playTime;

  /// volumeDelta。
  double? volumeDelta;

  /// 创建 Music。
  Music();

  /// 创建 Music。
  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MusicToJson(this);
}

/// Music2。
@JsonSerializable()
class Music2 {
  /// br。
  int? br;

  /// fid。
  int? fid;

  /// size。
  int? size;

  /// vd。
  double? vd;

  /// 创建 Music2。
  Music2();

  /// 创建 Music2。
  factory Music2.fromJson(Map<String, dynamic> json) => _$Music2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Music2ToJson(this);
}

/// Lyrics。
@JsonSerializable()
class Lyrics {
  /// txt。
  String? txt;

  /// 创建 Lyrics。
  Lyrics();

  /// 创建 Lyrics。
  factory Lyrics.fromJson(Map<String, dynamic> json) => _$LyricsFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$LyricsToJson(this);
}

/// Lyrics2。
@JsonSerializable()
class Lyrics2 {
  /// lyric。
  String? lyric;

  /// version。
  int? version;

  /// 创建 Lyrics2。
  Lyrics2();

  /// 创建 Lyrics2。
  factory Lyrics2.fromJson(Map<String, dynamic> json) =>
      _$Lyrics2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Lyrics2ToJson(this);
}

/// Privilege。
@JsonSerializable()
class Privilege {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// fee。
  int? fee;

  /// payed。
  int? payed;

  /// st。
  int? st;

  /// pl。
  int? pl;

  /// dl。
  int? dl;

  /// sp。
  int? sp;

  /// cp。
  int? cp;

  /// subp。
  int? subp;

  /// cs。
  bool? cs;

  /// maxbr。
  int? maxbr;

  /// fl。
  int? fl;

  /// toast。
  bool? toast;

  /// flag。
  int? flag;

  /// preSell。
  bool? preSell;

  /// 创建 Privilege。
  Privilege();

  /// 创建 Privilege。
  factory Privilege.fromJson(Map<String, dynamic> json) =>
      _$PrivilegeFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PrivilegeToJson(this);
}

/// Song。
@JsonSerializable()
class Song {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// copyrightId。
  int? copyrightId;

  /// disc。
  String? disc;

  /// no。
  int? no;

  /// fee。
  int? fee;

  /// status。
  int? status;

  /// starred。
  bool? starred;

  /// starredNum。
  int? starredNum;

  /// popularity。
  double? popularity;

  /// score。
  int? score;

  /// duration。
  int? duration;

  /// playedNum。
  int? playedNum;

  /// dayPlays。
  int? dayPlays;

  /// hearTime。
  int? hearTime;

  /// ringtone。
  String? ringtone;

  /// copyFrom。
  String? copyFrom;

  /// commentThreadId。
  String? commentThreadId;

  /// artists。
  List<Artist>? artists;

  /// album。
  Album? album;

  // Lyrics String[]
  /// lyrics。
  dynamic lyrics;

  /// privilege。
  Privilege? privilege;

  /// copyright。
  int? copyright;

  /// transName。
  String? transName;

  /// mark。
  int? mark;

  /// rtype。
  int? rtype;

  /// mvid。
  int? mvid;

  /// alg。
  String? alg;

  /// reason。
  String? reason;

  /// hMusic。
  Music? hMusic;

  /// mMusic。
  Music? mMusic;

  /// lMusic。
  Music? lMusic;

  /// bMusic。
  Music? bMusic;

  // {type: 2, typeDesc: 其它版本可播, songId: null}
  // String noCopyrightRcmd;

  /// 创建 Song。
  Song();

  /// 创建 Song。
  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SongToJson(this);
}

/// Song2。
@JsonSerializable()
class Song2 {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// pst。
  int? pst;

  /// t。
  int? t;

  /// ar。
  List<Artist>? ar;

  /// pop。
  double? pop;

  /// st。
  int? st;

  /// rt。
  String? rt;

  /// fee。
  int? fee;

  /// v。
  int? v;

  /// cf。
  String? cf;

  /// al。
  Album? al;

  /// dt。
  int? dt;

  /// h。
  Music2? h;

  /// m。
  Music2? m;

  /// l。
  Music2? l;

  /// a。
  Music2? a;

  /// mark。
  int? mark;

  /// mv。
  int? mv;

  /// rtype。
  int? rtype;

  /// mst。
  int? mst;

  /// cp。
  int? cp;

  /// publishTime。
  int? publishTime;

  /// reason。
  String? reason;

  /// privilege。
  Privilege? privilege;

  /// available。
  bool? available;

  /// 创建 Song2。
  Song2();

  /// 创建 Song2。
  factory Song2.fromJson(Map<String, dynamic> json) => _$Song2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Song2ToJson(this);
}

/// SongDetailWrap。
@JsonSerializable()
class SongDetailWrap extends ServerStatusBean {
  /// songs。
  List<Song2>? songs;

  /// privileges。
  List<Privilege>? privileges;

  /// 创建 SongDetailWrap。
  SongDetailWrap();

  /// 创建 SongDetailWrap。
  factory SongDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$SongDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SongDetailWrapToJson(this);
}

/// SongUrl。
@JsonSerializable()
class SongUrl {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// url。
  String? url;

  //码率
  /// br。
  int? br;

  /// size。
  int? size;

  /// code。
  int? code;

  /// expi。
  int? expi;

  /// gain。
  double? gain;

  /// fee。
  int? fee;

  /// payed。
  int? payed;

  /// flag。
  int? flag;

  /// canExtend。
  bool? canExtend;

  /// md5。
  String? md5;

  /// 创建 SongUrl。
  SongUrl();

  /// 创建 SongUrl。
  factory SongUrl.fromJson(Map<String, dynamic> json) =>
      _$SongUrlFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SongUrlToJson(this);
}

/// SongUrlListWrap。
@JsonSerializable()
class SongUrlListWrap extends ServerStatusBean {
  /// data。
  List<SongUrl>? data;

  /// 创建 SongUrlListWrap。
  SongUrlListWrap();

  /// 创建 SongUrlListWrap。
  factory SongUrlListWrap.fromJson(Map<String, dynamic> json) =>
      _$SongUrlListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SongUrlListWrapToJson(this);
}

/// SongLyricWrap。
@JsonSerializable()
class SongLyricWrap extends ServerStatusBean {
  /// sgc。
  bool? sgc;

  /// sfy。
  bool? sfy;

  /// qfy。
  bool? qfy;

  /// lrc。
  late Lyrics2 lrc;

  /// klyric。
  late Lyrics2 klyric;

  /// tlyric。
  late Lyrics2 tlyric;

  /// 创建 SongLyricWrap。
  SongLyricWrap();

  /// 创建 SongLyricWrap。
  factory SongLyricWrap.fromJson(Map<String, dynamic> json) =>
      _$SongLyricWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SongLyricWrapToJson(this);
}

/// SongListWrap。
@JsonSerializable()
class SongListWrap extends ServerStatusBean {
  /// songs。
  List<Song>? songs;

  /// 创建 SongListWrap。
  SongListWrap();

  /// 创建 SongListWrap。
  factory SongListWrap.fromJson(Map<String, dynamic> json) =>
      _$SongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SongListWrapToJson(this);
}

/// SongListWrap2。
@JsonSerializable()
class SongListWrap2 extends ServerStatusBean {
  /// data。
  List<Song>? data;

  /// 创建 SongListWrap2。
  SongListWrap2();

  /// 创建 SongListWrap2。
  factory SongListWrap2.fromJson(Map<String, dynamic> json) =>
      _$SongListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SongListWrap2ToJson(this);
}

/// PersonalizedSongItem。
@JsonSerializable()
class PersonalizedSongItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// picUrl。
  String? picUrl;

  /// copywriter。
  String? copywriter;

  /// canDislike。
  bool? canDislike;

  /// alg。
  String? alg;

  /// type。
  int? type;

  /// song。
  late Song song;

  /// 创建 PersonalizedSongItem。
  PersonalizedSongItem();

  /// 创建 PersonalizedSongItem。
  factory PersonalizedSongItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedSongItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PersonalizedSongItemToJson(this);
}

/// PersonalizedSongListWrap。
@JsonSerializable()
class PersonalizedSongListWrap extends ServerStatusBean {
  /// result。
  List<PersonalizedSongItem>? result;

  /// category。
  int? category;

  /// 创建 PersonalizedSongListWrap。
  PersonalizedSongListWrap();

  /// 创建 PersonalizedSongListWrap。
  factory PersonalizedSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonalizedSongListWrapToJson(this);
}

/// LikeSongListWrap。
@JsonSerializable()
class LikeSongListWrap extends ServerStatusBean {
  /// checkPoint。
  int? checkPoint;

  /// ids。
  late List<int> ids;

  /// 创建 LikeSongListWrap。
  LikeSongListWrap();

  /// 创建 LikeSongListWrap。
  factory LikeSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$LikeSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LikeSongListWrapToJson(this);
}

/// CloudSongItem。
@JsonSerializable()
class CloudSongItem {
  /// simpleSong。
  late Song2 simpleSong;

  /// songId。
  @JsonKey(fromJson: dynamicToString)
  late String songId;

  /// songName。
  String? songName;

  /// fileName。
  String? fileName;

  /// cover。
  int? cover;

  /// fileSize。
  int? fileSize;

  /// addTime。
  late int addTime;

  /// version。
  int? version;

  /// coverId。
  String? coverId;

  /// lyricId。
  String? lyricId;

  /// album。
  String? album;

  /// artist。
  String? artist;

  /// bitrate。
  int? bitrate;

  /// 创建 CloudSongItem。
  CloudSongItem();

  /// 创建 CloudSongItem。
  factory CloudSongItem.fromJson(Map<String, dynamic> json) =>
      _$CloudSongItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$CloudSongItemToJson(this);
}

/// CloudSongListWrap。
@JsonSerializable()
class CloudSongListWrap extends ServerStatusListBean {
  /// size。
  String? size;

  /// maxSize。
  String? maxSize;

  /// upgradeSign。
  int? upgradeSign;

  /// data。
  List<CloudSongItem>? data;

  /// 创建 CloudSongListWrap。
  CloudSongListWrap();

  /// 创建 CloudSongListWrap。
  factory CloudSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$CloudSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CloudSongListWrapToJson(this);
}

/// RecommendSongReason。
@JsonSerializable()
class RecommendSongReason {
  /// songId。
  @JsonKey(fromJson: dynamicToString)
  String? songId;

  /// reason。
  String? reason;

  /// 创建 RecommendSongReason。
  RecommendSongReason();

  /// 创建 RecommendSongReason。
  factory RecommendSongReason.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongReasonFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$RecommendSongReasonToJson(this);
}

/// RecommendSongListWrap。
@JsonSerializable()
class RecommendSongListWrap {
  /// dailySongs。
  List<Song2>? dailySongs;

  /// orderSongs。
  List<Song2>? orderSongs;

  /// recommendReasons。
  List<RecommendSongReason>? recommendReasons;

  /// 创建 RecommendSongListWrap。
  RecommendSongListWrap();

  /// 创建 RecommendSongListWrap。
  factory RecommendSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$RecommendSongListWrapToJson(this);
}

/// RecommendSongListWrapX。
@JsonSerializable()
class RecommendSongListWrapX extends ServerStatusBean {
  /// data。
  late RecommendSongListWrap data;

  /// 创建 RecommendSongListWrapX。
  RecommendSongListWrapX();

  /// 创建 RecommendSongListWrapX。
  factory RecommendSongListWrapX.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecommendSongListWrapXToJson(this);
}

/// RecommendSongListHistoryWrap。
@JsonSerializable()
class RecommendSongListHistoryWrap {
  /// dates。
  List<String>? dates;

  /// purchaseUrl。
  String? purchaseUrl;

  /// description。
  String? description;

  /// noHistoryMessage。
  String? noHistoryMessage;

  /// songs。
  List<Song2>? songs;

  /// 创建 RecommendSongListHistoryWrap。
  RecommendSongListHistoryWrap();

  /// 创建 RecommendSongListHistoryWrap。
  factory RecommendSongListHistoryWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListHistoryWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$RecommendSongListHistoryWrapToJson(this);
}

/// RecommendSongListHistoryWrapX。
@JsonSerializable()
class RecommendSongListHistoryWrapX extends ServerStatusBean {
  /// data。
  late RecommendSongListHistoryWrap data;

  /// 创建 RecommendSongListHistoryWrapX。
  RecommendSongListHistoryWrapX();

  /// 创建 RecommendSongListHistoryWrapX。
  factory RecommendSongListHistoryWrapX.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListHistoryWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecommendSongListHistoryWrapXToJson(this);
}

/// ArtistSongListWrap。
@JsonSerializable()
class ArtistSongListWrap extends ServerStatusBean {
  /// songs。
  List<Song2>? songs;

  /// 创建 ArtistSongListWrap。
  ArtistSongListWrap();

  /// 创建 ArtistSongListWrap。
  factory ArtistSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistSongListWrapToJson(this);
}

/// ArtistNewSongListData。
@JsonSerializable()
class ArtistNewSongListData {
  /// hasMore。
  bool? hasMore;

  /// newSongCount。
  int? newSongCount;

  /// newWorks。
  List<Song2>? newWorks;

  /// 创建 ArtistNewSongListData。
  ArtistNewSongListData();

  /// 创建 ArtistNewSongListData。
  factory ArtistNewSongListData.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewSongListDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistNewSongListDataToJson(this);
}

/// ArtistNewSongListWrap。
@JsonSerializable()
class ArtistNewSongListWrap extends ServerStatusBean {
  /// data。
  late ArtistNewSongListData data;

  /// 创建 ArtistNewSongListWrap。
  ArtistNewSongListWrap();

  /// 创建 ArtistNewSongListWrap。
  factory ArtistNewSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistNewSongListWrapToJson(this);
}

/// ArtistDetailAndSongListWrap。
@JsonSerializable()
class ArtistDetailAndSongListWrap extends ServerStatusBean {
  /// hotSongs。
  List<Song2>? hotSongs;

  /// artist。
  late Artist artist;

  /// 创建 ArtistDetailAndSongListWrap。
  ArtistDetailAndSongListWrap();

  /// 创建 ArtistDetailAndSongListWrap。
  factory ArtistDetailAndSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailAndSongListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistDetailAndSongListWrapToJson(this);
}

/// PlayList。
@JsonSerializable()
class PlayList {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  //歌单名
  /// name。
  String? name;

  /// description。
  String? description;

  /// coverImgUrl。
  String? coverImgUrl;

  /// picUrl。
  String? picUrl;

  /// tag。
  String? tag;

  /// tags。
  List<String>? tags;

  /// copywriter。
  String? copywriter;

  /// createTime。
  int? createTime;

  /// updateTime。
  int? updateTime;

  /// playCount。
  @JsonKey(fromJson: dynamicToInt)
  int? playCount;

  /// subscribedCount。
  int? subscribedCount;

  /// shareCount。
  int? shareCount;

  /// commentCount。
  int? commentCount;

  /// subscribed。
  bool? subscribed;

  /// trackCount。
  int? trackCount;

  /// trackNumberUpdateTime。
  int? trackNumberUpdateTime;

  /// commentThreadId。
  String? commentThreadId;

  /// alg。
  String? alg;

  // 歌单类型:
  // 0: 自建?
  // 5: 我喜欢的音乐
  /// specialType。
  int? specialType;

  /// creator。
  NeteaseUserInfo? creator;

  /// subscribers。
  List<NeteaseUserInfo>? subscribers;

  /// tracks。
  List<PlayTrack>? tracks;

  /// trackIds。
  List<PlayTrackId>? trackIds;

  /// 创建 PlayList。
  PlayList();

  @override
  String toString() {
    return 'Play{id: $id, name: $name}';
  }

  /// 创建 PlayList。
  factory PlayList.fromJson(Map<String, dynamic> json) =>
      _$PlayListFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlayListToJson(this);
}

/// PlayTrack。
@JsonSerializable()
class PlayTrack {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// pst。
  int? pst;

  /// t。
  int? t;

  /// ar。
  List<Artist>? ar;

  /// pop。
  double? pop;

  /// st。
  int? st;

  /// rt。
  String? rt;

  /// fee。
  int? fee;

  /// v。
  int? v;

  /// cf。
  String? cf;

  /// al。
  late Album al;

  /// dt。
  int? dt;

  /// h。
  Music2? h;

  /// m。
  Music2? m;

  /// l。
  Music2? l;

  /// a。
  Music2? a;

  /// cd。
  String? cd;

  /// no。
  int? no;

  /// ftype。
  int? ftype;

  /// rtUrls。
  List<dynamic>? rtUrls;

  /// djId。
  int? djId;

  /// copyright。
  int? copyright;

  /// s_id。
  int? s_id;

  /// mark。
  int? mark;

  /// originCoverType。
  int? originCoverType;

  /// single。
  int? single;

  /// rtype。
  int? rtype;

  /// mst。
  int? mst;

  /// cp。
  int? cp;

  /// mv。
  int? mv;

  /// publishTime。
  int? publishTime;

  /// 创建 PlayTrack。
  PlayTrack();

  /// 创建 PlayTrack。
  factory PlayTrack.fromJson(Map<String, dynamic> json) =>
      _$PlayTrackFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlayTrackToJson(this);
}

/// PlayTrackId。
@JsonSerializable()
class PlayTrackId {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// v。
  int? v;

  /// t。
  int? t;

  /// at。
  int? at;

  /// lr。
  int? lr;

  /// 创建 PlayTrackId。
  PlayTrackId();

  /// 创建 PlayTrackId。
  factory PlayTrackId.fromJson(Map<String, dynamic> json) =>
      _$PlayTrackIdFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlayTrackIdToJson(this);
}

/// MultiPlayListWrap。
@JsonSerializable()
class MultiPlayListWrap extends ServerStatusBean {
  /// playlists。
  List<PlayList>? playlists;

  /// 创建 MultiPlayListWrap。
  MultiPlayListWrap();

  /// 创建 MultiPlayListWrap。
  factory MultiPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$MultiPlayListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MultiPlayListWrapToJson(this);
}

/// MultiPlayListWrap2。
@JsonSerializable()
class MultiPlayListWrap2 extends ServerStatusBean {
  /// playlists。
  List<PlayList>? playlists;

  /// 创建 MultiPlayListWrap2。
  MultiPlayListWrap2();

  /// 创建 MultiPlayListWrap2。
  factory MultiPlayListWrap2.fromJson(Map<String, dynamic> json) =>
      _$MultiPlayListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MultiPlayListWrap2ToJson(this);
}

/// RecommendPlayListWrap。
@JsonSerializable()
class RecommendPlayListWrap extends ServerStatusBean {
  /// recommend。
  List<PlayList>? recommend;

  /// featureFirst。
  bool? featureFirst;

  /// haveRcmdSongs。
  bool? haveRcmdSongs;

  /// 创建 RecommendPlayListWrap。
  RecommendPlayListWrap();

  /// 创建 RecommendPlayListWrap。
  factory RecommendPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendPlayListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RecommendPlayListWrapToJson(this);
}

/// PersonalizedPlayListWrap。
@JsonSerializable()
class PersonalizedPlayListWrap extends ServerStatusBean {
  /// result。
  List<PlayList>? result;

  /// hasTaste。
  bool? hasTaste;

  /// category。
  int? category;

  /// 创建 PersonalizedPlayListWrap。
  PersonalizedPlayListWrap();

  /// 创建 PersonalizedPlayListWrap。
  factory PersonalizedPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPlayListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonalizedPlayListWrapToJson(this);
}

/// PlaylistCatalogueItem。
@JsonSerializable()
class PlaylistCatalogueItem {
  /// name。
  String? name;

  /// resourceCount。
  int? resourceCount;

  /// imgUrl。
  String? imgUrl;

  /// type。
  int? type;

  /// category。
  int? category;

  /// resourceType。
  int? resourceType;

  /// hot。
  bool? hot;

  /// activity。
  bool? activity;

  /// 创建 PlaylistCatalogueItem。
  PlaylistCatalogueItem();

  /// 创建 PlaylistCatalogueItem。
  factory PlaylistCatalogueItem.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCatalogueItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlaylistCatalogueItemToJson(this);
}

/// PlaylistCatalogueWrap。
@JsonSerializable()
class PlaylistCatalogueWrap extends ServerStatusBean {
  /// all。
  PlaylistCatalogueItem? all;

  /// sub。
  List<PlaylistCatalogueItem>? sub;

  /// categories。
  Map<int, String>? categories;

  /// 创建 PlaylistCatalogueWrap。
  PlaylistCatalogueWrap();

  /// 创建 PlaylistCatalogueWrap。
  factory PlaylistCatalogueWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCatalogueWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaylistCatalogueWrapToJson(this);
}

/// PlaylistHotTag。
@JsonSerializable()
class PlaylistHotTag {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// category。
  int? category;

  /// usedCount。
  int? usedCount;

  /// type。
  int? type;

  /// position。
  int? position;

  /// highQuality。
  int? highQuality;

  /// highQualityPos。
  int? highQualityPos;

  /// officialPos。
  int? officialPos;

  /// createTime。
  int? createTime;

  /// 创建 PlaylistHotTag。
  PlaylistHotTag();

  /// 创建 PlaylistHotTag。
  factory PlaylistHotTag.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlaylistHotTagToJson(this);
}

/// PlaylistHotTagsItem。
@JsonSerializable()
class PlaylistHotTagsItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// activity。
  bool? activity;

  /// hot。
  bool? hot;

  /// position。
  int? position;

  /// category。
  int? category;

  /// createTime。
  int? createTime;

  /// type。
  int? type;

  /// playlistTag。
  PlaylistHotTag? playlistTag;

  /// 创建 PlaylistHotTagsItem。
  PlaylistHotTagsItem();

  /// 创建 PlaylistHotTagsItem。
  factory PlaylistHotTagsItem.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagsItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlaylistHotTagsItemToJson(this);
}

/// PlaylistHotTagsWrap。
@JsonSerializable()
class PlaylistHotTagsWrap extends ServerStatusBean {
  /// tags。
  List<PlaylistHotTagsItem>? tags;

  /// 创建 PlaylistHotTagsWrap。
  PlaylistHotTagsWrap();

  /// 创建 PlaylistHotTagsWrap。
  factory PlaylistHotTagsWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagsWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaylistHotTagsWrapToJson(this);
}

/// PLAYLIST_CATEGORY。
const PLAYLIST_CATEGORY = [
  {'name': '云音乐新歌榜', 'id': '3779629'},
  {'name': '云音乐热歌榜', 'id': '3778678'},
  {'name': '云音乐原创榜', 'id': '2884035'},
  {'name': '云音乐飙升榜', 'id': '19723756'},
  {'name': '云音乐电音榜', 'id': '10520166'},
  {'name': 'UK排行榜周榜', 'id': '180106'},
  {'name': '美国Billboard周榜', 'id': '60198'},
  {'name': 'KTV嗨榜', 'id': '21845217'},
  {'name': 'iTunes榜', 'id': '11641012'},
  {'name': 'Hit FM Top榜', 'id': '120001'},
  {'name': '日本Oricon周榜', 'id': '60131'},
  {'name': '韩国Melon排行榜周榜', 'id': '3733003'},
  {'name': '韩国Mnet排行榜周榜', 'id': '60255'},
  {'name': '韩国Melon原声周榜', 'id': '46772709'},
  {'name': '中国TOP排行榜(港台榜)', 'id': '112504'},
  {'name': '中国TOP排行榜(内地榜)', 'id': '64016'},
  {'name': '香港电台中文歌曲龙虎榜', 'id': '10169002'},
  {'name': '华语金曲榜', 'id': '4395559'},
  {'name': '中国嘻哈榜', 'id': '1899724'},
  {'name': '法国 NRJ EuroHot 30周榜', 'id': '27135204'},
  {'name': '台湾Hito排行榜', 'id': '112463'},
  {'name': 'Beatport全球电子舞曲榜', 'id': '3812895'},
  {'name': '云音乐ACG音乐榜', 'id': '71385702'},
  {'name': '云音乐说唱榜 ', 'id': '991319590'},
  {'name': '云音乐古典音乐榜', 'id': '71384707'},
  {'name': '云音乐电音榜', 'id': '1978921795'},
  {'name': '抖音排行榜', 'id': '2250011882'},
  {'name': '新声榜', 'id': '2617766278'},
  {'name': '云音乐韩语榜', 'id': '745956260'},
  {'name': '英国Q杂志中文版周榜', 'id': '2023401535'},
  {'name': '电竞音乐榜', 'id': '2006508653'},
  {'name': '云音乐欧美热歌榜', 'id': '2809513713'},
  {'name': '云音乐欧美新歌榜', 'id': '2809577409'},
  {'name': '说唱TOP榜', 'id': '2847251561'},
  {'name': '云音乐ACG动画榜', 'id': '3001835560'},
  {'name': '云音乐ACG游戏榜', 'id': '3001795926'},
  {'name': '云音乐ACG VOCALOID榜', 'id': '3001890046'}
];

/// SinglePlayListWrap。
@JsonSerializable()
class SinglePlayListWrap extends ServerStatusBean {
  /// playlist。
  PlayList? playlist;

  /// 创建 SinglePlayListWrap。
  SinglePlayListWrap();

  /// 创建 SinglePlayListWrap。
  factory SinglePlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$SinglePlayListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SinglePlayListWrapToJson(this);
}

/// PlayListDetailDynamicWrap。
@JsonSerializable()
class PlayListDetailDynamicWrap extends ServerStatusBean {
  /// commentCount。
  int? commentCount;

  /// shareCount。
  int? shareCount;

  /// playCount。
  int? playCount;

  /// bookedCount。
  int? bookedCount;

  /// subscribed。
  bool? subscribed;

  /// remarkName。
  String? remarkName;

  /// followed。
  bool? followed;

  /// 创建 PlayListDetailDynamicWrap。
  PlayListDetailDynamicWrap();

  /// 创建 PlayListDetailDynamicWrap。
  factory PlayListDetailDynamicWrap.fromJson(Map<String, dynamic> json) =>
      _$PlayListDetailDynamicWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayListDetailDynamicWrapToJson(this);
}

/// PlaymodeIntelligenceItem。
@JsonSerializable()
class PlaymodeIntelligenceItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// recommended。
  bool? recommended;

  /// alg。
  String? alg;

  /// songInfo。
  Song2? songInfo;

  /// 创建 PlaymodeIntelligenceItem。
  PlaymodeIntelligenceItem();

  /// 创建 PlaymodeIntelligenceItem。
  factory PlaymodeIntelligenceItem.fromJson(Map<String, dynamic> json) =>
      _$PlaymodeIntelligenceItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$PlaymodeIntelligenceItemToJson(this);
}

/// PlaymodeIntelligenceListWrap。
@JsonSerializable()
class PlaymodeIntelligenceListWrap extends ServerStatusBean {
  /// data。
  List<PlaymodeIntelligenceItem>? data;

  /// 创建 PlaymodeIntelligenceListWrap。
  PlaymodeIntelligenceListWrap();

  /// 创建 PlaymodeIntelligenceListWrap。
  factory PlaymodeIntelligenceListWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaymodeIntelligenceListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaymodeIntelligenceListWrapToJson(this);
}

/// Artist。
@JsonSerializable()
class Artist {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// accountId。
  @JsonKey(fromJson: dynamicToString)
  String? accountId;

  /// name。
  String? name;

  /// picUrl。
  String? picUrl;

  /// img1v1Id。
  int? img1v1Id;

  /// img1v1Url。
  String? img1v1Url;

  /// cover。
  String? cover;

  /// albumSize。
  int? albumSize;

  /// musicSize。
  int? musicSize;

  /// mvSize。
  int? mvSize;

  /// topicPerson。
  int? topicPerson;

  /// trans。
  String? trans;

  /// briefDesc。
  String? briefDesc;

  /// followed。
  bool? followed;

  /// publishTime。
  int? publishTime;

  /// 创建 Artist。
  Artist();

  /// 创建 Artist。
  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

/// ArtistsListWrap。
@JsonSerializable()
class ArtistsListWrap extends ServerStatusBean {
  /// artists。
  List<Artist>? artists;

  /// 创建 ArtistsListWrap。
  ArtistsListWrap();

  /// 创建 ArtistsListWrap。
  factory ArtistsListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistsListWrapToJson(this);
}

/// ArtistsTopListWrap。
@JsonSerializable()
class ArtistsTopListWrap {
  /// artists。
  List<Artist>? artists;

  /// type。
  int? type;

  /// updateTime。
  int? updateTime;

  /// 创建 ArtistsTopListWrap。
  ArtistsTopListWrap();

  /// 创建 ArtistsTopListWrap。
  factory ArtistsTopListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsTopListWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistsTopListWrapToJson(this);
}

/// ArtistsTopListWrapX。
@JsonSerializable()
class ArtistsTopListWrapX extends ServerStatusBean {
  /// list。
  ArtistsTopListWrap? list;

  /// 创建 ArtistsTopListWrapX。
  ArtistsTopListWrapX();

  /// 创建 ArtistsTopListWrapX。
  factory ArtistsTopListWrapX.fromJson(Map<String, dynamic> json) =>
      _$ArtistsTopListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistsTopListWrapXToJson(this);
}

/// ArtistIntroduction。
@JsonSerializable()
class ArtistIntroduction {
  /// ti。
  String? ti;

  /// txt。
  String? txt;

  /// 创建 ArtistIntroduction。
  ArtistIntroduction();

  /// 创建 ArtistIntroduction。
  factory ArtistIntroduction.fromJson(Map<String, dynamic> json) =>
      _$ArtistIntroductionFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistIntroductionToJson(this);
}

/// ArtistDescWrap。
@JsonSerializable()
class ArtistDescWrap extends ServerStatusBean {
  /// introduction。
  List<ArtistIntroduction>? introduction;

  /// briefDesc。
  String? briefDesc;

  /// count。
  int? count;

  /// topicData。
  List<TopicItem2>? topicData;

  /// 创建 ArtistDescWrap。
  ArtistDescWrap();

  /// 创建 ArtistDescWrap。
  factory ArtistDescWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDescWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistDescWrapToJson(this);
}

/// ArtistDetailData。
@JsonSerializable()
class ArtistDetailData {
  /// blacklist。
  bool? blacklist;

  /// showPriMsg。
  bool? showPriMsg;

  /// videoCount。
  int? videoCount;

  /// artist。
  Artist? artist;

  /// 创建 ArtistDetailData。
  ArtistDetailData();

  /// 创建 ArtistDetailData。
  factory ArtistDetailData.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistDetailDataToJson(this);
}

/// ArtistDetailWrap。
@JsonSerializable()
class ArtistDetailWrap extends ServerStatusBean {
  /// data。
  ArtistDetailData? data;

  /// 创建 ArtistDetailWrap。
  ArtistDetailWrap();

  /// 创建 ArtistDetailWrap。
  factory ArtistDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistDetailWrapToJson(this);
}

/// Album。
@JsonSerializable()
class Album {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// type。
  String? type;

  /// subType。
  String? subType;

  /// mark。
  int? mark;

  /// size。
  int? size;

  /// publishTime。
  int? publishTime;

  /// picUrl。
  String? picUrl;

  /// tags。
  String? tags;

  /// copyrightId。
  int? copyrightId;

  /// companyId。
  int? companyId;

  /// company。
  String? company;

  /// description。
  String? description;

  /// briefDesc。
  String? briefDesc;

  /// artist。
  Artist? artist;

  /// artists。
  List<Artist>? artists;

  /// isSub。
  bool? isSub;

  /// paid。
  bool? paid;

  /// onSale。
  bool? onSale;

  /// 创建 Album。
  Album();

  /// 创建 Album。
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

/// AlbumDetailWrap。
@JsonSerializable()
class AlbumDetailWrap extends ServerStatusBean {
  /// songs。
  List<Song2>? songs;

  /// album。
  Album? album;

  /// 创建 AlbumDetailWrap。
  AlbumDetailWrap();

  /// 创建 AlbumDetailWrap。
  factory AlbumDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlbumDetailWrapToJson(this);
}

/// AlbumDetailDynamicWrap。
@JsonSerializable()
class AlbumDetailDynamicWrap extends ServerStatusBean {
  /// onSale。
  bool? onSale;

  /// isSub。
  bool? isSub;

  /// subTime。
  int? subTime;

  /// commentCount。
  int? commentCount;

  /// likedCount。
  int? likedCount;

  /// shareCount。
  int? shareCount;

  /// subCount。
  int? subCount;

  /// 创建 AlbumDetailDynamicWrap。
  AlbumDetailDynamicWrap();

  /// 创建 AlbumDetailDynamicWrap。
  factory AlbumDetailDynamicWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumDetailDynamicWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlbumDetailDynamicWrapToJson(this);
}

/// AlbumListWrap。
@JsonSerializable()
class AlbumListWrap extends ServerStatusListBean {
  /// albums。
  List<Album>? albums;

  /// 创建 AlbumListWrap。
  AlbumListWrap();

  /// 创建 AlbumListWrap。
  factory AlbumListWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlbumListWrapToJson(this);
}

/// ArtistAlbumListWrap。
@JsonSerializable()
class ArtistAlbumListWrap extends ServerStatusListBean {
  /// time。
  int? time;

  /// hotAlbums。
  List<Album>? hotAlbums;

  /// artist。
  late Artist artist;

  /// 创建 ArtistAlbumListWrap。
  ArtistAlbumListWrap();

  /// 创建 ArtistAlbumListWrap。
  factory ArtistAlbumListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistAlbumListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistAlbumListWrapToJson(this);
}

/// MvCreator。
@JsonSerializable()
class MvCreator {
  /// userId。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// userName。
  String? userName;

  /// 创建 MvCreator。
  MvCreator();

  /// 创建 MvCreator。
  factory MvCreator.fromJson(Map<String, dynamic> json) =>
      _$MvCreatorFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MvCreatorToJson(this);
}

/// Mv。
@JsonSerializable()
class Mv {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// cover。
  String? cover;

  /// playCount。
  int? playCount;

  /// briefDesc。
  String? briefDesc;

  /// desc。
  String? desc;

  /// arTransName。
  String? arTransName;

  /// artisAlias。
  String? artisAlias;

  /// artisTransName。
  String? artisTransName;

  /// artistName。
  String? artistName;

  /// artistImgUrl。
  String? artistImgUrl;

  /// artistId。
  int? artistId;

  /// mvId。
  int? mvId;

  /// mvName。
  String? mvName;

  /// mvCoverUrl。
  String? mvCoverUrl;

  /// duration。
  int? duration;

  /// publishTime。
  @JsonKey(fromJson: dynamicToString)
  String? publishTime;

  /// publishDate。
  String? publishDate;

  /// mark。
  int? mark;

  /// alg。
  String? alg;

  /// artists。
  List<Artist>? artists;

  /// 创建 Mv。
  Mv();

  /// 创建 Mv。
  factory Mv.fromJson(Map<String, dynamic> json) => _$MvFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MvToJson(this);
}

/// Mv2。
@JsonSerializable()
class Mv2 {
  /// type。
  int? type;

  /// title。
  String? title;

  /// durationms。
  int? durationms;

  /// playTime。
  int? playTime;

  /// vid。
  String? vid;

  /// coverUrl。
  String? coverUrl;

  /// aliaName。
  String? aliaName;

  /// transName。
  String? transName;

  /// creator。
  List<MvCreator>? creator;

  /// 创建 Mv2。
  Mv2();

  /// 创建 Mv2。
  factory Mv2.fromJson(Map<String, dynamic> json) => _$Mv2FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Mv2ToJson(this);
}

/// Mv3。
@JsonSerializable()
class Mv3 {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// artistName。
  String? artistName;

  /// imgurl。
  late String imgurl;

  /// imgurl16v9。
  late String imgurl16v9;

  /// status。
  int? status;

  /// artist。
  late Artist artist;

  /// 创建 Mv3。
  Mv3();

  /// 创建 Mv3。
  factory Mv3.fromJson(Map<String, dynamic> json) => _$Mv3FromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$Mv3ToJson(this);
}

/// MvListWrap。
@JsonSerializable()
class MvListWrap extends ServerStatusListBean {
  /// mvs。
  List<Mv>? mvs;

  /// 创建 MvListWrap。
  MvListWrap();

  /// 创建 MvListWrap。
  factory MvListWrap.fromJson(Map<String, dynamic> json) =>
      _$MvListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvListWrapToJson(this);
}

/// MvListWrap2。
@JsonSerializable()
class MvListWrap2 extends ServerStatusListBean {
  /// data。
  List<Mv>? data;

  /// updateTime。
  int? updateTime;

  /// 创建 MvListWrap2。
  MvListWrap2();

  /// 创建 MvListWrap2。
  factory MvListWrap2.fromJson(Map<String, dynamic> json) =>
      _$MvListWrap2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvListWrap2ToJson(this);
}

/// PersonalizedMvListWrap。
@JsonSerializable()
class PersonalizedMvListWrap extends ServerStatusBean {
  /// result。
  List<Mv>? result;

  /// category。
  int? category;

  /// 创建 PersonalizedMvListWrap。
  PersonalizedMvListWrap();

  /// 创建 PersonalizedMvListWrap。
  factory PersonalizedMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedMvListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PersonalizedMvListWrapToJson(this);
}

/// ArtistMvListWrap。
@JsonSerializable()
class ArtistMvListWrap extends MvListWrap {
  /// time。
  int? time;

  /// 创建 ArtistMvListWrap。
  ArtistMvListWrap();

  /// 创建 ArtistMvListWrap。
  factory ArtistMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistMvListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistMvListWrapToJson(this);
}

/// ArtistNewMvListData。
@JsonSerializable()
class ArtistNewMvListData {
  /// hasMore。
  bool? hasMore;

  /// newWorks。
  List<Mv>? newWorks;

  /// 创建 ArtistNewMvListData。
  ArtistNewMvListData();

  /// 创建 ArtistNewMvListData。
  factory ArtistNewMvListData.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewMvListDataFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$ArtistNewMvListDataToJson(this);
}

/// ArtistNewMvListWrap。
@JsonSerializable()
class ArtistNewMvListWrap extends ServerStatusBean {
  /// data。
  late ArtistNewMvListData data;

  /// 创建 ArtistNewMvListWrap。
  ArtistNewMvListWrap();

  /// 创建 ArtistNewMvListWrap。
  factory ArtistNewMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewMvListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArtistNewMvListWrapToJson(this);
}

/// MvDetailWrap。
@JsonSerializable()
class MvDetailWrap extends ServerStatusBean {
  /// loadingPic。
  String? loadingPic;

  /// bufferPic。
  String? bufferPic;

  /// loadingPicFS。
  String? loadingPicFS;

  /// bufferPicFS。
  String? bufferPicFS;

  /// subed。
  bool? subed;

  /// data。
  Mv? data;

  /// 创建 MvDetailWrap。
  MvDetailWrap();

  /// 创建 MvDetailWrap。
  factory MvDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$MvDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvDetailWrapToJson(this);
}

/// MvDetailInfoWrap。
@JsonSerializable()
class MvDetailInfoWrap extends ServerStatusBean {
  /// likedCount。
  int? likedCount;

  /// shareCount。
  int? shareCount;

  /// commentCount。
  int? commentCount;

  /// liked。
  bool? liked;

  /// 创建 MvDetailInfoWrap。
  MvDetailInfoWrap();

  /// 创建 MvDetailInfoWrap。
  factory MvDetailInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$MvDetailInfoWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvDetailInfoWrapToJson(this);
}

/// MvUrl。
@JsonSerializable()
class MvUrl {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// url。
  String? url;

  /// md5。
  String? md5;

  /// msg。
  String? msg;

  /// r。
  int? r;

  /// size。
  int? size;

  /// expi。
  int? expi;

  /// fee。
  int? fee;

  /// mvFee。
  int? mvFee;

  /// st。
  int? st;

  /// 创建 MvUrl。
  MvUrl();

  /// 创建 MvUrl。
  factory MvUrl.fromJson(Map<String, dynamic> json) => _$MvUrlFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$MvUrlToJson(this);
}

/// MvUrlWrap。
@JsonSerializable()
class MvUrlWrap extends ServerStatusBean {
  /// data。
  late MvUrl data;

  /// 创建 MvUrlWrap。
  MvUrlWrap();

  /// 创建 MvUrlWrap。
  factory MvUrlWrap.fromJson(Map<String, dynamic> json) =>
      _$MvUrlWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MvUrlWrapToJson(this);
}

/// VideoResolution。
@JsonSerializable()
class VideoResolution {
  /// resolution。
  int? resolution;

  /// size。
  int? size;

  /// 创建 VideoResolution。
  VideoResolution();

  /// 创建 VideoResolution。
  factory VideoResolution.fromJson(Map<String, dynamic> json) =>
      _$VideoResolutionFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoResolutionToJson(this);
}

/// VideoUrlInfo。
@JsonSerializable()
class VideoUrlInfo {
  /// id。
  late String id;

  /// url。
  String? url;

  /// size。
  int? size;

  /// validityTime。
  int? validityTime;

  /// needPay。
  bool? needPay;

  /// r。
  int? r;

  /// 创建 VideoUrlInfo。
  VideoUrlInfo();

  /// 创建 VideoUrlInfo。
  factory VideoUrlInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlInfoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoUrlInfoToJson(this);
}

/// VideoBase。
@JsonSerializable()
class VideoBase {
  /// vid。
  String? vid;

  /// title。
  String? title;

  /// description。
  String? description;

  /// scm。
  String? scm;

  /// alg。
  String? alg;

  /// threadId。
  String? threadId;

  /// coverUrl。
  String? coverUrl;

  /// previewUrl。
  String? previewUrl;

  /// width。
  int? width;

  /// height。
  int? height;

  /// praisedCount。
  int? praisedCount;

  /// playTime。
  int? playTime;

  /// durationms。
  int? durationms;

  /// previewDurationms。
  int? previewDurationms;

  /// commentCount。
  int? commentCount;

  /// shareCount。
  int? shareCount;

  /// praised。
  bool? praised;

  /// subscribed。
  bool? subscribed;

  /// hasRelatedGameAd。
  bool? hasRelatedGameAd;

  /// resolutions。
  List<VideoResolution>? resolutions;

  /// urlInfo。
  VideoUrlInfo? urlInfo;

  /// videoGroup。
  List<VideoMetaItem>? videoGroup;

  /// relateSong。
  List<Song>? relateSong;

  /// 创建 VideoBase。
  VideoBase();

  /// 创建 VideoBase。
  factory VideoBase.fromJson(Map<String, dynamic> json) =>
      _$VideoBaseFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoBaseToJson(this);
}

/// Video。
@JsonSerializable()
class Video extends VideoBase {
  /// creator。
  late NeteaseUserInfo creator;

  /// 创建 Video。
  Video();

  /// 创建 Video。
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}

/// Video2。
@JsonSerializable()
class Video2 extends VideoBase {
  /// creator。
  List<NeteaseUserInfo>? creator;

  /// 创建 Video2。
  Video2();

  /// 创建 Video2。
  factory Video2.fromJson(Map<String, dynamic> json) => _$Video2FromJson(json);

  @override
  Map<String, dynamic> toJson() => _$Video2ToJson(this);
}

/// VideoMetaItem。
@JsonSerializable()
class VideoMetaItem {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// name。
  String? name;

  /// url。
  String? url;

  /// relatedVideoType。
  String? relatedVideoType;

  /// selectTab。
  bool? selectTab;

  /// 创建 VideoMetaItem。
  VideoMetaItem();

  /// 创建 VideoMetaItem。
  factory VideoMetaItem.fromJson(Map<String, dynamic> json) =>
      _$VideoMetaItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoMetaItemToJson(this);
}

/// VideoMetaListWrap。
@JsonSerializable()
class VideoMetaListWrap extends ServerStatusBean {
  /// data。
  List<VideoMetaItem>? data;

  /// 创建 VideoMetaListWrap。
  VideoMetaListWrap();

  /// 创建 VideoMetaListWrap。
  factory VideoMetaListWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoMetaListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoMetaListWrapToJson(this);
}

/// VideoWrap。
@JsonSerializable()
class VideoWrap {
  /// type。
  int? type;

  /// displayed。
  bool? displayed;

  /// alg。
  String? alg;

  /// extAlg。
  String? extAlg;

  /// data。
  late Video data;

  /// 创建 VideoWrap。
  VideoWrap();

  /// 创建 VideoWrap。
  factory VideoWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoWrapToJson(this);
}

/// VideoListWrapX。
@JsonSerializable()
class VideoListWrapX extends ServerStatusListBean {
  /// datas。
  List<VideoWrap>? datas;

  /// rcmdLimit。
  int? rcmdLimit;

  /// 创建 VideoListWrapX。
  VideoListWrapX();

  /// 创建 VideoListWrapX。
  factory VideoListWrapX.fromJson(Map<String, dynamic> json) =>
      _$VideoListWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoListWrapXToJson(this);
}

/// VideoListWrap。
@JsonSerializable()
class VideoListWrap extends ServerStatusBean {
  /// data。
  List<Video2>? data;

  /// 创建 VideoListWrap。
  VideoListWrap();

  /// 创建 VideoListWrap。
  factory VideoListWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoListWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoListWrapToJson(this);
}

/// VideoDetailWrap。
@JsonSerializable()
class VideoDetailWrap extends ServerStatusBean {
  /// data。
  late Video data;

  /// 创建 VideoDetailWrap。
  VideoDetailWrap();

  /// 创建 VideoDetailWrap。
  factory VideoDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoDetailWrapToJson(this);
}

/// VideoDetailInfoWrap。
@JsonSerializable()
class VideoDetailInfoWrap extends ServerStatusBean {
  /// likedCount。
  int? likedCount;

  /// shareCount。
  int? shareCount;

  /// commentCount。
  int? commentCount;

  /// liked。
  bool? liked;

  /// 创建 VideoDetailInfoWrap。
  VideoDetailInfoWrap();

  /// 创建 VideoDetailInfoWrap。
  factory VideoDetailInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailInfoWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoDetailInfoWrapToJson(this);
}

/// VideoUrl。
@JsonSerializable()
class VideoUrl {
  /// id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// url。
  String? url;

  /// size。
  int? size;

  /// validityTime。
  int? validityTime;

  /// needPay。
  bool? needPay;

  /// r。
  int? r;

  /// 创建 VideoUrl。
  VideoUrl();

  /// 创建 VideoUrl。
  factory VideoUrl.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$VideoUrlToJson(this);
}

/// VideoUrlWrap。
@JsonSerializable()
class VideoUrlWrap extends ServerStatusBean {
  /// urls。
  List<VideoUrl>? urls;

  /// 创建 VideoUrlWrap。
  VideoUrlWrap();

  /// 创建 VideoUrlWrap。
  factory VideoUrlWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VideoUrlWrapToJson(this);
}
