# 注释补齐过程问题记录

本文档记录补齐 public API 注释时顺手发现的工程问题。记录原则：

- 只记录，不在补注释批次中修复。
- 只记录可复现、可定位的问题，避免泛泛而谈。
- 后续集中治理时再按影响范围拆计划和提交。
- 如果同一问题在多个目录重复出现，只记录代表性位置和影响面。

## 记录格式

每条问题按以下格式记录：

- **位置**：文件或目录。
- **现象**：补注释时观察到的具体问题。
- **风险**：后续维护、架构边界或迁移上的影响。
- **建议**：后续集中处理方向。

## 已记录问题

### 1. app theme 常量仍有历史命名和职责混杂

- **位置**：`lib/app/theme/app_colors.dart`、`lib/app/theme/app_text_styles.dart`。
- **现象**：`AppColors` 与 `AppTheme` 同时承担基础色板和主题配置；部分颜色命名偏视觉结果，如 `min`、`middle`、`max`、`empty`，难以表达业务或 UI 语义。`app_text_styles.dart` 使用全局可变 `TextStyle` 顶层变量，而不是不可变常量或主题扩展。
- **风险**：后续 UI 调整时难以判断某个颜色或字体样式的真实用途，容易继续扩大“一处常量到处复用”的隐式耦合。
- **建议**：后续把主题 token、业务状态色、组件专用样式拆开；顶层样式优先改为 `const` 或集中进主题扩展。

### 2. presentation adapter 中仍暴露 GetX Rx 类型

- **位置**：`lib/app/presentation_adapters/shell_playback_port.dart`、`lib/app/presentation_adapters/shell_user_port.dart`。
- **现象**：Shell 端口为了兼容现有 GetX 展示层，仍把 `Rx` 类型作为端口返回值。
- **风险**：虽然该端口位于 presentation adapter 层，短期可接受，但未来迁 Riverpod 时 Shell 与 GetX 的绑定面仍偏大。
- **建议**：后续将 Shell 端口输出收敛为 immutable view state 或 `ValueListenable`/普通 getter，避免跨 adapter 传播 GetX 类型。

### 3. FeatureControllerFactory 仍直接组装部分 application service

- **位置**：`lib/app/bootstrap/feature_controller_factory.dart`。
- **现象**：`playlistPage()` 内部即时创建 `PlaylistDetailService`，而不是完全由 registrar 统一注册后注入。
- **风险**：组合根职责还不完全一致，同类 application service 有的在 registrar 注册，有的在 factory 内创建，后续排查依赖图时需要多看一个入口。
- **建议**：后续把页面级 application service 的创建策略统一：要么全部 registrar 注册，要么明确 factory 只负责页面生命周期型对象。

### 4. PresentationAdapterRegistrar 仍集中处理多类 UI adapter

- **位置**：`lib/app/bootstrap/registrars/presentation_adapter_registrar.dart`。
- **现象**：toast、播放主题、Shell port、设置页导航、评论内容构建都集中在同一个 registrar。
- **风险**：文件暂时不大，但职责横跨 playback、shell、settings、comment，后续新增 adapter 时容易重新变成展示层装配聚合点。
- **建议**：后续按 feature 或 adapter 类型拆成小 registrar，但继续保持 `AppBinding` 单一入口。

### 5. 路由观察者只有日志，缺少可替换端口

- **位置**：`lib/app/routing/app_router_observer.dart`。
- **现象**：路由切换日志直接写在 observer 中。
- **风险**：如果后续要接入埋点、调试开关或测试替身，当前 observer 会继续承担策略判断。
- **建议**：后续抽出轻量 navigation logging/analytics port，由 observer 只负责转发路由事件。
