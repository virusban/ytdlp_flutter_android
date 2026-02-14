allprojects {
    repositories {
        google()
        mavenCentral()
        // Some older FFmpeg Kit artifacts are hosted on JCenter/JitPack
        jcenter()
        maven {
            url = uri("https://jitpack.io")
        }
        // Arthenica FFmpeg Kit repositories
        maven {
            url = uri("https://maven.ffmpegkit.org")
        }
        maven {
            url = uri("https://maven.arthenica.com")
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
