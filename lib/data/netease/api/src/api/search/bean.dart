// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
import '../../../src/api/bean.dart';
import '../../../src/api/dj/bean.dart';
import '../../../src/api/event/bean.dart';
import '../../../src/api/play/bean.dart';
import '../../../src/api/user/bean.dart';

part 'bean.g.dart';

/// SearchSongWrap。
@JsonSerializable()
class SearchSongWrap {
  /// songs。
  late List<Song> songs;

  /// 创建 SearchSongWrap。
  SearchSongWrap();

  /// 创建 SearchSongWrap。
  factory SearchSongWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchSongWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchSongWrapToJson(this);
}

/// SearchSongWrapX。
@JsonSerializable()
class SearchSongWrapX extends ServerStatusBean {
  /// result。
  late SearchSongWrap result;

  /// 创建 SearchSongWrapX。
  SearchSongWrapX();

  /// 创建 SearchSongWrapX。
  factory SearchSongWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchSongWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchSongWrapXToJson(this);
}

/// SearchAlbumsWrapX。
@JsonSerializable()
class SearchAlbumsWrapX extends ServerStatusBean {
  /// result。
  late AlbumListWrap result;

  /// 创建 SearchAlbumsWrapX。
  SearchAlbumsWrapX();

  /// 创建 SearchAlbumsWrapX。
  factory SearchAlbumsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchAlbumsWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchAlbumsWrapXToJson(this);
}

/// SearchArtistsWrap。
@JsonSerializable()
class SearchArtistsWrap {
  /// artists。
  late List<Artist> artists;

  /// 创建 SearchArtistsWrap。
  SearchArtistsWrap();

  /// 创建 SearchArtistsWrap。
  factory SearchArtistsWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchArtistsWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchArtistsWrapToJson(this);
}

/// SearchArtistsWrapX。
@JsonSerializable()
class SearchArtistsWrapX extends ServerStatusBean {
  /// result。
  late SearchArtistsWrap result;

  /// 创建 SearchArtistsWrapX。
  SearchArtistsWrapX();

  /// 创建 SearchArtistsWrapX。
  factory SearchArtistsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchArtistsWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchArtistsWrapXToJson(this);
}

/// SearchPlaylistWrap。
@JsonSerializable()
class SearchPlaylistWrap {
  /// playlists。
  late List<PlayList> playlists;

  /// 创建 SearchPlaylistWrap。
  SearchPlaylistWrap();

  /// 创建 SearchPlaylistWrap。
  factory SearchPlaylistWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchPlaylistWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchPlaylistWrapToJson(this);
}

/// SearchPlaylistWrapX。
@JsonSerializable()
class SearchPlaylistWrapX extends ServerStatusBean {
  /// result。
  late SearchPlaylistWrap result;

  /// 创建 SearchPlaylistWrapX。
  SearchPlaylistWrapX();

  /// 创建 SearchPlaylistWrapX。
  factory SearchPlaylistWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchPlaylistWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchPlaylistWrapXToJson(this);
}

/// SearchUserWrapX。
@JsonSerializable()
class SearchUserWrapX extends ServerStatusBean {
  /// result。
  late UserListWrap result;

  /// 创建 SearchUserWrapX。
  SearchUserWrapX();

  /// 创建 SearchUserWrapX。
  factory SearchUserWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchUserWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchUserWrapXToJson(this);
}

/// SearchMvWrapX。
@JsonSerializable()
class SearchMvWrapX extends ServerStatusBean {
  /// result。
  late MvListWrap result;

  /// 创建 SearchMvWrapX。
  SearchMvWrapX();

  /// 创建 SearchMvWrapX。
  factory SearchMvWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchMvWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchMvWrapXToJson(this);
}

/// SearchLyricsWrap。
@JsonSerializable()
class SearchLyricsWrap {
  /// songs。
  late List<Song> songs;

  /// 创建 SearchLyricsWrap。
  SearchLyricsWrap();

  /// 创建 SearchLyricsWrap。
  factory SearchLyricsWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchLyricsWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchLyricsWrapToJson(this);
}

/// SearchLyricsWrapX。
@JsonSerializable()
class SearchLyricsWrapX extends ServerStatusBean {
  /// result。
  late SearchLyricsWrap result;

