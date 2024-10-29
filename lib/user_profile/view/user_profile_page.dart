import 'package:app_ui/app_ui.dart';
import 'package:conexion/app/bloc/app_bloc.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/user_profile/bloc/user_profile_bloc.dart';
import 'package:conexion/user_profile/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:user_repository/user_repository.dart';

import '../../selector/selector.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileBloc(
        userId: userId,
        postsRepository: context.read<PostsRepository>(),
        userRepository: context.read<UserRepository>(),
      )
        ..add(const UserProfileSubscriptionRequested())
        ..add(const UserProfilePostsCountSubscriptionRequested())
        ..add(const UserProfileFollowingsCountSubscriptionRequested())
        ..add(const UserProfileFollowersCountSubscriptionRequested()),
      child: UserProfileView(
        userId: userId,
      ),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({required this.userId, super.key});

  final String userId;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late ScrollController _nestedScrollController;

  @override
  void initState() {
    _nestedScrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return AppScaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _nestedScrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: MultiSliver(
                  children: [
                    const UserProfileAppBar(),
                    if (!user.isAnonymous) ...[
                      UserProfileHeader(userId: widget.userId),
                      SliverPersistentHeader(
                        pinned: !ModalRoute.of(context)!.isFirst,
                        delegate: const _UserProfileTabBarDelegate(
                          TabBar(
                            indicatorSize: TabBarIndicatorSize.tab,
                            padding: EdgeInsets.zero,
                            labelPadding: EdgeInsets.zero,
                            indicatorWeight: 1,
                            tabs: [
                              Tab(
                                icon: Icon(Icons.grid_on),
                                iconMargin: EdgeInsets.zero,
                              ),
                              Tab(
                                icon: Icon(Icons.person_outline),
                                iconMargin: EdgeInsets.zero,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ];
          },
          body: const TabBarView(children: [
            UserPostsPage(),
            UserProfileMentionedPostsPage(),
          ]),
        ),
      ),
    );
  }
}

class _UserProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _UserProfileTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: context.theme.scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(_UserProfileTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class UserProfileAppBar extends StatelessWidget {
  const UserProfileAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc bloc) => bloc.isOwner);
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return SliverPadding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      sliver: SliverAppBar(
        centerTitle: false,
        pinned: !ModalRoute.of(context)!.isFirst,
        floating: ModalRoute.of(context)!.isFirst,
        title: Row(
          children: [
            Flexible(
                flex: 12,
                child: Text(
                  '${user.displayFullName} ',
                  style:
                      context.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                )),
            Flexible(
              child: Assets.icons.verifiedUser.svg(
                width: AppSize.iconSizeSmall,
                height: AppSize.iconSizeSmall,
              ),
            )
          ],
        ),
        actions: [
          if (!isOwner)
            const UserProfileActions()
          else ...[
            const UserProfileAddMediaButton(),
            if (ModalRoute.of(context)?.isFirst ?? false) ...const [
              Gap.h(AppSpacing.md),
              UserProfileSettingsButton(),
            ],
          ],
        ],
      ),
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () {},
      child: Icon(Icons.adaptive.more_outlined, size: AppSize.iconSize),
    );
  }
}

class UserProfileSettingsButton extends StatelessWidget {
  const UserProfileSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.showListOptionsModal(
        options: [
          ModalOption(child: const LocaleModalOption()),
          ModalOption(child: const ThemeSelectorModalOption()),
          ModalOption(child: const LogoutModalOption()),
        ],
      ).then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: Assets.icons.setting.svg(
        height: AppSize.iconSize,
        width: AppSize.iconSize,
        colorFilter: ColorFilter.mode(
          context.adaptiveColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class UserProfileAddMediaButton extends StatelessWidget {
  const UserProfileAddMediaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.showListOptionsModal(
        title: context.l10n.createText,
        options: createMediaModalOptions(
          reelLabel: context.l10n.reelText,
          postLabel: context.l10n.postText,
          storyLabel: context.l10n.storyText,
          context: context,
          goTo: (route, {extra}) =>
              context.pushNamed(route, extra: extra),
          enableStory: true,
          
        ),
      ).then((option) {
        if (option == null) return;
        option.onTap(context);
      }),
      child: const Icon(
        Icons.add_box_outlined,
        size: AppSize.iconSize,
      ),
    );
  }
}

class UserPostsPage extends StatelessWidget {
  const UserPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class UserProfileMentionedPostsPage extends StatelessWidget {
  const UserProfileMentionedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LogoutModalOption extends StatelessWidget {
  const LogoutModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      onTap: () => context.confirmAction(
        fn: () {
          context.pop();
          context.read<AppBloc>().add(const AppLogoutRequested());
        },
        title: context.l10n.logOutText,
        content: context.l10n.logOutConfirmationText,
        noText: context.l10n.cancelText,
        yesText: context.l10n.logOutText,
      ),
      child: ListTile(
        title: Text(
          context.l10n.logOutText,
          style: context.bodyLarge?.apply(color: AppColors.red),
        ),
        leading: const Icon(Icons.logout, color: AppColors.red),
      ),
    );
  }
}
