-dontwarn javax.lang.model.element.Modifier

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# OnyxSDK
-keep class com.onyx.** { *; }
-dontwarn com.onyx.**

# Sentry
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**
