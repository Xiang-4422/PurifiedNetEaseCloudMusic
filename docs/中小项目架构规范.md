# Flutter 中小项目架构规范

## 1. 目标

本规范适用于中小型 Flutter 项目，目标是：

- 目录清晰，代码容易查找
- 职责明确，避免页面代码过重
- 不过度设计，不强制套用复杂架构
- 方便后期从小项目平滑演进到中大型项目

本规范不追求严格的 Clean Architecture，而是采用更适合中小项目的实用分层方式。

---

## 2. 基础目录结构

推荐目录结构如下：

```txt
lib/
  main.dart
  app.dart

  config/
  routes/
  theme/

  pages/
  widgets/
  models/
  services/
  repositories/
  utils/
  constants/
```

完整示例：

```txt
lib/
  main.dart
  app.dart

  config/
    app_config.dart
    env.dart

  routes/
    app_router.dart
    route_names.dart

  theme/
    app_theme.dart
    app_colors.dart
    app_text_styles.dart

  pages/
    home/
      home_page.dart
      home_controller.dart
      widgets/
        home_header.dart
        home_card.dart

    login/
      login_page.dart
      login_controller.dart
      widgets/
        login_form.dart

    profile/
      profile_page.dart
      profile_controller.dart
      widgets/

    about_page.dart
    terms_page.dart

  widgets/
    primary_button.dart
    loading_view.dart
    empty_view.dart
    error_view.dart

  models/
    user.dart
    product.dart
    pagination.dart

  services/
    api_service.dart
    auth_service.dart
    storage_service.dart

  repositories/
    user_repository.dart
    product_repository.dart
    auth_repository.dart

  utils/
    validators.dart
    formatters.dart
    logger.dart

  constants/
    api_paths.dart
    storage_keys.dart
    assets.dart
```

---

## 3. 目录职责说明

### 3.1 `main.dart`

应用入口，只负责启动应用。

```dart
void main() {
  runApp(const App());
}
```

不建议在 `main.dart` 中写大量初始化逻辑。

如果存在初始化逻辑，例如环境配置、日志、存储、依赖初始化，可以封装到单独方法中。

---

### 3.2 `app.dart`

应用根组件，负责：

- MaterialApp / CupertinoApp
- 全局主题
- 路由配置
- 全局 Provider / Riverpod Scope / 依赖注入入口

示例：

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: RouteNames.home,
    );
  }
}
```

---

### 3.3 `config/`

存放应用配置，例如：

- 环境配置
- baseUrl
- debug 开关
- flavor 配置

示例：

```txt
config/
  app_config.dart
  env.dart
```

---

### 3.4 `routes/`

集中管理路由。

```txt
routes/
  app_router.dart
  route_names.dart
```

`route_names.dart`：

```dart
class RouteNames {
  static const home = '/';
  static const login = '/login';
  static const profile = '/profile';
}
```

`app_router.dart`：

```dart
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
```

中小项目可以先使用原生路由。若项目存在登录拦截、深链接、复杂嵌套路由、多 Tab 路由等需求，可以考虑使用 `go_router`。

---

### 3.5 `theme/`

存放主题相关代码。

```txt
theme/
  app_theme.dart
  app_colors.dart
  app_text_styles.dart
```

职责包括：

- 颜色
- 字体
- 圆角
- 间距
- 主题配置

页面中不建议大量散落颜色值和字体样式。

不推荐：

```dart
Text(
  '标题',
  style: TextStyle(
    color: Color(0xFF333333),
    fontSize: 18,
  ),
)
```

推荐：

```dart
Text(
  '标题',
  style: AppTextStyles.title,
)
```

---

### 3.6 `pages/`

存放页面模块。

简单页面可以直接放在 `pages/` 下：

```txt
pages/
  about_page.dart
  terms_page.dart
```

复杂页面建议单独建目录：

```txt
pages/
  login/
    login_page.dart
    login_controller.dart
    widgets/
      login_form.dart
```

页面目录中可以包含：

- `xxx_page.dart`
- `xxx_controller.dart`
- `xxx_state.dart`，仅复杂状态需要
- `widgets/`，当前页面专用组件

---

### 3.7 `widgets/`

存放全局通用组件。

```txt
widgets/
  primary_button.dart
  loading_view.dart
  empty_view.dart
  error_view.dart
  app_dialog.dart
