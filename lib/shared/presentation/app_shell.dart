import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rikit/app/router/app_routes.dart';
import 'package:rikit/shared/notifications/notification_controller.dart';
import 'package:rikit/shared/notifications/notification_overlay.dart';
import 'package:rikit/shared/presentation/rikit_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.currentLocation,
    required this.notifications,
    required this.child,
    super.key,
  });

  final String currentLocation;
  final NotificationController notifications;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: -180,
            left: 80,
            child: _AmbientGlow(size: 460, opacity: 0.12),
          ),
          Row(
            children: [
              _Sidebar(
                currentLocation: currentLocation,
                compact: MediaQuery.sizeOf(context).width < 980,
              ),
              Expanded(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 22,
            right: 22,
            child: NotificationOverlay(controller: notifications),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.currentLocation, required this.compact});

  final String currentLocation;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 76.0 : 236.0;
    return AnimatedContainer(
      key: const ValueKey('app-sidebar'),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xE60D0F12),
        border: Border(right: BorderSide(color: RikitColors.borderSubtle)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: 16,
          ),
          child: Column(
            children: [
              _Brand(compact: compact),
              const SizedBox(height: 30),
              _SidebarItem(
                label: 'Home',
                icon: Icons.grid_view_rounded,
                route: AppRoutes.home,
                selected: currentLocation == AppRoutes.home,
                compact: compact,
              ),
              const SizedBox(height: 22),
              if (!compact)
                const _SectionLabel(label: 'TOOLS')
              else
                const Divider(height: 1),
              const SizedBox(height: 10),
              _SidebarItem(
                label: 'JSON Formatter',
                icon: Icons.data_object_rounded,
                route: AppRoutes.jsonFormatter,
                selected: currentLocation == AppRoutes.jsonFormatter,
                compact: compact,
              ),
              const SizedBox(height: 12),
              _SidebarItem(
                label: 'Design System',
                icon: Icons.palette_rounded,
                route: AppRoutes.designSystem,
                selected: currentLocation == AppRoutes.designSystem,
                compact: compact,
              ),
              const Spacer(),
              if (!compact) const _SectionLabel(label: 'SYSTEM'),
              const SizedBox(height: 8),
              _SidebarItem(
                label: 'Logs',
                icon: Icons.receipt_long_rounded,
                route: AppRoutes.logs,
                selected: currentLocation == AppRoutes.logs,
                compact: compact,
              ),
              const SizedBox(height: 6),
              _SidebarItem(
                label: 'Settings',
                icon: Icons.tune_rounded,
                route: AppRoutes.settings,
                selected: currentLocation == AppRoutes.settings,
                compact: compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: compact
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: RikitColors.primary,
            borderRadius: BorderRadius.circular(11),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55FF4D5E),
                blurRadius: 22,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'R',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: 11),
          const Text(
            'rikit',
            style: TextStyle(
              color: RikitColors.text,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: Theme.of(context).textTheme.labelMedium),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.route,
    required this.selected,
    required this.compact,
  });

  final String label;
  final IconData icon;
  final String route;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final item = Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? const Color(0x18FF4D5E) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: ValueKey('nav-$label'),
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(10),
          hoverColor: RikitColors.surfaceHover,
          focusColor: RikitColors.surfaceHover,
          child: Container(
            height: 42,
            padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: const Color(0x35FF4D5E))
                  : null,
            ),
            child: Row(
              mainAxisAlignment: compact
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? RikitColors.primary : RikitColors.textMuted,
                ),
                if (!compact) ...[
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? RikitColors.text
                            : RikitColors.textMuted,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return compact ? Tooltip(message: label, child: item) : item;
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              RikitColors.primary.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
