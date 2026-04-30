import 'package:bujuan/data/netease/api/models/common/bean.dart';

/// 云盘歌曲列表响应。
class CloudEntity extends ServerStatusBean {
  // int? code;
  /// 云盘歌曲数据列表。
  List<CloudData>? data;

  /// 当前云盘已使用容量。
  String? size;

  /// 云盘升级标记。
  num? upgradeSign;

  /// 云盘歌曲总数。
  num? count;

  /// 是否还有下一页数据。
  bool? hasMore;

  /// 云盘最大容量。
  String? maxSize;

  /// 创建云盘歌曲列表响应。
  CloudEntity(
      {this.data,
      this.size,
      this.upgradeSign,
      this.count,
      this.hasMore,
      this.maxSize});

  /// 从 JSON 构建云盘歌曲列表响应。
  CloudEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <CloudData>[];
      for (var v in (json['data'] as List)) {
        (data ?? []).add(CloudData.fromJson(v));
      }
    }
    size = json['size'];
    upgradeSign = json['upgradeSign'];
    count = json['count'];
    hasMore = json['hasMore'];
    maxSize = json['maxSize'];
  }

  /// 转换为 JSON。
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = (this.data ?? []).map((v) => v.toJson()).toList();
    }
    data['size'] = size;
    data['upgradeSign'] = upgradeSign;
    data['count'] = count;
    data['hasMore'] = hasMore;
    data['maxSize'] = maxSize;
    return data;
  }
}

/// 云盘中的单首歌曲条目。
class CloudData {
  /// 歌曲名称。
  String? songName;

  /// 云盘原始文件名。
  String? fileName;

  /// 加入云盘时间戳。
  num? addTime;

  /// 歌手名称。
  String? artist;

  /// 专辑名称。
  String? album;

  /// 歌词 id。
  String? lyricId;

  /// 音频码率。
  num? bitrate;

  /// 接口返回的标准歌曲对象。
  CloudDataSimplesong? simpleSong;

  /// 云盘条目版本。
  num? version;

  /// 封面资源 id。
  num? cover;

  /// 封面字符串 id。
  String? coverId;

  /// 文件大小。
  num? fileSize;

  /// 歌曲 id。
  num? songId;

  /// 创建云盘歌曲条目。
  CloudData(
      {this.songName,
      this.fileName,
      this.addTime,
      this.artist,
      this.album,
      this.lyricId,
      this.bitrate,
      this.simpleSong,
      this.version,
      this.cover,
      this.coverId,
      this.fileSize,
      this.songId});

  /// 从 JSON 构建云盘歌曲条目。
  CloudData.fromJson(Map<String, dynamic> json) {
    songName = json['songName'];
    fileName = json['fileName'];
    addTime = json['addTime'];
    artist = json['artist'];
    album = json['album'];
    lyricId = json['lyricId'];
    bitrate = json['bitrate'];
    simpleSong = json['simpleSong'] != null
        ? CloudDataSimplesong.fromJson(json['simpleSong'])
        : null;
    version = json['version'];
    cover = json['cover'];
    coverId = json['coverId'];
    fileSize = json['fileSize'];
    songId = json['songId'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['songName'] = songName;
    data['fileName'] = fileName;
    data['addTime'] = addTime;
    data['artist'] = artist;
    data['album'] = album;
    data['lyricId'] = lyricId;
    data['bitrate'] = bitrate;
    if (simpleSong != null) {
      data['simpleSong'] = simpleSong?.toJson();
    }
    data['version'] = version;
    data['cover'] = cover;
    data['coverId'] = coverId;
    data['fileSize'] = fileSize;
    data['songId'] = songId;
    return data;
  }
}

/// 云盘歌曲接口返回的标准歌曲数据。
class CloudDataSimplesong {
  /// 歌曲序号。
  num? no;

  /// 铃声或相关资源标记。
  String? rt;

  /// 版权状态。
  num? copyright;

  /// 付费类型。
  num? fee;

  /// 重定向播放地址。
  dynamic rurl;

  /// 当前歌曲播放权限。
  CloudDataSimplesongPrivilege? privilege;

  /// 音乐状态字段。
  num? mst;

  /// 播放状态字段。
  num? pst;

  /// 热度。
  num? pop;

  /// 时长，单位为毫秒。
  int? dt;

  /// 资源类型。
  num? rtype;

  /// 云盘源歌曲 id。
  num? sId;

  /// 歌曲 id。
  num? id;

  /// 歌曲状态。
  num? st;

  /// 附加信息。
  dynamic a;

