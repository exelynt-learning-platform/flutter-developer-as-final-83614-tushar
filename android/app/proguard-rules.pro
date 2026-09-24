# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep models and entities from obfuscation if serialized
-keep class com.tushar.employee_management.** { *; }

# Suppress Play Core warnings for Flutter deferred components
-dontwarn com.google.android.play.core.**
