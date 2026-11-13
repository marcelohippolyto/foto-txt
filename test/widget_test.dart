import 'package:flutter_test/flutter_test.dart';
import 'package:foto_txt/main.dart';

void main() {
  testWidgets('mostra os botões iniciais', (tester) async {
    await tester.pumpWidget(const FotoTxtApp());
    expect(find.text('Tirar foto'), findsOneWidget);
    expect(find.text('Escolher da galeria'), findsOneWidget);
  });
}
