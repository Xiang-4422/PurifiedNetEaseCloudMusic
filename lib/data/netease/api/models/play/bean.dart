// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import '../common/bean.dart';
import '../event/bean.dart';
import '../user/bean.dart';

part 'bean.g.dart';

@JsonSerializable()

/// 旧版歌曲音质文件信息。
class Music {
  /// 音频文件 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 音频名称。
  String? name;

  /// 文件大小。
  int? size;

  /// 文件扩展名。
  String? extension;

  /// 采样率。
  int? sr;

  /// DFS 文件 id。
  int? dfsId;

  /// 码率。
  int? bitrate;

  /// 播放时长。
  int? playTime;

  /// 音量增益。
  double? volumeDelta;

  /// 创建旧版歌曲音质文件信息。
  Music();

  /// 从 JSON 构建旧版歌曲音质文件信息。
  factory Music.fromJson(Map<String, dynamic> json) => _$MusicFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MusicToJson(this);
}

@JsonSerializable()

/// 新版歌曲音质文件摘要。
class Music2 {
  /// 音频码率。
  int? br;

  /// 文件 id。
  int? fid;

  /// 文件大小。
  int? size;

  /// 音量增益。
  double? vd;

  /// 创建新版歌曲音质文件摘要。
  Music2();

  /// 从 JSON 构建新版歌曲音质文件摘要。
  factory Music2.fromJson(Map<String, dynamic> json) => _$Music2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Music2ToJson(this);
}

@JsonSerializable()

/// 简单歌词文本。
class Lyrics {
  /// 歌词文本。
  String? txt;

  /// 创建简单歌词文本。
  Lyrics();

  /// 从 JSON 构建简单歌词文本。
  factory Lyrics.fromJson(Map<String, dynamic> json) => _$LyricsFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$LyricsToJson(this);
}

@JsonSerializable()

/// 歌词内容及版本信息。
class Lyrics2 {
  /// 歌词文本。
  String? lyric;

  /// 歌词版本号。
  int? version;

  /// 创建歌词内容。
  Lyrics2();

  /// 从 JSON 构建歌词内容。
  factory Lyrics2.fromJson(Map<String, dynamic> json) =>
      _$Lyrics2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Lyrics2ToJson(this);
}

@JsonSerializable()

/// 歌曲播放权限信息。
class Privilege {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 付费类型。
  int? fee;

  /// 支付状态。
  int? payed;

  /// 歌曲可用状态。
  int? st;

  /// 可播放码率。
  int? pl;

  /// 可下载码率。
  int? dl;

  /// 试听码率。
  int? sp;

  /// 云盘权限码。
  int? cp;

  /// 订阅权限码。
  int? subp;

  /// 是否为云盘歌曲。
  bool? cs;

  /// 最大码率。
  int? maxbr;

  /// 实际可播放码率。
  int? fl;

  /// 是否需要弹出提示。
  bool? toast;

  /// 权限标记位。
  int? flag;

  /// 是否预售。
  bool? preSell;

  /// 创建歌曲播放权限信息。
  Privilege();

  /// 从 JSON 构建歌曲播放权限信息。
  factory Privilege.fromJson(Map<String, dynamic> json) =>
      _$PrivilegeFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PrivilegeToJson(this);
}

@JsonSerializable()

/// 旧版歌曲详情数据。
class Song {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 歌曲名称。
  String? name;

  /// 版权 id。
  int? copyrightId;

  /// 碟片编号。
  String? disc;

  /// 曲目序号。
  int? no;

  /// 付费类型。
  int? fee;

  /// 歌曲状态。
  int? status;

  /// 是否已收藏。
  bool? starred;

  /// 收藏数量。
  int? starredNum;

  /// 热度。
  double? popularity;

  /// 评分。
  int? score;

  /// 歌曲时长。
  int? duration;

  /// 播放次数。
  int? playedNum;

  /// 日播放次数。
  int? dayPlays;

  /// 收听时间。
  int? hearTime;

  /// 铃声地址。
  String? ringtone;

  /// 来源文案。
  String? copyFrom;

  /// 评论线程 id。
  String? commentThreadId;

  /// 歌手列表。
  List<Artist>? artists;

  /// 专辑信息。
  Album? album;

  /// 歌词数组或原始歌词结构，随接口返回变化。
  dynamic lyrics;

  /// 播放权限信息。
  Privilege? privilege;

  /// 版权状态。
  int? copyright;

  /// 翻译名称。
  String? transName;

  /// 歌曲标记。
  int? mark;

  /// 相关资源类型。
  int? rtype;

  /// MV id。
  int? mvid;

  /// 推荐算法标识。
  String? alg;

  /// 推荐理由。
  String? reason;

  /// 高音质文件信息。
  Music? hMusic;

  /// 中音质文件信息。
  Music? mMusic;

  /// 低音质文件信息。
  Music? lMusic;

  /// 基础音质文件信息。
  Music? bMusic;

  /// 创建旧版歌曲详情。
  Song();

  /// 从 JSON 构建旧版歌曲详情。
  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SongToJson(this);
}

@JsonSerializable()

/// 新版歌曲详情数据。
class Song2 {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 歌曲名称。
  String? name;

  /// 歌曲发布状态。
  int? pst;

  /// 歌曲类型。
  int? t;

  /// 歌手列表。
  List<Artist>? ar;

  /// 热度。
  double? pop;

  /// 歌曲状态。
  int? st;

  /// 铃声或关联文本。
  String? rt;

  /// 付费类型。
  int? fee;

  /// 版本号。
  int? v;

  /// 来源文案。
  String? cf;

  /// 专辑信息。
  Album? al;

  /// 歌曲时长。
  int? dt;

  /// 高音质文件摘要。
  Music2? h;

  /// 中音质文件摘要。
  Music2? m;

  /// 低音质文件摘要。
  Music2? l;

  /// 无损或附加音质文件摘要。
  Music2? a;

  /// 歌曲标记。
  int? mark;

  /// MV id。
  int? mv;

  /// 相关资源类型。
  int? rtype;

  /// 服务端状态位。
  int? mst;

  /// 版权状态。
  int? cp;

  /// 发布时间。
  int? publishTime;

  /// 推荐理由。
  String? reason;

  /// 播放权限信息。
  Privilege? privilege;

  /// 是否可播放。
  bool? available;

  /// 创建新版歌曲详情。
  Song2();

  /// 从 JSON 构建新版歌曲详情。
  factory Song2.fromJson(Map<String, dynamic> json) => _$Song2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Song2ToJson(this);
}

@JsonSerializable()

/// 歌曲详情响应。
class SongDetailWrap extends ServerStatusBean {
  /// 歌曲详情列表。
  List<Song2>? songs;

