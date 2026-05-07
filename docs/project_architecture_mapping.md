# Bujuan Flutter 架构映射

本项目保留当前 `app/ui/features/data/core/domain` 大边界，并将 `flutter_mid_size_project_architecture_standard.md` 中的中小项目职责映射到现有目录。目录名不机械照搬，职责必须对齐。

## 职责映射

| 标准职责 | 本项目目录 | 说明 |
| --- | --- | --- |
| `main.dart` | `lib/main.dart` | 只负责启动顺序：初始化后 `runApp(const App())`。 |
| `app.dart` | `lib/app.dart` | 应用根组件，承接全局路由、主题和依赖装配入口。 |
| `routes/` | `lib/app/routing/` | 路由声明、生成路由和路由观察者。 |
| `theme/` | `lib/app/theme/` | 颜色、尺寸、主题和视觉缓存适配。 |
| `pages/` | `lib/ui/pages/` | 页面入口和页面局部 widget。 |
| `widgets/` | `lib/ui/widgets/` | 两个及以上页面复用的全局展示组件。 |
| `models/` | `lib/domain/entities/` | 跨层传递的领域数据模型，保持纯 Dart。 |
| `controllers/` | `lib/features/*/*_controller.dart` | 页面状态、页面流程和 UI 命令入口。 |
| `repositories/` | `lib/features/*/*_repository.dart` | 业务数据聚合、缓存策略、领域对象转换和跨 service 编排。 |
| `services/` | `lib/data/*`、`lib/core/*`、`lib/features/*/application/*` | 网络、本地存储、SDK、播放、下载等底层能力或复杂业务应用服务。 |
| `utils/constants/` | `lib/core/*`、`lib/app/theme/*`、`lib/generated/assets.dart` | 通用工具、平台能力、缓存 key、资源常量和视觉常量。 |

## 调用方向

推荐调用链保持为：

```txt
ui page/widget
  -> feature controller
    -> feature repository / feature application service
      -> data source / platform service / SDK facade
        -> DTO / database / network client
```

禁止反向依赖：

- `core/data/domain` 不依赖 `features` 或 `ui`。
- `repository` 不依赖 Controller、Widget、Toast、Dialog、Navigator 或 GetX 容器。
- `controller` 不直接访问 Dio、Hive、CacheBox、Drift DAO、remote data source 或平台 SDK。
- `ui/widgets/common` 只保留通用展示组件，不能读取 feature controller/repository。
- 网易云 DTO、API client 和 endpoint 细节只能留在 `lib/data/netease/api` 与 `lib/data/netease/remote`。

## 组件归属

- 只有一个页面或页面簇使用的 widget 放入对应 `lib/ui/pages/<page>/widgets/`。
- 播放底部面板、顶部搜索面板和壳层专用组件属于 shell 页面局部组件。
- `lib/ui/widgets/common` 用于真正跨页面复用的基础组件，例如加载态、图片、刷新、列表项和布局辅助。

## 状态与副作用

- 继续使用 GetX 作为当前全局状态和依赖容器。
- GetX 只能停留在 UI、controller 和 app bootstrap 边界，不能进入 `core/data/domain`。
- Controller 发布状态和一次性 effect；Toast、Dialog、路由跳转由 page 或 app presentation adapter 消费。
- 登录态、设置项和轻量偏好通过 repository/store 持久化，Controller 不直接触碰 Hive/CacheBox。
