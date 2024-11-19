import 'package:chats_repository/chats_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/bootstrap.dart';
import 'package:conexion/firebase_options_prod.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:search_repository/search_repository.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  bootstrap(
    (
      powerSyncRepository,
      firebaseRemoteConfigRepository,
    ) async {
      final tokenStorage = InMemoryTokenStorage();

      final iOSClientId = getIt<AppFlavor>().getEnv(Env.iOSClientId);
      final webClientId = getIt<AppFlavor>().getEnv(Env.webClientId);

      final googleSignIn = GoogleSignIn(
        clientId: iOSClientId,
        serverClientId: webClientId,
      );
      final supabaseAuthenticationClient = SupabaseAuthenticationClient(
        powerSyncRepository: powerSyncRepository,
        tokenStorage: tokenStorage,
        googleSignIn: googleSignIn,
      );

      final powerSyncDatabaseClient = PowerSyncDatabaseClient(
        powerSyncRepository: powerSyncRepository,
      );

      final chatsRepository = ChatsRepository(
        databaseClient: powerSyncDatabaseClient,
      );

      final userRepository = UserRepository(
        databaseClient: powerSyncDatabaseClient,
        authenticationClient: supabaseAuthenticationClient,
      );
      final searchRepository =
          SearchRepository(databaseClient: powerSyncDatabaseClient);
      final postRepository = PostsRepository(
        databaseClient: powerSyncDatabaseClient,
      );
      return App(
        user: await userRepository.user.first,
        userRepository: userRepository,
        postsRepository: postRepository,
        chatsRepository: chatsRepository,
        searchRepository: searchRepository,
        firebaseRemoteConfigRepository: firebaseRemoteConfigRepository,
        databaseClient: powerSyncDatabaseClient,
      );
    },
    appFlavor: AppFlavor.production(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