```

判断规则：

- 两个及以上页面复用：放到 `lib/widgets/`
- 只有当前页面使用：放到当前页面的 `widgets/`

---

### 3.8 `models/`

存放数据模型。

```txt
models/
  user.dart
  product.dart
  order.dart
  pagination.dart
```

Model 只负责：

- 数据字段定义
- JSON 序列化 / 反序列化
- 简单数据转换

示例：

```dart
class User {
  final String id;
  final String name;
  final String? avatar;

  const User({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }
}
```

不建议在 Model 中存放页面状态。

不推荐：

```dart
class User {
  bool isLoading = false;
}
```

---

### 3.9 `services/`

存放底层能力封装。

常见 Service：

```txt
services/
  api_service.dart
  storage_service.dart
  auth_service.dart
  upload_service.dart
  location_service.dart
```

Service 负责：

- 网络请求
- 本地存储
- 文件上传
- 定位
- 权限
- 第三方 SDK 调用

Service 不应该依赖页面，也不应该知道具体业务页面。

---

### 3.10 `repositories/`

存放业务数据封装。

Repository 负责连接 Controller 和 Service。

它可以处理：

- 调用 API
- 转换 Model
- 缓存策略
- 多个 Service 的组合
- 业务层面的数据处理

示例：

```dart
class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<User> getCurrentUser() async {
    final json = await apiService.get(ApiPaths.userInfo);
    return User.fromJson(json);
  }
}
```

页面和 Controller 不应该直接写网络请求细节。

---

### 3.11 `utils/`

存放通用工具函数。

```txt
utils/
  validators.dart
  formatters.dart
  logger.dart
  date_utils.dart
```

工具类应该尽量保持纯函数或无状态。

---

### 3.12 `constants/`

存放常量。

```txt
constants/
  api_paths.dart
  storage_keys.dart
  assets.dart
```

示例：

```dart
class ApiPaths {
  static const login = '/auth/login';
  static const userInfo = '/user/me';
}
```

```dart
class StorageKeys {
  static const token = 'token';
  static const userInfo = 'user_info';
}
```

```dart
class AppAssets {
  static const icHome = 'assets/icons/ic_home.png';
  static const emptyOrder = 'assets/images/empty_order.png';
}
```

避免在业务代码中散落字符串常量。

---

## 4. 推荐分层

中小项目推荐保持以下调用关系：

```txt
Page / Widget
    ↓
Controller
    ↓
Repository
    ↓
Service
```

各层职责：

| 层级 | 职责 |
|---|---|
| Page / Widget | 页面展示、用户交互 |
| Controller | 页面状态、页面业务逻辑 |
| Repository | 业务数据封装、Model 转换、缓存策略 |
| Service | 网络、本地存储、第三方 SDK 等底层能力 |

调用规则：

- Page 可以调用 Controller
- Controller 可以调用 Repository
- Repository 可以调用 Service
- Service 不应该反向调用 Repository、Controller、Page
- Widget 不应该直接调用 ApiService
- Page 不应该直接处理复杂业务数据逻辑

---

## 5. Page / Controller / State 使用规范

### 5.1 不是每个 Page 都必须有 Controller

Controller 按需创建，不是 Page 的标配。

推荐规则：

```txt
纯展示页面
  → 只有 page

少量本地 UI 状态
  → page + StatefulWidget / ValueNotifier

有接口请求、提交、分页、复杂逻辑
  → page + controller

状态字段很多、状态切换复杂
  → page + controller + state
```

---

### 5.2 简单页面

适用于关于我们、协议页、静态说明页。

```txt
pages/
  about_page.dart
```

示例：

```dart
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('关于我们')),
    );
  }
}
```

---

### 5.3 少量本地状态

适用于 Tab 切换、展开收起、当前选中项等。

可以直接使用 `StatefulWidget`、`ValueNotifier` 或 `TextEditingController`。

不需要单独创建 Controller。

---

### 5.4 需要 Controller 的场景

当页面存在以下情况时，建议创建 Controller：

- 接口请求
- loading / error / empty 状态
- 表单提交
- 分页加载
- 下拉刷新
- 多个组件共享页面状态
- 页面业务逻辑明显变多

示例结构：

```txt
pages/
  login/
    login_page.dart
    login_controller.dart
    widgets/
      login_form.dart
