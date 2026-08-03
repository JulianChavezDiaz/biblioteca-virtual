// Stub for dart:html on non-web platforms
class Window {
  Location get location => Location();
}

class Location {
  String get href => '';
}

final window = Window();

class IFrameElement {
  String? src;
  bool? allowFullscreen;
  CssStyleDeclaration style = CssStyleDeclaration();
}

class CssStyleDeclaration {
  String? border;
  String? width;
  String? height;
}