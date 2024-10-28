import 'package:api_repository/api_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/bootstrap.dart';
import 'package:conexion/firebase_options_dev.dart';
import 'package:database_client/database_client.dart';
import 'package:env/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:powersync/powersync.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  // ignore: lines_longer_than_80_chars
  bootstrap(
    (powerSyncRepository) async {
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

      final userRepository = UserRepository(
        databaseClient: powerSyncDatabaseClient,
        authenticationClient: supabaseAuthenticationClient,
      );

      final postRepository = PostsRepository(
        databaseClient: powerSyncDatabaseClient,
      );
      return App(
        user: await userRepository.user.first,
        userRepository: userRepository,
        postsRepository: postRepository,
      );
    },
    appFlavor: AppFlavor.development(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
