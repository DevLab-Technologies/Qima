import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Compose compiler for the Glance home-screen widgets in
    // src/main/kotlin/.../widget/ (androidx.glance is Compose-based even
    // though it renders to RemoteViews, not a real view hierarchy).
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.devtools.ksp")
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
    // 37 rather than Flutter's default: androidx.appfunctions (the read-only
    // assistant answers in AssistantFunctions.kt) needs it to compile.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications v10+ regardless of whether
        // scheduled (not just immediate) notifications are used — see its
        // README "Android Setup · Gradle setup".
        isCoreLibraryDesugaringEnabled = true
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

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
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
    // Compose Material 3 for the widgets' native configuration Activities
    // (android/app/src/main/kotlin/.../widget/*ConfigActivity.kt).
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    // Read-only App Functions for the system assistant (AssistantFunctions.kt);
    // the compiler generates the service and its XML description.
    implementation("androidx.appfunctions:appfunctions:1.0.0-beta01")
    ksp("androidx.appfunctions:appfunctions-compiler:1.0.0-beta01")
    // flutter_local_notifications' core-library desugaring requirement (see
    // compileOptions above).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // integration_test (in debug builds) asks for espresso 3.2, whose core
    // and idling-resource modules share a namespace, an error since AGP 9.
    constraints {
        debugImplementation("androidx.test.espresso:espresso-core:3.6.1")
    }

    testImplementation("junit:junit:4.13.2")
    testImplementation("org.json:json:20240303")
}
