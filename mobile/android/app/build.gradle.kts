plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.dalili"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.dalili"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            isMinifyEnabled = true
            isShrinkResources = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Per-ABI splitting is intentionally NOT configured via a manual
    // Gradle `splits {}` block here — the Flutter Gradle plugin already
    // sets `ndk.abiFilters` itself, and a manual `splits.abi` block
    // conflicts with it ("Conflicting configuration" build failure).
    // Flutter's own mechanism for this is the build command:
    //   flutter build apk --split-per-abi
    // (or, preferably for Play Store distribution, `flutter build
    // appbundle`, which delivers per-device ABI splits automatically
    // without any extra Gradle config). This was the largest remaining
    // lever on APK size after minify/shrink — use one of the two build
    // commands above instead of a universal `flutter build apk`.
}

flutter {
    source = "../.."
}
