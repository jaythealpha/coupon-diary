# ML Kit 텍스트 인식은 스크립트별 모델 클래스를 리플렉션으로 찾는다.
# 난독화로 이름이 바뀌면 한글 인식기가 런타임에 로드되지 않는다.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_** { *; }

# 사용하지 않는 다른 스크립트(중국어·일본어·데바나가리) 인식기는 넣지 않는다.
# 없는 클래스를 참조한다는 경고만 나오므로 무시한다.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**

# flutter_local_notifications가 예약 알림을 GSON으로 직렬화해 보관한다.
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
