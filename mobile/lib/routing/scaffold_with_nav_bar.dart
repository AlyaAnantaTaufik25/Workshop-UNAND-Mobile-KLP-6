import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x0D0F172A),
                    blurRadius: 18,
                    offset: Offset(0, -5))
              ]),
          child: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
                  child: Row(children: [
                    _destination(0, 'Beranda', Icons.home_outlined),
                    _destination(
                        1, 'Kegiatan Saya', Icons.calendar_month_outlined),
                    _destination(
                        2, 'Sertifikat', Icons.workspace_premium_outlined),
                    _destination(3, 'Profil', Icons.person_outline_rounded),
                  ]))),
        ),
      );

  Widget _destination(int index, String label, IconData icon) {
    final selected = navigationShell.currentIndex == index;
    return Expanded(
        child: Semantics(
            selected: selected,
            button: true,
            label: label,
            excludeSemantics: true,
            child: Material(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    onTap: () => navigationShell.goBranch(index,
                        initialLocation: index == navigationShell.currentIndex),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(icon,
                              size: 21,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF52605A)),
                          const SizedBox(height: 4),
                          Text(label,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF52605A))),
                        ]))))));
  }
}
