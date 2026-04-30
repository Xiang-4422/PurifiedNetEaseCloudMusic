// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import '../../../src/api/bean.dart';
import '../../../src/api/dj/bean.dart';
import '../../../src/api/event/bean.dart';
import '../../../src/api/play/bean.dart';
import '../../../src/api/user/bean.dart';

part 'bean.g.dart';

/// 单曲搜索结果数据。
@JsonSerializable()
class SearchSongWrap {
  /// 匹配到的歌曲列表。
  late List<Song> songs;

  /// 创建单曲搜索结果数据。
  SearchSongWrap();

  /// 从 JSON 构建单曲搜索结果数据。
  factory SearchSongWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchSongWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchSongWrapToJson(this);
}

/// 单曲搜索响应。
@JsonSerializable()
class SearchSongWrapX extends ServerStatusBean {
  /// 单曲搜索结果数据。
  late SearchSongWrap result;

  /// 创建单曲搜索响应。
  SearchSongWrapX();

  /// 从 JSON 构建单曲搜索响应。
  factory SearchSongWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchSongWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchSongWrapXToJson(this);
}

/// 专辑搜索响应。
@JsonSerializable()
class SearchAlbumsWrapX extends ServerStatusBean {
  /// 专辑搜索结果数据。
  late AlbumListWrap result;

  /// 创建专辑搜索响应。
  SearchAlbumsWrapX();

  /// 从 JSON 构建专辑搜索响应。
  factory SearchAlbumsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchAlbumsWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchAlbumsWrapXToJson(this);
}

/// 歌手搜索结果数据。
@JsonSerializable()
class SearchArtistsWrap {
  /// 匹配到的歌手列表。
  late List<Artist> artists;

  /// 创建歌手搜索结果数据。
  SearchArtistsWrap();

  /// 从 JSON 构建歌手搜索结果数据。
  factory SearchArtistsWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchArtistsWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchArtistsWrapToJson(this);
}

/// 歌手搜索响应。
@JsonSerializable()
class SearchArtistsWrapX extends ServerStatusBean {
  /// 歌手搜索结果数据。
  late SearchArtistsWrap result;

  /// 创建歌手搜索响应。
  SearchArtistsWrapX();

  /// 从 JSON 构建歌手搜索响应。
  factory SearchArtistsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchArtistsWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchArtistsWrapXToJson(this);
}

/// 歌单搜索结果数据。
@JsonSerializable()
class SearchPlaylistWrap {
  /// 匹配到的歌单列表。
  late List<PlayList> playlists;

  /// 创建歌单搜索结果数据。
  SearchPlaylistWrap();

  /// 从 JSON 构建歌单搜索结果数据。
  factory SearchPlaylistWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchPlaylistWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchPlaylistWrapToJson(this);
}

/// 歌单搜索响应。
@JsonSerializable()
class SearchPlaylistWrapX extends ServerStatusBean {
  /// 歌单搜索结果数据。
  late SearchPlaylistWrap result;

  /// 创建歌单搜索响应。
  SearchPlaylistWrapX();

  /// 从 JSON 构建歌单搜索响应。
  factory SearchPlaylistWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchPlaylistWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchPlaylistWrapXToJson(this);
}

/// 用户搜索响应。
@JsonSerializable()
class SearchUserWrapX extends ServerStatusBean {
  /// 用户搜索结果数据。
  late UserListWrap result;

  /// 创建用户搜索响应。
  SearchUserWrapX();

  /// 从 JSON 构建用户搜索响应。
  factory SearchUserWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchUserWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchUserWrapXToJson(this);
}

/// MV 搜索响应。
@JsonSerializable()
class SearchMvWrapX extends ServerStatusBean {
  /// MV 搜索结果数据。
  late MvListWrap result;

  /// 创建 MV 搜索响应。
  SearchMvWrapX();

  /// 从 JSON 构建 MV 搜索响应。
  factory SearchMvWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchMvWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchMvWrapXToJson(this);
}

/// 歌词搜索结果数据。
@JsonSerializable()
class SearchLyricsWrap {
  /// 匹配到的歌曲列表。
  late List<Song> songs;

  /// 创建歌词搜索结果数据。
  SearchLyricsWrap();

  /// 从 JSON 构建歌词搜索结果数据。
  factory SearchLyricsWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchLyricsWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchLyricsWrapToJson(this);
}

/// 歌词搜索响应。
@JsonSerializable()
class SearchLyricsWrapX extends ServerStatusBean {
  /// 歌词搜索结果数据。
  late SearchLyricsWrap result;

  /// 创建歌词搜索响应。
  SearchLyricsWrapX();

