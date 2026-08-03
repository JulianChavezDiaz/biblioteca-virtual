# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase rules
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# PDF viewer rules
-keep class com.github.barteksc.pdfviewer.** { *; }
-keep class com.syncfusion.flutter.pdfviewer.** { *; }

# Video player rules
-keep class io.flutter.plugins.videoplayer.** { *; }

# Network rules
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-dontwarn retrofit2.**
-dontwarn okhttp3.**

# General Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}