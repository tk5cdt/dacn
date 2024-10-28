import 'package:powersync_repository/powersync_repository.dart' hide User;
import 'package:user_repository/user_repository.dart';

abstract class UserBaseRepository {
  const UserBaseRepository();

  String? get currentUserId;

  Stream<User> profile({required String userId});

  Stream<int> followingsCountOf({required String userId});

  Stream<int> followersCountOf({required String userId});
}

abstract class PostsBaseRepository {
  const PostsBaseRepository();

  Stream<int> postsAmountOf({required String userId});
}

/// {@template database_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
abstract class DatabaseClient implements UserBaseRepository, PostsBaseRepository {
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
  Stream<User> profile({required String userId}) => _powerSyncRepository.db().watch(
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
      ).map(
        (event) => event.first['posts_count'] as int,
      );
      
  @override
  Stream<int> followersCountOf({required String userId}) =>
      _powerSyncRepository.db().watch(
        'SELECT COUNT(*) AS subscription_count FROM subscriptions '
        'WHERE subscribed_to_id = ?',
        parameters: [userId],
      ).map(
        (event) => event.first['subscription_count'] as int,
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
}
