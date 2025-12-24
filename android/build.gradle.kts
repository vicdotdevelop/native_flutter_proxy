import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

allprojects {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

group = "com.victorblaess.native_flutter_proxy"

android {
    namespace = "com.victorblaess.native_flutter_proxy"
    ndkVersion = "27.3.13750724"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    defaultConfig {
        minSdk = flutter.minSdkVersion
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    lint {
        disable.add("InvalidPackage")
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
