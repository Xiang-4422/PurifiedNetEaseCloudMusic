import 'dart:io';

import 'package:bujuan/ui/pages/auth/login_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login qr refresh uses an explicit control', () {
    final source = File('lib/ui/pages/auth/login_page_view.dart').readAsStringSync();

    expect(loginQrRefreshControlLabel(), '刷新登录二维码');
    expect(source, contains('Tooltip('));
    expect(source, contains('OutlinedButton.icon('));
    expect(source, contains('Icons.refresh'));
    expect(source, contains('onPressed: controller.refreshQrCode'));
    expect(source, isNot(contains('GestureDetector(')));
  });
}
