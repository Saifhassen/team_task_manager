plugins {
    id("com.android.application")
    id("kotlin-android")
<<<<<<< HEAD
=======
    id("com.google.gms.google-services")
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.team_task_manager"
    compileSdk = flutter.compileSdkVersion
<<<<<<< HEAD
    ndkVersion = flutter.ndkVersion
=======
    ndkVersion = "27.0.12077973"
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
=======
        isCoreLibraryDesugaringEnabled = true // ✅ الصيغة الصحيحة في Kotlin DSL
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
<<<<<<< HEAD
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.team_task_manager"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
=======
        applicationId = "com.example.team_task_manager"
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
=======
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
<<<<<<< HEAD
=======

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.16.0"))
    implementation("com.google.firebase:firebase-analytics")

    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.9.0")

    // ✅ دعم desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

// ✅ تفعيل Google Services (Firebase)
apply(plugin = "com.google.gms.google-services")
>>>>>>> 79bd5efd2fb98a4aaa480b01e6f2d7cebefcce7c
