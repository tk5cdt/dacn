import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:env/env.dart';
import 'package:powersync/sqlite3_common.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';
import 'package:con_blocks/con_blocks.dart';

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

abstract class ChatsBaseRepository {
  /// Returns a stream of real-time chats of the user identified by [userId].
  Stream<List<ChatInbox>> chatsOf({required String userId});

  /// Returns a stream of real-time messages of the chat identified by [chatId].
  Stream<List<Message>> messagesOf({required String chatId});

  /// Creates and send message with provided data. After sending the message
  /// the notification is sent to the user, identified by [receiver]'s `id`.
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  });

  /// Deletes the message with provided [messageId].
  Future<void> deleteMessage({required String messageId});

  /// Deletes the chat with provided [chatId] and participant from the chat,
  /// identified by [userId].
  Future<void> deleteChat({required String chatId, required String userId});

  /// Creates a new chat with provided [userId] and [participantId].
  Future<void> createChat({
    required String userId,
    required String participantId,
  });

  /// Marks the message as read by [messageId].
  Future<void> readMessage({
    required String messageId,
  });

  /// Edits the message with provided [oldMessage] and [newMessage].
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
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
    implements UserBaseRepository, PostsBaseRepository, ChatsBaseRepository {
  /// {@macro database_client}
  const DatabaseClient();
}

