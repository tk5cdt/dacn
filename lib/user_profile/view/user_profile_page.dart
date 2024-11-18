import 'dart:math';
import 'package:app_ui/app_ui.dart';
import 'package:collection/equality.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:conexion/app/bloc/app_bloc.dart';
import 'package:conexion/feed/post/video/widgets/post_popup.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/user_profile/bloc/user_profile_bloc.dart';
import 'package:conexion/user_profile/widgets/widgets.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
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
    this.props = const UserProfileProps.build(),
    super.key,
  });

  final String userId;
  final UserProfileProps props;

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
        props: props
      ),
    );
  }
}

class UserProfileView extends StatefulWidget {
  const UserProfileView({required this.userId, required this.props, super.key});

  final String userId;
  final UserProfileProps props;

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  late ScrollController _nestedScrollController;
  
  UserProfileProps get props => widget.props;
  
  @override
  void initState() {
    super.initState();
    _nestedScrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final promoAction =
        props.promoBlockAction as NavigateToSponsoredPostAuthorProfileAction?;
    final user = context.select((UserProfileBloc bloc) => bloc.state.user);

    return AppScaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !props.isSponsored
          ? null
          : PromoFloatingAction(
              url: promoAction!.promoUrl,
              promoImageUrl: promoAction.promoPreviewImageUrl,
              title: context.l10n.learnMoreAboutUserPromoText,
              subtitle: context.l10n.visitUserPromoWebsiteText,
            ),
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
                    UserProfileAppBar(
                      sponsoredPost: props.sponsoredPost,
                    ),
                    if (!user.isAnonymous || props.sponsoredPost != null) ...[
                      UserProfileHeader(
                        userId: widget.userId,
                        sponsoredPost: props.sponsoredPost,
                      ),
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
          body: TabBarView(
            children: [
              UserPostsPage(sponsoredPost: props.sponsoredPost),
              const UserProfileMentionedPostsPage(),
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
  const UserProfileAppBar({this.sponsoredPost, super.key});

  final PostSponsoredBlock? sponsoredPost;

  @override
  Widget build(BuildContext context) {
    final isOwner = context.select((UserProfileBloc bloc) => bloc.isOwner);
    final user$ = context.select((UserProfileBloc b) => b.state.user);
    final user = sponsoredPost == null
        ? user$
        : user$.isAnonymous
            ? sponsoredPost!.author.toUser
            : user$;

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
          onCreateReelTap: () => PickImage().pickVideo(
            context, 
            onMediaPicked: (context, details) => context.pushNamed(
              'publish_post',
              extra: CreatePostProps(details: details, pickVideo: true,),
            ),
          ),
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

class UserPostsPage extends StatefulWidget {
  const UserPostsPage({this.sponsoredPost, super.key});

  final PostSponsoredBlock? sponsoredPost;

  @override
  State<UserPostsPage> createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bloc = context.read<UserProfileBloc>();

    return CustomScrollView(
      cacheExtent: 2760,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        BetterStreamBuilder<List<PostBlock>>(
          initialData: const <PostBlock>[],
          stream: bloc.userPosts(),
          errorBuilder: (context, error) {
            print('Error loading posts: $error');
            return const SizedBox.shrink();
          },
          comparator: const ListEquality<PostBlock>().equals,
          builder: (context, blocks) {
            if (blocks.isEmpty && widget.sponsoredPost == null) {
              return const EmptyPosts();
            }
            return SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: widget.sponsoredPost != null ? 1 : blocks.length,
              itemBuilder: (context, index) {
                final block = widget.sponsoredPost ?? blocks[index];
                final multiMedia = block.media.length > 1;

                return PostPopup(
                  block: block,
                  index: index,
                  builder: (_) => PostSmall(
                    key: ValueKey(block.id),
                    pinned: false,
                    isReel: block.isReel,
                    multiMedia: multiMedia,
                    mediaUrl: block.firstMediaUrl!,
                    imageThumbnailBuilder: (_, url) => PostSmallImage(url: url),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class PostSmallImage extends StatelessWidget {
  const PostSmallImage({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    /// AppSpacing.xxs is the padding of the image.
    final screenWidth = (context.screenWidth - AppSpacing.xxs) / 3;
    final pixelRatio = context.devicePixelRatio;

    final size = min((screenWidth * pixelRatio) ~/ 1, 1920);
    return ImageAttachmentThumbnail(
      resizeHeight: size,
      resizeWidth: size,
      image: Attachment(imageUrl: url),
      fit: BoxFit.cover,
    );
  }
}

class UserProfileMentionedPostsPage extends StatelessWidget {
  const UserProfileMentionedPostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        const EmptyPosts(icon: Icons.person_pin_outlined),
      ],
    );
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
