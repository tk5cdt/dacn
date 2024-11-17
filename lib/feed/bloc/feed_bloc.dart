import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:con_blocks/con_blocks.dart';
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
    on<FeedPageRequested>(_onFeedPageRequested);
    on<FeedRefreshRequested>(
      _onFeedRefreshRequested,
      transformer: throttleDroppable(duration: 550.ms),
    );
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
    emit(state.loading());
    try {
      final currentPage = event.page ?? state.feed.feedPage.page;
      final (:newPage, :hasMore, :blocks) =
          await fetchFeedPage(page: currentPage);

      final feed = state.feed.copyWith(
        feedPage: state.feed.feedPage.copyWith(
          page: newPage,
          hasMore: hasMore,
          blocks: [...state.feed.feedPage.blocks, ...blocks],
          totalBlocks: state.feed.feedPage.totalBlocks + blocks.length,
        ),
      );

      emit(state.populated(feed: feed));

      if (!hasMore) add(const FeedRecommendedPostsPageRequested());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
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
} 