  /// 从 JSON 构建歌词搜索响应。
  factory SearchLyricsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchLyricsWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchLyricsWrapXToJson(this);
}

/// 播客搜索结果数据。
@JsonSerializable()
class SearchDjradiorap {
  /// 匹配到的播客列表。
  late List<DjRadio> djRadios;

  /// 创建播客搜索结果数据。
  SearchDjradiorap();

  /// 从 JSON 构建播客搜索结果数据。
  factory SearchDjradiorap.fromJson(Map<String, dynamic> json) =>
      _$SearchDjradiorapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchDjradiorapToJson(this);
}

/// 播客搜索响应。
@JsonSerializable()
class SearchDjradioWrapX extends ServerStatusBean {
  /// 播客搜索结果数据。
  late SearchDjradiorap result;

  /// 创建播客搜索响应。
  SearchDjradioWrapX();

  /// 从 JSON 构建播客搜索响应。
  factory SearchDjradioWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchDjradioWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchDjradioWrapXToJson(this);
}

/// 视频搜索结果数据。
@JsonSerializable()
class SearchVideoWrap {
  /// 匹配到的视频列表。
  late List<Mv2> videos;

  /// 创建视频搜索结果数据。
  SearchVideoWrap();

  /// 从 JSON 构建视频搜索结果数据。
  factory SearchVideoWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchVideoWrapToJson(this);
}

/// 视频搜索响应。
@JsonSerializable()
class SearchVideoWrapX extends ServerStatusBean {
  /// 视频搜索结果数据。
  late SearchVideoWrap result;

  /// 创建视频搜索响应。
  SearchVideoWrapX();

  /// 从 JSON 构建视频搜索响应。
  factory SearchVideoWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchVideoWrapXToJson(this);
}

/// 综合搜索中的单曲模块。
@JsonSerializable()
class SearchComplexSong {
  /// 单曲列表。
  late List<Song2> songs;

  /// 更多结果入口文案。
  String? moreText;

  /// 高亮文案。
  String? highText;

  /// 是否还有更多单曲结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索单曲模块。
  SearchComplexSong();

  /// 从 JSON 构建综合搜索单曲模块。
  factory SearchComplexSong.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSongFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexSongToJson(this);
}

/// 综合搜索中的 Mlog 模块。
@JsonSerializable()
class SearchComplexMlog {
  /// Mlog 列表。
  late List<MyLog> mlogs;

  /// 更多结果入口文案。
  String? moreText;

  /// 是否还有更多 Mlog 结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索 Mlog 模块。
  SearchComplexMlog();

  /// 从 JSON 构建综合搜索 Mlog 模块。
  factory SearchComplexMlog.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexMlogFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexMlogToJson(this);
}

/// 综合搜索中的歌单模块。
@JsonSerializable()
class SearchComplexPlaylist {
  /// 歌单列表。
  late List<PlayList> playLists;

  /// 更多结果入口文案。
  String? moreText;

  /// 高亮文案。
  String? highText;

  /// 是否还有更多歌单结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索歌单模块。
  SearchComplexPlaylist();

  /// 从 JSON 构建综合搜索歌单模块。
  factory SearchComplexPlaylist.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexPlaylistFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexPlaylistToJson(this);
}

/// 综合搜索中的歌手模块。
@JsonSerializable()
class SearchComplexArtist {
  /// 歌手列表。
  late List<Artist> artists;

  /// 更多结果入口文案。
  String? moreText;

  /// 高亮文案。
  String? highText;

  /// 是否还有更多歌手结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索歌手模块。
  SearchComplexArtist();

  /// 从 JSON 构建综合搜索歌手模块。
  factory SearchComplexArtist.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexArtistFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexArtistToJson(this);
}

/// 综合搜索中的专辑模块。
@JsonSerializable()
class SearchComplexAlbum {
  /// 专辑列表。
  late List<Album> albums;

  /// 更多结果入口文案。
  String? moreText;

  /// 高亮文案。
  String? highText;

  /// 是否还有更多专辑结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索专辑模块。
  SearchComplexAlbum();

  /// 从 JSON 构建综合搜索专辑模块。
  factory SearchComplexAlbum.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexAlbumFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexAlbumToJson(this);
}

/// 综合搜索中的视频模块。
@JsonSerializable()
class SearchComplexVideo {
  /// 视频列表。
  late List<Video2> videos;

  /// 更多结果入口文案。
  String? moreText;

  /// 高亮文案。
  String? highText;

  /// 是否还有更多视频结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索视频模块。
  SearchComplexVideo();

  /// 从 JSON 构建综合搜索视频模块。
  factory SearchComplexVideo.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexVideoFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexVideoToJson(this);
}

