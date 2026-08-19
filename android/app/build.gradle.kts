import java.util.Properties

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

// Release signing material, resolved from `android/key.properties` for local
// release builds and from environment variables in CI. Absent on contributor
// machines and in the debug-only CI job, which is why `release` below degrades
// to debug signing rather than failing the build.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { load(it) }
    }
}

fun signingValue(propertyKey: String, environmentKey: String): String? =
    keystoreProperties.getProperty(propertyKey) ?: System.getenv(environmentKey)

val releaseStoreFile = signingValue("storeFile", "QIMA_KEYSTORE_PATH")
val releaseStorePassword = signingValue("storePassword", "QIMA_KEYSTORE_PASSWORD")
val releaseKeyAlias = signingValue("keyAlias", "QIMA_KEY_ALIAS")
val releaseKeyPassword = signingValue("keyPassword", "QIMA_KEY_PASSWORD")
val hasReleaseSigning = releaseStoreFile != null &&
    releaseStorePassword != null &&
    releaseKeyAlias != null &&
    releaseKeyPassword != null

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

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    defaultConfig {
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
            // Never ship a publicly distributed APK signed with the debug key:
            // it is a shared, well-known key, so anyone could sign an "update"
            // that Android would install straight over a user's install. The
            // fallback exists only so contributors and the debug-only CI job
            // can still build without the private keystore.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "WARNING: no release keystore found - signing the release build with the " +
                        "debug key. This build MUST NOT be distributed."
                )
                signingConfigs.getByName("debug")
            }
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