  /// 创建 SearchLyricsWrapX。
  SearchLyricsWrapX();

  /// 创建 SearchLyricsWrapX。
  factory SearchLyricsWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchLyricsWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchLyricsWrapXToJson(this);
}

/// SearchDjradiorap。
@JsonSerializable()
class SearchDjradiorap {
  /// djRadios。
  late List<DjRadio> djRadios;

  /// 创建 SearchDjradiorap。
  SearchDjradiorap();

  /// 创建 SearchDjradiorap。
  factory SearchDjradiorap.fromJson(Map<String, dynamic> json) =>
      _$SearchDjradiorapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchDjradiorapToJson(this);
}

/// SearchDjradioWrapX。
@JsonSerializable()
class SearchDjradioWrapX extends ServerStatusBean {
  /// result。
  late SearchDjradiorap result;

  /// 创建 SearchDjradioWrapX。
  SearchDjradioWrapX();

  /// 创建 SearchDjradioWrapX。
  factory SearchDjradioWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchDjradioWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchDjradioWrapXToJson(this);
}

/// SearchVideoWrap。
@JsonSerializable()
class SearchVideoWrap {
  /// videos。
  late List<Mv2> videos;

  /// 创建 SearchVideoWrap。
  SearchVideoWrap();

  /// 创建 SearchVideoWrap。
  factory SearchVideoWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchVideoWrapToJson(this);
}

/// SearchVideoWrapX。
@JsonSerializable()
class SearchVideoWrapX extends ServerStatusBean {
  /// result。
  late SearchVideoWrap result;

  /// 创建 SearchVideoWrapX。
  SearchVideoWrapX();

  /// 创建 SearchVideoWrapX。
  factory SearchVideoWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchVideoWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchVideoWrapXToJson(this);
}

/// SearchComplexSong。
@JsonSerializable()
class SearchComplexSong {
  /// songs。
  late List<Song2> songs;

  /// moreText。
  String? moreText;

  /// highText。
  String? highText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexSong。
  SearchComplexSong();

  /// 创建 SearchComplexSong。
  factory SearchComplexSong.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSongFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexSongToJson(this);
}

/// SearchComplexMlog。
@JsonSerializable()
class SearchComplexMlog {
  /// mlogs。
  late List<MyLog> mlogs;

  /// moreText。
  String? moreText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexMlog。
  SearchComplexMlog();

  /// 创建 SearchComplexMlog。
  factory SearchComplexMlog.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexMlogFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexMlogToJson(this);
}

/// SearchComplexPlaylist。
@JsonSerializable()
class SearchComplexPlaylist {
  /// playLists。
  late List<PlayList> playLists;

  /// moreText。
  String? moreText;

  /// highText。
  String? highText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexPlaylist。
  SearchComplexPlaylist();

  /// 创建 SearchComplexPlaylist。
  factory SearchComplexPlaylist.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexPlaylistFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexPlaylistToJson(this);
}

/// SearchComplexArtist。
@JsonSerializable()
class SearchComplexArtist {
  /// artists。
  late List<Artist> artists;

  /// moreText。
  String? moreText;

  /// highText。
  String? highText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexArtist。
  SearchComplexArtist();

  /// 创建 SearchComplexArtist。
  factory SearchComplexArtist.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexArtistFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexArtistToJson(this);
}

/// SearchComplexAlbum。
@JsonSerializable()
class SearchComplexAlbum {
  /// albums。
  late List<Album> albums;

  /// moreText。
  String? moreText;

  /// highText。
  String? highText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexAlbum。
  SearchComplexAlbum();

  /// 创建 SearchComplexAlbum。
  factory SearchComplexAlbum.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexAlbumFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexAlbumToJson(this);
}

/// SearchComplexVideo。
@JsonSerializable()
class SearchComplexVideo {
  /// videos。
  late List<Video2> videos;

  /// moreText。
  String? moreText;

  /// highText。
  String? highText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexVideo。
  SearchComplexVideo();

  /// 创建 SearchComplexVideo。
  factory SearchComplexVideo.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexVideoFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexVideoToJson(this);
}

/// SearchComplexSimQueryItem。
@JsonSerializable()
class SearchComplexSimQueryItem {
  /// keyword。
  String? keyword;