  /// 歌曲播放权限列表。
  List<Privilege>? privileges;

  /// 创建歌曲详情响应。
  SongDetailWrap();

  /// 从 JSON 构建歌曲详情响应。
  factory SongDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$SongDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SongDetailWrapToJson(this);
}

@JsonSerializable()

/// 歌曲播放地址信息。
class SongUrl {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 播放地址。
  String? url;

  /// 播放码率。
  int? br;

  /// 文件大小。
  int? size;

  /// 地址响应状态码。
  int? code;

  /// 地址过期时间。
  int? expi;

  /// 音量增益。
  double? gain;

  /// 付费类型。
  int? fee;

  /// 支付状态。
  int? payed;

  /// 权限标记位。
  int? flag;

  /// 是否可扩展到更高音质。
  bool? canExtend;

  /// 文件 md5。
  String? md5;

  /// 创建歌曲播放地址信息。
  SongUrl();

  /// 从 JSON 构建歌曲播放地址信息。
  factory SongUrl.fromJson(Map<String, dynamic> json) =>
      _$SongUrlFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SongUrlToJson(this);
}

@JsonSerializable()

/// 歌曲播放地址列表响应。
class SongUrlListWrap extends ServerStatusBean {
  /// 播放地址列表。
  List<SongUrl>? data;

  /// 创建歌曲播放地址列表响应。
  SongUrlListWrap();

  /// 从 JSON 构建歌曲播放地址列表响应。
  factory SongUrlListWrap.fromJson(Map<String, dynamic> json) =>
      _$SongUrlListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SongUrlListWrapToJson(this);
}

@JsonSerializable()

/// 歌曲歌词响应。
class SongLyricWrap extends ServerStatusBean {
  /// 是否包含逐字歌词。
  bool? sgc;

  /// 是否包含翻译歌词。
  bool? sfy;

  /// 是否包含逐字翻译。
  bool? qfy;

  /// 原文歌词。
  late Lyrics2 lrc;

  /// K 歌歌词。
  late Lyrics2 klyric;

  /// 翻译歌词。
  late Lyrics2 tlyric;

  /// 创建歌曲歌词响应。
  SongLyricWrap();

  /// 从 JSON 构建歌曲歌词响应。
  factory SongLyricWrap.fromJson(Map<String, dynamic> json) =>
      _$SongLyricWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SongLyricWrapToJson(this);
}

@JsonSerializable()

/// 旧版歌曲列表响应。
class SongListWrap extends ServerStatusBean {
  /// 歌曲列表。
  List<Song>? songs;

  /// 创建旧版歌曲列表响应。
  SongListWrap();

  /// 从 JSON 构建旧版歌曲列表响应。
  factory SongListWrap.fromJson(Map<String, dynamic> json) =>
      _$SongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SongListWrapToJson(this);
}

@JsonSerializable()

/// 使用 data 字段承载的旧版歌曲列表响应。
class SongListWrap2 extends ServerStatusBean {
  /// 歌曲列表。
  List<Song>? data;

  /// 创建 data 包装的歌曲列表响应。
  SongListWrap2();

  /// 从 JSON 构建 data 包装的歌曲列表响应。
  factory SongListWrap2.fromJson(Map<String, dynamic> json) =>
      _$SongListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SongListWrap2ToJson(this);
}

@JsonSerializable()

/// 私人推荐歌曲条目。
class PersonalizedSongItem {
  /// 推荐条目 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 推荐条目名称。
  String? name;

  /// 推荐封面地址。
  String? picUrl;

  /// 推荐文案。
  String? copywriter;

  /// 是否可点不感兴趣。
  bool? canDislike;

  /// 推荐算法标识。
  String? alg;

  /// 推荐类型。
  int? type;

  /// 推荐歌曲详情。
  late Song song;

  /// 创建私人推荐歌曲条目。
  PersonalizedSongItem();

  /// 从 JSON 构建私人推荐歌曲条目。
  factory PersonalizedSongItem.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedSongItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PersonalizedSongItemToJson(this);
}

@JsonSerializable()

/// 私人推荐歌曲列表响应。
class PersonalizedSongListWrap extends ServerStatusBean {
  /// 推荐歌曲条目列表。
  List<PersonalizedSongItem>? result;

  /// 推荐分类。
  int? category;

  /// 创建私人推荐歌曲列表响应。
  PersonalizedSongListWrap();

  /// 从 JSON 构建私人推荐歌曲列表响应。
  factory PersonalizedSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PersonalizedSongListWrapToJson(this);
}

@JsonSerializable()

/// 喜欢歌曲 id 列表响应。
class LikeSongListWrap extends ServerStatusBean {
  /// 服务端检查点。
  int? checkPoint;

  /// 喜欢歌曲 id 列表。
  late List<int> ids;

  /// 创建喜欢歌曲列表响应。
  LikeSongListWrap();

  /// 从 JSON 构建喜欢歌曲列表响应。
  factory LikeSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$LikeSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$LikeSongListWrapToJson(this);
}

@JsonSerializable()

/// 云盘歌曲条目。
class CloudSongItem {
  /// 云盘歌曲对应的简单歌曲信息。
  late Song2 simpleSong;

  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String songId;

  /// 歌曲名称。
  String? songName;

  /// 云盘文件名。
  String? fileName;

  /// 封面资源 id。
  int? cover;

  /// 文件大小。
  int? fileSize;

  /// 添加时间。
  late int addTime;

  /// 云盘文件版本号。
  int? version;

  /// 封面文件 id。
  String? coverId;

  /// 歌词文件 id。
  String? lyricId;

  /// 专辑名称。
  String? album;

  /// 歌手名称。
  String? artist;

  /// 上传文件码率。
  int? bitrate;

  /// 创建云盘歌曲条目。
  CloudSongItem();

  /// 从 JSON 构建云盘歌曲条目。
  factory CloudSongItem.fromJson(Map<String, dynamic> json) =>
      _$CloudSongItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$CloudSongItemToJson(this);
}

@JsonSerializable()

/// 云盘歌曲列表响应。
class CloudSongListWrap extends ServerStatusListBean {
  /// 已使用空间大小。
  String? size;

  /// 最大空间大小。
  String? maxSize;

  /// 扩容提示标识。
  int? upgradeSign;

  /// 云盘歌曲列表。
  List<CloudSongItem>? data;

  /// 创建云盘歌曲列表响应。
  CloudSongListWrap();

  /// 从 JSON 构建云盘歌曲列表响应。
  factory CloudSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$CloudSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$CloudSongListWrapToJson(this);
}

@JsonSerializable()

