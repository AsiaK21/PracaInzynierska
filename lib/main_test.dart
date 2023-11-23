import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projekt_inzynierski/user/login_screen.dart';
import 'main.dart';

void main() {
  testWidgets('App initializes without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(tester.takeException(), isNull);
  });

  testWidgets('WelcomeScreen delays navigation', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.pump(const Duration(seconds: 6));

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('WelcomeScreen contains PL logo', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    await tester.pump(const Duration(seconds: 6));

    expect(
      find.byWidgetPredicate(
            (Widget widget) =>
        widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/PL_logo.png',
      ),
      findsOneWidget,
    );
  });
}
