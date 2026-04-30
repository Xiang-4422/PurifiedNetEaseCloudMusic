# Netease 数据接入架构

`lib/data/netease` 是网易云音乐远程数据接入层。它负责把网易云接口、Cookie、加密、DTO 和领域实体转换隔离在 data 层内，对上只暴露面向 repository 使用的 remote data source 和少量 source 门面。

本目录不属于业务编排层，也不属于展示层。页面、controller、application service 不应直接依赖 `api` 里的 SDK/DTO。

## 目录结构

```text
lib/data/netease/
├── api/
│   ├── netease_music_api.dart
│   └── src/
│       ├── client/
│       │   ├── dio_ext.dart
│       │   ├── encrypt_ext.dart
│       │   ├── netease_api.dart
│       │   ├── netease_bean.dart
│       │   └── netease_handler.dart
│       ├── endpoints/
│       │   └── */api.dart
│       ├── models/
│       │   ├── common/bean.dart
│       │   ├── */bean.dart
│       │   └── */bean.g.dart
├── mappers/
│   ├── netease_album_mapper.dart
│   ├── netease_artist_mapper.dart
│   ├── netease_comment_mapper.dart
│   ├── netease_playlist_mapper.dart
│   ├── netease_radio_mapper.dart
│   └── netease_track_mapper.dart
├── remote/
│   ├── netease_album_remote_data_source.dart
│   ├── netease_artist_remote_data_source.dart
│   ├── netease_auth_remote_data_source.dart
│   ├── netease_cloud_remote_data_source.dart
│   ├── netease_comment_remote_data_source.dart
│   ├── netease_explore_remote_data_source.dart
│   ├── netease_playlist_remote_data_source.dart
│   ├── netease_radio_remote_data_source.dart
│   ├── netease_search_remote_data_source.dart
│   └── netease_user_remote_data_source.dart
├── netease_music_source.dart
└── netease_remote_bootstrap.dart
```

## 分层职责

### `api/`

`api/` 是网易云 SDK 兼容层，保留接口请求、响应 DTO、Cookie、加密、Dio 拦截器和登录态刷新逻辑。

- `api/netease_music_api.dart` 是对外 export 入口。
- `api/client/netease_api.dart` 定义 `NeteaseMusicApi`，通过 mixin 组合登录、播放、搜索、用户、动态、播客等接口。
- `api/client/dio_ext.dart`、`encrypt_ext.dart`、`netease_handler.dart` 负责请求参数、加密、Cookie 和响应处理。
- `api/client/netease_bean.dart` 汇总 DTO export 和网易云接口状态码。
- `api/endpoints/*/api.dart` 是按接口域拆分的请求方法。
- `api/models/*/bean.dart` 是接口 DTO。
- `api/models/*/bean.g.dart` 是 JSON 序列化生成文件，不手写业务逻辑。
- `api/models/common/bean.dart` 是各接口共享的基础响应 DTO。

这一层可以依赖 Dio、Cookie、JSON DTO 和网易云协议细节，但不应依赖 feature、controller、repository 或 Flutter UI。

### `mappers/`

`mappers/` 是 DTO 到领域实体的转换层。

典型职责：

- 给网易云资源补 `netease:` source 前缀。
- 将 `Song`、`Song2`、`PlayList`、`Album`、`Artist` 等 DTO 转换成 `Track`、`PlaylistEntity`、`AlbumEntity`、`ArtistEntity`。
- 将接口里不稳定的字段、空值和兼容字段收口成 domain 可理解的结构。

mapper 是 data/domain 边界，允许 import 网易云 DTO 和 domain entity，但不应 import presentation、controller、repository 或 GetX。

### `remote/`

`remote/` 存放 repository 面向网易云远程能力的主要入口。它负责调用 `NeteaseMusicApi`，再通过 mapper 返回 domain entity、轻量结果记录或 data 层约定的快照。

按业务域拆分：

