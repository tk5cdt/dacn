import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:env/env.dart';
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

  /// Returns the stream of real-time posts of the current user.
  Stream<List<Post>> postsOf({String? userId});

  /// Returns a stream of amount of posts of the user identified by [userId].
  Stream<int> postsAmountOf({required String userId});

  // Create a new post with provided details.
  Future<Post?> createPost({
    required String id,
    required String caption,
    required String media,
  });

  /// Returns the page of posts with provided [offset] and [limit].
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  });

  /// Fetches the profiles of users who liked the post, identified by [postId]
  /// and who are in followings of the user identified by current user `id`.
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  });

  /// Returns a real-time stream of likes count of post by provided [id].
  Stream<int> likesOf({
    required String id,
    bool post = true,
  });

  /// Returns a real-time stream of whether the post by [id] is liked by user
  /// identified by [userId].
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  });

  /// Likes the post by provided either post or comment [id].
  Future<void> like({
    required String id,
    bool post = true,
  });

  /// Returns a stream of amount of comments of the post identified by [postId].
  Stream<int> commentsAmountOf({required String postId});

  /// Deletes the post with provided [id].
  /// Returns the optional `id` of the deleted post.
  Future<String?> deletePost({required String id});

  /// Updates the post with provided [id] and optional parameters to update.
  Future<Post?> updatePost({required String id, String? caption});
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

  Future<void> _checkConnection() async {
    try {
      final db = _powerSyncRepository.db();
      final isConnected = await db.execute('SELECT 1');
      print('Database connection check: ${isConnected.isNotEmpty}');
    } catch (e) {
      print('Database connection error: $e');
      rethrow;
    }
  }

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
        'SELECT COUNT(*) AS subscription_count FROM subscriptions WHERE subscriber_id = ?',
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

  @override
  Future<String?> deletePost({required String id}) async {
    final result = await _powerSyncRepository
        .db()
        .execute('DELETE FROM posts WHERE id = ? RETURNING id', [id]);
    if (result.isEmpty) return null;
    return result.first['id'] as String;
  }
  
  @override
  Future<List<Post>> getPage({
    required int offset,
    required int limit,
    bool onlyReels = false,
  }) async {
//       final result = await _powerSyncRepository.db().execute(
//         '''
// SELECT
//   posts.*,
//   p.id as user_id,
//   p.avatar_url as avatar_url,
//   p.username as username
// FROM
//   posts
//   inner join profiles p on posts.user_id = p.id
// WHERE array_length(array(posts.media), 1) = 1
//   AND posts.media.type = '__video_media__'
// LIMIT ?1 OFFSET ?2
//     ''',
//         [limit, offset],
//       );

//       final posts = <Post>[];

//       for (final row in result) {
//         final json = Map<String, dynamic>.from(row);
//         final post = Post.fromJson(json);
//         posts.add(post);
//       }
//       return posts;
//   }

    final result = await _powerSyncRepository.db().computeWithDatabase(
      (db) async {
        final result = db.select(
          '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  inner join profiles p on posts.user_id = p.id 
ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
    ''',
          [limit, offset],
        );
        print('RESULT: $result');
        
        final jsonListMedia = result.map((row) {
          final json = Map<String, dynamic>.from(row);
          return json['media'] as String;
        }).toList();

        final receivePort = ReceivePort();

        void computeJsonListMedia(List<dynamic> args) {
          final sendPort = args[0] as SendPort;
          final jsonListMedia = args[1] as List<String>;
          final listMedia = jsonListMedia
              .map(
                (jsonMedia) => (jsonDecode(jsonMedia) as List<dynamic>)
                    .cast<Map<String, dynamic>>(),
              )
              .toList();

          return sendPort.send(listMedia);
        }

        final isolate = await Isolate.spawn(
          computeJsonListMedia,
          [receivePort.sendPort, jsonListMedia],
        );
        isolate.kill(priority: Isolate.immediate);
        final media =
            await receivePort.first as List<List<Map<String, dynamic>>>;

        final posts = <Post>[];
        for (var i = 0; i < result.length; i++) {
          final json = Map<String, dynamic>.from(result[i]);
          final post = Post(
            id: json['id'] as String,
            createdAt: DateTime.parse(json['created_at'] as String),
            author: User(
              id: json['user_id'] as String,
              avatarUrl: json['avatar_url'] as String?,
              username: json['username'] as String?,
              fullName: json['full_name'] as String?,
            ),
            caption: json['caption'] as String,
            media: List<Media>.from(media[i].map(Media.fromJson).toList()),
          );
          posts.add(post);
        }
        return posts;
      },
    );
// final result = await _powerSyncRepository.db().execute(
//           '''
// SELECT
//   posts.*,
//   p.id as user_id,
//   p.avatar_url as avatar_url,
//   p.username as username,
//   p.full_name as full_name
// FROM
//   posts
//   inner join profiles p on posts.user_id = p.id
// ORDER BY created_at DESC LIMIT ?1 OFFSET ?2
//     ''',
//           [limit, offset],
//         );

//     final instaBlocks = result.map((row) {
//       final json = Map<String, dynamic>.from(row);
//       return Post.fromJson(json);
//     }).toList();
    return result;
  }

  @override
  Future<Post?> updatePost({required String id, String? caption}) async {
    final row = await _powerSyncRepository.db().execute(
      '''
UPDATE posts
SET
  caption = ?2,
  updated_at = ?3
WHERE id = ?1
RETURNING *
''',
      [id, caption, DateTime.timestamp().toIso8601String()],
    );
    if (row.isEmpty) return null;
    final json = Map<String, dynamic>.from(row.first);
    return Post.fromJson(json);
  }


  @override
  Future<List<User>> getPostLikersInFollowings({
    required String postId,
    int limit = 3,
    int offset = 0,
  }) async {
    final result = await _powerSyncRepository.db().getAll(
      '''
SELECT id, avatar_url, username, full_name
FROM profiles
WHERE id IN (
    SELECT l.user_id
    FROM likes l
    WHERE l.post_id = ?1
    AND EXISTS (
        SELECT *
        FROM subscriptions f
        WHERE f.subscribed_to_id = l.user_Id
        AND f.subscriber_id = ?2
    ) AND id <> ?2
)
LIMIT ?3 OFFSET ?4
''',
      [postId, currentUserId, limit, offset],
    );
    if (result.isEmpty) return [];
    return result.safeMap(User.fromJson).toList(growable: false);
  }

  @override
  Stream<int> likesOf({required String id, bool post = true}) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository.db().watch(
      '''
      SELECT COUNT(*) AS total_likes
      FROM likes
      WHERE $statement = ? AND $statement IS NOT NULL
      ''',
      parameters: [id],
    ).map((result) => result.safeMap((row) => row['total_likes']).first as int);
  }

  @override
  Stream<bool> isLiked({
    required String id,
    String? userId,
    bool post = true,
  }) {
    final statement = post ? 'post_id' : 'comment_id';
    return _powerSyncRepository.db().watch(
      '''
      SELECT EXISTS (
        SELECT 1 
        FROM likes
        WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      )
            ''',
      parameters: [userId ?? currentUserId, id],
    ).map((event) => (event.first.values.first! as int).isTrue);
  }

  @override
  Stream<int> commentsAmountOf({required String postId}) =>
      _powerSyncRepository.db().watch(
        '''
      SELECT COUNT(*) AS comments_count FROM comments
      WHERE post_id = ? 
      ''',
        parameters: [postId],
      ).map(
        (result) => result.map((row) => row['comments_count']).first as int,
      );

  @override
  Future<void> like({
    required String id,
    bool post = true,
  }) async {
    if (currentUserId == null) return;
    final statement = post ? 'post_id' : 'comment_id';
    final exists = await _powerSyncRepository.db().execute(
      'SELECT 1 FROM likes '
      'WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL',
      [currentUserId, id],
    );
    if (exists.isEmpty) {
      await _powerSyncRepository.db().execute(
        '''
          INSERT INTO likes(user_id, $statement, id)
            VALUES(?, ?, uuid())
      ''',
        [currentUserId, id],
      );
      return;
    }
    await _powerSyncRepository.db().execute(
      '''
          DELETE FROM likes 
          WHERE user_id = ? AND $statement = ? AND $statement IS NOT NULL
      ''',
      [currentUserId, id],
    );
  }

  @override
  Stream<List<Post>> postsOf({String? userId}) {
    if (currentUserId == null) return const Stream.empty();
    if (userId == null) {
      return _powerSyncRepository.db().watch(
        '''
SELECT
  posts.*,
  p.id as user_id,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?1
ORDER BY created_at DESC
      ''',
        parameters: [currentUserId],
      ).map(
        (event) => event
            .safeMap((row) => Post.fromJson(Map<String, dynamic>.from(row)))
            .toList(growable: false),
      );
    }
    return _powerSyncRepository.db().watch(
      '''
SELECT
  posts.*,
  p.avatar_url as avatar_url,
  p.username as username,
  p.full_name as full_name
FROM
  posts
  left join profiles p on posts.user_id = p.id 
WHERE user_id = ?
ORDER BY created_at DESC
      ''',
      parameters: [userId],
    ).map(
      (event) {
        try {
          return event
              .map((row) => Post.fromJson(Map<String, dynamic>.from(row)))
              .toList(growable: false);
        } catch (e) {
          print('Error parsing posts: $e');
          return <Post>[];
        }
      },
    );
  }
}