  /// alg。
  String? alg;

  /// 创建 SearchComplexSimQueryItem。
  SearchComplexSimQueryItem();

  /// 创建 SearchComplexSimQueryItem。
  factory SearchComplexSimQueryItem.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSimQueryItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexSimQueryItemToJson(this);
}

/// SearchComplexSimQuery。
@JsonSerializable()
class SearchComplexSimQuery {
  /// sim_querys。
  late List<SearchComplexSimQueryItem> sim_querys;

  /// more。
  bool? more;

  /// 创建 SearchComplexSimQuery。
  SearchComplexSimQuery();

  /// 创建 SearchComplexSimQuery。
  factory SearchComplexSimQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexSimQueryFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexSimQueryToJson(this);
}

/// SearchComplexTalk。
@JsonSerializable()
class SearchComplexTalk {
  /// users。
  List<NeteaseUserInfo>? users;

  /// moreText。
  String? moreText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexTalk。
  SearchComplexTalk();

  /// 创建 SearchComplexTalk。
  factory SearchComplexTalk.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexTalkFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexTalkToJson(this);
}

/// SearchComplexUser。
@JsonSerializable()
class SearchComplexUser {
  /// users。
  late List<NeteaseUserInfo> users;

  /// moreText。
  String? moreText;

  /// more。
  bool? more;

  /// resourceIds。
  late List<int> resourceIds;

  /// 创建 SearchComplexUser。
  SearchComplexUser();

  /// 创建 SearchComplexUser。
  factory SearchComplexUser.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexUserFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexUserToJson(this);
}

/// SearchComplexWrap。
@JsonSerializable()
class SearchComplexWrap {
  /// song。
  SearchComplexSong? song;

  /// mlog。
  SearchComplexMlog? mlog;

  /// playList。
  SearchComplexPlaylist? playList;

  /// artist。
  SearchComplexArtist? artist;

  /// album。
  SearchComplexAlbum? album;

  /// video。
  SearchComplexVideo? video;

  /// sim_query。
  SearchComplexSimQuery? sim_query;

  /// talk。
  SearchComplexTalk? talk;

  /// user。
  SearchComplexUser? user;

  /// order。
  List<String>? order;

  /// 创建 SearchComplexWrap。
  SearchComplexWrap();

  /// 创建 SearchComplexWrap。
  factory SearchComplexWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchComplexWrapToJson(this);
}

/// SearchComplexWrapX。
@JsonSerializable()
class SearchComplexWrapX extends ServerStatusBean {
  /// result。
  late SearchComplexWrap result;

  /// 创建 SearchComplexWrapX。
  SearchComplexWrapX();

  /// 创建 SearchComplexWrapX。
  factory SearchComplexWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchComplexWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchComplexWrapXToJson(this);
}

/// SearchKey。
@JsonSerializable()
class SearchKey {
  /// showKeyword。
  String? showKeyword;

  /// action。
  int? action;

  /// realkeyword。
  String? realkeyword;

  /// searchType。
  int? searchType;

  /// alg。
  String? alg;

  /// gap。
  int? gap;

  /// 创建 SearchKey。
  SearchKey();

  /// 创建 SearchKey。
  factory SearchKey.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchKeyToJson(this);
}

/// SearchKeyWrap。
@JsonSerializable()
class SearchKeyWrap extends ServerStatusBean {
  /// data。
  late SearchKey data;

  /// 创建 SearchKeyWrap。
  SearchKeyWrap();

  /// 创建 SearchKeyWrap。
  factory SearchKeyWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchKeyWrapToJson(this);
}

/// SearchHotKey。
@JsonSerializable()
class SearchHotKey {
  /// first。
  String? first;

  /// second。
  int? second;

  /// iconType。
  late int iconType;

  /// 创建 SearchHotKey。
  SearchHotKey();

  /// 创建 SearchHotKey。
  factory SearchHotKey.fromJson(Map<String, dynamic> json) =>
      _$SearchHotKeyFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchHotKeyToJson(this);
}

/// SearchHotKeyWrap。
@JsonSerializable()
class SearchHotKeyWrap {
  /// hots。
  late List<SearchHotKey> hots;

