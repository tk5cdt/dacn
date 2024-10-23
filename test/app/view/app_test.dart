import 'package:conexion/app/view/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_repository/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  group('App', () {
    testWidgets('has a title and message', (tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        App(userRepository: MockUserRepository()),
      );

      // Verify that our counter starts at 0.
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
