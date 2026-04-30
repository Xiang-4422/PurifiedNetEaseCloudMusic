// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Music _$MusicFromJson(Map<String, dynamic> json) => Music()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..size = (json['size'] as num?)?.toInt()
  ..extension = json['extension'] as String?
  ..sr = (json['sr'] as num?)?.toInt()
  ..dfsId = (json['dfsId'] as num?)?.toInt()
  ..bitrate = (json['bitrate'] as num?)?.toInt()
  ..playTime = (json['playTime'] as num?)?.toInt()
  ..volumeDelta = (json['volumeDelta'] as num?)?.toDouble();

Map<String, dynamic> _$MusicToJson(Music instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'size': instance.size,
      'extension': instance.extension,
      'sr': instance.sr,
      'dfsId': instance.dfsId,
      'bitrate': instance.bitrate,
      'playTime': instance.playTime,
      'volumeDelta': instance.volumeDelta,
    };

Music2 _$Music2FromJson(Map<String, dynamic> json) => Music2()
  ..br = (json['br'] as num?)?.toInt()
  ..fid = (json['fid'] as num?)?.toInt()
  ..size = (json['size'] as num?)?.toInt()
  ..vd = (json['vd'] as num?)?.toDouble();

Map<String, dynamic> _$Music2ToJson(Music2 instance) => <String, dynamic>{
      'br': instance.br,
      'fid': instance.fid,
      'size': instance.size,
      'vd': instance.vd,
    };

Lyrics _$LyricsFromJson(Map<String, dynamic> json) =>
    Lyrics()..txt = json['txt'] as String?;

Map<String, dynamic> _$LyricsToJson(Lyrics instance) => <String, dynamic>{
      'txt': instance.txt,
    };

Lyrics2 _$Lyrics2FromJson(Map<String, dynamic> json) => Lyrics2()
  ..lyric = json['lyric'] as String?
  ..version = (json['version'] as num?)?.toInt();

Map<String, dynamic> _$Lyrics2ToJson(Lyrics2 instance) => <String, dynamic>{
      'lyric': instance.lyric,
      'version': instance.version,
    };

Privilege _$PrivilegeFromJson(Map<String, dynamic> json) => Privilege()
  ..id = dynamicToString(json['id'])
  ..fee = (json['fee'] as num?)?.toInt()
  ..payed = (json['payed'] as num?)?.toInt()
  ..st = (json['st'] as num?)?.toInt()
  ..pl = (json['pl'] as num?)?.toInt()
  ..dl = (json['dl'] as num?)?.toInt()
  ..sp = (json['sp'] as num?)?.toInt()
  ..cp = (json['cp'] as num?)?.toInt()
  ..subp = (json['subp'] as num?)?.toInt()
  ..cs = json['cs'] as bool?
  ..maxbr = (json['maxbr'] as num?)?.toInt()
  ..fl = (json['fl'] as num?)?.toInt()
  ..toast = json['toast'] as bool?
  ..flag = (json['flag'] as num?)?.toInt()
  ..preSell = json['preSell'] as bool?;

Map<String, dynamic> _$PrivilegeToJson(Privilege instance) => <String, dynamic>{
      'id': instance.id,
      'fee': instance.fee,
      'payed': instance.payed,
      'st': instance.st,
      'pl': instance.pl,
      'dl': instance.dl,
      'sp': instance.sp,
      'cp': instance.cp,
      'subp': instance.subp,
      'cs': instance.cs,
      'maxbr': instance.maxbr,
      'fl': instance.fl,
      'toast': instance.toast,
      'flag': instance.flag,
      'preSell': instance.preSell,
    };

