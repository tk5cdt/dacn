import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:conexion/feed/feed.dart';
import 'package:conexion/feed/post/video/video.dart';
import 'package:conexion/home/home.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final videoPlayer = VideoPlayerInheritedWidget.of(context);
    
    final navigationBarItems = mainNavigationBarItems(
      homeLabel: context.l10n.homeNavBarItemLabel,
      searchLabel: context.l10n.searchNavBarItemLabel,
      createMediaLabel: context.l10n.createMediaNavBarItemLabel,
      reelsLabel: context.l10n.reelsNavBarItemLabel,
      userProfileLabel: context.l10n.profileNavBarItemLabel,
      userProfileAvatar: const Icon(Icons.person),
    );
    return BottomNavigationBar(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) {
        HomeProvider().togglePageView(enable: index == 0);
        if ([0, 1, 2, 3].contains(index)) {
          if (index case 0) videoPlayer.videoPlayerState.playFeed();
          if (index case 1) videoPlayer.videoPlayerState.playTimeline();
          if (index case 2) {
            HomeProvider().animateToPage(0);
            HomeProvider().togglePageView();
          }
          if (index case 3) videoPlayer.videoPlayerState.playReels();
        } else {
          videoPlayer.videoPlayerState.stopAll();
        }
        if (index != 2) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        }
        if (index == 0) {
          if (!(index == navigationShell.currentIndex)) return;
          FeedPageController().scrollToTop();
        }
      },
      iconSize: 28,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: navigationBarItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: item.child ?? Icon(item.icon),
              tooltip: item.tooltip,
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