/// 每日推荐歌曲理由。
class RecommendSongReason {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  String? songId;

  /// 推荐理由文案。
  String? reason;

  /// 创建每日推荐歌曲理由。
  RecommendSongReason();

  /// 从 JSON 构建每日推荐歌曲理由。
  factory RecommendSongReason.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongReasonFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$RecommendSongReasonToJson(this);
}

@JsonSerializable()

/// 每日推荐歌曲数据。
class RecommendSongListWrap {
  /// 每日推荐歌曲列表。
  List<Song2>? dailySongs;

  /// 排序后的推荐歌曲列表。
  List<Song2>? orderSongs;

  /// 推荐理由列表。
  List<RecommendSongReason>? recommendReasons;

  /// 创建每日推荐歌曲数据。
  RecommendSongListWrap();

  /// 从 JSON 构建每日推荐歌曲数据。
  factory RecommendSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$RecommendSongListWrapToJson(this);
}

@JsonSerializable()

/// 每日推荐歌曲响应。
class RecommendSongListWrapX extends ServerStatusBean {
  /// 每日推荐歌曲数据。
  late RecommendSongListWrap data;

  /// 创建每日推荐歌曲响应。
  RecommendSongListWrapX();

  /// 从 JSON 构建每日推荐歌曲响应。
  factory RecommendSongListWrapX.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$RecommendSongListWrapXToJson(this);
}

@JsonSerializable()

/// 每日推荐历史数据。
class RecommendSongListHistoryWrap {
  /// 可查看历史日期列表。
  List<String>? dates;

  /// 购买入口地址。
  String? purchaseUrl;

  /// 历史推荐说明。
  String? description;

  /// 无历史记录提示文案。
  String? noHistoryMessage;

  /// 历史推荐歌曲列表。
  List<Song2>? songs;

  /// 创建每日推荐历史数据。
  RecommendSongListHistoryWrap();

  /// 从 JSON 构建每日推荐历史数据。
  factory RecommendSongListHistoryWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListHistoryWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$RecommendSongListHistoryWrapToJson(this);
}

@JsonSerializable()

/// 每日推荐历史响应。
class RecommendSongListHistoryWrapX extends ServerStatusBean {
  /// 每日推荐历史数据。
  late RecommendSongListHistoryWrap data;

  /// 创建每日推荐历史响应。
  RecommendSongListHistoryWrapX();

  /// 从 JSON 构建每日推荐历史响应。
  factory RecommendSongListHistoryWrapX.fromJson(Map<String, dynamic> json) =>
      _$RecommendSongListHistoryWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$RecommendSongListHistoryWrapXToJson(this);
}

@JsonSerializable()

/// 歌手歌曲列表响应。
class ArtistSongListWrap extends ServerStatusBean {
  /// 歌手歌曲列表。
  List<Song2>? songs;

  /// 创建歌手歌曲列表响应。
  ArtistSongListWrap();

  /// 从 JSON 构建歌手歌曲列表响应。
  factory ArtistSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistSongListWrapToJson(this);
}

@JsonSerializable()

/// 歌手新歌列表数据。
class ArtistNewSongListData {
  /// 是否还有更多新歌。
  bool? hasMore;

  /// 新歌总数。
  int? newSongCount;

  /// 新歌列表。
  List<Song2>? newWorks;

  /// 创建歌手新歌列表数据。
  ArtistNewSongListData();

  /// 从 JSON 构建歌手新歌列表数据。
  factory ArtistNewSongListData.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewSongListDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistNewSongListDataToJson(this);
}

@JsonSerializable()

/// 歌手新歌列表响应。
class ArtistNewSongListWrap extends ServerStatusBean {
  /// 歌手新歌列表数据。
  late ArtistNewSongListData data;

  /// 创建歌手新歌列表响应。
  ArtistNewSongListWrap();

  /// 从 JSON 构建歌手新歌列表响应。
  factory ArtistNewSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistNewSongListWrapToJson(this);
}

@JsonSerializable()

/// 歌手详情与热门歌曲响应。
class ArtistDetailAndSongListWrap extends ServerStatusBean {
  /// 热门歌曲列表。
  List<Song2>? hotSongs;

  /// 歌手信息。
  late Artist artist;

  /// 创建歌手详情与热门歌曲响应。
  ArtistDetailAndSongListWrap();

  /// 从 JSON 构建歌手详情与热门歌曲响应。
  factory ArtistDetailAndSongListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailAndSongListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistDetailAndSongListWrapToJson(this);
}

@JsonSerializable()

/// 歌单详情数据。
class PlayList {
  /// 歌单 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 创建者用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 歌单名称。
  String? name;

  /// 歌单描述。
  String? description;

  /// 歌单封面地址。
  String? coverImgUrl;

  /// 歌单图片地址。
  String? picUrl;

  /// 单个标签。
  String? tag;

  /// 标签列表。
  List<String>? tags;

  /// 推荐文案。
  String? copywriter;

  /// 创建时间。
  int? createTime;

  /// 更新时间。
  int? updateTime;

  /// 播放次数。
  @JsonKey(fromJson: dynamicToInt)
  int? playCount;

  /// 订阅数量。
  int? subscribedCount;

  /// 分享数量。
  int? shareCount;

  /// 评论数量。
  int? commentCount;

  /// 当前用户是否已订阅。
  bool? subscribed;

  /// 歌曲数量。
  int? trackCount;

  /// 歌曲数量更新时间。
  int? trackNumberUpdateTime;

  /// 评论线程 id。
  String? commentThreadId;

  /// 推荐算法标识。
  String? alg;

  /// 歌单特殊类型，例如 5 表示我喜欢的音乐。
  int? specialType;

  /// 创建者用户信息。
  NeteaseUserInfo? creator;

  /// 订阅用户列表。
  List<NeteaseUserInfo>? subscribers;

  /// 歌单歌曲列表。
  List<PlayTrack>? tracks;

  /// 歌单歌曲 id 列表。
  List<PlayTrackId>? trackIds;

  /// 创建歌单详情数据。
  PlayList();

  /// 返回用于日志调试的歌单摘要。
  @override
  String toString() {
    return 'Play{id: $id, name: $name}';
  }

  /// 从 JSON 构建歌单详情数据。
  factory PlayList.fromJson(Map<String, dynamic> json) =>
      _$PlayListFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlayListToJson(this);
}

@JsonSerializable()

/// 歌单歌曲条目。
class PlayTrack {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 歌曲名称。
  String? name;

  /// 发布状态。
  int? pst;

  /// 歌曲类型。
  int? t;

  /// 歌手列表。
  List<Artist>? ar;

  /// 热度。
  double? pop;

