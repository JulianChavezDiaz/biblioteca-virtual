// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biblioteca_digital/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Probar AppState que incluye los Providers
    await tester.pumpWidget(const AppState());
    
    // Verificar que carga elementos básicos (el texto exacto puede variar según la pantalla inicial)
    // Buscamos algo genérico que sepamos que está, como un Scaffold o CircularProgressIndicator inicialmente
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