/// 综合搜索中的相似搜索词条目。
@JsonSerializable()
class SearchComplexSimQueryItem {
  /// 推荐搜索词。
  String? keyword;

  /// 推荐算法标识。
  String? alg;

  /// 创建相似搜索词条目。
  SearchComplexSimQueryItem();

  /// 从 JSON 构建相似搜索词条目。
  factory SearchComplexSimQueryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSimQueryItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexSimQueryItemToJson(this);
}

/// 综合搜索中的相似搜索词模块。
@JsonSerializable()
class SearchComplexSimQuery {
  /// 相似搜索词列表。
  late List<SearchComplexSimQueryItem> sim_querys;

  /// 是否还有更多相似搜索词。
  bool? more;

  /// 创建相似搜索词模块。
  SearchComplexSimQuery();

  /// 从 JSON 构建相似搜索词模块。
  factory SearchComplexSimQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSimQueryFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexSimQueryToJson(this);
}

/// 综合搜索中的话题或用户讨论模块。
@JsonSerializable()
class SearchComplexTalk {
  /// 相关用户列表。
  List<NeteaseUserInfo>? users;

  /// 更多结果入口文案。
  String? moreText;

  /// 是否还有更多结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索讨论模块。
  SearchComplexTalk();

  /// 从 JSON 构建综合搜索讨论模块。
  factory SearchComplexTalk.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexTalkFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexTalkToJson(this);
}

/// 综合搜索中的用户模块。
@JsonSerializable()
class SearchComplexUser {
  /// 用户列表。
  late List<NeteaseUserInfo> users;

  /// 更多结果入口文案。
  String? moreText;

  /// 是否还有更多用户结果。
  bool? more;

  /// 资源 id 列表。
  late List<int> resourceIds;

  /// 创建综合搜索用户模块。
  SearchComplexUser();

  /// 从 JSON 构建综合搜索用户模块。
  factory SearchComplexUser.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexUserFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexUserToJson(this);
}

/// 综合搜索结果数据。
@JsonSerializable()
class SearchComplexWrap {
  /// 单曲模块。
  SearchComplexSong? song;

  /// Mlog 模块。
  SearchComplexMlog? mlog;

  /// 歌单模块。
  SearchComplexPlaylist? playList;

  /// 歌手模块。
  SearchComplexArtist? artist;

  /// 专辑模块。
  SearchComplexAlbum? album;

  /// 视频模块。
  SearchComplexVideo? video;

  /// 相似搜索词模块。
  SearchComplexSimQuery? sim_query;

  /// 讨论模块。
  SearchComplexTalk? talk;

  /// 用户模块。
  SearchComplexUser? user;

  /// 综合搜索模块展示顺序。
  List<String>? order;

  /// 创建综合搜索结果数据。
  SearchComplexWrap();

  /// 从 JSON 构建综合搜索结果数据。
  factory SearchComplexWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchComplexWrapToJson(this);
}

/// 综合搜索响应。
@JsonSerializable()
class SearchComplexWrapX extends ServerStatusBean {
  /// 综合搜索结果数据。
  late SearchComplexWrap result;

  /// 创建综合搜索响应。
  SearchComplexWrapX();

  /// 从 JSON 构建综合搜索响应。
  factory SearchComplexWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchComplexWrapXToJson(this);
}

/// 默认搜索关键词。
@JsonSerializable()
class SearchKey {
  /// 展示给用户的关键词。
  String? showKeyword;

  /// 点击动作类型。
  int? action;

  /// 实际搜索关键词。
  String? realkeyword;

  /// 搜索类型。
  int? searchType;

  /// 推荐算法标识。
  String? alg;

  /// 刷新间隔或展示间隔。
  int? gap;

  /// 创建默认搜索关键词。
  SearchKey();

  /// 从 JSON 构建默认搜索关键词。
  factory SearchKey.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchKeyToJson(this);
}

/// 默认搜索关键词响应。
@JsonSerializable()
class SearchKeyWrap extends ServerStatusBean {
  /// 默认搜索关键词数据。
  late SearchKey data;

  /// 创建默认搜索关键词响应。
  SearchKeyWrap();

  /// 从 JSON 构建默认搜索关键词响应。
  factory SearchKeyWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchKeyWrapToJson(this);
}

/// 简略热搜词条目。
@JsonSerializable()
class SearchHotKey {
  /// 热搜词文本。
  String? first;

  /// 热搜权重或排序值。
  int? second;

  /// 热搜图标类型。
  late int iconType;

  /// 创建简略热搜词条目。
  SearchHotKey();

  /// 从 JSON 构建简略热搜词条目。
  factory SearchHotKey.fromJson(Map<String, dynamic> json) =>
      _$SearchHotKeyFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchHotKeyToJson(this);
}

