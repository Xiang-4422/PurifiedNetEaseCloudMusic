import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/load_state_view.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 用户资料和退出登录页面。
class UserProfilePageView extends StatefulWidget {
  /// 创建用户资料页面。
  const UserProfilePageView({Key? key}) : super(key: key);

  @override
  State<UserProfilePageView> createState() => _UserProfilePageViewState();
}

class _UserProfilePageViewState extends State<UserProfilePageView> {
  late final UserProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController(
      userId: Get.find<UserSessionController>().userInfo.value.userId,
      repository: Get.find<UserRepository>(),
    )..loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    final bottomPadding = AppDimensions.bottomPanelHeaderHeight + context.mediaQueryPadding.bottom;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ValueListenableBuilder(
          valueListenable: _controller.state,
          builder: (context, state, child) => LoadStateView(
            state: state,
            builder: (userData) => LayoutBuilder(
              builder: (context, constraints) {
                final cardTopMargin = constraints.maxWidth < 360 ? 150.0 : 200.0;
                final avatarSize = constraints.maxWidth < 360 ? 180.0 : 240.0;
                final minContentHeight = (constraints.maxHeight - topPadding - bottomPadding).clamp(0.0, double.infinity);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: topPadding,
                    bottom: bottomPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minContentHeight),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: context.width,
                          margin: EdgeInsets.only(
                            top: cardTopMargin,
                            left: AppDimensions.paddingSmall,
                            right: AppDimensions.paddingSmall,
                          ),
                          padding: EdgeInsets.only(
                            left: AppDimensions.paddingMedium,
                            right: AppDimensions.paddingMedium,
                            bottom: AppDimensions.paddingLarge,
                            top: avatarSize / 2 + AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                userData.nickname,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: constraints.maxWidth < 360 ? 32 : 40,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  userData.signature.isEmpty ? '这个人很懒，什么都没写' : userData.signature,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth < 360 ? 16 : 20,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _ProfileCountText(
                                      count: userData.follows,
                                      label: '关注',
                                    ),
                                    _ProfileCountText(
                                      count: userData.followeds,
                                      label: '粉丝',
                                    ),
                                    _ProfileCountText(
                                      count: userData.playlistCount,
                                      label: '歌单',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              GestureDetector(
                                child: Container(
                                  height: 56,
                                  alignment: Alignment.center,
                                  width: context.width,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppDimensions.paddingMedium,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    '注销登录',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                                onTap: () {
                                  UserSessionController.to.clearUser();
                                  AutoRouter.of(context).pop();
                                },
                              )
                            ],
                          ),
                        ),
                        SimpleExtendedImage.avatar(
                          ArtworkPathResolver.resolveDisplayPath(
                            userData.avatarUrl,
                          ),
                          width: avatarSize,
                          height: avatarSize,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileCountText extends StatelessWidget {
  const _ProfileCountText({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        '$count $label',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