Song _$SongFromJson(Map<String, dynamic> json) => Song()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..copyrightId = (json['copyrightId'] as num?)?.toInt()
  ..disc = json['disc'] as String?
  ..no = (json['no'] as num?)?.toInt()
  ..fee = (json['fee'] as num?)?.toInt()
  ..status = (json['status'] as num?)?.toInt()
  ..starred = json['starred'] as bool?
  ..starredNum = (json['starredNum'] as num?)?.toInt()
  ..popularity = (json['popularity'] as num?)?.toDouble()
  ..score = (json['score'] as num?)?.toInt()
  ..duration = (json['duration'] as num?)?.toInt()
  ..playedNum = (json['playedNum'] as num?)?.toInt()
  ..dayPlays = (json['dayPlays'] as num?)?.toInt()
  ..hearTime = (json['hearTime'] as num?)?.toInt()
  ..ringtone = json['ringtone'] as String?
  ..copyFrom = json['copyFrom'] as String?
  ..commentThreadId = json['commentThreadId'] as String?
  ..artists = (json['artists'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList()
  ..album = json['album'] == null
      ? null
      : Album.fromJson(json['album'] as Map<String, dynamic>)
  ..lyrics = json['lyrics']
  ..privilege = json['privilege'] == null
      ? null
      : Privilege.fromJson(json['privilege'] as Map<String, dynamic>)
  ..copyright = (json['copyright'] as num?)?.toInt()
  ..transName = json['transName'] as String?
  ..mark = (json['mark'] as num?)?.toInt()
  ..rtype = (json['rtype'] as num?)?.toInt()
  ..mvid = (json['mvid'] as num?)?.toInt()
  ..alg = json['alg'] as String?
  ..reason = json['reason'] as String?
  ..hMusic = json['hMusic'] == null
      ? null
      : Music.fromJson(json['hMusic'] as Map<String, dynamic>)
  ..mMusic = json['mMusic'] == null
      ? null
      : Music.fromJson(json['mMusic'] as Map<String, dynamic>)
  ..lMusic = json['lMusic'] == null
      ? null
      : Music.fromJson(json['lMusic'] as Map<String, dynamic>)
  ..bMusic = json['bMusic'] == null
      ? null
      : Music.fromJson(json['bMusic'] as Map<String, dynamic>);

Map<String, dynamic> _$SongToJson(Song instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'copyrightId': instance.copyrightId,
      'disc': instance.disc,
      'no': instance.no,
      'fee': instance.fee,
      'status': instance.status,
      'starred': instance.starred,
      'starredNum': instance.starredNum,
      'popularity': instance.popularity,
      'score': instance.score,
      'duration': instance.duration,
      'playedNum': instance.playedNum,
      'dayPlays': instance.dayPlays,
      'hearTime': instance.hearTime,
      'ringtone': instance.ringtone,
      'copyFrom': instance.copyFrom,
      'commentThreadId': instance.commentThreadId,
      'artists': instance.artists,
      'album': instance.album,
      'lyrics': instance.lyrics,
      'privilege': instance.privilege,
      'copyright': instance.copyright,
      'transName': instance.transName,
      'mark': instance.mark,
      'rtype': instance.rtype,
      'mvid': instance.mvid,
      'alg': instance.alg,
      'reason': instance.reason,
      'hMusic': instance.hMusic,
      'mMusic': instance.mMusic,
      'lMusic': instance.lMusic,
      'bMusic': instance.bMusic,
    };

Song2 _$Song2FromJson(Map<String, dynamic> json) => Song2()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..pst = (json['pst'] as num?)?.toInt()
  ..t = (json['t'] as num?)?.toInt()
  ..ar = (json['ar'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList()
  ..pop = (json['pop'] as num?)?.toDouble()
  ..st = (json['st'] as num?)?.toInt()
  ..rt = json['rt'] as String?
  ..fee = (json['fee'] as num?)?.toInt()
  ..v = (json['v'] as num?)?.toInt()
  ..cf = json['cf'] as String?
  ..al = json['al'] == null
      ? null
      : Album.fromJson(json['al'] as Map<String, dynamic>)
  ..dt = (json['dt'] as num?)?.toInt()
  ..h = json['h'] == null
      ? null
      : Music2.fromJson(json['h'] as Map<String, dynamic>)
  ..m = json['m'] == null
      ? null
      : Music2.fromJson(json['m'] as Map<String, dynamic>)
  ..l = json['l'] == null
      ? null
      : Music2.fromJson(json['l'] as Map<String, dynamic>)
  ..a = json['a'] == null
      ? null
      : Music2.fromJson(json['a'] as Map<String, dynamic>)
  ..mark = (json['mark'] as num?)?.toInt()
  ..mv = (json['mv'] as num?)?.toInt()
  ..rtype = (json['rtype'] as num?)?.toInt()
  ..mst = (json['mst'] as num?)?.toInt()
  ..cp = (json['cp'] as num?)?.toInt()
  ..publishTime = (json['publishTime'] as num?)?.toInt()
  ..reason = json['reason'] as String?
  ..privilege = json['privilege'] == null
      ? null
      : Privilege.fromJson(json['privilege'] as Map<String, dynamic>)
  ..available = json['available'] as bool?;

Map<String, dynamic> _$Song2ToJson(Song2 instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pst': instance.pst,
      't': instance.t,
      'ar': instance.ar,
      'pop': instance.pop,
      'st': instance.st,
      'rt': instance.rt,
      'fee': instance.fee,
      'v': instance.v,
      'cf': instance.cf,
      'al': instance.al,
      'dt': instance.dt,
      'h': instance.h,
      'm': instance.m,
      'l': instance.l,
      'a': instance.a,
      'mark': instance.mark,
      'mv': instance.mv,
      'rtype': instance.rtype,
      'mst': instance.mst,
      'cp': instance.cp,
      'publishTime': instance.publishTime,
      'reason': instance.reason,
      'privilege': instance.privilege,
      'available': instance.available,
    };

SongDetailWrap _$SongDetailWrapFromJson(Map<String, dynamic> json) =>
    SongDetailWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..songs = (json['songs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList()
      ..privileges = (json['privileges'] as List<dynamic>?)
          ?.map((e) => Privilege.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$SongDetailWrapToJson(SongDetailWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'songs': instance.songs,
      'privileges': instance.privileges,
    };

SongUrl _$SongUrlFromJson(Map<String, dynamic> json) => SongUrl()
  ..id = dynamicToString(json['id'])
  ..url = json['url'] as String?
  ..br = (json['br'] as num?)?.toInt()
  ..size = (json['size'] as num?)?.toInt()
  ..code = (json['code'] as num?)?.toInt()
  ..expi = (json['expi'] as num?)?.toInt()
  ..gain = (json['gain'] as num?)?.toDouble()
  ..fee = (json['fee'] as num?)?.toInt()
  ..payed = (json['payed'] as num?)?.toInt()
  ..flag = (json['flag'] as num?)?.toInt()
  ..canExtend = json['canExtend'] as bool?
  ..md5 = json['md5'] as String?;

Map<String, dynamic> _$SongUrlToJson(SongUrl instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'br': instance.br,
      'size': instance.size,
      'code': instance.code,
      'expi': instance.expi,
      'gain': instance.gain,
      'fee': instance.fee,
      'payed': instance.payed,
      'flag': instance.flag,
      'canExtend': instance.canExtend,
      'md5': instance.md5,
    };

SongUrlListWrap _$SongUrlListWrapFromJson(Map<String, dynamic> json) =>
    SongUrlListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => SongUrl.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$SongUrlListWrapToJson(SongUrlListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

SongLyricWrap _$SongLyricWrapFromJson(Map<String, dynamic> json) =>
    SongLyricWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..sgc = json['sgc'] as bool?
      ..sfy = json['sfy'] as bool?
      ..qfy = json['qfy'] as bool?
      ..lrc = Lyrics2.fromJson(json['lrc'] as Map<String, dynamic>)
      ..klyric = Lyrics2.fromJson(json['klyric'] as Map<String, dynamic>)
      ..tlyric = Lyrics2.fromJson(json['tlyric'] as Map<String, dynamic>);

Map<String, dynamic> _$SongLyricWrapToJson(SongLyricWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'sgc': instance.sgc,
      'sfy': instance.sfy,
      'qfy': instance.qfy,
      'lrc': instance.lrc,
      'klyric': instance.klyric,
      'tlyric': instance.tlyric,
    };

SongListWrap _$SongListWrapFromJson(Map<String, dynamic> json) => SongListWrap()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..songs = (json['songs'] as List<dynamic>?)
      ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$SongListWrapToJson(SongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'songs': instance.songs,
    };

SongListWrap2 _$SongListWrap2FromJson(Map<String, dynamic> json) =>
    SongListWrap2()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$SongListWrap2ToJson(SongListWrap2 instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

PersonalizedSongItem _$PersonalizedSongItemFromJson(
        Map<String, dynamic> json) =>
    PersonalizedSongItem()
      ..id = dynamicToString(json['id'])
      ..name = json['name'] as String?
      ..picUrl = json['picUrl'] as String?
      ..copywriter = json['copywriter'] as String?
      ..canDislike = json['canDislike'] as bool?
      ..alg = json['alg'] as String?
      ..type = (json['type'] as num?)?.toInt()
      ..song = Song.fromJson(json['song'] as Map<String, dynamic>);

Map<String, dynamic> _$PersonalizedSongItemToJson(
        PersonalizedSongItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picUrl': instance.picUrl,
      'copywriter': instance.copywriter,
      'canDislike': instance.canDislike,
      'alg': instance.alg,
      'type': instance.type,
      'song': instance.song,
    };

PersonalizedSongListWrap _$PersonalizedSongListWrapFromJson(
        Map<String, dynamic> json) =>
    PersonalizedSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..result = (json['result'] as List<dynamic>?)
          ?.map((e) => PersonalizedSongItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..category = (json['category'] as num?)?.toInt();

Map<String, dynamic> _$PersonalizedSongListWrapToJson(
        PersonalizedSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'result': instance.result,
      'category': instance.category,
    };

LikeSongListWrap _$LikeSongListWrapFromJson(Map<String, dynamic> json) =>
    LikeSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..checkPoint = (json['checkPoint'] as num?)?.toInt()
      ..ids = (json['ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList();

Map<String, dynamic> _$LikeSongListWrapToJson(LikeSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'checkPoint': instance.checkPoint,
      'ids': instance.ids,
    };

CloudSongItem _$CloudSongItemFromJson(Map<String, dynamic> json) =>
    CloudSongItem()
      ..simpleSong = Song2.fromJson(json['simpleSong'] as Map<String, dynamic>)
      ..songId = dynamicToString(json['songId'])
      ..songName = json['songName'] as String?
      ..fileName = json['fileName'] as String?
      ..cover = (json['cover'] as num?)?.toInt()
      ..fileSize = (json['fileSize'] as num?)?.toInt()
      ..addTime = (json['addTime'] as num).toInt()
      ..version = (json['version'] as num?)?.toInt()
      ..coverId = json['coverId'] as String?
      ..lyricId = json['lyricId'] as String?
      ..album = json['album'] as String?
      ..artist = json['artist'] as String?
      ..bitrate = (json['bitrate'] as num?)?.toInt();

Map<String, dynamic> _$CloudSongItemToJson(CloudSongItem instance) =>
    <String, dynamic>{
      'simpleSong': instance.simpleSong,
      'songId': instance.songId,
      'songName': instance.songName,
      'fileName': instance.fileName,
      'cover': instance.cover,
      'fileSize': instance.fileSize,
      'addTime': instance.addTime,
      'version': instance.version,
      'coverId': instance.coverId,
      'lyricId': instance.lyricId,
      'album': instance.album,
      'artist': instance.artist,
      'bitrate': instance.bitrate,
    };

CloudSongListWrap _$CloudSongListWrapFromJson(Map<String, dynamic> json) =>
    CloudSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..more = json['more'] as bool?
      ..hasMore = json['hasMore'] as bool?
      ..count = (json['count'] as num?)?.toInt()
      ..total = (json['total'] as num?)?.toInt()
      ..size = json['size'] as String?
      ..maxSize = json['maxSize'] as String?
      ..upgradeSign = (json['upgradeSign'] as num?)?.toInt()
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => CloudSongItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$CloudSongListWrapToJson(CloudSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'size': instance.size,
      'maxSize': instance.maxSize,
      'upgradeSign': instance.upgradeSign,
      'data': instance.data,
    };

RecommendSongReason _$RecommendSongReasonFromJson(Map<String, dynamic> json) =>
    RecommendSongReason()
      ..songId = dynamicToString(json['songId'])
      ..reason = json['reason'] as String?;

Map<String, dynamic> _$RecommendSongReasonToJson(
        RecommendSongReason instance) =>
    <String, dynamic>{
      'songId': instance.songId,
      'reason': instance.reason,
    };

RecommendSongListWrap _$RecommendSongListWrapFromJson(
        Map<String, dynamic> json) =>
    RecommendSongListWrap()
      ..dailySongs = (json['dailySongs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList()
      ..orderSongs = (json['orderSongs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList()
      ..recommendReasons = (json['recommendReasons'] as List<dynamic>?)
          ?.map((e) => RecommendSongReason.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$RecommendSongListWrapToJson(
        RecommendSongListWrap instance) =>
    <String, dynamic>{
      'dailySongs': instance.dailySongs,
      'orderSongs': instance.orderSongs,
      'recommendReasons': instance.recommendReasons,
    };

RecommendSongListWrapX _$RecommendSongListWrapXFromJson(
        Map<String, dynamic> json) =>
    RecommendSongListWrapX()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data =
          RecommendSongListWrap.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$RecommendSongListWrapXToJson(
        RecommendSongListWrapX instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

RecommendSongListHistoryWrap _$RecommendSongListHistoryWrapFromJson(
        Map<String, dynamic> json) =>
    RecommendSongListHistoryWrap()
      ..dates =
          (json['dates'] as List<dynamic>?)?.map((e) => e as String).toList()
      ..purchaseUrl = json['purchaseUrl'] as String?
      ..description = json['description'] as String?
      ..noHistoryMessage = json['noHistoryMessage'] as String?
      ..songs = (json['songs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$RecommendSongListHistoryWrapToJson(
        RecommendSongListHistoryWrap instance) =>
    <String, dynamic>{
      'dates': instance.dates,
      'purchaseUrl': instance.purchaseUrl,
      'description': instance.description,
      'noHistoryMessage': instance.noHistoryMessage,
      'songs': instance.songs,
    };

RecommendSongListHistoryWrapX _$RecommendSongListHistoryWrapXFromJson(
        Map<String, dynamic> json) =>
    RecommendSongListHistoryWrapX()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = RecommendSongListHistoryWrap.fromJson(
          json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$RecommendSongListHistoryWrapXToJson(
        RecommendSongListHistoryWrapX instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

ArtistSongListWrap _$ArtistSongListWrapFromJson(Map<String, dynamic> json) =>
    ArtistSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..songs = (json['songs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ArtistSongListWrapToJson(ArtistSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'songs': instance.songs,
    };

ArtistNewSongListData _$ArtistNewSongListDataFromJson(
        Map<String, dynamic> json) =>
    ArtistNewSongListData()
      ..hasMore = json['hasMore'] as bool?
      ..newSongCount = (json['newSongCount'] as num?)?.toInt()
      ..newWorks = (json['newWorks'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ArtistNewSongListDataToJson(
        ArtistNewSongListData instance) =>
    <String, dynamic>{
      'hasMore': instance.hasMore,
      'newSongCount': instance.newSongCount,
      'newWorks': instance.newWorks,
    };

ArtistNewSongListWrap _$ArtistNewSongListWrapFromJson(
        Map<String, dynamic> json) =>
    ArtistNewSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data =
          ArtistNewSongListData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistNewSongListWrapToJson(
        ArtistNewSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

ArtistDetailAndSongListWrap _$ArtistDetailAndSongListWrapFromJson(
        Map<String, dynamic> json) =>
    ArtistDetailAndSongListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..hotSongs = (json['hotSongs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList()
      ..artist = Artist.fromJson(json['artist'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistDetailAndSongListWrapToJson(
        ArtistDetailAndSongListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'hotSongs': instance.hotSongs,
      'artist': instance.artist,
    };

PlayList _$PlayListFromJson(Map<String, dynamic> json) => PlayList()
  ..id = dynamicToString(json['id'])
  ..userId = dynamicToString(json['userId'])
  ..name = json['name'] as String?
  ..description = json['description'] as String?
  ..coverImgUrl = json['coverImgUrl'] as String?
  ..picUrl = json['picUrl'] as String?
  ..tag = json['tag'] as String?
  ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList()
  ..copywriter = json['copywriter'] as String?
  ..createTime = (json['createTime'] as num?)?.toInt()
  ..updateTime = (json['updateTime'] as num?)?.toInt()
  ..playCount = dynamicToInt(json['playCount'])
  ..subscribedCount = (json['subscribedCount'] as num?)?.toInt()
  ..shareCount = (json['shareCount'] as num?)?.toInt()
  ..commentCount = (json['commentCount'] as num?)?.toInt()
  ..subscribed = json['subscribed'] as bool?
  ..trackCount = (json['trackCount'] as num?)?.toInt()
  ..trackNumberUpdateTime = (json['trackNumberUpdateTime'] as num?)?.toInt()
  ..commentThreadId = json['commentThreadId'] as String?
  ..alg = json['alg'] as String?
  ..specialType = (json['specialType'] as num?)?.toInt()
  ..creator = json['creator'] == null
      ? null
      : NeteaseUserInfo.fromJson(json['creator'] as Map<String, dynamic>)
  ..subscribers = (json['subscribers'] as List<dynamic>?)
      ?.map((e) => NeteaseUserInfo.fromJson(e as Map<String, dynamic>))
      .toList()
  ..tracks = (json['tracks'] as List<dynamic>?)
      ?.map((e) => PlayTrack.fromJson(e as Map<String, dynamic>))
      .toList()
  ..trackIds = (json['trackIds'] as List<dynamic>?)
      ?.map((e) => PlayTrackId.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$PlayListToJson(PlayList instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'coverImgUrl': instance.coverImgUrl,
      'picUrl': instance.picUrl,
      'tag': instance.tag,
      'tags': instance.tags,
      'copywriter': instance.copywriter,
      'createTime': instance.createTime,
      'updateTime': instance.updateTime,
      'playCount': instance.playCount,
      'subscribedCount': instance.subscribedCount,
      'shareCount': instance.shareCount,
      'commentCount': instance.commentCount,
      'subscribed': instance.subscribed,
      'trackCount': instance.trackCount,
      'trackNumberUpdateTime': instance.trackNumberUpdateTime,
      'commentThreadId': instance.commentThreadId,
      'alg': instance.alg,
      'specialType': instance.specialType,
      'creator': instance.creator,
      'subscribers': instance.subscribers,
      'tracks': instance.tracks,
      'trackIds': instance.trackIds,
    };

PlayTrack _$PlayTrackFromJson(Map<String, dynamic> json) => PlayTrack()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..pst = (json['pst'] as num?)?.toInt()
  ..t = (json['t'] as num?)?.toInt()
  ..ar = (json['ar'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList()
  ..pop = (json['pop'] as num?)?.toDouble()
  ..st = (json['st'] as num?)?.toInt()
  ..rt = json['rt'] as String?
  ..fee = (json['fee'] as num?)?.toInt()
  ..v = (json['v'] as num?)?.toInt()
  ..cf = json['cf'] as String?
  ..al = Album.fromJson(json['al'] as Map<String, dynamic>)
  ..dt = (json['dt'] as num?)?.toInt()
  ..h = json['h'] == null
      ? null
      : Music2.fromJson(json['h'] as Map<String, dynamic>)
  ..m = json['m'] == null
      ? null
      : Music2.fromJson(json['m'] as Map<String, dynamic>)
  ..l = json['l'] == null
      ? null
      : Music2.fromJson(json['l'] as Map<String, dynamic>)
  ..a = json['a'] == null
      ? null
      : Music2.fromJson(json['a'] as Map<String, dynamic>)
  ..cd = json['cd'] as String?
  ..no = (json['no'] as num?)?.toInt()
  ..ftype = (json['ftype'] as num?)?.toInt()
  ..rtUrls = json['rtUrls'] as List<dynamic>?
  ..djId = (json['djId'] as num?)?.toInt()
  ..copyright = (json['copyright'] as num?)?.toInt()
  ..s_id = (json['s_id'] as num?)?.toInt()
  ..mark = (json['mark'] as num?)?.toInt()
  ..originCoverType = (json['originCoverType'] as num?)?.toInt()
  ..single = (json['single'] as num?)?.toInt()
  ..rtype = (json['rtype'] as num?)?.toInt()
  ..mst = (json['mst'] as num?)?.toInt()
  ..cp = (json['cp'] as num?)?.toInt()
  ..mv = (json['mv'] as num?)?.toInt()
  ..publishTime = (json['publishTime'] as num?)?.toInt();

Map<String, dynamic> _$PlayTrackToJson(PlayTrack instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'pst': instance.pst,
      't': instance.t,
      'ar': instance.ar,
      'pop': instance.pop,
      'st': instance.st,
      'rt': instance.rt,
      'fee': instance.fee,
      'v': instance.v,
      'cf': instance.cf,
      'al': instance.al,
      'dt': instance.dt,
      'h': instance.h,
      'm': instance.m,
      'l': instance.l,
      'a': instance.a,
      'cd': instance.cd,
      'no': instance.no,
      'ftype': instance.ftype,
      'rtUrls': instance.rtUrls,
      'djId': instance.djId,
      'copyright': instance.copyright,
      's_id': instance.s_id,
      'mark': instance.mark,
      'originCoverType': instance.originCoverType,
      'single': instance.single,
      'rtype': instance.rtype,
      'mst': instance.mst,
      'cp': instance.cp,
      'mv': instance.mv,
      'publishTime': instance.publishTime,
    };

PlayTrackId _$PlayTrackIdFromJson(Map<String, dynamic> json) => PlayTrackId()
  ..id = dynamicToString(json['id'])
  ..v = (json['v'] as num?)?.toInt()
  ..t = (json['t'] as num?)?.toInt()
  ..at = (json['at'] as num?)?.toInt()
  ..lr = (json['lr'] as num?)?.toInt();

Map<String, dynamic> _$PlayTrackIdToJson(PlayTrackId instance) =>
    <String, dynamic>{
      'id': instance.id,
      'v': instance.v,
      't': instance.t,
      'at': instance.at,
      'lr': instance.lr,
    };

MultiPlayListWrap _$MultiPlayListWrapFromJson(Map<String, dynamic> json) =>
    MultiPlayListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..playlists = (json['playlists'] as List<dynamic>?)
          ?.map((e) => PlayList.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MultiPlayListWrapToJson(MultiPlayListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'playlists': instance.playlists,
    };

MultiPlayListWrap2 _$MultiPlayListWrap2FromJson(Map<String, dynamic> json) =>
    MultiPlayListWrap2()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..playlists = (json['playlist'] as List<dynamic>?)
          ?.map((e) => PlayList.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$MultiPlayListWrap2ToJson(MultiPlayListWrap2 instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'playlist': instance.playlists,
    };

RecommendPlayListWrap _$RecommendPlayListWrapFromJson(
        Map<String, dynamic> json) =>
    RecommendPlayListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..recommend = (json['recommend'] as List<dynamic>?)
          ?.map((e) => PlayList.fromJson(e as Map<String, dynamic>))
          .toList()
      ..featureFirst = json['featureFirst'] as bool?
      ..haveRcmdSongs = json['haveRcmdSongs'] as bool?;

Map<String, dynamic> _$RecommendPlayListWrapToJson(
        RecommendPlayListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'recommend': instance.recommend,
      'featureFirst': instance.featureFirst,
      'haveRcmdSongs': instance.haveRcmdSongs,
    };

PersonalizedPlayListWrap _$PersonalizedPlayListWrapFromJson(
        Map<String, dynamic> json) =>
    PersonalizedPlayListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..result = (json['result'] as List<dynamic>?)
          ?.map((e) => PlayList.fromJson(e as Map<String, dynamic>))
          .toList()
      ..hasTaste = json['hasTaste'] as bool?
      ..category = (json['category'] as num?)?.toInt();

Map<String, dynamic> _$PersonalizedPlayListWrapToJson(
        PersonalizedPlayListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'result': instance.result,
      'hasTaste': instance.hasTaste,
      'category': instance.category,
    };

PlaylistCatalogueItem _$PlaylistCatalogueItemFromJson(
        Map<String, dynamic> json) =>
    PlaylistCatalogueItem()
      ..name = json['name'] as String?
      ..resourceCount = (json['resourceCount'] as num?)?.toInt()
      ..imgUrl = json['imgUrl'] as String?
      ..type = (json['type'] as num?)?.toInt()
      ..category = (json['category'] as num?)?.toInt()
      ..resourceType = (json['resourceType'] as num?)?.toInt()
      ..hot = json['hot'] as bool?
      ..activity = json['activity'] as bool?;

Map<String, dynamic> _$PlaylistCatalogueItemToJson(
        PlaylistCatalogueItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'resourceCount': instance.resourceCount,
      'imgUrl': instance.imgUrl,
      'type': instance.type,
      'category': instance.category,
      'resourceType': instance.resourceType,
      'hot': instance.hot,
      'activity': instance.activity,
    };

PlaylistCatalogueWrap _$PlaylistCatalogueWrapFromJson(
        Map<String, dynamic> json) =>
    PlaylistCatalogueWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..all = json['all'] == null
          ? null
          : PlaylistCatalogueItem.fromJson(json['all'] as Map<String, dynamic>)
      ..sub = (json['sub'] as List<dynamic>?)
          ?.map(
              (e) => PlaylistCatalogueItem.fromJson(e as Map<String, dynamic>))
          .toList()
      ..categories = (json['categories'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(int.parse(k), e as String),
      );

Map<String, dynamic> _$PlaylistCatalogueWrapToJson(
        PlaylistCatalogueWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'all': instance.all,
      'sub': instance.sub,
      'categories':
          instance.categories?.map((k, e) => MapEntry(k.toString(), e)),
    };

PlaylistHotTag _$PlaylistHotTagFromJson(Map<String, dynamic> json) =>
    PlaylistHotTag()
      ..id = dynamicToString(json['id'])
      ..name = json['name'] as String?
      ..category = (json['category'] as num?)?.toInt()
      ..usedCount = (json['usedCount'] as num?)?.toInt()
      ..type = (json['type'] as num?)?.toInt()
      ..position = (json['position'] as num?)?.toInt()
      ..highQuality = (json['highQuality'] as num?)?.toInt()
      ..highQualityPos = (json['highQualityPos'] as num?)?.toInt()
      ..officialPos = (json['officialPos'] as num?)?.toInt()
      ..createTime = (json['createTime'] as num?)?.toInt();

Map<String, dynamic> _$PlaylistHotTagToJson(PlaylistHotTag instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'usedCount': instance.usedCount,
      'type': instance.type,
      'position': instance.position,
      'highQuality': instance.highQuality,
      'highQualityPos': instance.highQualityPos,
      'officialPos': instance.officialPos,
      'createTime': instance.createTime,
    };

PlaylistHotTagsItem _$PlaylistHotTagsItemFromJson(Map<String, dynamic> json) =>
    PlaylistHotTagsItem()
      ..id = dynamicToString(json['id'])
      ..name = json['name'] as String?
      ..activity = json['activity'] as bool?
      ..hot = json['hot'] as bool?
      ..position = (json['position'] as num?)?.toInt()
      ..category = (json['category'] as num?)?.toInt()
      ..createTime = (json['createTime'] as num?)?.toInt()
      ..type = (json['type'] as num?)?.toInt()
      ..playlistTag = json['playlistTag'] == null
          ? null
          : PlaylistHotTag.fromJson(
              json['playlistTag'] as Map<String, dynamic>);

Map<String, dynamic> _$PlaylistHotTagsItemToJson(
        PlaylistHotTagsItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'activity': instance.activity,
      'hot': instance.hot,
      'position': instance.position,
      'category': instance.category,
      'createTime': instance.createTime,
      'type': instance.type,
      'playlistTag': instance.playlistTag,
    };

PlaylistHotTagsWrap _$PlaylistHotTagsWrapFromJson(Map<String, dynamic> json) =>
    PlaylistHotTagsWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..tags = (json['tags'] as List<dynamic>?)
          ?.map((e) => PlaylistHotTagsItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PlaylistHotTagsWrapToJson(
        PlaylistHotTagsWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'tags': instance.tags,
    };

SinglePlayListWrap _$SinglePlayListWrapFromJson(Map<String, dynamic> json) =>
    SinglePlayListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..playlist = json['playlist'] == null
          ? null
          : PlayList.fromJson(json['playlist'] as Map<String, dynamic>);

Map<String, dynamic> _$SinglePlayListWrapToJson(SinglePlayListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'playlist': instance.playlist,
    };

PlayListDetailDynamicWrap _$PlayListDetailDynamicWrapFromJson(
        Map<String, dynamic> json) =>
    PlayListDetailDynamicWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..commentCount = (json['commentCount'] as num?)?.toInt()
      ..shareCount = (json['shareCount'] as num?)?.toInt()
      ..playCount = (json['playCount'] as num?)?.toInt()
      ..bookedCount = (json['bookedCount'] as num?)?.toInt()
      ..subscribed = json['subscribed'] as bool?
      ..remarkName = json['remarkName'] as String?
      ..followed = json['followed'] as bool?;

Map<String, dynamic> _$PlayListDetailDynamicWrapToJson(
        PlayListDetailDynamicWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'playCount': instance.playCount,
      'bookedCount': instance.bookedCount,
      'subscribed': instance.subscribed,
      'remarkName': instance.remarkName,
      'followed': instance.followed,
    };

PlaymodeIntelligenceItem _$PlaymodeIntelligenceItemFromJson(
        Map<String, dynamic> json) =>
    PlaymodeIntelligenceItem()
      ..id = dynamicToString(json['id'])
      ..recommended = json['recommended'] as bool?
      ..alg = json['alg'] as String?
      ..songInfo = json['songInfo'] == null
          ? null
          : Song2.fromJson(json['songInfo'] as Map<String, dynamic>);

Map<String, dynamic> _$PlaymodeIntelligenceItemToJson(
        PlaymodeIntelligenceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recommended': instance.recommended,
      'alg': instance.alg,
      'songInfo': instance.songInfo,
    };

PlaymodeIntelligenceListWrap _$PlaymodeIntelligenceListWrapFromJson(
        Map<String, dynamic> json) =>
    PlaymodeIntelligenceListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) =>
              PlaymodeIntelligenceItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$PlaymodeIntelligenceListWrapToJson(
        PlaymodeIntelligenceListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

Artist _$ArtistFromJson(Map<String, dynamic> json) => Artist()
  ..id = dynamicToString(json['id'])
  ..accountId = dynamicToString(json['accountId'])
  ..name = json['name'] as String?
  ..picUrl = json['picUrl'] as String?
  ..img1v1Id = (json['img1v1Id'] as num?)?.toInt()
  ..img1v1Url = json['img1v1Url'] as String?
  ..cover = json['cover'] as String?
  ..albumSize = (json['albumSize'] as num?)?.toInt()
  ..musicSize = (json['musicSize'] as num?)?.toInt()
  ..mvSize = (json['mvSize'] as num?)?.toInt()
  ..topicPerson = (json['topicPerson'] as num?)?.toInt()
  ..trans = json['trans'] as String?
  ..briefDesc = json['briefDesc'] as String?
  ..followed = json['followed'] as bool?
  ..publishTime = (json['publishTime'] as num?)?.toInt();

Map<String, dynamic> _$ArtistToJson(Artist instance) => <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'name': instance.name,
      'picUrl': instance.picUrl,
      'img1v1Id': instance.img1v1Id,
      'img1v1Url': instance.img1v1Url,
      'cover': instance.cover,
      'albumSize': instance.albumSize,
      'musicSize': instance.musicSize,
      'mvSize': instance.mvSize,
      'topicPerson': instance.topicPerson,
      'trans': instance.trans,
      'briefDesc': instance.briefDesc,
      'followed': instance.followed,
      'publishTime': instance.publishTime,
    };

ArtistsListWrap _$ArtistsListWrapFromJson(Map<String, dynamic> json) =>
    ArtistsListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..artists = (json['artists'] as List<dynamic>?)
          ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ArtistsListWrapToJson(ArtistsListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'artists': instance.artists,
    };

ArtistsTopListWrap _$ArtistsTopListWrapFromJson(Map<String, dynamic> json) =>
    ArtistsTopListWrap()
      ..artists = (json['artists'] as List<dynamic>?)
          ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
          .toList()
      ..type = (json['type'] as num?)?.toInt()
      ..updateTime = (json['updateTime'] as num?)?.toInt();

Map<String, dynamic> _$ArtistsTopListWrapToJson(ArtistsTopListWrap instance) =>
    <String, dynamic>{
      'artists': instance.artists,
      'type': instance.type,
      'updateTime': instance.updateTime,
    };

ArtistsTopListWrapX _$ArtistsTopListWrapXFromJson(Map<String, dynamic> json) =>
    ArtistsTopListWrapX()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..list = json['list'] == null
          ? null
          : ArtistsTopListWrap.fromJson(json['list'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistsTopListWrapXToJson(
        ArtistsTopListWrapX instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'list': instance.list,
    };

ArtistIntroduction _$ArtistIntroductionFromJson(Map<String, dynamic> json) =>
    ArtistIntroduction()
      ..ti = json['ti'] as String?
      ..txt = json['txt'] as String?;

Map<String, dynamic> _$ArtistIntroductionToJson(ArtistIntroduction instance) =>
    <String, dynamic>{
      'ti': instance.ti,
      'txt': instance.txt,
    };

ArtistDescWrap _$ArtistDescWrapFromJson(Map<String, dynamic> json) =>
    ArtistDescWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..introduction = (json['introduction'] as List<dynamic>?)
          ?.map((e) => ArtistIntroduction.fromJson(e as Map<String, dynamic>))
          .toList()
      ..briefDesc = json['briefDesc'] as String?
      ..count = (json['count'] as num?)?.toInt()
      ..topicData = (json['topicData'] as List<dynamic>?)
          ?.map((e) => TopicItem2.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ArtistDescWrapToJson(ArtistDescWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'introduction': instance.introduction,
      'briefDesc': instance.briefDesc,
      'count': instance.count,
      'topicData': instance.topicData,
    };

ArtistDetailData _$ArtistDetailDataFromJson(Map<String, dynamic> json) =>
    ArtistDetailData()
      ..blacklist = json['blacklist'] as bool?
      ..showPriMsg = json['showPriMsg'] as bool?
      ..videoCount = (json['videoCount'] as num?)?.toInt()
      ..artist = json['artist'] == null
          ? null
          : Artist.fromJson(json['artist'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistDetailDataToJson(ArtistDetailData instance) =>
    <String, dynamic>{
      'blacklist': instance.blacklist,
      'showPriMsg': instance.showPriMsg,
      'videoCount': instance.videoCount,
      'artist': instance.artist,
    };

ArtistDetailWrap _$ArtistDetailWrapFromJson(Map<String, dynamic> json) =>
    ArtistDetailWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = json['data'] == null
          ? null
          : ArtistDetailData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistDetailWrapToJson(ArtistDetailWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

Album _$AlbumFromJson(Map<String, dynamic> json) => Album()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..type = json['type'] as String?
  ..subType = json['subType'] as String?
  ..mark = (json['mark'] as num?)?.toInt()
  ..size = (json['size'] as num?)?.toInt()
  ..publishTime = (json['publishTime'] as num?)?.toInt()
  ..picUrl = json['picUrl'] as String?
  ..tags = json['tags'] as String?
  ..copyrightId = (json['copyrightId'] as num?)?.toInt()
  ..companyId = (json['companyId'] as num?)?.toInt()
  ..company = json['company'] as String?
  ..description = json['description'] as String?
  ..briefDesc = json['briefDesc'] as String?
  ..artist = json['artist'] == null
      ? null
      : Artist.fromJson(json['artist'] as Map<String, dynamic>)
  ..artists = (json['artists'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList()
  ..isSub = json['isSub'] as bool?
  ..paid = json['paid'] as bool?
  ..onSale = json['onSale'] as bool?;

Map<String, dynamic> _$AlbumToJson(Album instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'subType': instance.subType,
      'mark': instance.mark,
      'size': instance.size,
      'publishTime': instance.publishTime,
      'picUrl': instance.picUrl,
      'tags': instance.tags,
      'copyrightId': instance.copyrightId,
      'companyId': instance.companyId,
      'company': instance.company,
      'description': instance.description,
      'briefDesc': instance.briefDesc,
      'artist': instance.artist,
      'artists': instance.artists,
      'isSub': instance.isSub,
      'paid': instance.paid,
      'onSale': instance.onSale,
    };

AlbumDetailWrap _$AlbumDetailWrapFromJson(Map<String, dynamic> json) =>
    AlbumDetailWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..songs = (json['songs'] as List<dynamic>?)
          ?.map((e) => Song2.fromJson(e as Map<String, dynamic>))
          .toList()
      ..album = json['album'] == null
          ? null
          : Album.fromJson(json['album'] as Map<String, dynamic>);

Map<String, dynamic> _$AlbumDetailWrapToJson(AlbumDetailWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'songs': instance.songs,
      'album': instance.album,
    };

AlbumDetailDynamicWrap _$AlbumDetailDynamicWrapFromJson(
        Map<String, dynamic> json) =>
    AlbumDetailDynamicWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..onSale = json['onSale'] as bool?
      ..isSub = json['isSub'] as bool?
      ..subTime = (json['subTime'] as num?)?.toInt()
      ..commentCount = (json['commentCount'] as num?)?.toInt()
      ..likedCount = (json['likedCount'] as num?)?.toInt()
      ..shareCount = (json['shareCount'] as num?)?.toInt()
      ..subCount = (json['subCount'] as num?)?.toInt();

Map<String, dynamic> _$AlbumDetailDynamicWrapToJson(
        AlbumDetailDynamicWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'onSale': instance.onSale,
      'isSub': instance.isSub,
      'subTime': instance.subTime,
      'commentCount': instance.commentCount,
      'likedCount': instance.likedCount,
      'shareCount': instance.shareCount,
      'subCount': instance.subCount,
    };

AlbumListWrap _$AlbumListWrapFromJson(Map<String, dynamic> json) =>
    AlbumListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..more = json['more'] as bool?
      ..hasMore = json['hasMore'] as bool?
      ..count = (json['count'] as num?)?.toInt()
      ..total = (json['total'] as num?)?.toInt()
      ..albums = (json['albums'] as List<dynamic>?)
          ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$AlbumListWrapToJson(AlbumListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'albums': instance.albums,
    };

ArtistAlbumListWrap _$ArtistAlbumListWrapFromJson(Map<String, dynamic> json) =>
    ArtistAlbumListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..more = json['more'] as bool?
      ..hasMore = json['hasMore'] as bool?
      ..count = (json['count'] as num?)?.toInt()
      ..total = (json['total'] as num?)?.toInt()
      ..time = (json['time'] as num?)?.toInt()
      ..hotAlbums = (json['hotAlbums'] as List<dynamic>?)
          ?.map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList()
      ..artist = Artist.fromJson(json['artist'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistAlbumListWrapToJson(
        ArtistAlbumListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'time': instance.time,
      'hotAlbums': instance.hotAlbums,
      'artist': instance.artist,
    };

MvCreator _$MvCreatorFromJson(Map<String, dynamic> json) => MvCreator()
  ..userId = dynamicToString(json['userId'])
  ..userName = json['userName'] as String?;

Map<String, dynamic> _$MvCreatorToJson(MvCreator instance) => <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
    };

Mv _$MvFromJson(Map<String, dynamic> json) => Mv()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..cover = json['cover'] as String?
  ..playCount = (json['playCount'] as num?)?.toInt()
  ..briefDesc = json['briefDesc'] as String?
  ..desc = json['desc'] as String?
  ..arTransName = json['arTransName'] as String?
  ..artisAlias = json['artisAlias'] as String?
  ..artisTransName = json['artisTransName'] as String?
  ..artistName = json['artistName'] as String?
  ..artistImgUrl = json['artistImgUrl'] as String?
  ..artistId = (json['artistId'] as num?)?.toInt()
  ..mvId = (json['mvId'] as num?)?.toInt()
  ..mvName = json['mvName'] as String?
  ..mvCoverUrl = json['mvCoverUrl'] as String?
  ..duration = (json['duration'] as num?)?.toInt()
  ..publishTime = dynamicToString(json['publishTime'])
  ..publishDate = json['publishDate'] as String?
  ..mark = (json['mark'] as num?)?.toInt()
  ..alg = json['alg'] as String?
  ..artists = (json['artists'] as List<dynamic>?)
      ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MvToJson(Mv instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cover': instance.cover,
      'playCount': instance.playCount,
      'briefDesc': instance.briefDesc,
      'desc': instance.desc,
      'arTransName': instance.arTransName,
      'artisAlias': instance.artisAlias,
      'artisTransName': instance.artisTransName,
      'artistName': instance.artistName,
      'artistImgUrl': instance.artistImgUrl,
      'artistId': instance.artistId,
      'mvId': instance.mvId,
      'mvName': instance.mvName,
      'mvCoverUrl': instance.mvCoverUrl,
      'duration': instance.duration,
      'publishTime': instance.publishTime,
      'publishDate': instance.publishDate,
      'mark': instance.mark,
      'alg': instance.alg,
      'artists': instance.artists,
    };

Mv2 _$Mv2FromJson(Map<String, dynamic> json) => Mv2()
  ..type = (json['type'] as num?)?.toInt()
  ..title = json['title'] as String?
  ..durationms = (json['durationms'] as num?)?.toInt()
  ..playTime = (json['playTime'] as num?)?.toInt()
  ..vid = json['vid'] as String?
  ..coverUrl = json['coverUrl'] as String?
  ..aliaName = json['aliaName'] as String?
  ..transName = json['transName'] as String?
  ..creator = (json['creator'] as List<dynamic>?)
      ?.map((e) => MvCreator.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$Mv2ToJson(Mv2 instance) => <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'durationms': instance.durationms,
      'playTime': instance.playTime,
      'vid': instance.vid,
      'coverUrl': instance.coverUrl,
      'aliaName': instance.aliaName,
      'transName': instance.transName,
      'creator': instance.creator,
    };

Mv3 _$Mv3FromJson(Map<String, dynamic> json) => Mv3()
  ..id = dynamicToString(json['id'])
  ..name = json['name'] as String?
  ..artistName = json['artistName'] as String?
  ..imgurl = json['imgurl'] as String
  ..imgurl16v9 = json['imgurl16v9'] as String
  ..status = (json['status'] as num?)?.toInt()
  ..artist = Artist.fromJson(json['artist'] as Map<String, dynamic>);

Map<String, dynamic> _$Mv3ToJson(Mv3 instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artistName': instance.artistName,
      'imgurl': instance.imgurl,
      'imgurl16v9': instance.imgurl16v9,
      'status': instance.status,
      'artist': instance.artist,
    };

MvListWrap _$MvListWrapFromJson(Map<String, dynamic> json) => MvListWrap()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..more = json['more'] as bool?
  ..hasMore = json['hasMore'] as bool?
  ..count = (json['count'] as num?)?.toInt()
  ..total = (json['total'] as num?)?.toInt()
  ..mvs = (json['mvs'] as List<dynamic>?)
      ?.map((e) => Mv.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$MvListWrapToJson(MvListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'mvs': instance.mvs,
    };

MvListWrap2 _$MvListWrap2FromJson(Map<String, dynamic> json) => MvListWrap2()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..more = json['more'] as bool?
  ..hasMore = json['hasMore'] as bool?
  ..count = (json['count'] as num?)?.toInt()
  ..total = (json['total'] as num?)?.toInt()
  ..data = (json['data'] as List<dynamic>?)
      ?.map((e) => Mv.fromJson(e as Map<String, dynamic>))
      .toList()
  ..updateTime = (json['updateTime'] as num?)?.toInt();

Map<String, dynamic> _$MvListWrap2ToJson(MvListWrap2 instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'data': instance.data,
      'updateTime': instance.updateTime,
    };

PersonalizedMvListWrap _$PersonalizedMvListWrapFromJson(
        Map<String, dynamic> json) =>
    PersonalizedMvListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..result = (json['result'] as List<dynamic>?)
          ?.map((e) => Mv.fromJson(e as Map<String, dynamic>))
          .toList()
      ..category = (json['category'] as num?)?.toInt();

Map<String, dynamic> _$PersonalizedMvListWrapToJson(
        PersonalizedMvListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'result': instance.result,
      'category': instance.category,
    };

ArtistMvListWrap _$ArtistMvListWrapFromJson(Map<String, dynamic> json) =>
    ArtistMvListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..more = json['more'] as bool?
      ..hasMore = json['hasMore'] as bool?
      ..count = (json['count'] as num?)?.toInt()
      ..total = (json['total'] as num?)?.toInt()
      ..mvs = (json['mvs'] as List<dynamic>?)
          ?.map((e) => Mv.fromJson(e as Map<String, dynamic>))
          .toList()
      ..time = (json['time'] as num?)?.toInt();

Map<String, dynamic> _$ArtistMvListWrapToJson(ArtistMvListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'mvs': instance.mvs,
      'time': instance.time,
    };

ArtistNewMvListData _$ArtistNewMvListDataFromJson(Map<String, dynamic> json) =>
    ArtistNewMvListData()
      ..hasMore = json['hasMore'] as bool?
      ..newWorks = (json['newWorks'] as List<dynamic>?)
          ?.map((e) => Mv.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$ArtistNewMvListDataToJson(
        ArtistNewMvListData instance) =>
    <String, dynamic>{
      'hasMore': instance.hasMore,
      'newWorks': instance.newWorks,
    };

ArtistNewMvListWrap _$ArtistNewMvListWrapFromJson(Map<String, dynamic> json) =>
    ArtistNewMvListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data =
          ArtistNewMvListData.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$ArtistNewMvListWrapToJson(
        ArtistNewMvListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

MvDetailWrap _$MvDetailWrapFromJson(Map<String, dynamic> json) => MvDetailWrap()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..loadingPic = json['loadingPic'] as String?
  ..bufferPic = json['bufferPic'] as String?
  ..loadingPicFS = json['loadingPicFS'] as String?
  ..bufferPicFS = json['bufferPicFS'] as String?
  ..subed = json['subed'] as bool?
  ..data = json['data'] == null
      ? null
      : Mv.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$MvDetailWrapToJson(MvDetailWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'loadingPic': instance.loadingPic,
      'bufferPic': instance.bufferPic,
      'loadingPicFS': instance.loadingPicFS,
      'bufferPicFS': instance.bufferPicFS,
      'subed': instance.subed,
      'data': instance.data,
    };

MvDetailInfoWrap _$MvDetailInfoWrapFromJson(Map<String, dynamic> json) =>
    MvDetailInfoWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..likedCount = (json['likedCount'] as num?)?.toInt()
      ..shareCount = (json['shareCount'] as num?)?.toInt()
      ..commentCount = (json['commentCount'] as num?)?.toInt()
      ..liked = json['liked'] as bool?;

Map<String, dynamic> _$MvDetailInfoWrapToJson(MvDetailInfoWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'likedCount': instance.likedCount,
      'shareCount': instance.shareCount,
      'commentCount': instance.commentCount,
      'liked': instance.liked,
    };

MvUrl _$MvUrlFromJson(Map<String, dynamic> json) => MvUrl()
  ..id = dynamicToString(json['id'])
  ..url = json['url'] as String?
  ..md5 = json['md5'] as String?
  ..msg = json['msg'] as String?
  ..r = (json['r'] as num?)?.toInt()
  ..size = (json['size'] as num?)?.toInt()
  ..expi = (json['expi'] as num?)?.toInt()
  ..fee = (json['fee'] as num?)?.toInt()
  ..mvFee = (json['mvFee'] as num?)?.toInt()
  ..st = (json['st'] as num?)?.toInt();

Map<String, dynamic> _$MvUrlToJson(MvUrl instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'md5': instance.md5,
      'msg': instance.msg,
      'r': instance.r,
      'size': instance.size,
      'expi': instance.expi,
      'fee': instance.fee,
      'mvFee': instance.mvFee,
      'st': instance.st,
    };

MvUrlWrap _$MvUrlWrapFromJson(Map<String, dynamic> json) => MvUrlWrap()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..data = MvUrl.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$MvUrlWrapToJson(MvUrlWrap instance) => <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

VideoResolution _$VideoResolutionFromJson(Map<String, dynamic> json) =>
    VideoResolution()
      ..resolution = (json['resolution'] as num?)?.toInt()
      ..size = (json['size'] as num?)?.toInt();

Map<String, dynamic> _$VideoResolutionToJson(VideoResolution instance) =>
    <String, dynamic>{
      'resolution': instance.resolution,
      'size': instance.size,
    };

VideoUrlInfo _$VideoUrlInfoFromJson(Map<String, dynamic> json) => VideoUrlInfo()
  ..id = json['id'] as String
  ..url = json['url'] as String?
  ..size = (json['size'] as num?)?.toInt()
  ..validityTime = (json['validityTime'] as num?)?.toInt()
  ..needPay = json['needPay'] as bool?
  ..r = (json['r'] as num?)?.toInt();

Map<String, dynamic> _$VideoUrlInfoToJson(VideoUrlInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'size': instance.size,
      'validityTime': instance.validityTime,
      'needPay': instance.needPay,
      'r': instance.r,
    };

VideoBase _$VideoBaseFromJson(Map<String, dynamic> json) => VideoBase()
  ..vid = json['vid'] as String?
  ..title = json['title'] as String?
  ..description = json['description'] as String?
  ..scm = json['scm'] as String?
  ..alg = json['alg'] as String?
  ..threadId = json['threadId'] as String?
  ..coverUrl = json['coverUrl'] as String?
  ..previewUrl = json['previewUrl'] as String?
  ..width = (json['width'] as num?)?.toInt()
  ..height = (json['height'] as num?)?.toInt()
  ..praisedCount = (json['praisedCount'] as num?)?.toInt()
  ..playTime = (json['playTime'] as num?)?.toInt()
  ..durationms = (json['durationms'] as num?)?.toInt()
  ..previewDurationms = (json['previewDurationms'] as num?)?.toInt()
  ..commentCount = (json['commentCount'] as num?)?.toInt()
  ..shareCount = (json['shareCount'] as num?)?.toInt()
  ..praised = json['praised'] as bool?
  ..subscribed = json['subscribed'] as bool?
  ..hasRelatedGameAd = json['hasRelatedGameAd'] as bool?
  ..resolutions = (json['resolutions'] as List<dynamic>?)
      ?.map((e) => VideoResolution.fromJson(e as Map<String, dynamic>))
      .toList()
  ..urlInfo = json['urlInfo'] == null
      ? null
      : VideoUrlInfo.fromJson(json['urlInfo'] as Map<String, dynamic>)
  ..videoGroup = (json['videoGroup'] as List<dynamic>?)
      ?.map((e) => VideoMetaItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..relateSong = (json['relateSong'] as List<dynamic>?)
      ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$VideoBaseToJson(VideoBase instance) => <String, dynamic>{
      'vid': instance.vid,
      'title': instance.title,
      'description': instance.description,
      'scm': instance.scm,
      'alg': instance.alg,
      'threadId': instance.threadId,
      'coverUrl': instance.coverUrl,
      'previewUrl': instance.previewUrl,
      'width': instance.width,
      'height': instance.height,
      'praisedCount': instance.praisedCount,
      'playTime': instance.playTime,
      'durationms': instance.durationms,
      'previewDurationms': instance.previewDurationms,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'praised': instance.praised,
      'subscribed': instance.subscribed,
      'hasRelatedGameAd': instance.hasRelatedGameAd,
      'resolutions': instance.resolutions,
      'urlInfo': instance.urlInfo,
      'videoGroup': instance.videoGroup,
      'relateSong': instance.relateSong,
    };

Video _$VideoFromJson(Map<String, dynamic> json) => Video()
  ..vid = json['vid'] as String?
  ..title = json['title'] as String?
  ..description = json['description'] as String?
  ..scm = json['scm'] as String?
  ..alg = json['alg'] as String?
  ..threadId = json['threadId'] as String?
  ..coverUrl = json['coverUrl'] as String?
  ..previewUrl = json['previewUrl'] as String?
  ..width = (json['width'] as num?)?.toInt()
  ..height = (json['height'] as num?)?.toInt()
  ..praisedCount = (json['praisedCount'] as num?)?.toInt()
  ..playTime = (json['playTime'] as num?)?.toInt()
  ..durationms = (json['durationms'] as num?)?.toInt()
  ..previewDurationms = (json['previewDurationms'] as num?)?.toInt()
  ..commentCount = (json['commentCount'] as num?)?.toInt()
  ..shareCount = (json['shareCount'] as num?)?.toInt()
  ..praised = json['praised'] as bool?
  ..subscribed = json['subscribed'] as bool?
  ..hasRelatedGameAd = json['hasRelatedGameAd'] as bool?
  ..resolutions = (json['resolutions'] as List<dynamic>?)
      ?.map((e) => VideoResolution.fromJson(e as Map<String, dynamic>))
      .toList()
  ..urlInfo = json['urlInfo'] == null
      ? null
      : VideoUrlInfo.fromJson(json['urlInfo'] as Map<String, dynamic>)
  ..videoGroup = (json['videoGroup'] as List<dynamic>?)
      ?.map((e) => VideoMetaItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..relateSong = (json['relateSong'] as List<dynamic>?)
      ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
      .toList()
  ..creator = NeteaseUserInfo.fromJson(json['creator'] as Map<String, dynamic>);

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'vid': instance.vid,
      'title': instance.title,
      'description': instance.description,
      'scm': instance.scm,
      'alg': instance.alg,
      'threadId': instance.threadId,
      'coverUrl': instance.coverUrl,
      'previewUrl': instance.previewUrl,
      'width': instance.width,
      'height': instance.height,
      'praisedCount': instance.praisedCount,
      'playTime': instance.playTime,
      'durationms': instance.durationms,
      'previewDurationms': instance.previewDurationms,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'praised': instance.praised,
      'subscribed': instance.subscribed,
      'hasRelatedGameAd': instance.hasRelatedGameAd,
      'resolutions': instance.resolutions,
      'urlInfo': instance.urlInfo,
      'videoGroup': instance.videoGroup,
      'relateSong': instance.relateSong,
      'creator': instance.creator,
    };

Video2 _$Video2FromJson(Map<String, dynamic> json) => Video2()
  ..vid = json['vid'] as String?
  ..title = json['title'] as String?
  ..description = json['description'] as String?
  ..scm = json['scm'] as String?
  ..alg = json['alg'] as String?
  ..threadId = json['threadId'] as String?
  ..coverUrl = json['coverUrl'] as String?
  ..previewUrl = json['previewUrl'] as String?
  ..width = (json['width'] as num?)?.toInt()
  ..height = (json['height'] as num?)?.toInt()
  ..praisedCount = (json['praisedCount'] as num?)?.toInt()
  ..playTime = (json['playTime'] as num?)?.toInt()
  ..durationms = (json['durationms'] as num?)?.toInt()
  ..previewDurationms = (json['previewDurationms'] as num?)?.toInt()
  ..commentCount = (json['commentCount'] as num?)?.toInt()
  ..shareCount = (json['shareCount'] as num?)?.toInt()
  ..praised = json['praised'] as bool?
  ..subscribed = json['subscribed'] as bool?
  ..hasRelatedGameAd = json['hasRelatedGameAd'] as bool?
  ..resolutions = (json['resolutions'] as List<dynamic>?)
      ?.map((e) => VideoResolution.fromJson(e as Map<String, dynamic>))
      .toList()
  ..urlInfo = json['urlInfo'] == null
      ? null
      : VideoUrlInfo.fromJson(json['urlInfo'] as Map<String, dynamic>)
  ..videoGroup = (json['videoGroup'] as List<dynamic>?)
      ?.map((e) => VideoMetaItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..relateSong = (json['relateSong'] as List<dynamic>?)
      ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
      .toList()
  ..creator = (json['creator'] as List<dynamic>?)
      ?.map((e) => NeteaseUserInfo.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$Video2ToJson(Video2 instance) => <String, dynamic>{
      'vid': instance.vid,
      'title': instance.title,
      'description': instance.description,
      'scm': instance.scm,
      'alg': instance.alg,
      'threadId': instance.threadId,
      'coverUrl': instance.coverUrl,
      'previewUrl': instance.previewUrl,
      'width': instance.width,
      'height': instance.height,
      'praisedCount': instance.praisedCount,
      'playTime': instance.playTime,
      'durationms': instance.durationms,
      'previewDurationms': instance.previewDurationms,
      'commentCount': instance.commentCount,
      'shareCount': instance.shareCount,
      'praised': instance.praised,
      'subscribed': instance.subscribed,
      'hasRelatedGameAd': instance.hasRelatedGameAd,
      'resolutions': instance.resolutions,
      'urlInfo': instance.urlInfo,
      'videoGroup': instance.videoGroup,
      'relateSong': instance.relateSong,
      'creator': instance.creator,
    };

VideoMetaItem _$VideoMetaItemFromJson(Map<String, dynamic> json) =>
    VideoMetaItem()
      ..id = dynamicToString(json['id'])
      ..name = json['name'] as String?
      ..url = json['url'] as String?
      ..relatedVideoType = json['relatedVideoType'] as String?
      ..selectTab = json['selectTab'] as bool?;

Map<String, dynamic> _$VideoMetaItemToJson(VideoMetaItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'relatedVideoType': instance.relatedVideoType,
      'selectTab': instance.selectTab,
    };

VideoMetaListWrap _$VideoMetaListWrapFromJson(Map<String, dynamic> json) =>
    VideoMetaListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => VideoMetaItem.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$VideoMetaListWrapToJson(VideoMetaListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

VideoWrap _$VideoWrapFromJson(Map<String, dynamic> json) => VideoWrap()
  ..type = (json['type'] as num?)?.toInt()
  ..displayed = json['displayed'] as bool?
  ..alg = json['alg'] as String?
  ..extAlg = json['extAlg'] as String?
  ..data = Video.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$VideoWrapToJson(VideoWrap instance) => <String, dynamic>{
      'type': instance.type,
      'displayed': instance.displayed,
      'alg': instance.alg,
      'extAlg': instance.extAlg,
      'data': instance.data,
    };

VideoListWrapX _$VideoListWrapXFromJson(Map<String, dynamic> json) =>
    VideoListWrapX()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..more = json['more'] as bool?
      ..hasMore = json['hasMore'] as bool?
      ..count = (json['count'] as num?)?.toInt()
      ..total = (json['total'] as num?)?.toInt()
      ..datas = (json['datas'] as List<dynamic>?)
          ?.map((e) => VideoWrap.fromJson(e as Map<String, dynamic>))
          .toList()
      ..rcmdLimit = (json['rcmdLimit'] as num?)?.toInt();

Map<String, dynamic> _$VideoListWrapXToJson(VideoListWrapX instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'more': instance.more,
      'hasMore': instance.hasMore,
      'count': instance.count,
      'total': instance.total,
      'datas': instance.datas,
      'rcmdLimit': instance.rcmdLimit,
    };

VideoListWrap _$VideoListWrapFromJson(Map<String, dynamic> json) =>
    VideoListWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = (json['data'] as List<dynamic>?)
          ?.map((e) => Video2.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$VideoListWrapToJson(VideoListWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

VideoDetailWrap _$VideoDetailWrapFromJson(Map<String, dynamic> json) =>
    VideoDetailWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..data = Video.fromJson(json['data'] as Map<String, dynamic>);

Map<String, dynamic> _$VideoDetailWrapToJson(VideoDetailWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'data': instance.data,
    };

VideoDetailInfoWrap _$VideoDetailInfoWrapFromJson(Map<String, dynamic> json) =>
    VideoDetailInfoWrap()
      ..code = dynamicToInt(json['code'])
      ..message = json['message'] as String?
      ..msg = json['msg'] as String?
      ..likedCount = (json['likedCount'] as num?)?.toInt()
      ..shareCount = (json['shareCount'] as num?)?.toInt()
      ..commentCount = (json['commentCount'] as num?)?.toInt()
      ..liked = json['liked'] as bool?;

Map<String, dynamic> _$VideoDetailInfoWrapToJson(
        VideoDetailInfoWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'likedCount': instance.likedCount,
      'shareCount': instance.shareCount,
      'commentCount': instance.commentCount,
      'liked': instance.liked,
    };

VideoUrl _$VideoUrlFromJson(Map<String, dynamic> json) => VideoUrl()
  ..id = dynamicToString(json['id'])
  ..url = json['url'] as String?
  ..size = (json['size'] as num?)?.toInt()
  ..validityTime = (json['validityTime'] as num?)?.toInt()
  ..needPay = json['needPay'] as bool?
  ..r = (json['r'] as num?)?.toInt();

Map<String, dynamic> _$VideoUrlToJson(VideoUrl instance) => <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'size': instance.size,
      'validityTime': instance.validityTime,
      'needPay': instance.needPay,
      'r': instance.r,
    };

VideoUrlWrap _$VideoUrlWrapFromJson(Map<String, dynamic> json) => VideoUrlWrap()
  ..code = dynamicToInt(json['code'])
  ..message = json['message'] as String?
  ..msg = json['msg'] as String?
  ..urls = (json['urls'] as List<dynamic>?)
      ?.map((e) => VideoUrl.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$VideoUrlWrapToJson(VideoUrlWrap instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'msg': instance.msg,
      'urls': instance.urls,
    };
