import 'package:api_repository/api_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class TodosCubit extends Cubit<List<String>> {
  TodosCubit({
    required ApiRepository apiRepository,
  })  : _apiRepository = apiRepository,
        super(const <String>[]);
  final ApiRepository _apiRepository;

  void fetchTodos() => emit(_apiRepository.fetchTodos());
}
