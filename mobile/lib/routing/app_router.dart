import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../modules/attendance/views/attendance_screen.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/register_screen.dart';
import '../modules/certificates/views/certificate_list_screen.dart';
import '../modules/certificates/views/certificate_verify_screen.dart';
import '../modules/health/views/health_screen.dart';
import '../modules/profile/views/profile_screen.dart';
import '../modules/registrations/views/my_registrations_screen.dart';
import '../modules/workshops/views/workshop_detail_screen.dart';
import '../modules/workshops/views/workshop_list_screen.dart';
import 'scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Konfigurasi GoRouter dengan StatefulShellRoute untuk navigasi bawah (bottom navigation)
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    // Rute Layar Penuh di Luar Bottom Nav
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/health',
      builder: (context, state) => const HealthScreen(),
    ),

    // StatefulShellRoute untuk 5 Tab Navigasi Aktor PESERTA
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Katalog Workshop
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/workshops',
              builder: (context, state) => const WorkshopListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return WorkshopDetailScreen(workshopId: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 2: Kegiatan Saya
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/registrations',
              builder: (context, state) => const MyRegistrationsScreen(),
            ),
          ],
        ),

        // Tab 3: Presensi
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/attendance',
              builder: (context, state) => const AttendanceScreen(),
            ),
          ],
        ),

        // Tab 4: Sertifikat
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/certificates',
              builder: (context, state) => const CertificateListScreen(),
              routes: [
                GoRoute(
                  path: 'verify',
                  builder: (context, state) => const CertificateVerifyScreen(),
                ),
              ],
            ),
          ],
        ),

        // Tab 5: Profil Peserta
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

