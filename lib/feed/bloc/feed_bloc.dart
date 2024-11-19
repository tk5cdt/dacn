import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:collection/collection.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:conexion/app/view/app.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'feed_bloc_mixin.dart';
part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> with FeedBlocMixin{
  FeedBloc({
    required PostsRepository postsRepository,
    required FirebaseRemoteConfigRepository firebaseRemoteConfigRepository,
  })  : _postsRepository = postsRepository,
        _firebaseRemoteConfigRepository = firebaseRemoteConfigRepository,
        super(const FeedState.initial()) {
    print('FeedBloc constructor called');
    on<FeedPageRequested>(_onFeedPageRequested);
    on<FeedRefreshRequested>(
      _onFeedRefreshRequested,
      transformer: throttleDroppable(duration: 550.ms),
    );
    on<FeedRecommendedPostsPageRequested>(
      _onFeedRecommendedPostsPageRequested,
      transformer: sequential(),
    );
    on<FeedPostCreateRequested>(_onFeedPostCreateRequested);
    on<FeedUpdateRequested>(_onFeedUpdateRequested);
  }

  @override
  PostsRepository get postsRepository => _postsRepository;

  @override
  FirebaseRemoteConfigRepository get firebaseRemoteConfigRepository =>
      _firebaseRemoteConfigRepository;

  final PostsRepository _postsRepository;
  final FirebaseRemoteConfigRepository _firebaseRemoteConfigRepository;

  Future<void> _onFeedPageRequested(
    FeedPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    print('FeedPageRequested triggered for page: ${event.page}');
    try {
      emit(state.loading());
      print('State emitted: loading');

      final currentPage = event.page ?? state.feed.feedPage.page;
      print('Fetching feed for page: $currentPage');

      final (:newPage, :hasMore, :blocks) = await fetchFeedPage(page: currentPage);
      print('Feed fetched - blocks count: ${blocks.length}');

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          page: newPage,
          hasMore: hasMore,
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));
      print('State emitted: populated with ${blocks.length} blocks');
      if (!hasMore) add(const FeedRecommendedPostsPageRequested());
    } catch (error, stackTrace) {
      print('Error in _onFeedPageRequested: $error');
      print('Stack trace: $stackTrace');
      emit(state.failure());
    }
  }

  Future<void> _onFeedRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final (:newPage, :hasMore, :blocks) = await fetchFeedPage();
      final feed = state.feed.copyWith(
        feedPage: FeedPage(
          page: newPage,
          blocks: blocks,
          hasMore: hasMore,
          totalBlocks: blocks.length,
        ),
      );

      emit(state.populated(feed: feed));

      if (!hasMore) add(const FeedRecommendedPostsPageRequested());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedRecommendedPostsPageRequested(
    FeedRecommendedPostsPageRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      final recommendedBlocks = <ConBlock>[
        ...PostsRepository.recommendedPosts..shuffle(),
      ];
      final blocks = await insertSponsoredBlocks(
        hasMore: true,
        blocks: recommendedBlocks,
      );

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure());
    }
  }

  Future<void> _onFeedPostCreateRequested(
    FeedPostCreateRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    try {
      print('Creating post with ID: ${event.postId}, caption: ${event.caption}, media: ${event.media}');
      final newPost = await _postsRepository.createPost(
        id: event.postId,
        caption: event.caption,
        media: json.encode(event.media),
      );

      print('Post created: $newPost');
      if (newPost != null) {
        add(
          FeedUpdateRequested(
            update:
                FeedPageUpdate(newPost: newPost, type: PageUpdateType.create),
          ),
        );
      }
      emit(state.populated());
      toggleLoadingIndeterminate(enable: false);
      openSnackbar(
        const SnackbarMessage.success(
          title: 'Successfully created post!',
        ),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      print('Error in _onFeedPostCreateRequested: $error');
      openSnackbar(
        const SnackbarMessage.error(title: 'Failed to create post!'),
      );
      emit(state.failure());
    }
  }

  Future<void> _onFeedUpdateRequested(
    FeedUpdateRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(state.loading());
    final update = event.update;
    final oldFeed = state.feed;

    try {
      final feedBlock = oldFeed.feedPage.blocks.findPostBlock(
        test: (block) => block.id == update.newPost.id,
      );
      final reel = oldFeed.reelsPage.blocks.findPostBlock(
        test: (block) =>
            block.id == update.newPost.id &&
            block.type == PostReelBlock.identifier,
      );
      if (feedBlock == null && reel == null && !update.isCreate) {
        return emit(state.populated());
      }
      final updatedFeedBlocks = oldFeed.updateFeedPage(update: update);
      List<ConBlock>? updatedReelsBlocks;
      if (update.canUpdateReel) {
        updatedReelsBlocks = oldFeed.updateReelsPage(update: update);
      }

      final feed = oldFeed.copyWith(
        feedPage: oldFeed.feedPage.copyWith(
          blocks: updatedFeedBlocks,
          totalBlocks: updatedFeedBlocks.length,
        ),
        reelsPage: oldFeed.reelsPage.copyWith(
          blocks: updatedReelsBlocks,
          totalBlocks: updatedReelsBlocks?.length,
        ),
      );

      emit(state.populated(feed: feed));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.failure());
    }
  }
} 