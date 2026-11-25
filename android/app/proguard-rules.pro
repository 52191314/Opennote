# 🤖 Generated wholely or partially with Google Antigravity
-dontwarn javax.lang.model.element.Modifier

# R8 size optimizations
-repackageclasses 'o'
-allowaccessmodification
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
}

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep JNI native methods and descriptors across all native SDKs
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# OnyxSDK (keep only pen, note touch points, and EPD hardware reflection classes;
# let R8 tree-shake unused Onyx cloud/network/Tika/BouncyCastle transitive classes)
-keep class com.onyx.android.sdk.pen.** { *; }
-keep class com.onyx.android.sdk.data.note.** { *; }
-keep class com.onyx.android.sdk.api.device.** { *; }
-keep class com.onyx.android.sdk.device.** { *; }
-dontwarn com.onyx.**
-dontwarn org.apache.tika.**
-dontwarn org.bouncycastle.**

# Sentry (consumer rules in AAR keep required JNI/reflection hooks)
-dontwarn io.sentry.**