  /// 歌曲状态。
  int? st;

  /// 铃声或关联文本。
  String? rt;

  /// 付费类型。
  int? fee;

  /// 版本号。
  int? v;

  /// 来源文案。
  String? cf;

  /// 专辑信息。
  late Album al;

  /// 歌曲时长。
  int? dt;

  /// 高音质文件摘要。
  Music2? h;

  /// 中音质文件摘要。
  Music2? m;

  /// 低音质文件摘要。
  Music2? l;

  /// 无损或附加音质文件摘要。
  Music2? a;

  /// 碟片编号。
  String? cd;

  /// 曲目序号。
  int? no;

  /// 文件类型。
  int? ftype;

  /// 铃声地址列表。
  List<dynamic>? rtUrls;

  /// DJ 节目 id。
  int? djId;

  /// 版权状态。
  int? copyright;

  /// 服务端歌曲 id 别名字段。
  int? s_id;

  /// 歌曲标记。
  int? mark;

  /// 原始封面类型。
  int? originCoverType;

  /// 是否单曲。
  int? single;

  /// 相关资源类型。
  int? rtype;

  /// 服务端状态位。
  int? mst;

  /// 版权状态码。
  int? cp;

  /// MV id。
  int? mv;

  /// 发布时间。
  int? publishTime;

  /// 创建歌单歌曲条目。
  PlayTrack();

  /// 从 JSON 构建歌单歌曲条目。
  factory PlayTrack.fromJson(Map<String, dynamic> json) =>
      _$PlayTrackFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlayTrackToJson(this);
}

@JsonSerializable()

/// 歌单歌曲 id 条目。
class PlayTrackId {
  /// 歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 歌曲版本号。
  int? v;

  /// 添加时间。
  int? t;

  /// 添加者或添加时间字段。
  int? at;

  /// 最近播放或歌词字段。
  int? lr;

  /// 创建歌单歌曲 id 条目。
  PlayTrackId();

  /// 从 JSON 构建歌单歌曲 id 条目。
  factory PlayTrackId.fromJson(Map<String, dynamic> json) =>
      _$PlayTrackIdFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlayTrackIdToJson(this);
}

@JsonSerializable()

/// 多歌单列表响应。
class MultiPlayListWrap extends ServerStatusBean {
  /// 歌单列表。
  List<PlayList>? playlists;

  /// 创建多歌单列表响应。
  MultiPlayListWrap();

  /// 从 JSON 构建多歌单列表响应。
  factory MultiPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$MultiPlayListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MultiPlayListWrapToJson(this);
}

@JsonSerializable()

/// 另一种多歌单列表响应。
class MultiPlayListWrap2 extends ServerStatusBean {
  /// 歌单列表。
  @JsonKey(name: 'playlist')
  List<PlayList>? playlists;

  /// 创建多歌单列表响应。
  MultiPlayListWrap2();

  /// 从 JSON 构建多歌单列表响应。
  factory MultiPlayListWrap2.fromJson(Map<String, dynamic> json) =>
      _$MultiPlayListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MultiPlayListWrap2ToJson(this);
}

@JsonSerializable()

/// 推荐歌单列表响应。
class RecommendPlayListWrap extends ServerStatusBean {
  /// 推荐歌单列表。
  List<PlayList>? recommend;

  /// 是否优先展示特色内容。
  bool? featureFirst;

  /// 是否包含推荐歌曲。
  bool? haveRcmdSongs;

  /// 创建推荐歌单列表响应。
  RecommendPlayListWrap();

  /// 从 JSON 构建推荐歌单列表响应。
  factory RecommendPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$RecommendPlayListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$RecommendPlayListWrapToJson(this);
}

@JsonSerializable()

/// 个性化推荐歌单列表响应。
class PersonalizedPlayListWrap extends ServerStatusBean {
  /// 个性化歌单列表。
  List<PlayList>? result;

  /// 是否已有口味画像。
  bool? hasTaste;

  /// 推荐分类。
  int? category;

  /// 创建个性化推荐歌单列表响应。
  PersonalizedPlayListWrap();

  /// 从 JSON 构建个性化推荐歌单列表响应。
  factory PersonalizedPlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedPlayListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PersonalizedPlayListWrapToJson(this);
}

@JsonSerializable()

/// 歌单分类条目。
class PlaylistCatalogueItem {
  /// 分类名称。
  String? name;

  /// 分类下资源数量。
  int? resourceCount;

  /// 分类图片地址。
  String? imgUrl;

  /// 分类类型。
  int? type;

  /// 分类分组。
  int? category;

  /// 资源类型。
  int? resourceType;

  /// 是否热门分类。
  bool? hot;

  /// 是否活动分类。
  bool? activity;

  /// 创建歌单分类条目。
  PlaylistCatalogueItem();

  /// 从 JSON 构建歌单分类条目。
  factory PlaylistCatalogueItem.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCatalogueItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlaylistCatalogueItemToJson(this);
}

@JsonSerializable()

/// 歌单分类响应。
class PlaylistCatalogueWrap extends ServerStatusBean {
  /// 全部歌单分类。
  PlaylistCatalogueItem? all;

  /// 子分类列表。
  List<PlaylistCatalogueItem>? sub;

  /// 分类分组名称映射。
  Map<int, String>? categories;

  /// 创建歌单分类响应。
  PlaylistCatalogueWrap();

  /// 从 JSON 构建歌单分类响应。
  factory PlaylistCatalogueWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistCatalogueWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlaylistCatalogueWrapToJson(this);
}

@JsonSerializable()

/// 热门歌单标签详情。
class PlaylistHotTag {
  /// 标签 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 标签名称。
  String? name;

  /// 标签分类。
  int? category;

  /// 使用次数。
  int? usedCount;

  /// 标签类型。
  int? type;

  /// 标签位置。
  int? position;

  /// 是否高品质标签。
  int? highQuality;

  /// 高品质位置。
  int? highQualityPos;

  /// 官方位置。
  int? officialPos;

  /// 创建时间。
  int? createTime;

  /// 创建热门歌单标签详情。
  PlaylistHotTag();

  /// 从 JSON 构建热门歌单标签详情。
  factory PlaylistHotTag.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlaylistHotTagToJson(this);
}

@JsonSerializable()

/// 热门歌单标签条目。
class PlaylistHotTagsItem {
  /// 标签 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 标签名称。
  String? name;

  /// 是否活动标签。
  bool? activity;

  /// 是否热门标签。
  bool? hot;

  /// 标签位置。
  int? position;

  /// 标签分类。
  int? category;

  /// 创建时间。
  int? createTime;

  /// 标签类型。
  int? type;

  /// 标签详情。
  PlaylistHotTag? playlistTag;

