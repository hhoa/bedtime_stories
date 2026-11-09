import 'dart:developer';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser mic permission: `granted`, `prompt`, `denied`, or null when the
/// browser can't tell (Firefox and older Safari don't know "microphone").
Future<String?> webMicState() async {
  try {
    final status = await web.window.navigator.permissions
        .query({'name': 'microphone'}.jsify()! as JSObject)
        .toDart;
    return status.state;
  } catch (e) {
    log('permissions.query failed: $e', name: 'webMicState');
    return null;
  }
}
