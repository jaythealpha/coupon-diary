# ML Kit 텍스트 인식은 스크립트별 모델 클래스를 리플렉션으로 찾는다.
# 난독화로 이름이 바뀌면 한글 인식기가 런타임에 로드되지 않는다.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }

# 한국어 모델은 build.gradle.kts에서 implementation으로 실제로 넣는다.
# (예전에는 이 파일이 "넣지 않는다"고만 적어두고 한국어까지 빠져 있었다.
#  그래서 첫 Android 릴리스 빌드가 R8 단계에서 멈췄다.)
#
# 쓰지 않는 나머지 스크립트는 넣지 않으므로 참조 경고만 끈다.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**

# flutter_local_notifications가 예약 알림을 GSON으로 직렬화해 보관한다.
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
