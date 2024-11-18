import 'package:app_ui/app_ui.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/feed/post/bloc/post_bloc.dart';
import 'package:conexion/feed/post/video/video.dart';
import 'package:conexion/user_profile/user_profile.dart';
import 'package:conexion_blocks_ui/conexion_blocks_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

import '../../feed.dart';

class PostView extends StatelessWidget {
  const PostView({
    required this.block,
    this.builder,
    this.postIndex,
    this.withInViewNotifier = true,
    this.withCustomVideoPlayer = true,
    this.videoPlayerType = VideoPlayerType.feed,
    super.key,
  });

  final PostBlock block;
  final WidgetBuilder? builder;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;
  final VideoPlayerType videoPlayerType;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AppBloc bloc) => bloc.state.user);

    return BlocProvider(
      create: (context) => PostBloc(
        postId: block.id,
        userRepository: context.read<UserRepository>(),
        postsRepository: context.read<PostsRepository>(),
      )
        ..add(const PostLikesCountSubscriptionRequested())
        ..add(const PostCommentsCountSubscriptionRequested())
        ..add(const PostIsLikedSubscriptionRequested())
        ..add(
          PostAuthorFollowingStatusSubscriptionRequested(
            ownerId: block.author.id,
            currentUserId: user.id,
          ),
        )
        ..add(const PostLikersInFollowingsFetchRequested()),
      child: builder?.call(context) ??
          PostLargeView(
            block: block,
            postIndex: postIndex,
            withInViewNotifier: withInViewNotifier,
            withCustomVideoPlayer: withCustomVideoPlayer,
            videoPlayerType: videoPlayerType,
          ),
    );
  }
}

class PostLargeView extends StatelessWidget {
  const PostLargeView({
    required this.block,
    required this.postIndex,
    required this.withInViewNotifier,
    required this.withCustomVideoPlayer,
    required this.videoPlayerType,
    super.key,
  });

  final PostBlock block;
  final int? postIndex;
  final bool withInViewNotifier;
  final bool withCustomVideoPlayer;
  final VideoPlayerType videoPlayerType;

  void _navigateToPostAuthor(
    BuildContext context, {
    required String id,
    UserProfileProps? props,
  }) =>
      context.pushNamed(
        'user_profile',
        pathParameters: {'user_id': id},
        extra: props,
      );

  void _handleOnPostTap(BuildContext context, {required BlockAction action}) =>
      action.when(
        navigateToPostAuthor: (action) =>
            _navigateToPostAuthor(context, id: action.authorId),
        navigateToSponsoredPostAuthor: (action) => _navigateToPostAuthor(
          context,
          id: action.authorId,
          props: UserProfileProps.build(
            isSponsored: true,
            promoBlockAction: action,
            sponsoredPost: block as PostSponsoredBlock,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostBloc>();

    final isOwner = context.select((PostBloc bloc) => bloc.state.isOwner);
    final isLiked = context.select((PostBloc bloc) => bloc.state.isLiked);
    final likesCount = context.select((PostBloc bloc) => bloc.state.likes);
    final isFollowed = context.select((PostBloc bloc) => bloc.state.isFollowed);
    final commentsCount =
        context.select((PostBloc bloc) => bloc.state.commentsCount);
    final likersInFollowings =
        context.select((PostBloc bloc) => bloc.state.likersInFollowings);

    return PostLarge(
      block: block,
      isOwner: isOwner,
      isLiked: isLiked,
      likePost: () => bloc.add(const PostLikeRequested()),
      likesCount: likesCount,
      isFollowed: isOwner || (isFollowed ?? true),
      follow: () =>
          bloc.add(PostAuthorFollowRequested(authorId: block.author.id)),
      enableFollowButton: true,
      commentsCount: commentsCount,
      postIndex: postIndex,
      withInViewNotifier: withInViewNotifier,
      likersInFollowings: likersInFollowings,
      // postAuthorAvatarBuilder: (context, author, onAvatarTap) {
      //   return UserStoriesAvatar(
      //     resizeHeight: 108,
      //     author: author.toUser,
      //     onAvatarTap: onAvatarTap,
      //     enableInactiveBorder: false,
      //     withAdaptiveBorder: false,
      //   );
      // },
      postOptionsSettings: isOwner
          ? PostOptionsSettings.owner(
              onPostEdit: (block) => context.pushNamed(
                'post_edit',
                pathParameters: {'post_id': block.id},
                extra: block,
              ),
              onPostDelete: (_) {
                bloc.add(const PostDeleteRequested());
                context.read<FeedBloc>().add(
                      FeedUpdateRequested(
                        update: FeedPageUpdate(
                          newPost: block.toPost,
                          type: PageUpdateType.delete,
                        ),
                      ),
                    );
              },
            )
          : const PostOptionsSettings.viewer(),
      onCommentsTap: (showFullSized) {

      },
      onUserTap: (userId) => _navigateToPostAuthor(context, id: userId),
      onPressed: (action) => _handleOnPostTap(context, action: action),
      onPostShareTap: (postId, author) {

      },
      videoPlayerBuilder: !withCustomVideoPlayer
          ? null
          : (_, media, aspectRatio, isInView) {
              final videoPlayerState = VideoPlayerInheritedWidget.of(context).videoPlayerState;

              return VideoPlayerInViewNotifierWidget(
                type: videoPlayerType, 
                builder: (context, shouldPlay, child){
                  final play = shouldPlay && isInView;
                  return ValueListenableBuilder(
                    valueListenable: videoPlayerState.withSound, 
                    builder: (context, withSound, child){
                      return InlineVideo(
                        key: ValueKey(media.id),
                        videoSettings: VideoSettings.build(
                          videoUrl: media.url,
                          shouldPlay: play,
                          aspectRatio: aspectRatio,
                          blurHash: media.blurHash,
                          withSound: withSound,
                          onSoundToggled: ({required enable}) => {
                            videoPlayerState.withSound.value = enable,
                          }
                          )
                        );
                    }
                    );
                }
                );
          }
    );
  }
}
