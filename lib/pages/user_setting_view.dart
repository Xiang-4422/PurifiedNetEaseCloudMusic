import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/load_state_view.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../common/constants/app_constants.dart';

class UserProfilePageView extends StatefulWidget {
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
      userId: AppController.to.userInfo.value.userId,
    )..loadInitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _controller.refresh,
        child: ValueListenableBuilder(
          valueListenable: _controller.state,
          builder: (context, state, child) => LoadStateView(
            state: state,
            builder: (userData) => Container(
              padding: EdgeInsets.only(
                top: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                bottom: AppDimensions.bottomPanelHeaderHeight,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: context.width,
                    margin: const EdgeInsets.only(top: 200),
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 25,
                      top: 80,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      children: [
                        Text(
                          userData.nickname,
                          style: const TextStyle(fontSize: 56),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            userData.signature,
                            style: const TextStyle(
                                fontSize: 32, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('${userData.follows} 关注'),
                              Text('${userData.followeds} 粉丝'),
                              Text('${userData.playlistCount} 歌单'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        Obx(
                          () => GestureDetector(
                            child: Container(
                              height: 88,
                              alignment: Alignment.center,
                              width: context.width,
                              margin: const EdgeInsets.symmetric(
                                vertical: 40,
                                horizontal: 35,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '注销登录',
                                style: TextStyle(
                                    fontSize: 28, color: Colors.white),
                              ),
                            ),
                            onTap: () {
                              UserController.to.clearUser();
                              AutoRouter.of(context).pop();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SimpleExtendedImage.avatar(
                    ArtworkPathResolver.resolveDisplayPath(userData.avatarUrl),
                    width: 260,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
