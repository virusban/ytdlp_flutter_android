plugins {
    id("com.android.application")
    kotlin("android")
    id("com.chaquo.python")
}

android {
    namespace = "com.ronna.ytdlpflutterandroid"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.ronna.ytdlpflutterandroid"
        minSdk = 30
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

python {
    buildPython("3.10")
    pip {
        install("yt-dlp")
        install("ffmpeg-python")
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation("androidx.core:core-ktx:1.12.0")
}