  /// 创建热门歌单标签条目。
  PlaylistHotTagsItem();

  /// 从 JSON 构建热门歌单标签条目。
  factory PlaylistHotTagsItem.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagsItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlaylistHotTagsItemToJson(this);
}

@JsonSerializable()

/// 热门歌单标签列表响应。
class PlaylistHotTagsWrap extends ServerStatusBean {
  /// 热门标签列表。
  List<PlaylistHotTagsItem>? tags;

  /// 创建热门歌单标签列表响应。
  PlaylistHotTagsWrap();

  /// 从 JSON 构建热门歌单标签列表响应。
  factory PlaylistHotTagsWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaylistHotTagsWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlaylistHotTagsWrapToJson(this);
}

/// 内置榜单歌单分类列表。
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

@JsonSerializable()

/// 单个歌单详情响应。
class SinglePlayListWrap extends ServerStatusBean {
  /// 歌单详情。
  PlayList? playlist;

  /// 创建单个歌单详情响应。
  SinglePlayListWrap();

  /// 从 JSON 构建单个歌单详情响应。
  factory SinglePlayListWrap.fromJson(Map<String, dynamic> json) =>
      _$SinglePlayListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SinglePlayListWrapToJson(this);
}

@JsonSerializable()

/// 歌单动态统计响应。
class PlayListDetailDynamicWrap extends ServerStatusBean {
  /// 评论数量。
  int? commentCount;

  /// 分享数量。
  int? shareCount;

  /// 播放数量。
  int? playCount;

  /// 预订或收藏数量。
  int? bookedCount;

  /// 当前用户是否已订阅。
  bool? subscribed;

  /// 备注名称。
  String? remarkName;

  /// 当前用户是否已关注创建者。
  bool? followed;

  /// 创建歌单动态统计响应。
  PlayListDetailDynamicWrap();

  /// 从 JSON 构建歌单动态统计响应。
  factory PlayListDetailDynamicWrap.fromJson(Map<String, dynamic> json) =>
      _$PlayListDetailDynamicWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlayListDetailDynamicWrapToJson(this);
}

@JsonSerializable()

/// 心动模式推荐歌曲条目。
class PlaymodeIntelligenceItem {
  /// 推荐歌曲 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 是否为推荐结果。
  bool? recommended;

  /// 推荐算法标识。
  String? alg;

  /// 推荐歌曲详情。
  Song2? songInfo;

  /// 创建心动模式推荐歌曲条目。
  PlaymodeIntelligenceItem();

  /// 从 JSON 构建心动模式推荐歌曲条目。
  factory PlaymodeIntelligenceItem.fromJson(Map<String, dynamic> json) =>
      _$PlaymodeIntelligenceItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$PlaymodeIntelligenceItemToJson(this);
}

@JsonSerializable()

/// 心动模式推荐歌曲列表响应。
class PlaymodeIntelligenceListWrap extends ServerStatusBean {
  /// 心动模式推荐歌曲列表。
  List<PlaymodeIntelligenceItem>? data;

  /// 创建心动模式推荐歌曲列表响应。
  PlaymodeIntelligenceListWrap();

  /// 从 JSON 构建心动模式推荐歌曲列表响应。
  factory PlaymodeIntelligenceListWrap.fromJson(Map<String, dynamic> json) =>
      _$PlaymodeIntelligenceListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PlaymodeIntelligenceListWrapToJson(this);
}

@JsonSerializable()

/// 歌手信息。
class Artist {
  /// 歌手 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 歌手账号 id。
  @JsonKey(fromJson: dynamicToString)
  String? accountId;

  /// 歌手名称。
  String? name;

  /// 歌手图片地址。
  String? picUrl;

  /// 1v1 头像资源 id。
  int? img1v1Id;

  /// 1v1 头像地址。
  String? img1v1Url;

  /// 歌手封面地址。
  String? cover;

  /// 专辑数量。
  int? albumSize;

  /// 歌曲数量。
  int? musicSize;

  /// MV 数量。
  int? mvSize;

  /// 话题人数。
  int? topicPerson;

  /// 翻译名称。
  String? trans;

  /// 简介。
  String? briefDesc;

  /// 当前用户是否已关注。
  bool? followed;

  /// 发布时间。
  int? publishTime;

  /// 创建歌手信息。
  Artist();

  /// 从 JSON 构建歌手信息。
  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable()

/// 歌手列表响应。
class ArtistsListWrap extends ServerStatusBean {
  /// 歌手列表。
  List<Artist>? artists;

  /// 创建歌手列表响应。
  ArtistsListWrap();

  /// 从 JSON 构建歌手列表响应。
  factory ArtistsListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistsListWrapToJson(this);
}

@JsonSerializable()

/// 歌手榜列表数据。
class ArtistsTopListWrap {
  /// 歌手列表。
  List<Artist>? artists;

  /// 榜单类型。
  int? type;

  /// 更新时间。
  int? updateTime;

  /// 创建歌手榜列表数据。
  ArtistsTopListWrap();

  /// 从 JSON 构建歌手榜列表数据。
  factory ArtistsTopListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistsTopListWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistsTopListWrapToJson(this);
}

@JsonSerializable()

/// 歌手榜列表响应。
class ArtistsTopListWrapX extends ServerStatusBean {
  /// 歌手榜列表数据。
  ArtistsTopListWrap? list;

  /// 创建歌手榜列表响应。
  ArtistsTopListWrapX();

  /// 从 JSON 构建歌手榜列表响应。
  factory ArtistsTopListWrapX.fromJson(Map<String, dynamic> json) =>
      _$ArtistsTopListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistsTopListWrapXToJson(this);
}

@JsonSerializable()

/// 歌手介绍片段。
class ArtistIntroduction {
  /// 介绍标题。
  String? ti;

  /// 介绍正文。
  String? txt;

  /// 创建歌手介绍片段。
  ArtistIntroduction();

  /// 从 JSON 构建歌手介绍片段。
  factory ArtistIntroduction.fromJson(Map<String, dynamic> json) =>
      _$ArtistIntroductionFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistIntroductionToJson(this);
}

@JsonSerializable()

/// 歌手描述响应。
class ArtistDescWrap extends ServerStatusBean {
  /// 分段介绍列表。
  List<ArtistIntroduction>? introduction;

  /// 简介。
  String? briefDesc;

  /// 介绍数量。
  int? count;

  /// 相关话题数据。
  List<TopicItem2>? topicData;

  /// 创建歌手描述响应。
  ArtistDescWrap();

  /// 从 JSON 构建歌手描述响应。
  factory ArtistDescWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDescWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistDescWrapToJson(this);
}

@JsonSerializable()

/// 歌手详情数据。
class ArtistDetailData {
  /// 是否在黑名单中。
  bool? blacklist;

