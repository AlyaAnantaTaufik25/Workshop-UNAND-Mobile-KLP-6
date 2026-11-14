import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/attendance/views/attendance_screen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/certificates/views/certificate_list_screen.dart';
import '../modules/certificates/views/certificate_verify_screen.dart';
import '../modules/health/views/health_screen.dart';
import '../modules/notifications/views/notifications_screen.dart';
import '../modules/profile/views/profile_screen.dart';
import '../modules/registrations/views/my_registrations_screen.dart';
import '../modules/workshops/views/workshop_detail_screen.dart';
import '../modules/workshops/views/workshop_list_screen.dart';
import '../core/widgets/workshop_widgets.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
      body: AppEmptyState(
          icon: Icons.explore_off_outlined,
          title: 'Halaman tidak ditemukan',
          message: 'Silakan kembali untuk menjelajahi kegiatan UNAND.',
          action: AppButton('Kembali ke Beranda',
              onPressed: () => context.go('/workshops')))),
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/health', builder: (_, __) => const HealthScreen()),
    GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen()),
    GoRoute(
        path: '/attendance',
        builder: (_, state) => AttendanceScreen(
            workshopId: state.uri.queryParameters['workshop'] ?? 'kuliah-ai',
            dayId: state.uri.queryParameters['day'])),
    GoRoute(
        path: '/attendance/status/:id',
        builder: (_, state) =>
            AttendanceStatusScreen(workshopId: state.pathParameters['id']!)),
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/workshops',
              builder: (_, __) => const WorkshopListScreen(),
              routes: [
                GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => WorkshopDetailScreen(
                        workshopId: state.pathParameters['id']!)),
              ])
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/registrations',
              builder: (_, __) => const MyRegistrationsScreen())
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/certificates',
              builder: (_, __) => const CertificateListScreen(),
              routes: [
                GoRoute(
                    path: 'verify',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const CertificateVerifyScreen()),
                GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => CertificateDetailScreen(
                        workshopId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                          path: 'correction',
                          parentNavigatorKey: _rootNavigatorKey,
                          builder: (_, state) => CertificateCorrectionScreen(
                              workshopId: state.pathParameters['id']!)),
                    ]),
              ])
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const EditProfileScreen()),
              ])
        ]),
      ],
    ),
  ],
);
