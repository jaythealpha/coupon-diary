import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/gift/presentation/gift_screen.dart';
import '../features/help/presentation/how_to_screen.dart';
import '../features/recognition/presentation/add_coupon_screen.dart';
import '../features/recognition/presentation/gallery_scan_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/usage/presentation/use_coupon_screen.dart';
import '../features/vault/presentation/coupon_detail_screen.dart';
import '../features/vault/presentation/coupon_form_screen.dart';
import '../features/vault/presentation/vault_screen.dart';

/// 모든 화면은 URL로 도달 가능해야 한다. 알림 탭 → 해당 쿠폰으로 바로 열기
/// (딥링크)가 이 앱의 핵심 동선이기 때문.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'vault',
      builder: (context, state) => const VaultScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'add',
          builder: (context, state) => const AddCouponScreen(),
          routes: [
            GoRoute(
              path: 'gallery',
              name: 'addFromGallery',
              builder: (context, state) => const GalleryScanScreen(),
            ),
            GoRoute(
              path: 'manual',
              name: 'addManual',
              builder: (context, state) => const CouponFormScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: 'help',
          name: 'help',
          builder: (context, state) => const HowToScreen(),
        ),
        GoRoute(
          path: 'coupon/:id',
          name: 'couponDetail',
          builder: (context, state) =>
              CouponDetailScreen(couponId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'use',
              name: 'useCoupon',
              builder: (context, state) =>
                  UseCouponScreen(couponId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'edit',
              name: 'editCoupon',
              builder: (context, state) =>
                  CouponFormScreen(couponId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'gift',
              name: 'giftCoupon',
              builder: (context, state) =>
                  GiftScreen(couponId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('찾을 수 없는 화면')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('요청한 화면을 찾을 수 없습니다.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.goNamed('vault'),
              child: const Text('보관함으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
  ),
);
