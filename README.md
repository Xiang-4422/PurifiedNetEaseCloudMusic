# PurifiedNetEaseCloudMusic

README 是本项目文档入口。`docs/` 下只保留少量人工维护文档：

1. [项目架构](./docs/项目架构.md)
2. [重构路线](./docs/重构路线.md)
3. [网易云接口开发包](./docs/网易云接口开发包.md)
4. [代码注释规范](./docs/代码注释规范.md)
5. [Flutter 中小项目架构规范](./docs/中小项目架构规范.md)

## 当前结论

项目当前采用“本地优先 + feature-first + 渐进瘦身”的工程方向，不做一次性重写，也不继续追加低价值分层。

- 普通页面默认走 `Page/View + Controller -> Repository`。
- 全局播放能力允许页面直接使用 `PlayerController`，不用再通过空壳 port/usecase 转发。
- 业务事实来源收敛为 `Drift` 本地数据库和网络刷新；自有业务 `snapshot` 持久化已经移除。
- `Hive` 只保留登录态、设置项和轻量视觉缓存。
- 继续保留 `Flutter`、`GetX`、`auto_route`、`Dio`、`Drift`、`Hive`、`just_audio + audio_service`。
- 硬边界仍然保留：`core/data/domain` 不依赖 Flutter/GetX，presentation 不直接访问 DAO、Drift data source 或网易云 remote data source。

## 文档使用规则

- 技术方案、目录方案、本地缓存和边界约束，以 [`docs/项目架构.md`](./docs/项目架构.md) 为准。
- 后续整理项、阶段路线和 UI 方向，以 [`docs/重构路线.md`](./docs/重构路线.md) 为准。
- 复刻并跟随上游网易云接口仓库，以 [`docs/网易云接口开发包.md`](./docs/网易云接口开发包.md) 为准。
- 代码注释要求，以 [`docs/代码注释规范.md`](./docs/代码注释规范.md) 为准。
- 每次阶段性架构调整后，同步更新相关文档，避免文档继续描述已删除的结构。