  /// 是否展示私信入口。
  bool? showPriMsg;

  /// 视频数量。
  int? videoCount;

  /// 歌手信息。
  Artist? artist;

  /// 创建歌手详情数据。
  ArtistDetailData();

  /// 从 JSON 构建歌手详情数据。
  factory ArtistDetailData.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistDetailDataToJson(this);
}

@JsonSerializable()

/// 歌手详情响应。
class ArtistDetailWrap extends ServerStatusBean {
  /// 歌手详情数据。
  ArtistDetailData? data;

  /// 创建歌手详情响应。
  ArtistDetailWrap();

  /// 从 JSON 构建歌手详情响应。
  factory ArtistDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistDetailWrapToJson(this);
}

@JsonSerializable()

/// 专辑信息。
class Album {
  /// 专辑 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 专辑名称。
  String? name;

  /// 专辑类型。
  String? type;

  /// 专辑子类型。
  String? subType;

  /// 专辑标记。
  int? mark;

  /// 歌曲数量或资源大小。
  int? size;

  /// 发布时间。
  int? publishTime;

  /// 专辑封面地址。
  String? picUrl;

  /// 专辑标签。
  String? tags;

  /// 版权 id。
  int? copyrightId;

  /// 唱片公司 id。
  int? companyId;

  /// 唱片公司名称。
  String? company;

  /// 专辑描述。
  String? description;

  /// 简介。
  String? briefDesc;

  /// 主歌手信息。
  Artist? artist;

  /// 歌手列表。
  List<Artist>? artists;

  /// 当前用户是否已收藏。
  bool? isSub;

  /// 是否已付费。
  bool? paid;

  /// 是否在售。
  bool? onSale;

  /// 创建专辑信息。
  Album();

  /// 从 JSON 构建专辑信息。
  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()

/// 专辑详情响应。
class AlbumDetailWrap extends ServerStatusBean {
  /// 专辑歌曲列表。
  List<Song2>? songs;

  /// 专辑信息。
  Album? album;

  /// 创建专辑详情响应。
  AlbumDetailWrap();

  /// 从 JSON 构建专辑详情响应。
  factory AlbumDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AlbumDetailWrapToJson(this);
}

@JsonSerializable()

/// 专辑动态统计响应。
class AlbumDetailDynamicWrap extends ServerStatusBean {
  /// 是否在售。
  bool? onSale;

  /// 当前用户是否已收藏。
  bool? isSub;

  /// 收藏时间。
  int? subTime;

  /// 评论数量。
  int? commentCount;

  /// 点赞数量。
  int? likedCount;

  /// 分享数量。
  int? shareCount;

  /// 收藏数量。
  int? subCount;

  /// 创建专辑动态统计响应。
  AlbumDetailDynamicWrap();

  /// 从 JSON 构建专辑动态统计响应。
  factory AlbumDetailDynamicWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumDetailDynamicWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AlbumDetailDynamicWrapToJson(this);
}

@JsonSerializable()

/// 专辑列表响应。
class AlbumListWrap extends ServerStatusListBean {
  /// 专辑列表。
  List<Album>? albums;

  /// 创建专辑列表响应。
  AlbumListWrap();

  /// 从 JSON 构建专辑列表响应。
  factory AlbumListWrap.fromJson(Map<String, dynamic> json) =>
      _$AlbumListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$AlbumListWrapToJson(this);
}

@JsonSerializable()

/// 歌手专辑列表响应。
class ArtistAlbumListWrap extends ServerStatusListBean {
  /// 下一页时间游标。
  int? time;

  /// 热门专辑列表。
  List<Album>? hotAlbums;

  /// 歌手信息。
  late Artist artist;

  /// 创建歌手专辑列表响应。
  ArtistAlbumListWrap();

  /// 从 JSON 构建歌手专辑列表响应。
  factory ArtistAlbumListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistAlbumListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistAlbumListWrapToJson(this);
}

@JsonSerializable()

/// MV 创建者信息。
class MvCreator {
  /// 创建者用户 id。
  @JsonKey(fromJson: dynamicToString)
  String? userId;

  /// 创建者用户名。
  String? userName;

  /// 创建 MV 创建者信息。
  MvCreator();

  /// 从 JSON 构建 MV 创建者信息。
  factory MvCreator.fromJson(Map<String, dynamic> json) =>
      _$MvCreatorFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MvCreatorToJson(this);
}

@JsonSerializable()

/// MV 信息。
class Mv {
  /// MV id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// MV 名称。
  String? name;

  /// MV 封面地址。
  String? cover;

  /// 播放次数。
  int? playCount;

  /// 简介。
  String? briefDesc;

  /// 描述。
  String? desc;

  /// 歌手翻译名称。
  String? arTransName;

  /// 歌手别名。
  String? artisAlias;

  /// 歌手翻译名。
  String? artisTransName;

  /// 歌手名称。
  String? artistName;

  /// 歌手图片地址。
  String? artistImgUrl;

  /// 歌手 id。
  int? artistId;

  /// MV id 的兼容字段。
  int? mvId;

  /// MV 名称兼容字段。
  String? mvName;

  /// MV 封面兼容字段。
  String? mvCoverUrl;

  /// MV 时长。
  int? duration;

  /// 发布时间。
  @JsonKey(fromJson: dynamicToString)
  String? publishTime;

  /// 发布日期文案。
  String? publishDate;

  /// MV 标记。
  int? mark;

  /// 推荐算法标识。
  String? alg;

  /// 关联歌手列表。
  List<Artist>? artists;

  /// 创建 MV 信息。
  Mv();

  /// 从 JSON 构建 MV 信息。
  factory Mv.fromJson(Map<String, dynamic> json) => _$MvFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MvToJson(this);
}

@JsonSerializable()

/// 视频流中的 MV 摘要。
class Mv2 {
  /// 条目类型。
  int? type;

  /// 标题。
  String? title;

  /// 时长，单位毫秒。
  int? durationms;

  /// 播放次数。
  int? playTime;

  /// 视频 id。
  String? vid;

  /// 封面地址。
  String? coverUrl;

  /// 别名。
  String? aliaName;

  /// 翻译名称。
  String? transName;

  /// 创建者列表。
  List<MvCreator>? creator;

  /// 创建视频流 MV 摘要。
  Mv2();

  /// 从 JSON 构建视频流 MV 摘要。
  factory Mv2.fromJson(Map<String, dynamic> json) => _$Mv2FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Mv2ToJson(this);
}

@JsonSerializable()

/// 私信等场景使用的 MV 摘要。
class Mv3 {
  /// MV id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// MV 名称。
  String? name;

