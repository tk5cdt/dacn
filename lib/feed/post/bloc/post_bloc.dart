import 'package:bloc/bloc.dart';
import 'package:con_blocks/con_blocks.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';

part 'post_bloc.g.dart';
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends HydratedBloc<PostEvent, PostState> {
  PostBloc({
    required String postId,
    required PostsRepository postsRepository,
    required UserRepository userRepository,
  }) :  _postId = postId,
        _postsRepository = postsRepository,
        _userRepository = userRepository,
        super(PostState.initial()) {
    on<PostLikesCountSubscriptionRequested>(
      _onPostLikesCountSubscriptionRequested,
    );
    on<PostIsLikedSubscriptionRequested>(
      _onPostIsLikedSubscriptionRequested
    );
    on<PostAuthorFollowingStatusSubscriptionRequested>(
      _onPostAuthorFollowingStatusSubscriptionRequested,
    );
    on<PostCommentsCountSubscriptionRequested>(
      _onPostCommentsCountSubscriptionRequested,
    );
    on<PostLikeRequested>(
      _onPostLikeRequested
    );
    on<PostAuthorFollowRequested>(
      _onPostAuthorFollowRequested
    );
    on<PostLikersInFollowingsFetchRequested>(
      _onPostLikersInFollowingsFetchRequested,
    );
    on<PostUpdateRequested>(_onPostUpdateRequested);
    on<PostDeleteRequested>(_onPostDeleteRequested);
  }
  final UserRepository _userRepository;
  final PostsRepository _postsRepository;
  final String _postId;

  @override
  String get id => _postId;

  Future<void> _onPostLikesCountSubscriptionRequested(
    PostLikesCountSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.likesOf(id: id),
      onData: (likesCount) => state.copyWith(likes: likesCount),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostIsLikedSubscriptionRequested(
    PostIsLikedSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.isLiked(id: id),
      onData: (isLiked) => state.copyWith(isLiked: isLiked),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostAuthorFollowingStatusSubscriptionRequested(
    PostAuthorFollowingStatusSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    if (event.currentUserId == event.ownerId) {
      emit(state.copyWith(isOwner: true));
      return;
    }
    await emit.forEach(
      _userRepository.followingStatus(userId: event.ownerId),
      onData: (isFollowed) =>
          state.copyWith(isFollowed: isFollowed, isOwner: false),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostCommentsCountSubscriptionRequested(
    PostCommentsCountSubscriptionRequested event,
    Emitter<PostState> emit,
  ) async {
    await emit.forEach(
      _postsRepository.commentsAmountOf(postId: id),
      onData: (commentsCount) => state.copyWith(commentsCount: commentsCount),
      onError: (error, stackTrace) {
        addError(error, stackTrace);
        return state.copyWith(status: PostStatus.failure);
      },
    );
  }

  Future<void> _onPostLikeRequested(
    PostLikeRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      await _postsRepository.like(id: id);
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostAuthorFollowRequested(
    PostAuthorFollowRequested event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      await _userRepository.follow(followToId: event.authorId);
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostLikersInFollowingsFetchRequested(
    PostLikersInFollowingsFetchRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      final likersInFollowings =
          await _postsRepository.getPostLikersInFollowings(postId: id);
      emit(state.copyWith(likersInFollowings: likersInFollowings));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostUpdateRequested(
    PostUpdateRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      final post =
          await _postsRepository.updatePost(id: id, caption: event.caption);

      if (post != null) {
        event.onPostUpdated?.call(post.toPostLargeBlock);
      }
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> _onPostDeleteRequested(
    PostDeleteRequested event,
    Emitter<PostState> emit,
  ) async {
    try {
      await _postsRepository.deletePost(id: id);
      emit(state.copyWith(status: PostStatus.success));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  @override
  PostState? fromJson(Map<String, dynamic> json) => PostState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(PostState state) => state.toJson();
}

  
