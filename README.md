# PurifiedNetEaseCloudMusic

项目正式架构与重构计划文档如下：

- [技术架构设计](./docs/technical-architecture.md)
- [重构计划与进度](./docs/refactor-plan.md)
- [代码注释规范](./docs/comment-guidelines.md)

## 当前结论

本项目后续采用“基于现有仓库的渐进式重构”策略，不做一次性推倒重来。

长期目标已经明确升级为：

- 本地优先的多源音乐播放器
- 支持远程源、本地媒体库、离线缓存与无网络可用
- UI 与播放器优先消费本地数据，而不是直接依赖远程接口返回

- 保留现有稳定基础设施：`Flutter`、`auto_route`、`Dio`、`Hive`、`just_audio + audio_service`
- 现阶段不以迁移状态管理框架为第一目标
- 优先修正职责边界：页面不再直调业务流程，Controller 不再继续膨胀，数据访问统一收口到 `Repository`
- 后续将逐步建立统一领域实体、本地媒体库、`MusicSource` 抽象与离线能力
- 后续所有架构调整与进度更新，以文档为准

## 文档使用规则

- 技术方案、目录方案、边界约束，以 [`docs/technical-architecture.md`](./docs/technical-architecture.md) 为准
- 分阶段任务、完成情况、阻塞项，以 [`docs/refactor-plan.md`](./docs/refactor-plan.md) 为准
- 后续每完成一个阶段性改动，都需要同步更新进度文档
- 更完整的后续任务拆解、执行优先级和关键决策，也已固定在 [`docs/refactor-plan.md`](./docs/refactor-plan.md)