  /// CD 编号。
  String? cd;

  /// 发布时间戳。
  num? publishTime;

  /// 版权来源标记。
  String? cf;

  /// 高音质音频信息。
  dynamic h;

  /// MV id。
  num? mv;

  /// 专辑信息。
  CloudDataSimplesongAl? al;

  /// 低音质音频信息。
  CloudDataSimplesongL? l;

  /// 中音质音频信息。
  CloudDataSimplesongM? m;

  /// 版权方 id。
  num? cp;

  /// 播客节目 id。
  num? djId;

  /// 彩铃标记。
  String? crbt;

  /// 歌手列表。
  List<CloudDataSimplesongAr>? ar;

  /// 相关资源地址。
  dynamic rtUrl;

  /// 文件类型。
  num? ftype;

  /// 歌曲类型标记。
  num? t;

  /// 歌曲版本。
  num? v;

  /// 歌曲名称。
  String? name;

  /// 创建标准歌曲数据。
  CloudDataSimplesong(
      {this.no,
      this.rt,
      this.copyright,
      this.fee,
      this.rurl,
      this.privilege,
      this.mst,
      this.pst,
      this.pop,
      this.dt,
      this.rtype,
      this.sId,
      this.id,
      this.st,
      this.a,
      this.cd,
      this.publishTime,
      this.cf,
      this.h,
      this.mv,
      this.al,
      this.l,
      this.m,
      this.cp,
      this.djId,
      this.crbt,
      this.ar,
      this.rtUrl,
      this.ftype,
      this.t,
      this.v,
      this.name});

  /// 从 JSON 构建标准歌曲数据。
  CloudDataSimplesong.fromJson(Map<String, dynamic> json) {
    no = json['no'];
    rt = json['rt'];
    copyright = json['copyright'];
    fee = json['fee'];
    rurl = json['rurl'];
    privilege = json['privilege'] != null
        ? CloudDataSimplesongPrivilege.fromJson(json['privilege'])
        : null;
    mst = json['mst'];
    pst = json['pst'];
    pop = json['pop'];
    dt = json['dt'];
    rtype = json['rtype'];
    sId = json['s_id'];
    id = json['id'];
    st = json['st'];
    a = json['a'];
    cd = json['cd'];
    publishTime = json['publishTime'];
    cf = json['cf'];
    h = json['h'];
    mv = json['mv'];
    al = json['al'] != null ? CloudDataSimplesongAl.fromJson(json['al']) : null;
    l = json['l'] != null ? CloudDataSimplesongL.fromJson(json['l']) : null;
    m = json['m'] != null ? CloudDataSimplesongM.fromJson(json['m']) : null;
    cp = json['cp'];
    djId = json['djId'];
    crbt = json['crbt'];
    if (json['ar'] != null) {
      ar = <CloudDataSimplesongAr>[];
      for (var v in (json['ar'] as List)) {
        (ar ?? []).add(CloudDataSimplesongAr.fromJson(v));
      }
    }
    rtUrl = json['rtUrl'];
    ftype = json['ftype'];
    t = json['t'];
    v = json['v'];
    name = json['name'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['no'] = no;
    data['rt'] = rt;
    data['copyright'] = copyright;
    data['fee'] = fee;
    data['rurl'] = rurl;
    if (privilege != null) {
      data['privilege'] = privilege?.toJson();
    }
    data['mst'] = mst;
    data['pst'] = pst;
    data['pop'] = pop;
    data['dt'] = dt;
    data['rtype'] = rtype;
    data['s_id'] = sId;
    data['id'] = id;
    data['st'] = st;
    data['a'] = a;
    data['cd'] = cd;
    data['publishTime'] = publishTime;
    data['cf'] = cf;
    data['h'] = h;
    data['mv'] = mv;
    if (al != null) {
      data['al'] = al?.toJson();
    }
    if (l != null) {
      data['l'] = l?.toJson();
    }
    if (m != null) {
      data['m'] = m?.toJson();
    }
    data['cp'] = cp;
    data['djId'] = djId;
    data['crbt'] = crbt;
    if (ar != null) {
      data['ar'] = (ar ?? []).map((v) => v.toJson()).toList();
    }
    data['rtUrl'] = rtUrl;
    data['ftype'] = ftype;
    data['t'] = t;
    data['v'] = v;
    data['name'] = name;
    return data;
  }
}

/// 云盘歌曲播放权限信息。
class CloudDataSimplesongPrivilege {
  /// 权限状态。
  num? st;

