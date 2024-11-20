import 'package:api_repository/api_repository.dart';
import 'package:chats_repository/chats_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/bootstrap.dart';
import 'package:conexion/firebase_options_dev.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';

void main() {
  bootstrap(
    appFlavor: AppFlavor.development(),
    (
      powerSyncRepository,
      firebaseMessaging,
      sharedPreferences,
      firebaseRemoteConfigRepository,
    ) async {
      final firebaseNotificationsClient =
          FirebaseNotificationsClient(firebaseMessaging: firebaseMessaging);

      final notificationsRepository = NotificationsRepository(
        notificationsClient: firebaseNotificationsClient,
      );

      final tokenStorage = InMemoryTokenStorage();

      final appFlavor = AppFlavor.development();
      final iosClientId = appFlavor.getEnv(Env.iOSClientId);
      final webClientId = appFlavor.getEnv(Env.webClientId);
      final googleSignIn =
          GoogleSignIn(clientId: iosClientId, serverClientId: webClientId);

      final authenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository,
        tokenStorage: tokenStorage,
        googleSignIn: googleSignIn,
      );

      final databaseClient =
          PowerSyncDatabaseClient(powerSyncRepository: powerSyncRepository);

      final persistentStorage =
          PersistentStorage(sharedPreferences: sharedPreferences);

      // final storiesStorage = StoriesStorage(storage: persistentStorage);

      final userRepository = UserRepository(
        databaseClient: databaseClient,
        authenticationClient: authenticationClient,
      );

      final searchRepository = SearchRepository(databaseClient: databaseClient);

      final postsRepository = PostsRepository(databaseClient: databaseClient);

      final chatsRepository = ChatsRepository(databaseClient: databaseClient);

      // final storiesRepository = StoriesRepository(
      //   databaseClient: databaseClient,
      //   storage: storiesStorage,
      // );

      final powerSyncDatabaseClient = PowerSyncDatabaseClient(
        powerSyncRepository: powerSyncRepository,
      );

      return App(
        userRepository: userRepository,
        postsRepository: postsRepository,
        chatsRepository: chatsRepository,
        // storiesRepository: storiesRepository,
        searchRepository: searchRepository,
        notificationsRepository: notificationsRepository,
        firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
        user: await userRepository.user.first,
        databaseClient: powerSyncDatabaseClient,
      );
    },
  );
}
