import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Datos de la llave de firma. Se leen de android/key.properties, que Git ignora:
// las contraseñas nunca llegan a GitHub. Si el archivo no existe (por ejemplo, en otro
// computador), el APK de release se firma con la llave de depuración y nada falla.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hayLlaveDeFirma = keystorePropertiesFile.exists()
if (hayLlaveDeFirma) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "co.edu.unicartagena.oye_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "co.edu.unicartagena.oye_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Toma version y build de pubspec.yaml (version: 1.0.0+1).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hayLlaveDeFirma) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Firma con la misma llave del Corte 3 (oye-release.jks).
            signingConfig = if (hayLlaveDeFirma) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
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
