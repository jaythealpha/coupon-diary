import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 서명 키는 저장소에 넣지 않는다. `android/key.properties`(gitignore 대상)에서 읽고,
// 파일이 없으면 디버그 서명으로 떨어져 개발 빌드는 계속 동작한다.
// 설정 방법은 docs/03-release.md 참고.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    namespace = "com.coupondiary.coupon_diary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications가 예약 알림에 java.time을 쓴다.
        // 이 옵션이 없으면 구형 Android에서 빌드가 실패한다.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.coupondiary.coupon_diary"
        // ML Kit 온디바이스 인식의 최소 요구 버전.
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        resourceConfigurations += listOf("ko", "en")
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    // 한국어 텍스트 인식 모델.
    //
    // google_mlkit_text_recognition 플러그인은 스크립트별 모델을 전부
    // `compileOnly`로만 선언한다 — 앱이 쓰는 것만 직접 넣으라는 뜻이다.
    // 이걸 빠뜨리면 R8이 `KoreanTextRecognizerOptions` 부재로 빌드를 세우고,
    // R8을 꺼도 `TextRecognizer(script: korean)` 호출에서 런타임에 죽는다.
    // 한국어 기프티콘 인식이 이 앱의 전제라 없어서는 안 된다.
    implementation("com.google.mlkit:text-recognition-korean:16.0.1")
}

flutter {
    source = "../.."
}
