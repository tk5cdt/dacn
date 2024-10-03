import 'package:api_repository/api_repository.dart';
import 'package:conexion/app/app.dart';
import 'package:conexion/bootstrap.dart';

void main() {
  const apiRepository = ApiRepository();
  bootstrap(() => const App(
        apiRepository: apiRepository,
      ));
}