- `netease_auth_remote_data_source.dart`：登录、登出、二维码、账号状态。
- `netease_user_remote_data_source.dart`：用户资料、喜欢歌曲、用户歌单、推荐数据。
- `netease_playlist_remote_data_source.dart`：歌单详情、歌曲分页、订阅和歌单歌曲操作。
- `netease_album_remote_data_source.dart`：专辑详情和动态统计。
- `netease_artist_remote_data_source.dart`：歌手详情、歌曲、专辑、MV。
- `netease_search_remote_data_source.dart`：搜索入口。
- `netease_comment_remote_data_source.dart`：评论列表、楼层、发送、点赞等。
- `netease_cloud_remote_data_source.dart`：云盘歌曲。
- `netease_radio_remote_data_source.dart`：电台、播客相关远程数据。
- `netease_explore_remote_data_source.dart`：首页、榜单、发现页远程数据。

remote data source 可以知道网易云接口和 mapper，但不负责页面流程、缓存策略编排、播放队列模式切换或 UI 提示。

### `netease_music_source.dart`

`NeteaseMusicSource` 是更通用的音乐来源门面，用于按统一 source 概念访问网易云资源。

它提供搜索、获取曲目、获取播放地址、获取歌词、获取歌单等能力，并把网易云 id 规范化为项目内部的 source id 形式。

### `netease_remote_bootstrap.dart`

`NeteaseRemoteBootstrap` 是远程能力初始化入口，屏蔽底层 SDK 初始化细节。应用启动只应通过它初始化网易云远程能力，而不是直接关心 SDK 的文件路径、Cookie 和 Dio 组合方式。

## 依赖方向

当前推荐依赖方向：

```text
repository
  -> remote/netease_*_remote_data_source
    -> NeteaseMusicApi
    -> api/endpoints/* + api/models/*
    -> mapper
      -> domain entity
```

允许：

- repository 构造函数注入 remote data source。
- remote data source 调用 `NeteaseMusicApi`。
- remote data source 使用 mapper 返回 domain entity。
- mapper 同时依赖网易云 DTO 和 domain entity。

禁止：

- presentation/controller/application 直接 import `data/netease/api`。
- feature 页面直接调用 `NeteaseMusicApi`。
- mapper 或 remote data source 使用 GetX、Flutter UI、toast、dialog、route。
- repository 把网易云 DTO 透传给 presentation。
- domain 依赖本目录的任何文件。

## 数据流示例

以歌单详情为例：

```text
PlaylistRepository
  -> NeteasePlaylistRemoteDataSource.fetchPlaylistSnapshot()
    -> NeteaseMusicApi().playListDetail()
      -> SinglePlayListWrap / PlayList / PlayTrackId
    -> NeteasePlaylistMapper.fromPlaylist()
      -> PlaylistEntity
```

如果页面要加载歌单，不应绕过 repository 去直接访问 `NeteasePlaylistRemoteDataSource` 或 `NeteaseMusicApi`。页面流程应停留在 controller/application service，远程细节停留在 repository/data source。

## DTO 与生成文件

`api/models/*/bean.dart` 是接口 DTO，字段通常直接跟随网易云接口命名。这里会出现缩写字段、历史兼容字段和服务端拼写错误字段，这是 SDK 边界的正常现象。

维护规则：

- 不为了“好看”改 DTO 字段名，除非同步调整 JSON 映射和所有调用点。
- `*.g.dart` 由生成器维护，不手写修改。
- DTO 注释描述接口语义、单位、可空含义或兼容原因。
- DTO 不承载业务规则，不转换成 view model。

## 扩展新接口的步骤

1. 在 `api/endpoints/<domain>/api.dart` 增加底层接口方法。
2. 在对应 `api/models/<domain>/bean.dart` 增加 DTO，并保持 JSON 映射完整。
3. 如果上层需要 domain entity，在 `mappers/` 增加或扩展 mapper。
4. 在对应 `remote/netease_*_remote_data_source.dart` 增加远程数据源方法。
5. repository 通过构造函数注入并调用 remote data source。
6. application/controller 继续依赖 repository 或 application service，不直接依赖 SDK。

## 架构边界

这个目录的目标是隔离网易云协议变化。只要边界稳定，未来替换状态管理、拆 repository、迁移 provider 图，都不需要改动 SDK DTO 和大部分 mapper。

因此这里的核心要求不是“业务代码最少”，而是：

- 网易云接口细节不要向上泄漏。
- domain entity 不反向依赖 data。
- feature/presentation 不直接碰低层 SDK。
- remote data source 只做远程访问和数据转换，不做 UI 或页面流程编排。
