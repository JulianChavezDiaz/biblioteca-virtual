// Stub for dart:ui_web on non-web platforms
class PlatformViewRegistry {
  void registerViewFactory(String viewType, Function factory) {
    // No-op on mobile
  }
}

final platformViewRegistry = PlatformViewRegistry();