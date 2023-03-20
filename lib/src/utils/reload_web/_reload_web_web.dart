// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

void reloadWebImpl() {
  html.window.location.reload();
}
