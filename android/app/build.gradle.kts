// 🤖 Generated wholely or partially with Google Antigravity
import com.android.build.gradle.internal.api.ApkVariantOutputImpl
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val fallbackKeystorePropertiesFile = rootProject.file("fallback-key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else if (fallbackKeystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(fallbackKeystorePropertiesFile))
}

android {
    namespace = "com.woaiyj1314.opennote"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.woaiyj1314.opennote"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters.clear()
            abiFilters += listOf("arm64-v8a")
        }
    }

    androidResources {
        localeFilters += listOf(
            "en",
            "ar",
            "ca",
            "cs",
            "de",
            "eo",
            "es",
            "fa",
            "fr",
            "he",
            "hu",
            "it",
            "ja",
            "nl",
            "pl",
            "pt",
            "pt-rBR",
            "ru",
            "sl",
            "th",
            "tr",
            "uk",
            "vi",
            "b+zh+Hans+CN",
            "b+zh+Hant+TW",
        )
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
            pickFirsts.add("lib/*/libc++_shared.so")
        }
        resources.excludes.addAll(
            listOf(
                "META-INF/{AL2.0,LGPL2.1}",
                "META-INF/*.kotlin_module",
                "META-INF/*.version",
                "META-INF/androidx.*",
                "META-INF/com.android.tools/**",
                "DebugProbesKt.bin",
                "kotlin/**",
                "kotlin-tooling-metadata.json",
            ),
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.15.0")
}

base {
    archivesName.set("Opennote")
}

val abiCodes = mapOf("arm64-v8a" to 2)
android.applicationVariants.configureEach {
    val variant = this
    variant.outputs.forEach { output ->
        val impl = output as ApkVariantOutputImpl
        val abi = impl.filters.find { it.filterType == "ABI" }?.identifier
        val abiVersionCode = abiCodes[abi]
        if (abiVersionCode != null) {
            impl.versionCodeOverride = variant.versionCode * 10 + abiVersionCode
        }
        val abiSuffix = if (abi != null) "_$abi" else ""
        impl.outputFileName = "Opennote_v${variant.versionName}${abiSuffix}.apk"
    }
}
