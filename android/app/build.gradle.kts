import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.davidag.cinemapedia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.davidag.cinemapedia"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use(keystoreProperties::load)
    }
    fun releaseProperty(name: String, environmentName: String): String? =
        System.getenv(environmentName) ?: keystoreProperties.getProperty(name)

    val releaseStoreFile = releaseProperty("storeFile", "QUEVEO_STORE_FILE")
    val releaseStorePassword = releaseProperty("storePassword", "QUEVEO_STORE_PASSWORD")
    val releaseKeyAlias = releaseProperty("keyAlias", "QUEVEO_KEY_ALIAS")
    val releaseKeyPassword = releaseProperty("keyPassword", "QUEVEO_KEY_PASSWORD")
    val hasReleaseCredentials = listOf(
        releaseStoreFile,
        releaseStorePassword,
        releaseKeyAlias,
        releaseKeyPassword,
    ).all { it != null }

    signingConfigs {
        create("release") {
            if (hasReleaseCredentials) {
                keyAlias = requireNotNull(releaseKeyAlias)
                keyPassword = requireNotNull(releaseKeyPassword)
                storeFile = file(requireNotNull(releaseStoreFile))
                storePassword = requireNotNull(releaseStorePassword)
            }
        }
    }

    buildTypes {
        release {
            val requiresReleaseSigning = gradle.startParameter.taskNames.any {
                it.contains("release", ignoreCase = true)
            }
            if (requiresReleaseSigning && !hasReleaseCredentials) {
                throw GradleException(
                    "Missing release signing credentials. Use android/key.properties or tool/build_release.sh.",
                )
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

