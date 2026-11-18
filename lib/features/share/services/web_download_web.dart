import 'dart:convert';

import 'package:web/web.dart' as web;

void downloadFileWeb(List<int> bytes, String filename) {
  final base64String = base64Encode(bytes);
  final uri = 'data:application/octet-stream;base64,$base64String';
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = uri
    ..download = filename;

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}
