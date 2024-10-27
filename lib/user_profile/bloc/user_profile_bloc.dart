import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'user_profile_event.dart';
part 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  UserProfileBloc({
    required UserRepository userRepository, 
    String? userId,
  })
      : _userRepository = userRepository,
       _userId = userId ?? '',
        super(const UserProfileState.initial());
  final String _userId;
  final UserRepository _userRepository;
}