  /// 创建 SearchHotKeyWrap。
  SearchHotKeyWrap();

  /// 创建 SearchHotKeyWrap。
  factory SearchHotKeyWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchHotKeyWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchHotKeyWrapToJson(this);
}

/// SearchKeyWrapX。
@JsonSerializable()
class SearchKeyWrapX extends ServerStatusBean {
  /// result。
  late SearchHotKeyWrap result;

  /// 创建 SearchKeyWrapX。
  SearchKeyWrapX();

  /// 创建 SearchKeyWrapX。
  factory SearchKeyWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchKeyWrapXToJson(this);
}

/// SearchKeyDetailedItem。
@JsonSerializable()
class SearchKeyDetailedItem {
  /// searchWord。
  String? searchWord;

  /// content。
  String? content;

  /// iconUrl。
  String? iconUrl;

  /// url。
  String? url;

  /// alg。
  String? alg;

  /// score。
  int? score;

  /// source。
  int? source;

  /// iconType。
  late int iconType;

  /// 创建 SearchKeyDetailedItem。
  SearchKeyDetailedItem();

  /// 创建 SearchKeyDetailedItem。
  factory SearchKeyDetailedItem.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyDetailedItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchKeyDetailedItemToJson(this);
}

/// SearchKeyDetailedWrap。
@JsonSerializable()
class SearchKeyDetailedWrap extends ServerStatusBean {
  /// data。
  late List<SearchKeyDetailedItem> data;

  /// 创建 SearchKeyDetailedWrap。
  SearchKeyDetailedWrap();

  /// 创建 SearchKeyDetailedWrap。
  factory SearchKeyDetailedWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchKeyDetailedWrapFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchKeyDetailedWrapToJson(this);
}

/// SearchSuggestItem。
@JsonSerializable()
class SearchSuggestItem {
  /// keyword。
  String? keyword;

  /// type。
  int? type;

  /// alg。
  String? alg;

  /// lastKeyword。
  String? lastKeyword;

  /// 创建 SearchSuggestItem。
  SearchSuggestItem();

  /// 创建 SearchSuggestItem。
  factory SearchSuggestItem.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestItemFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchSuggestItemToJson(this);
}

/// SearchSuggestWrap。
@JsonSerializable()
class SearchSuggestWrap {
  /// allMatch。
  late List<SearchSuggestItem> allMatch;

  /// 创建 SearchSuggestWrap。
  SearchSuggestWrap();

  /// 创建 SearchSuggestWrap。
  factory SearchSuggestWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchSuggestWrapToJson(this);
}

/// SearchSuggestWrapX。
@JsonSerializable()
class SearchSuggestWrapX extends ServerStatusBean {
  /// result。
  late SearchSuggestWrap result;

  /// 创建 SearchSuggestWrapX。
  SearchSuggestWrapX();

  /// 创建 SearchSuggestWrapX。
  factory SearchSuggestWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchSuggestWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchSuggestWrapXToJson(this);
}

/// SearchMultiMatchWrap。
@JsonSerializable()
class SearchMultiMatchWrap {
  /// song。
  List<Song>? song;

  /// playList。
  List<PlayList>? playList;

  /// artist。
  List<Artist>? artist;

  /// album。
  List<Album>? album;

  /// orders。
  late List<String> orders;

  /// 创建 SearchMultiMatchWrap。
  SearchMultiMatchWrap();

  /// 创建 SearchMultiMatchWrap。
  factory SearchMultiMatchWrap.fromJson(Map<String, dynamic> json) =>
      _$SearchMultiMatchWrapFromJson(json);

  /// toJson。
  Map<String, dynamic> toJson() => _$SearchMultiMatchWrapToJson(this);
}

/// SearchMultiMatchWrapX。
@JsonSerializable()
class SearchMultiMatchWrapX extends ServerStatusBean {
  /// result。
  late SearchMultiMatchWrap result;

  /// 创建 SearchMultiMatchWrapX。
  SearchMultiMatchWrapX();

  /// 创建 SearchMultiMatchWrapX。
  factory SearchMultiMatchWrapX.fromJson(Map<String, dynamic> json) =>
      _$SearchMultiMatchWrapXFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SearchMultiMatchWrapXToJson(this);
}