class PowerSyncDatabaseClient
    implements DatabaseClient, PostsBaseRepository, ChatsBaseRepository {
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
    try {
      if (currentUserId == null) return null;
      print('Inserting post data...');

      try {
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

        print('Database insert result: $result');

        if (result.isEmpty) return null;
        final row = Map<String, dynamic>.from((result.first as ResultSet).first);
        final author = User.fromJson(result.last as Row);
        return Post.fromJson(row).copyWith(author: author);
      } catch (insertError) {
        print('Insert/Update error: $insertError');
        return null;
      }
    } catch (e) {
      print('Error in createPost: $e');
      rethrow;
    }
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

    print('user id: ${currentUserId}');

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

  @override
  Stream<List<ChatInbox>> chatsOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        '''
        select
          c.id,
          c.type,
          c.name,
          p2.id as participant_id,
          p2.full_name as participant_name,
          p2.email as participant_email,
          p2.username as participant_username,
          p2.avatar_url as participant_avatar_url,
          p2.push_token as participant_push_token
        from
          conversations c
          join participants pt on c.id = pt.conversation_id
          join profiles p on pt.user_id = p.id
          join participants pt2 on c.id = pt2.conversation_id
          join profiles p2 on pt2.user_id = p2.id
        where
          pt.user_id = ?1
          and pt2.user_id != ?1
        ''',
        parameters: [userId],
      ).map(
        (event) => event.safeMap(ChatInbox.fromRow).toList(growable: false),
      );

  @override
  Future<void> createChat({
    required String userId,
    required String participantId,
  }) async {
    final alreadyExists = await _powerSyncRepository.db().getOptional(
      '''
      SELECT 1
      FROM conversations c
      JOIN participants p1 ON c.id = p1.conversation_id
      JOIN participants p2 ON c.id = p2.conversation_id
      WHERE p1.user_id = ? AND p2.user_id = ?
      ''',
      [userId, participantId],
    );
    if (alreadyExists != null) return;
    final conversationId = uuid.v4();
    final createdConversation = _powerSyncRepository.db().execute(
      '''
      insert into
        conversations (id, type, name, created_at, updated_at)
      values
        (?, ?, '', ?, ?)
      ''',
      [conversationId, ChatType.oneOnOne.value, JiffyX.now(), JiffyX.now()],
    );
    final addParticipant1 = _powerSyncRepository.db().execute(
      '''
      insert into
        participants (id, user_id, conversation_id)
      values
        (?, ?, ?)
      ''',
      [uuid.v4(), userId, conversationId],
    );
    final addParticipant2 = _powerSyncRepository.db().execute(
      '''
      insert into
        participants (id, user_id, conversation_id)
      values
        (?, ?, ?)
      ''',
      [uuid.v4(), participantId, conversationId],
    );
    await createdConversation
        .whenComplete(() => Future.wait([addParticipant1, addParticipant2]));
  }

  @override
  Future<void> deleteChat({
    required String chatId,
    required String userId,
  }) async {
//     final participants = (await _powerSyncRepository.db().get(
//       '''
// select
//   count(*) as participants_count
// from
//   participants
// where conversation_id = ?
// ''',
//       [chatId],
//     ))['participants_count'] as int;
//     if (participants >= 1) {
//       final isParticipantInConversation = await _powerSyncRepository.db()
// .get(
//         '''
// select
//   *
// from
//   participants
// where
//   user_id = ?
//   and conversation_id = ?
//   ''',
//         [userId, chatId],
//       );
//       if (isParticipantInConversation.isEmpty) return;
//       await _powerSyncRepository.db().execute(
//         '''
// delete from participants
// where
//   user_id = ?
//   and conversation_id = ?
// ''',
//         [userId, chatId],
//       );
//       return;
//     }
    await _powerSyncRepository.db().execute(
      '''
      delete from conversations
      where
        id = ?
      ''',
      [chatId],
    );
  }

  @override
  Future<void> deleteMessage({required String messageId}) =>
      _powerSyncRepository.db().execute(
        '''
delete from messages
where
  id = ?
''',
        [messageId],
      );

  @override
  Future<void> readMessage({
    required String messageId,
  }) async {
    await _powerSyncRepository.db().execute(
      '''
      UPDATE messages
      SET
        is_read = 1
      WHERE
        id = ?
      ''',
      [messageId],
    );
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required User sender,
    required User receiver,
    required Message message,
    PostAuthor? postAuthor,
  }) =>
      _powerSyncRepository.db().writeTransaction((sqlContext) async {
        await sqlContext.execute(
          '''
          insert into
            messages (
              id, conversation_id, from_id, type, message, reply_message_id, created_at, 
              updated_at, is_read, is_deleted, is_edited, reply_message_username,
              reply_message_attachment_url, shared_post_id
              )
          values
            (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, ?, ?, ?)
          ''',
          [
            message.id,
            chatId,
            sender.id,
            message.type.value,
            message.message,
            message.replyMessageId,
            DateTime.now().toIso8601String(),
            DateTime.now().toIso8601String(),
            message.replyMessageUsername,
            message.replyMessageAttachmentUrl,
            message.sharedPostId,
          ],
        );

        await sqlContext.executeBatch(
          '''
insert into
  attachments (
    id, message_id, title, text, title_link, image_url,
    thumb_url, author_name, author_link, asset_url, og_scrape_url, type
  )
values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
          message.attachments
              .map(
                (a) => [
                  a.id,
                  message.id,
                  a.title,
                  a.text,
                  a.titleLink,
                  a.imageUrl,
                  a.thumbUrl,
                  a.authorName,
                  a.authorLink,
                  a.assetUrl,
                  a.ogScrapeUrl,
                  a.type,
                ],
              )
              .toList(),
        );

        try {
          final receivePort = ReceivePort();

          await Isolate.spawn(sendBackgroundNotification, [
            receivePort.sendPort,
            receiver,
            sender,
            message,
            postAuthor,
            chatId,
          ]);
        } catch (error, stackTrace) {
          logE(
            'Error send notification.',
            error: error,
            stackTrace: stackTrace,
          );
        }
      });

  @override
  Stream<List<Message>> messagesOf({required String chatId}) =>
      _powerSyncRepository.db().watch(
        '''
        SELECT
          m.*,
          m_sender.full_name as full_name,
          m_sender.username as username,
          m_sender.avatar_url as avatar_url,
          a.id as attachment_id,
          a.title as attachment_title,
          a.text as attachment_text,
          a.title_link as attachment_title_link,
          a.image_url as attachment_image_url,
          a.thumb_url as attachment_thumb_url,
          a.author_name as attachment_author_name,
          a.author_link as attachment_author_link,
          a.asset_url as attachment_asset_url,
          a.og_scrape_url as attachment_og_scrape_url,
          a.type as attachment_type,
          r.message as replied_message_message,
          p.caption as shared_post_caption,
          p.created_at as shared_post_created_at,
          p.media as shared_post_media,
          p_author.id as shared_post_author_id,
          p_author.username as shared_post_author_username,
          p_author.full_name as shared_post_author_full_name,
          p_author.avatar_url as shared_post_author_avatar_url
        FROm
          messages m
          left join attachments a on m.id = a.message_id
          left join messages r on m.reply_message_id = r.id
          left join posts p on m.shared_post_id = p.id
          join profiles m_sender on m.from_id = m_sender.id
          left join profiles p_author on p.user_id = p_author.id
        where
          m.conversation_id = ?   
        order by created_at asc
        ''',
        parameters: [chatId],
      ).map((event) => event.safeMap(Message.fromRow).toList(growable: false));

  /// Sends notification in a background isolate.
  Future<void> sendBackgroundNotification(List<dynamic> args) async {
    await sendNotification(
      reciever: args[1] as User,
      sender: args[2] as User,
      message: args[3] as Message,
      postAuthor: args[4] as PostAuthor?,
      chatId: args[5] as String,
    );
    Isolate.exit(args[0] as SendPort, args);
  }

  /// Sends notification using Google APIs to user.
  Future<void> sendNotification({
    required User reciever,
    required User sender,
    String? chatId,
    Message? message,
    PostAuthor? postAuthor,
  }) async {
    final notificationMessage = postAuthor != null
        ? 'Sent post by ${postAuthor.username}'
        : message?.message;
    final notificationBody =
        '(${reciever.displayUsername}): ${sender.displayUsername}: '
        '$notificationMessage';

    final data = {
      'to': reciever.pushToken,
      'content_available': true,
      'priority': 10,
      'notification': {
        'title': 'Instagram',
        'body': notificationBody,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'data': {
        if (chatId != null) 'chat_id': chatId,
      },
    };

    final headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      // HttpHeaders.authorizationHeader: 'key=${EnvProd.fcmServerKey}',
    };

    final res = await Dio().post<String>(
      'https://fcm.googleapis.com/fcm/send',
      data: jsonEncode(data),
      options: Options(headers: headers),
    );
    logD('Response: $res, \n status code: ${res.statusCode}');
  }

  @override
  Future<void> editMessage({
    required Message oldMessage,
    required Message newMessage,
  }) async {
    late final newMessageHasAttachments = newMessage.attachments.isNotEmpty;
    late final oldMessageHasAttachments = oldMessage.attachments.isNotEmpty;
    late final updateOldMessageAttachments =
        newMessageHasAttachments && oldMessageHasAttachments;
    late final insertNewMessageAttachments =
        newMessageHasAttachments && !oldMessageHasAttachments;

    await _powerSyncRepository.db().execute(
      '''
      update messages
      set
        message = ?1,
        updated_at = ?2
      where
        id = ?3
      ''',
      [
        newMessage.message,
        DateTime.timestamp().toIso8601String(),
        newMessage.id,
      ],
    );
    if (!newMessageHasAttachments && oldMessageHasAttachments) {
      await _powerSyncRepository.db().execute(
        '''
        delete from attachments
        where message_id = ?
        ''',
        [newMessage.id],
      );
      return;
    }
    if (updateOldMessageAttachments) {
      final oldAttachmentId = oldMessage.attachments.first.id;
      await _powerSyncRepository.db().executeBatch(
        '''
        update attachments
        set
          title = ?,
          text = ?,
          title_link = ?,
          image_url = ?,
          thumb_url = ?,
          author_name = ?,
          author_link = ?,
          asset_url = ?,
          og_scrape_url = ?
        where
          id = ?
          and message_id = ?
        ''',
        newMessage.attachments
            .map(
              (a) => [
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                oldAttachmentId,
                oldMessage.id,
              ],
            )
            .toList(),
      );
      return;
    }
    if (insertNewMessageAttachments) {
      await _powerSyncRepository.db().executeBatch(
        '''
        insert into
          attachments (
            id, message_id, title, text, title_link, image_url,
            thumb_url, author_name, author_link, asset_url, og_scrape_url, type
          )
        values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        newMessage.attachments
            .map(
              (a) => [
                a.id,
                newMessage.id,
                a.title,
                a.text,
                a.titleLink,
                a.imageUrl,
                a.thumbUrl,
                a.authorName,
                a.authorLink,
                a.assetUrl,
                a.ogScrapeUrl,
                a.type,
              ],
            )
            .toList(),
      );
    }
  }
}
