# PurifiedNetEaseCloudMusic

项目正式架构与重构计划文档如下：

- [技术架构设计](./docs/technical-architecture.md)
- [重构计划与进度](./docs/refactor-plan.md)

## 当前结论

本项目后续采用“基于现有仓库的渐进式重构”策略，不做一次性推倒重来。

- 保留现有稳定基础设施：`Flutter`、`auto_route`、`Dio`、`Hive`、`just_audio + audio_service`
- 现阶段不以迁移状态管理框架为第一目标
- 优先修正职责边界：页面不再直调业务流程，Controller 不再继续膨胀，数据访问统一收口到 `Repository`
- 后续所有架构调整与进度更新，以文档为准

## 文档使用规则

- 技术方案、目录方案、边界约束，以 [`docs/technical-architecture.md`](./docs/technical-architecture.md) 为准
- 分阶段任务、完成情况、阻塞项，以 [`docs/refactor-plan.md`](./docs/refactor-plan.md) 为准
- 后续每完成一个阶段性改动，都需要同步更新进度文档
