import 'package:devportal_external/app.dart';
import 'package:devportal_external/auth/sign_in_page.dart';
import 'package:devportal_external/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Full UI journeys for the external developer portal, driven through the real
/// widget tree (taps, text entry, navigation) at a desktop viewport.
void main() {
  Future<void> boot(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(DevPortalApp(deps: AppDependencies.bootstrap()));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'passWORD1234#');
    await tester.tap(find.descendant(
        of: find.byType(SignInPage), matching: find.byType(FilledButton)));
    await tester.pumpAndSettle();
  }

  testWidgets('catalog → BIAN product → Try-it returns a response',
      (tester) async {
    await boot(tester);
    expect(find.text('Build with our APIs.'), findsOneWidget);

    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();
    expect(find.text('API Catalog'), findsOneWidget);
    expect(find.text('Payment Initiation API'), findsOneWidget);

    await tester.tap(find.text('Payment Initiation API'));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);

    await tester.tap(find.widgetWithText(Tab, 'Try it'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
    await tester.pumpAndSettle();
    expect(find.text('200 OK'), findsOneWidget);
  });

  testWidgets('login → register app against a public product → keys issued',
      (tester) async {
    await boot(tester);
    await signIn(tester);
    expect(find.text('Aurora Mobile'), findsOneWidget); // dashboard

    await tester.tap(find.widgetWithText(FilledButton, 'Register app'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'CI Test App');
    await tester.tap(find.text('Accounts API')); // public → auto-approve
    await tester.pumpAndSettle();
    final createBtn =
        find.widgetWithText(FilledButton, 'Create app & get keys');
    await tester.ensureVisible(createBtn); // button is below the fold
    await tester.pumpAndSettle();
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    expect(find.text('Credentials'), findsOneWidget);
    expect(find.text('CONSUMER KEY'), findsOneWidget); // label is uppercased
  });

  testWidgets('flows → internal transfer runs to completion', (tester) async {
    await boot(tester);
    await tester.tap(find.text('Flows'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internal fund transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.textContaining('Run step'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Transfer complete'), findsOneWidget);
  });

  testWidgets('flows → external transfer adds a settlement step',
      (tester) async {
    await boot(tester);
    await tester.tap(find.text('Flows'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('External fund transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 4'), findsOneWidget); // extra clearing step

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.textContaining('Run step'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Transfer complete'), findsOneWidget);
  });
}
