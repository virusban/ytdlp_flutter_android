// Top-level build file

plugins {
    kotlin("jvm") version "1.9.10" apply false
}

buildscript {
    val kotlin_version by extra("1.9.10")
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.0.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("com.chaquo.python:gradle:15.0.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
