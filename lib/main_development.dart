import 'package:api_repository/api_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/bootstrap.dart';
import 'package:conexion/firebase_options_dev.dart';
import 'package:shared/shared.dart';

void main() {
  // ignore: lines_longer_than_80_chars
  const apiRepository = ApiRepository();
  bootstrap((powerSyncRepository) {
    return const App(apiRepository: apiRepository);
  }, 
  appFlavor: AppFlavor.development(),
  firebaseOptions: DefaultFirebaseOptions.currentPlatform,
  );
}