  /// 权限标记。
  num? flag;

  /// 子权限标记。
  num? subp;

  /// 免费可播放码率。
  num? fl;

  /// 付费类型。
  num? fee;

  /// 下载可用码率。
  num? dl;

  /// 版权方 id。
  num? cp;

  /// 是否云盘歌曲。
  bool? cs;

  /// 是否需要提示。
  bool? toast;

  /// 最大码率。
  num? maxbr;

  /// 歌曲 id。
  num? id;

  /// 播放可用码率。
  num? pl;

  /// 试听可用码率。
  num? sp;

  /// 是否已付费。
  num? payed;

  /// 创建播放权限信息。
  CloudDataSimplesongPrivilege(
      {this.st,
      this.flag,
      this.subp,
      this.fl,
      this.fee,
      this.dl,
      this.cp,
      this.cs,
      this.toast,
      this.maxbr,
      this.id,
      this.pl,
      this.sp,
      this.payed});

  /// 从 JSON 构建播放权限信息。
  CloudDataSimplesongPrivilege.fromJson(Map<String, dynamic> json) {
    st = json['st'];
    flag = json['flag'];
    subp = json['subp'];
    fl = json['fl'];
    fee = json['fee'];
    dl = json['dl'];
    cp = json['cp'];
    cs = json['cs'];
    toast = json['toast'];
    maxbr = json['maxbr'];
    id = json['id'];
    pl = json['pl'];
    sp = json['sp'];
    payed = json['payed'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['st'] = st;
    data['flag'] = flag;
    data['subp'] = subp;
    data['fl'] = fl;
    data['fee'] = fee;
    data['dl'] = dl;
    data['cp'] = cp;
    data['cs'] = cs;
    data['toast'] = toast;
    data['maxbr'] = maxbr;
    data['id'] = id;
    data['pl'] = pl;
    data['sp'] = sp;
    data['payed'] = payed;
    return data;
  }
}

/// 云盘歌曲专辑信息。
class CloudDataSimplesongAl {
  /// 专辑封面地址。
  String? picUrl;

  /// 专辑名称。
  String? name;

  /// 专辑 id。
  num? id;

  /// 专辑封面资源 id。
  num? pic;

  /// 创建专辑信息。
  CloudDataSimplesongAl({this.picUrl, this.name, this.id, this.pic});

  /// 从 JSON 构建专辑信息。
  CloudDataSimplesongAl.fromJson(Map<String, dynamic> json) {
    picUrl = json['picUrl'];
    name = json['name'];
    id = json['id'];
    pic = json['pic'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['picUrl'] = picUrl;
    data['name'] = name;
    data['id'] = id;
    data['pic'] = pic;
    return data;
  }
}

/// 云盘歌曲低音质音频信息。
class CloudDataSimplesongL {
  /// 码率。
  num? br;

  /// 文件 id。
  num? fid;

  /// 文件大小。
  num? size;

  /// 音量增益。
  double? vd;

  /// 创建低音质音频信息。
  CloudDataSimplesongL({this.br, this.fid, this.size, this.vd});

  /// 从 JSON 构建低音质音频信息。
  CloudDataSimplesongL.fromJson(Map<String, dynamic> json) {
    br = json['br'];
    fid = json['fid'];
    size = json['size'];
    vd = json['vd'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['br'] = br;
    data['fid'] = fid;
    data['size'] = size;
    data['vd'] = vd;
    return data;
  }
}

/// 云盘歌曲中音质音频信息。
class CloudDataSimplesongM {
  /// 码率。
  num? br;

  /// 文件 id。
  num? fid;

  /// 文件大小。
  num? size;

  /// 音量增益。
  double? vd;

  /// 创建中音质音频信息。
  CloudDataSimplesongM({this.br, this.fid, this.size, this.vd});

  /// 从 JSON 构建中音质音频信息。
  CloudDataSimplesongM.fromJson(Map<String, dynamic> json) {
    br = json['br'];
    fid = json['fid'];
    size = json['size'];
    vd = json['vd'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['br'] = br;
    data['fid'] = fid;
    data['size'] = size;
    data['vd'] = vd;
    return data;
  }
}

/// 云盘歌曲歌手信息。
class CloudDataSimplesongAr {
  /// 歌手名称。
  String? name;

  /// 歌手 id。
  num? id;

  /// 创建歌手信息。
  CloudDataSimplesongAr({this.name, this.id});

  /// 从 JSON 构建歌手信息。
  CloudDataSimplesongAr.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }

  /// 转换为 JSON。
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