  /// 歌手名称。
  String? artistName;

  /// 方形封面地址。
  late String imgurl;

  /// 16:9 封面地址。
  late String imgurl16v9;

  /// MV 状态。
  int? status;

  /// 歌手信息。
  late Artist artist;

  /// 创建 MV 摘要。
  Mv3();

  /// 从 JSON 构建 MV 摘要。
  factory Mv3.fromJson(Map<String, dynamic> json) => _$Mv3FromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$Mv3ToJson(this);
}

@JsonSerializable()

/// MV 列表响应。
class MvListWrap extends ServerStatusListBean {
  /// MV 列表。
  List<Mv>? mvs;

  /// 创建 MV 列表响应。
  MvListWrap();

  /// 从 JSON 构建 MV 列表响应。
  factory MvListWrap.fromJson(Map<String, dynamic> json) =>
      _$MvListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvListWrapToJson(this);
}

@JsonSerializable()

/// 使用 data 字段承载的 MV 列表响应。
class MvListWrap2 extends ServerStatusListBean {
  /// MV 列表。
  List<Mv>? data;

  /// 更新时间。
  int? updateTime;

  /// 创建 data 包装的 MV 列表响应。
  MvListWrap2();

  /// 从 JSON 构建 data 包装的 MV 列表响应。
  factory MvListWrap2.fromJson(Map<String, dynamic> json) =>
      _$MvListWrap2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvListWrap2ToJson(this);
}

@JsonSerializable()

/// 个性化 MV 列表响应。
class PersonalizedMvListWrap extends ServerStatusBean {
  /// 个性化 MV 列表。
  List<Mv>? result;

  /// 推荐分类。
  int? category;

  /// 创建个性化 MV 列表响应。
  PersonalizedMvListWrap();

  /// 从 JSON 构建个性化 MV 列表响应。
  factory PersonalizedMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$PersonalizedMvListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$PersonalizedMvListWrapToJson(this);
}

@JsonSerializable()

/// 歌手 MV 列表响应。
class ArtistMvListWrap extends MvListWrap {
  /// 下一页时间游标。
  int? time;

  /// 创建歌手 MV 列表响应。
  ArtistMvListWrap();

  /// 从 JSON 构建歌手 MV 列表响应。
  factory ArtistMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistMvListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistMvListWrapToJson(this);
}

@JsonSerializable()

/// 歌手新 MV 列表数据。
class ArtistNewMvListData {
  /// 是否还有更多新 MV。
  bool? hasMore;

  /// 新 MV 列表。
  List<Mv>? newWorks;

  /// 创建歌手新 MV 列表数据。
  ArtistNewMvListData();

  /// 从 JSON 构建歌手新 MV 列表数据。
  factory ArtistNewMvListData.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewMvListDataFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$ArtistNewMvListDataToJson(this);
}

@JsonSerializable()

/// 歌手新 MV 列表响应。
class ArtistNewMvListWrap extends ServerStatusBean {
  /// 歌手新 MV 列表数据。
  late ArtistNewMvListData data;

  /// 创建歌手新 MV 列表响应。
  ArtistNewMvListWrap();

  /// 从 JSON 构建歌手新 MV 列表响应。
  factory ArtistNewMvListWrap.fromJson(Map<String, dynamic> json) =>
      _$ArtistNewMvListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$ArtistNewMvListWrapToJson(this);
}

@JsonSerializable()

/// MV 详情响应。
class MvDetailWrap extends ServerStatusBean {
  /// 加载占位图。
  String? loadingPic;

  /// 缓冲占位图。
  String? bufferPic;

  /// 全屏加载占位图。
  String? loadingPicFS;

  /// 全屏缓冲占位图。
  String? bufferPicFS;

  /// 当前用户是否已收藏。
  bool? subed;

  /// MV 详情。
  Mv? data;

  /// 创建 MV 详情响应。
  MvDetailWrap();

  /// 从 JSON 构建 MV 详情响应。
  factory MvDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$MvDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvDetailWrapToJson(this);
}

@JsonSerializable()

/// MV 动态统计响应。
class MvDetailInfoWrap extends ServerStatusBean {
  /// 点赞数量。
  int? likedCount;

  /// 分享数量。
  int? shareCount;

  /// 评论数量。
  int? commentCount;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 创建 MV 动态统计响应。
  MvDetailInfoWrap();

  /// 从 JSON 构建 MV 动态统计响应。
  factory MvDetailInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$MvDetailInfoWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvDetailInfoWrapToJson(this);
}

@JsonSerializable()

/// MV 播放地址信息。
class MvUrl {
  /// MV id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 播放地址。
  String? url;

  /// 文件 md5。
  String? md5;

  /// 服务端提示消息。
  String? msg;

  /// 清晰度。
  int? r;

  /// 文件大小。
  int? size;

  /// 地址过期时间。
  int? expi;

  /// 付费类型。
  int? fee;

  /// MV 付费类型。
  int? mvFee;

  /// 地址状态。
  int? st;

  /// 创建 MV 播放地址信息。
  MvUrl();

  /// 从 JSON 构建 MV 播放地址信息。
  factory MvUrl.fromJson(Map<String, dynamic> json) => _$MvUrlFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$MvUrlToJson(this);
}

@JsonSerializable()

/// MV 播放地址响应。
class MvUrlWrap extends ServerStatusBean {
  /// MV 播放地址信息。
  late MvUrl data;

  /// 创建 MV 播放地址响应。
  MvUrlWrap();

  /// 从 JSON 构建 MV 播放地址响应。
  factory MvUrlWrap.fromJson(Map<String, dynamic> json) =>
      _$MvUrlWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$MvUrlWrapToJson(this);
}

@JsonSerializable()

/// 视频清晰度信息。
class VideoResolution {
  /// 清晰度数值。
  int? resolution;

  /// 对应文件大小。
  int? size;

  /// 创建视频清晰度信息。
  VideoResolution();

  /// 从 JSON 构建视频清晰度信息。
  factory VideoResolution.fromJson(Map<String, dynamic> json) =>
      _$VideoResolutionFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoResolutionToJson(this);
}

@JsonSerializable()

/// 视频播放地址详情。
class VideoUrlInfo {
  /// 视频 id。
  late String id;

  /// 播放地址。
  String? url;

  /// 文件大小。
  int? size;

  /// 有效时长。
  int? validityTime;

  /// 是否需要付费。
  bool? needPay;

  /// 清晰度。
  int? r;

  /// 创建视频播放地址详情。
  VideoUrlInfo();