/// 简略热搜词列表数据。
@JsonSerializable()
class SearchHotKeyWrap {
  /// 热搜词列表。
  late List<SearchHotKey> hots;

  /// 创建简略热搜词列表数据。
  SearchHotKeyWrap();

  /// 从 JSON 构建简略热搜词列表数据。
  factory SearchHotKeyWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchHotKeyWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchHotKeyWrapToJson(this);
}

/// 简略热搜词响应。
@JsonSerializable()
class SearchKeyWrapX extends ServerStatusBean {
  /// 简略热搜词列表数据。
  late SearchHotKeyWrap result;

  /// 创建简略热搜词响应。
  SearchKeyWrapX();

  /// 从 JSON 构建简略热搜词响应。
  factory SearchKeyWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchKeyWrapXToJson(this);
}

/// 详细热搜词条目。
@JsonSerializable()
class SearchKeyDetailedItem {
  /// 热搜词。
  String? searchWord;

  /// 热搜说明内容。
  String? content;

  /// 热搜图标地址。
  String? iconUrl;

  /// 热搜跳转地址。
  String? url;

  /// 推荐算法标识。
  String? alg;

  /// 热搜分数。
  int? score;

  /// 热搜来源。
  int? source;

  /// 热搜图标类型。
  late int iconType;

  /// 创建详细热搜词条目。
  SearchKeyDetailedItem();

  /// 从 JSON 构建详细热搜词条目。
  factory SearchKeyDetailedItem.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyDetailedItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchKeyDetailedItemToJson(this);
}

/// 详细热搜词响应。
@JsonSerializable()
class SearchKeyDetailedWrap extends ServerStatusBean {
  /// 详细热搜词列表。
  late List<SearchKeyDetailedItem> data;

  /// 创建详细热搜词响应。
  SearchKeyDetailedWrap();

  /// 从 JSON 构建详细热搜词响应。
  factory SearchKeyDetailedWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyDetailedWrapFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchKeyDetailedWrapToJson(this);
}

/// 搜索建议条目。
@JsonSerializable()
class SearchSuggestItem {
  /// 建议关键词。
  String? keyword;

  /// 建议类型。
  int? type;

  /// 推荐算法标识。
  String? alg;

  /// 上一次关键词。
  String? lastKeyword;

  /// 创建搜索建议条目。
  SearchSuggestItem();

  /// 从 JSON 构建搜索建议条目。
  factory SearchSuggestItem.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestItemFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchSuggestItemToJson(this);
}

/// 搜索建议列表数据。
@JsonSerializable()
class SearchSuggestWrap {
  /// 全部匹配建议列表。
  late List<SearchSuggestItem> allMatch;

  /// 创建搜索建议列表数据。
  SearchSuggestWrap();

  /// 从 JSON 构建搜索建议列表数据。
  factory SearchSuggestWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchSuggestWrapToJson(this);
}

/// 搜索建议响应。
@JsonSerializable()
class SearchSuggestWrapX extends ServerStatusBean {
  /// 搜索建议列表数据。
  late SearchSuggestWrap result;

  /// 创建搜索建议响应。
  SearchSuggestWrapX();

  /// 从 JSON 构建搜索建议响应。
  factory SearchSuggestWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchSuggestWrapXToJson(this);
}

/// 多重匹配搜索结果数据。
@JsonSerializable()
class SearchMultiMatchWrap {
  /// 匹配歌曲列表。
  List<Song>? song;

  /// 匹配歌单列表。
  List<PlayList>? playList;

  /// 匹配歌手列表。
  List<Artist>? artist;

  /// 匹配专辑列表。
  List<Album>? album;

  /// 多重匹配模块顺序。
  late List<String> orders;

  /// 创建多重匹配搜索结果数据。
  SearchMultiMatchWrap();

  /// 从 JSON 构建多重匹配搜索结果数据。
  factory SearchMultiMatchWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchMultiMatchWrapFromJson(json);

  /// 转换为 JSON。
  Map<String, dynamic> toJson() => _$SearchMultiMatchWrapToJson(this);
}

/// 多重匹配搜索响应。
@JsonSerializable()
class SearchMultiMatchWrapX extends ServerStatusBean {
  /// 多重匹配搜索结果数据。
  late SearchMultiMatchWrap result;

  /// 创建多重匹配搜索响应。
  SearchMultiMatchWrapX();

  /// 从 JSON 构建多重匹配搜索响应。
  factory SearchMultiMatchWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchMultiMatchWrapXFromJson(json);

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() => _$SearchMultiMatchWrapXToJson(this);
}
