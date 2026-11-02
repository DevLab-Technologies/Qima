pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.1.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.21" apply false
    // Kotlin 2.0+ moved the Compose compiler out of the Kotlin Gradle plugin
    // into this standalone plugin, versioned in lockstep with Kotlin itself.
    // Needed because the app module now hosts its own @Composable Glance
    // widget code (android/app/src/main/kotlin/.../widget/*.kt).
    id("org.jetbrains.kotlin.plugin.compose") version "2.3.21" apply false
    // Runs the androidx.appfunctions compiler over AssistantFunctions.kt.
    id("com.google.devtools.ksp") version "2.3.13" apply false
}

include(":app")
