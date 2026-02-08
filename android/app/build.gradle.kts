plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.chaquo.python")
}

android {
    namespace = "com.example.ytdlp_flutter_android"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ytdlp_flutter_android"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        python {
            pip {
                install("yt-dlp")
                install("ffmpeg-python")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {}
