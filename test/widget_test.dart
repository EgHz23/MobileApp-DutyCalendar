import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Login screen displays correctly', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the login screen elements are present.
    expect(find.text("Welcome to EMP"), findsOneWidget);
    expect(find.text("Sign in to continue"), findsOneWidget);
    expect(find.text("Email"), findsOneWidget);
    expect(find.text("Password"), findsOneWidget);
    expect(find.text("Prijava"), findsOneWidget);
    expect(find.text("Forgot Password?"), findsOneWidget);
    expect(find.text("Sign Up"), findsOneWidget);
  });
}
