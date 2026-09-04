import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Reliz imzosi `android/key.properties` faylidan o'qiladi. Bu fayl ham,
// keystore'ning o'zi ham git'ga tushmaydi (.gitignore) — parol hech qachon
// repoda saqlanmaydi. Fayl yo'q bo'lsa reliz debug kalit bilan imzolanadi:
// mahalliy sinov uchun ishlaydi, lekin Play Console bunday paketni qabul
// qilmaydi. Tayyorlash yo'riqnomasi: android/RELEASE.md
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "uz.ocam.pos"
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
        // Play Store'dagi doimiy identifikator — ilova chiqarilgandan keyin
        // o'zgartirib bo'lmaydi.
        applicationId = "uz.ocam.pos"

        // mobile_scanner kamera API'si uchun kamida 21 talab qilinadi;
        // Flutter'ning standart minSdk'i undan yuqori.
        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "OGOHLANTIRISH: android/key.properties topilmadi — reliz " +
                        "debug kalit bilan imzolanmoqda. Play Console bunday " +
                        "paketni rad etadi (android/RELEASE.md ga qarang)."
                )
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
