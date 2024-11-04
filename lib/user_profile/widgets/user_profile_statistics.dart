import 'package:app_ui/app_ui.dart';
import 'package:conexion/user_profile/bloc/user_profile_bloc.dart';
import 'package:conexion/user_profile/widgets/user_profile_followers.dart';
import 'package:conexion/user_profile/widgets/user_profile_followings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:conexion/l10n/l10n.dart';

class UserProfileStatistics extends StatefulWidget {
  const UserProfileStatistics({
    required this.tabIndex,
    super.key,
  });

  final int tabIndex;

  @override
  State<UserProfileStatistics> createState() => _UserProfileStatisticsState();
}

class _UserProfileStatisticsState extends State<UserProfileStatistics>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _tabController.animateTo(widget.tabIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: UserProfileStatisticsAppBar(controller: _tabController),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            UserProfileFollowers(),
            UserProfileFollowings(),
          ],
        ),
      ),
    );
  }
}

class UserProfileStatisticsAppBar extends StatelessWidget {
  const UserProfileStatisticsAppBar({
    required this.controller,
    super.key,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    final followers = context.select((UserProfileBloc b) => b.state.followersCount);
    final followings = context.select((UserProfileBloc b) => b.state.followingsCount);
    final user = context.select((UserProfileBloc b) => b.state.user);

    return SliverAppBar(
      pinned: true,
      centerTitle: false,
      title: Text(user.displayUsername),
      bottom: TabBar(
        indicatorWeight: 1,
        indicatorSize: TabBarIndicatorSize.tab,
        controller: controller,
        labelColor: context.adaptiveColor,
        labelStyle: context.bodyLarge,
        labelPadding: EdgeInsets.zero,
        unselectedLabelStyle: context.bodyLarge,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: context.adaptiveColor,
        tabs: [
          Tab(text: context.l10n.followersCountText(followers)),
          Tab(text: context.l10n.followingsCountText(followings)),
        ],
      ),
    );
  }
}
