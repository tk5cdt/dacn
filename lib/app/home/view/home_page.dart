import 'package:app_ui/app_ui.dart';
import 'package:conexion/feed/post/video/video.dart';
import 'package:conexion/navigation/view/bottom_nav_bar.dart';
import 'package:conexion/user_profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../home/home.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return HomeView(navigationShell: navigationShell);
  }
}

class HomeView extends StatefulWidget {
  const HomeView({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late VideoPlayerState _videoPlayerState;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _videoPlayerState = VideoPlayerState();
    _pageController = PageController(initialPage: 1)
      ..addListener(_onPageScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeProvider().setPageController(_pageController);
    });
  }

  void _onPageScroll() {
    _pageController.position.isScrollingNotifier.addListener(_isPageScrolling);
  }

  void _isPageScrolling() {
    final isScrolling =
        _pageController.position.isScrollingNotifier.value == true;
    final mainPageView = _pageController.page == 1;
    final navigationBarIndex = widget.navigationShell.currentIndex;
    final isFeed = !isScrolling && mainPageView && navigationBarIndex == 0;
    final isTimeline = !isScrolling && mainPageView && navigationBarIndex == 1;
    final isReels = !isScrolling && mainPageView && navigationBarIndex == 3;

    if (isScrolling) {
      _videoPlayerState.stopAll();
    }
    switch ((isFeed, isTimeline, isReels)) {
      case (true, false, false):
        _videoPlayerState.playFeed();
      case (false, true, false):
        _videoPlayerState.playTimeline();
      case (false, false, true):
        _videoPlayerState.playReels();
      case _:
        _videoPlayerState.stopAll();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.navigationShell.currentIndex == 0 &&
        !HomeProvider().enablePageView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HomeProvider().togglePageView();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return VideoPlayerInheritedWidget(
      videoPlayerState: _videoPlayerState, 
      child: ListenableBuilder(
        listenable: HomeProvider(), 
        builder: (context, child){
          return PageView.builder(
              itemCount: 3,
              controller: _pageController,
              physics: HomeProvider().enablePageView
                  ? null
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                // if (page != 0 && page != 2 && page == 1) {
                //   customImagePickerKey.currentState?.resetAll();
                // }
                if (page == 1 && widget.navigationShell.currentIndex != 0) {
                  HomeProvider().togglePageView(enable: false);
                }
              },
              itemBuilder: (context, index) {
                return switch (index) {
                  0 => UserProfileCreatePost(
                      canPop: false,
                      //imagePickerKey: customImagePickerKey,
                      onPopInvoked: () => HomeProvider().animateToPage(1),
                      onBackButtonTap: () => HomeProvider().animateToPage(1),
                    ),
                  2 => AppScaffold(
                    body: Center(
                      child: Text('Chats page', style: context.headlineSmall,),)
                    ),
                  _ => AppScaffold(
                    body: widget.navigationShell,
                    bottomNavigationBar: BottomNavBar(navigationShell: widget.navigationShell),
                    ),
                };
              },
            );
        }),
    );
  }
}
