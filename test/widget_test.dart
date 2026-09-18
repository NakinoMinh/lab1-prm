import 'package:flutter_test/flutter_test.dart';
import 'package:fap_attendance_app/main.dart';

void main() {
  testWidgets('App renders title smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FapAttendanceApp());
    expect(find.text('FAP ATTENDANCE'), findsOneWidget);
  });
}
