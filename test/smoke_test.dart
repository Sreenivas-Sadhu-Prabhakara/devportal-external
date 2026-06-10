import 'package:devportal_external/app.dart';
import 'package:devportal_external/auth/sign_in_page.dart';
import 'package:devportal_external/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(DevPortalApp(deps: AppDependencies.bootstrap()));
}

void main() {
  testWidgets('home renders nav and hero from mock catalog', (tester) async {
    await _pump(tester);
    expect(find.text('DEVPORTAL'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Build with our APIs.'), findsOneWidget);
    expect(find.text('Featured APIs'), findsOneWidget);
  });

  testWidgets('hardcoded login reaches the dashboard', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'passWORD1234#');
    await tester.tap(find.descendant(
        of: find.byType(SignInPage), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect(find.text('My apps'), findsWidgets); // nav button + page header
    expect(find.text('Aurora Mobile'), findsOneWidget);
  });

  testWidgets('wrong password is rejected', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'nope');
    await tester.tap(find.descendant(
        of: find.byType(SignInPage), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('My apps'), findsNothing);
  });

  testWidgets('BIAN transfer flow steps forward', (tester) async {
    await _pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Flows'));
    await tester.pumpAndSettle();
    expect(find.text('End-to-end flows'), findsOneWidget);
    expect(find.text('Internal fund transfer'), findsOneWidget);

    await tester.tap(find.text('Internal fund transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);

    await tester.tap(find.textContaining('Run step 1'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 3'), findsOneWidget);
  });
}
