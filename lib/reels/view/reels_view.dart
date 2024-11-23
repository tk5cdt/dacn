import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/feed/feed.dart';
import 'package:conexion/feed/post/video/video.dart';
import 'package:conexion/l10n/l10n.dart';
import 'package:conexion/reels/reel/reel.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
// import 'package:conexion/reels/view/reel_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  late PageController _pageController;

  late ValueNotifier<int> _currentIndex;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedReelsPageRequested());
    _pageController = PageController(keepPage: false);

    _currentIndex = ValueNotifier(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayerState =
        VideoPlayerInheritedWidget.of(context).videoPlayerState;

    return Stack(
      fit: StackFit.expand,
      children: [
        AppScaffold(
          body: BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (previous, current) {
              return previous.status != current.status ||
                  !const ListEquality<ConBlock>().equals(
                    previous.feed.reelsPage.blocks,
                    current.feed.reelsPage.blocks,
                  );
            },
            builder: (context, state) {
              final blocks = state.feed.reelsPage.blocks;

              if (blocks.isEmpty) {
                return const NoReelsFound();
              }
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context
                      .read<FeedBloc>()
                      .add(const FeedReelsRefreshRequested());
                  unawaited(
                    _pageController.animateToPage(
                      0,
                      duration: 150.ms,
                      curve: Curves.easeIn,
                    ),
                  );
                },
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: blocks.length,
                  allowImplicitScrolling: true,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  onPageChanged: (index) => _currentIndex.value = index,
                  itemBuilder: (context, index) {
                    return ListenableBuilder(
                      listenable: Listenable.merge(
                        [
                          videoPlayerState.shouldPlayReels,
                          videoPlayerState.withSound,
                          _currentIndex,
                        ],
                      ),
                      builder: (context, _) {
                        final isCurrent = index == _currentIndex.value;
                        final block = blocks[index];
                        if (block is PostReelBlock) {
                          return ReelView(
                            key: ValueKey(block.id),
                            play: isCurrent &&
                                videoPlayerState.shouldPlayReels.value,
                            withSound: videoPlayerState.withSound.value,
                            block: block,
                          );
                        }
                        return Center(
                          child: Text('Unknown block type: ${block.type}'),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          right: AppSpacing.md,
          top: AppSpacing.md,
          child: Tappable.faded(
            onTap: () =>
                context.pushNamed(AppRoutes.createPost.name, extra: true),
            child: Icon(
              Icons.camera_alt_outlined,
              size: AppSize.iconSize,
              color: context.adaptiveColor,
            ),
          ),
        ),
      ],
    );
  }
}

class NoReelsFound extends StatelessWidget {
  const NoReelsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(
        child: EmptyPosts(
          isSliver: false,
          text: context.l10n.noReelsFoundText,
          icon: Icons.video_collection_outlined,
          child: FittedBox(
            child: Tappable.faded(
              onTap: () =>
                  context.read<FeedBloc>().add(const FeedReelsPageRequested()),
              throttle: true,
              throttleDuration: 550.ms,
              backgroundColor: context.customReversedAdaptiveColor(
                light: context.theme.focusColor,
                dark: context.theme.focusColor,
              ),
              borderRadius: BorderRadius.circular(22),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.refresh),
                  Text(
                    context.l10n.refreshText,
                    style: context.labelLarge,
                  ),
                ].spacerBetween(width: AppSpacing.md),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
