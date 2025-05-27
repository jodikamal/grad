plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // إضافة هذه السطر
}

android {
    namespace = "com.example.graduation"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.graduation"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // تم تعديلها هنا
    }

    

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // تم تعديلها هنا
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.8.22")
    implementation("com.google.android.gms:play-services-wallet:19.1.0") // مكتبة خاصة بـ Google Pay إذا كنت تحتاجها
    implementation("com.stripe:stripe-android:20.32.1") // هذه هي مكتبة Stripe
}
