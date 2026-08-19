package com.coupondiary.coupon_diary

import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * local_auth의 생체 인증 다이얼로그(BiometricPrompt)는 FragmentActivity를 요구한다.
 * 기본 FlutterActivity를 그대로 두면 앱 잠금을 켤 때 런타임에 실패한다.
 */
class MainActivity : FlutterFragmentActivity()
