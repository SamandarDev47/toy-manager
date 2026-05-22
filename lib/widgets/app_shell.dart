import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final Future<void> Function()? onRefresh;

  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 110),
    this.scrollable = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final content = scrollable
        ? ListView(padding: padding, children: [child])
        : Padding(padding: padding, child: child);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: onRefresh == null ? content : RefreshIndicator(onRefresh: onRefresh!, child: content),
      ),
    );
  }
}

class HeroPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const HeroPanel({super.key, required this.icon, required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.35, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke),
        boxShadow: AppTheme.smallShadow,
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, color: AppTheme.primary, size: 36),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
        ],
      ),
    );
  }
}