```

---

### 5.5 需要 State 文件的场景

`xxx_state.dart` 不是必需文件。

只有在状态字段较多或状态组合复杂时，才单独拆出 State。

简单情况可以直接写在 Controller 中：

```dart
class LoginController extends ChangeNotifier {
  bool loading = false;
  String phone = '';
  String password = '';
  String? error;
}
```

复杂情况再拆：

```txt
pages/
  order/
    order_page.dart
    order_controller.dart
    order_state.dart
```

示例：

```dart
class OrderState {
  final bool loading;
  final String? error;
  final List<Order> orders;
  final bool hasMore;
  final int page;

  const OrderState({
    this.loading = false,
    this.error,
    this.orders = const [],
    this.hasMore = true,
    this.page = 1,
  });
}
```

---

## 6. 状态管理规范

中小项目状态管理原则：能简单就简单，不要所有状态都全局化。

推荐规则：

```txt
只影响当前 Widget
  → setState

影响当前页面多个组件
  → Controller / ValueNotifier / ChangeNotifier

影响多个页面
  → Provider / Riverpod / 全局状态
```

适合全局状态的数据：

- 当前登录用户
- token / 登录状态
- 购物车数量
- 主题
- 语言

不适合全局状态的数据：

- 页面 loading
- 表单输入值
- 当前页面 tab index
- 当前页面筛选条件

---

## 7. 命名规范

### 7.1 文件命名

使用小写加下划线。

推荐：

```txt
login_page.dart
login_controller.dart
user_repository.dart
api_service.dart
primary_button.dart
```

不推荐：

```txt
LoginPage.dart
loginPage.dart
userRepo.dart
```

---

### 7.2 类命名

使用大驼峰。

```dart
class LoginPage extends StatelessWidget {}
class LoginController extends ChangeNotifier {}
class UserRepository {}
class ApiService {}
```

---

### 7.3 变量和方法命名

使用小驼峰。

```dart
final userName = 'Tom';
Future<void> getUserInfo() async {}
```

---

### 7.4 常量命名

常量使用 `static const` 管理。

```dart
class StorageKeys {
  static const token = 'token';
}
```

---

## 8. Widget 拆分规范

### 8.1 何时拆分 Widget

满足以下任一情况可以拆分：

- build 方法过长
- 某块 UI 有明确业务含义
- 某块 UI 需要复用
- 某块 UI 有独立状态
- 嵌套层级太深，影响阅读

---

### 8.2 全局 Widget 和局部 Widget

全局复用组件：

```txt
lib/widgets/
  primary_button.dart
  loading_view.dart
```

页面内部组件：

```txt
lib/pages/home/widgets/
  home_header.dart
  home_card.dart
```

判断标准：

```txt
两个及以上页面使用
  → lib/widgets/

只有当前页面使用
  → 当前页面 widgets/
```

---

## 9. 网络请求规范

网络请求统一放在 `ApiService` 中处理。

`ApiService` 负责：

- baseUrl
- headers
- token
- timeout
- 错误码处理
- 请求日志
- 响应解析

不允许在 Page 或 Controller 中直接创建 Dio / http 请求。

不推荐：

```dart
final res = await Dio().post('/login');
```

推荐：

```dart
final res = await apiService.post(ApiPaths.login, data: data);
```

---

## 10. 错误处理规范

建议统一封装应用异常。

```dart
class AppException implements Exception {
  final String message;
  final int? code;

  AppException(this.message, {this.code});
}
```

Controller 中只处理展示层需要的信息。

```dart
try {
  await repository.login();
} on AppException catch (e) {
  error = e.message;
} catch (_) {
  error = '系统异常，请稍后重试';
}
```

---

## 11. Repository 规范

Repository 是业务数据层，不是简单转发 API。

可以处理：

- 接口结果转 Model
- 缓存读取和写入
- 多接口数据组合
- 登录成功后保存 token
- 接口字段兼容

示例：

```dart
class AuthRepository {
  final ApiService apiService;
  final StorageService storageService;

  AuthRepository(this.apiService, this.storageService);

