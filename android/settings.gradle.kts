pluginManagement {
    val agpVersion: String by settings
    val kotlinVersion: String by settings

    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    plugins {
        id("com.android.library") version agpVersion
        id("org.jetbrains.kotlin.android") version kotlinVersion
    }
}

rootProject.name = "native_flutter_proxy"
