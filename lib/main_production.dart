import 'package:conexion/app/app.dart';
import 'package:conexion/app/di/di.dart';
import 'package:conexion/bootstrap.dart';
import 'package:conexion/firebase_options_prod.dart';
import 'package:env/env.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared/shared.dart';
import 'package:supabase_authentication_client/supabase_authentication_client.dart';
import 'package:token_storage/token_storage.dart';
import 'package:user_repository/user_repository.dart';

void main() {
  bootstrap(
    (powerSyncRepository) {
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

      final userRepository = UserRepository(
        authenticationClient: supabaseAuthenticationClient,
      );
      return App(userRepository: userRepository);
    },
    appFlavor: AppFlavor.production(),
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
