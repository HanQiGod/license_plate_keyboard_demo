import 'package:flutter_test/flutter_test.dart';

import 'package:license_plate_keyboard_demo/main.dart';

void main() {
  testWidgets('renders custom license plate keyboard and updates step',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('自定义车牌号键盘'), findsOneWidget);
    expect(find.text('当前位：第 1 位 · 省份简称'), findsNWidgets(2));
    expect(find.text('普通车牌'), findsOneWidget);

    await tester.tap(find.text('京'));
    await tester.pump();

    expect(find.text('当前位：第 2 位 · 发牌机关字母'), findsNWidgets(2));
    expect(find.text('京······'), findsOneWidget);
  });
}