  Future<void> login(String phone, String password) async {
    final json = await apiService.post(
      ApiPaths.login,
      data: {
        'phone': phone,
        'password': password,
      },
    );

    final token = json['token'];
    await storageService.setString(StorageKeys.token, token);
  }
}
```

---

## 12. Service 规范

Service 只封装底层能力，不处理页面业务。

例如 `StorageService`：

```dart
class StorageService {
  Future<void> setString(String key, String value) async {
    // 保存字符串
  }

  Future<String?> getString(String key) async {
    // 读取字符串
  }
}
```

Service 不应该依赖 Controller 或 Page。

---

## 13. 表单处理规范

简单表单可以在 Page 中使用 `TextEditingController`。

复杂表单建议交给 Controller 管理提交逻辑。

Page 负责：

- 输入框展示
- 表单布局
- 按钮点击

Controller 负责：

- 参数校验
- 调用 Repository
- loading 状态
- 错误信息
- 提交成功后的状态更新

---

## 14. 资源文件规范

资源目录建议：

```txt
assets/
  images/
  icons/
  fonts/
  json/
```

命名建议：

```txt
ic_home.png
ic_profile.png
bg_login.png
empty_order.png
```

资源路径建议集中管理：

```dart
class AppAssets {
  static const icHome = 'assets/icons/ic_home.png';
  static const bgLogin = 'assets/images/bg_login.png';
}
```

---

## 15. 依赖管理规范

中小项目不强制使用复杂依赖注入框架。

可以优先使用：

- 构造函数传参
- Provider
- Riverpod

不建议一开始就引入复杂 DI 方案，除非项目规模较大或团队已有统一规范。

---

## 16. 测试规范

测试目录建议与业务结构保持相似。

```txt
test/
  models/
    user_test.dart
  repositories/
    user_repository_test.dart
  services/
    api_service_test.dart
  pages/
    login_controller_test.dart
```

优先测试：

- Model JSON 解析
- Repository 业务逻辑
- Controller 状态变化
- 工具函数

UI 测试可以根据项目情况逐步补充。

---

## 17. 禁止事项

中小项目不建议一开始就做以下事情：

- 每个页面都强制创建 controller 和 state
- 每个接口都创建 usecase
- 每个 model 都拆 entity / dto / mapper
- 页面中直接写 Dio / http 请求
- 页面中散落大量字符串常量
- 所有状态都放全局
- 为了架构而创建大量空目录
- 把只有一个页面使用的组件放到全局 widgets
- 在 Service 中处理页面跳转或弹窗
- 在 Model 中存放页面 loading / selected 等状态

---

## 18. 演进规则

项目可以按以下方式自然演进。

### 阶段一：简单项目

```txt
lib/
  main.dart
  app.dart
  pages/
  widgets/
  models/
  services/
  utils/
```

### 阶段二：中小项目

```txt
lib/
  main.dart
  app.dart
  config/
  routes/
  theme/
  pages/
  widgets/
  models/
  services/
  repositories/
  utils/
  constants/
```

### 阶段三：复杂模块局部升级

当某个模块变复杂时，可以在模块内部拆分：

```txt
pages/
  order/
    order_page.dart
    order_controller.dart
    order_state.dart
    widgets/
      order_item_card.dart
      order_filter_bar.dart
```

如果项目继续变大，可以再演进为：

```txt
features/
  order/
    presentation/
    data/
    domain/
```

但不建议中小项目一开始就采用这种结构。

---

## 19. 推荐默认模板

新项目可以直接使用以下结构：

```txt
lib/
  main.dart
  app.dart

  config/
  routes/
  theme/

  pages/
    home/
      home_page.dart
      home_controller.dart
      widgets/

    login/
      login_page.dart
      login_controller.dart
      widgets/

    about_page.dart

  widgets/
  models/
  services/
  repositories/
  utils/
  constants/
```

---

## 20. 核心原则

最终判断标准不是目录是否“高级”，而是：

- 新人能不能快速找到代码
- 页面会不会越来越臃肿
- 业务逻辑是否容易测试
- 改一个功能是否影响范围可控
- 项目变大时是否能平滑拆分

一句话原则：

> 简单页面简单写，复杂页面再拆分；Controller 和 State 按需创建，不作为 Page 的强制标配。

