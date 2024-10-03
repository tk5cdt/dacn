import 'package:conexion/app/app.dart';
import 'package:conexion/app/view/app_view.dart';
import 'package:conexion/counter/counter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const AppView());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
