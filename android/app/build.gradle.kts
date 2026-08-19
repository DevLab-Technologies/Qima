plugins {
    id("com.android.application")
    id("kotlin-android")
    // Compose compiler for the Glance home-screen widgets in
    // src/main/kotlin/.../widget/ (androidx.glance is Compose-based even
    // though it renders to RemoteViews, not a real view hierarchy).
    id("org.jetbrains.kotlin.plugin.compose")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.devlabtechnologies.qima"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildFeatures {
        compose = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.devlabtechnologies.qima"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Jetpack Glance for the home-screen widgets (android/app/src/main/kotlin/.../widget/).
    // Version pinned explicitly (rather than relying on home_widget's own
    // transitive dependency) so the app module's Compose classpath is
    // predictable regardless of what the plugin bundles in a future update.
    implementation("androidx.glance:glance-appwidget:1.1.1")
}