  /// 从 JSON 构建视频播放地址详情。
  factory VideoUrlInfo.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlInfoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoUrlInfoToJson(this);
}

@JsonSerializable()

/// 视频基础信息。
class VideoBase {
  /// 视频 id。
  String? vid;

  /// 视频标题。
  String? title;

  /// 视频描述。
  String? description;

  /// 推荐追踪 scm 参数。
  String? scm;

  /// 推荐算法标识。
  String? alg;

  /// 评论线程 id。
  String? threadId;

  /// 封面地址。
  String? coverUrl;

  /// 预览地址。
  String? previewUrl;

  /// 视频宽度。
  int? width;

  /// 视频高度。
  int? height;

  /// 点赞数量。
  int? praisedCount;

  /// 播放次数。
  int? playTime;

  /// 视频时长，单位毫秒。
  int? durationms;

  /// 预览时长，单位毫秒。
  int? previewDurationms;

  /// 评论数量。
  int? commentCount;

  /// 分享数量。
  int? shareCount;

  /// 当前用户是否已点赞。
  bool? praised;

  /// 当前用户是否已订阅。
  bool? subscribed;

  /// 是否存在相关游戏广告。
  bool? hasRelatedGameAd;

  /// 可用清晰度列表。
  List<VideoResolution>? resolutions;

  /// 当前播放地址详情。
  VideoUrlInfo? urlInfo;

  /// 视频分组标签。
  List<VideoMetaItem>? videoGroup;

  /// 关联歌曲列表。
  List<Song>? relateSong;

  /// 创建视频基础信息。
  VideoBase();

  /// 从 JSON 构建视频基础信息。
  factory VideoBase.fromJson(Map<String, dynamic> json) =>
      _$VideoBaseFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoBaseToJson(this);
}

@JsonSerializable()

/// 单创建者视频信息。
class Video extends VideoBase {
  /// 视频创建者。
  late NeteaseUserInfo creator;

  /// 创建单创建者视频信息。
  Video();

  /// 从 JSON 构建单创建者视频信息。
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoToJson(this);
}

@JsonSerializable()

/// 多创建者视频信息。
class Video2 extends VideoBase {
  /// 视频创建者列表。
  List<NeteaseUserInfo>? creator;

  /// 创建多创建者视频信息。
  Video2();

  /// 从 JSON 构建多创建者视频信息。
  factory Video2.fromJson(Map<String, dynamic> json) => _$Video2FromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$Video2ToJson(this);
}

@JsonSerializable()

/// 视频分类或分组标签。
class VideoMetaItem {
  /// 标签 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 标签名称。
  String? name;

  /// 标签地址。
  String? url;

  /// 关联视频类型。
  String? relatedVideoType;

  /// 是否选中当前标签。
  bool? selectTab;

  /// 创建视频分类标签。
  VideoMetaItem();

  /// 从 JSON 构建视频分类标签。
  factory VideoMetaItem.fromJson(Map<String, dynamic> json) =>
      _$VideoMetaItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoMetaItemToJson(this);
}

@JsonSerializable()

/// 视频分类标签列表响应。
class VideoMetaListWrap extends ServerStatusBean {
  /// 视频分类标签列表。
  List<VideoMetaItem>? data;

  /// 创建视频分类标签列表响应。
  VideoMetaListWrap();

  /// 从 JSON 构建视频分类标签列表响应。
  factory VideoMetaListWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoMetaListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoMetaListWrapToJson(this);
}

@JsonSerializable()

/// 推荐视频包装条目。
class VideoWrap {
  /// 条目类型。
  int? type;

  /// 是否已展示。
  bool? displayed;

  /// 推荐算法标识。
  String? alg;

  /// 扩展推荐算法标识。
  String? extAlg;

  /// 视频详情。
  late Video data;

  /// 创建推荐视频包装条目。
  VideoWrap();

  /// 从 JSON 构建推荐视频包装条目。
  factory VideoWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoWrapToJson(this);
}

@JsonSerializable()

/// 推荐视频列表响应。
class VideoListWrapX extends ServerStatusListBean {
  /// 推荐视频包装条目列表。
  List<VideoWrap>? datas;

  /// 推荐限制数量。
  int? rcmdLimit;

  /// 创建推荐视频列表响应。
  VideoListWrapX();

  /// 从 JSON 构建推荐视频列表响应。
  factory VideoListWrapX.fromJson(Map<String, dynamic> json) =>
      _$VideoListWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoListWrapXToJson(this);
}

@JsonSerializable()

/// 视频列表响应。
class VideoListWrap extends ServerStatusBean {
  /// 视频列表。
  List<Video2>? data;

  /// 创建视频列表响应。
  VideoListWrap();

  /// 从 JSON 构建视频列表响应。
  factory VideoListWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoListWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoListWrapToJson(this);
}

@JsonSerializable()

/// 视频详情响应。
class VideoDetailWrap extends ServerStatusBean {
  /// 视频详情。
  late Video data;

  /// 创建视频详情响应。
  VideoDetailWrap();

  /// 从 JSON 构建视频详情响应。
  factory VideoDetailWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoDetailWrapToJson(this);
}

@JsonSerializable()

/// 视频动态统计响应。
class VideoDetailInfoWrap extends ServerStatusBean {
  /// 点赞数量。
  int? likedCount;

  /// 分享数量。
  int? shareCount;

  /// 评论数量。
  int? commentCount;

  /// 当前用户是否已点赞。
  bool? liked;

  /// 创建视频动态统计响应。
  VideoDetailInfoWrap();

  /// 从 JSON 构建视频动态统计响应。
  factory VideoDetailInfoWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailInfoWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoDetailInfoWrapToJson(this);
}

@JsonSerializable()

/// 视频播放地址信息。
class VideoUrl {
  /// 视频 id。
  @JsonKey(fromJson: dynamicToString)
  late String id;

  /// 播放地址。
  String? url;

  /// 文件大小。
  int? size;

  /// 有效时长。
  int? validityTime;

  /// 是否需要付费。
  bool? needPay;

  /// 清晰度。
  int? r;

  /// 创建视频播放地址信息。
  VideoUrl();

  /// 从 JSON 构建视频播放地址信息。
  factory VideoUrl.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$VideoUrlToJson(this);
}

@JsonSerializable()

/// 视频播放地址响应。
class VideoUrlWrap extends ServerStatusBean {
  /// 视频播放地址列表。
  List<VideoUrl>? urls;

  /// 创建视频播放地址响应。
  VideoUrlWrap();

  /// 从 JSON 构建视频播放地址响应。
  factory VideoUrlWrap.fromJson(Map<String, dynamic> json) =>
      _$VideoUrlWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$VideoUrlWrapToJson(this);
}
