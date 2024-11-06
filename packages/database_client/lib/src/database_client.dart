import 'dart:async';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';
import 'package:powersync/sqlite3_common.dart';

abstract class UserBaseRepository {
  const UserBaseRepository();

  String? get currentUserId;

  Stream<User> profile({required String userId});

  Stream<int> followingsCountOf({required String userId});

  Stream<int> followersCountOf({required String userId});

  Stream<bool> followingStatus({required String userId, String? followerId});

  Future<bool> isFollowed({required String followerId, required String userId});

  Future<List<User>> getFollowers({String? userId});

  Future<List<User>> getFollowings({String? userId});

  Stream<List<User>> followers({required String userId});

  Future<void> follow({required String followToId, String? followerId});

  Future<void> unfollow({required String unfollowId, String? unfollowerId});

  Future<void> removeFollower({required String id});

  /// Updates currently authenticated database user's metadata.
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
  });
}

abstract class PostsBaseRepository {
  const PostsBaseRepository();

  Stream<int> postsAmountOf({required String userId});

  // Create a new post with provided details.
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  });
}

/// {@template database_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
abstract class DatabaseClient
    implements UserBaseRepository, PostsBaseRepository {
  /// {@macro database_client}
  const DatabaseClient();
}

class PowerSyncDatabaseClient implements DatabaseClient, PostsBaseRepository {
  const PowerSyncDatabaseClient({
    required PowerSyncRepository powerSyncRepository,
  }) : _powerSyncRepository = powerSyncRepository;

  final PowerSyncRepository _powerSyncRepository;

  @override
  String? get currentUserId =>
      _powerSyncRepository.supabase.auth.currentSession?.user.id;

  @override
  Stream<User> profile({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
        select * from profile where id = ?
      ''',
        parameters: [userId],
      ).map(
        (event) => event.isEmpty ? User.anonymous : User.fromJson(event.first),
      );

  @override
  Stream<int> postsAmountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
        select count(*) as posts_count from posts where user_id = ?
      ''',
        parameters: [userId],
      ).map((event) {
        print('Posts count in db: ${event.first['posts_count']}');
        return event.first['posts_count'] as int;
      }
          // (event) => event.first['posts_count'] as int,
          );

  @override
  Stream<int> followersCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      ).map((event) {
        print('Followers count in db: ${event.first['subscription_count']}');
        print('userId: $userId');
        return event.first['subscription_count'] as int;
      }
          // (event) => event.first['subscription_count'] as int,
          );

  @override
  Stream<int> followingsCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscriber_id = ?',
        parameters: [userId],
      ).map(
        (event) => event.first['subscription_count'] as int,
      );

  @override
  Stream<bool> followingStatus({
    required String userId,
    String? followerId,
  }) {
    if (followerId == null && currentUserId == null) {
      return const Stream.empty();
    }
    return _powerSyncRepository.db().watch(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      parameters: [followerId ?? currentUserId, userId],
    ).map((event) => event.isNotEmpty);
  }

  @override
  Future<bool> isFollowed({
    required String userId,
    String? followerId,
  }) async {
    final result = await _powerSyncRepository.db().execute(
      '''
    SELECT 1 FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
    ''',
      [followerId ?? currentUserId, userId],
    );
    return result.isNotEmpty;
  }

  @override
  Future<void> follow({
    required String followToId,
    String? followerId,
  }) async {
    if (currentUserId == null) return;
    if (followToId == currentUserId) return;
    final exists = await isFollowed(
      followerId: followerId ?? currentUserId!,
      userId: followToId,
    );
    if (!exists) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO subscriptions(id, subscriber_id, subscribed_to_id)
            VALUES(uuid(), ?, ?)
      ''',
        [followerId ?? currentUserId!, followToId],
      );
      return;
    }
    await unfollow(
      unfollowId: followToId,
      unfollowerId: followerId ?? currentUserId!,
    );
  }

  @override
  Future<void> unfollow({
    required String unfollowId,
    String? unfollowerId,
  }) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [unfollowerId ?? currentUserId, unfollowId],
    );
  }

  @override
  Stream<List<User>> followers({required String userId}) async* {
    final streamResult = _powerSyncRepository.db().watch(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      parameters: [userId],
    );
    await for (final result in streamResult) {
      final followers = <User>[];
      final followersFutures = await Future.wait(
        result.where((row) => row.isNotEmpty).safeMap(
              (row) => _powerSyncRepository.db().getOptional(
                'SELECT * FROM profiles WHERE id = ?',
                [row['subscriber_id']],
              ),
            ),
      );
      for (final user in followersFutures) {
        if (user == null) continue;
        final follower = User.fromJson(user);
        followers.add(follower);
      }
      yield followers;
    }
  }

  @override
  Future<List<User>> getFollowers({String? userId}) async {
    final followersId = await _powerSyncRepository.db().getAll(
      'SELECT subscriber_id FROM subscriptions WHERE subscribed_to_id = ? ',
      [userId ?? currentUserId],
    );
    if (followersId.isEmpty) return [];

    final followers = <User>[];
    for (final followerId in followersId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followerId['subscriber_id']],
      );
      if (result.isEmpty) continue;
      final follower = User.fromJson(result.first);
      followers.add(follower);
    }
    return followers;
  }

  @override
  Future<List<User>> getFollowings({String? userId}) async {
    final followingsUserId = await _powerSyncRepository.db().getAll(
      'SELECT subscribed_to_id FROM subscriptions WHERE subscriber_id = ? ',
      [userId ?? currentUserId],
    );
    if (followingsUserId.isEmpty) return [];

    final followings = <User>[];
    for (final followingsUserId in followingsUserId) {
      final result = await _powerSyncRepository.db().execute(
        'SELECT * FROM profiles WHERE id = ?',
        [followingsUserId['subscribed_to_id']],
      );
      if (result.isEmpty) continue;
      final following = User.fromJson(result.first);
      followings.add(following);
    }
    return followings;
  }

  @override
  Future<void> removeFollower({required String id}) async {
    if (currentUserId == null) return;
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM subscriptions WHERE subscriber_id = ? AND subscribed_to_id = ?
      ''',
      [id, currentUserId],
    );
  }

  @override
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  }) async {
    if (currentUserId == null) return null;
    final result = await Future.wait([
      _powerSyncRepository.db().execute(
        '''
    INSERT INTO posts(id, user_id, caption, media, created_at)
    VALUES(?, ?, ?, ?, ?)
    RETURNING *
    ''',
        [
          id,
          currentUserId,
          caption,
          media,
          DateTime.timestamp().toIso8601String(),
        ],
      ),
      _powerSyncRepository.db().get(
        '''
    SELECT * FROM profiles WHERE id = ?
    ''',
        [currentUserId],
      ),
    ]);
    if (result.isEmpty) return null;
    final row = Map<String, dynamic>.from((result.first as ResultSet).first);
    final author = User.fromJson(result.last as Row);
    return Post.fromJson(row).copyWith(author: author);
  }

  @override
  Future<void> updateUser({
    String? fullName,
    String? email,
    String? username,
    String? avatarUrl,
    String? pushToken,
    String? password,
  }) =>
      _powerSyncRepository.updateUser(
        email: email,
        password: password,
        data: {
          if (fullName != null) 'full_name': fullName,
          if (username != null) 'username': username,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          if (pushToken != null) 'push_token': pushToken,
        },
      );
}
