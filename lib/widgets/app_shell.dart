import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget child;
  final bool scrollable;
  final Future<void> Function()? onRefresh;
  final EdgeInsetsGeometry padding;

  const AppShell({super.key, required this.title, this.subtitle, this.icon, this.actions, required this.child, this.scrollable = true, this.onRefresh, this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 96)});

  @override
  Widget build(BuildContext context) {
    final content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (subtitle != null || icon != null) ...[
        HeroPanel(icon: icon ?? Icons.apps_rounded, title: title, subtitle: subtitle ?? ''),
        const SizedBox(height: 16),
      ],
      child,
    ]);
    final body = scrollable ? ListView(physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), padding: padding, children: [content]) : Padding(padding: padding, child: content);
    return Scaffold(
      backgroundColor: AppTheme.pageBg(context),
      appBar: AppBar(title: Text(title), actions: actions),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.pageGradientOf(context)),
        child: onRefresh == null ? body : RefreshIndicator(color: AppTheme.primary, onRefresh: onRefresh!, child: body),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: AppTheme.mainGradient, borderRadius: BorderRadius.circular(28), boxShadow: AppTheme.softShadow),
      child: Row(children: [
        Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.22))), child: Icon(icon, color: Colors.white, size: 30)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.3)),
          if (subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.35, fontSize: 13.5, fontWeight: FontWeight.w600)),
          ],
        ])),
        if (trailing != null) ...[const SizedBox(width: 10), trailing!],
      ]),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: AppTheme.card(context), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppTheme.line(context)), boxShadow: AppTheme.isDark(context) ? null : AppTheme.smallShadow),
      child: DefaultTextStyle.merge(style: TextStyle(color: AppTheme.text(context)), child: child),
    );
    if (onTap == null) return card;
    return Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(24), onTap: onTap, child: card));
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.buttonText, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 74, height: 74, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(24)), child: Icon(icon, color: AppTheme.primary, size: 36)),
        const SizedBox(height: 15),
        Text(title, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.text(context), fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.subtext(context), height: 1.38, fontSize: 14, fontWeight: FontWeight.w500)),
        if (buttonText != null && onPressed != null) ...[
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: onPressed, icon: const Icon(Icons.add_rounded), label: Text(buttonText!)),
        ],
      ]),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionTitle({super.key, required this.title, this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 10),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: AppTheme.text(context), fontSize: 18, fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[const SizedBox(height: 3), Text(subtitle!, style: TextStyle(color: AppTheme.subtext(context), fontSize: 13, fontWeight: FontWeight.w500))],
        ])),
        if (trailing != null) trailing!,
      ]),
    );
  }
}

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  const AppChip({super.key, required this.label, this.icon, this.selected = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppTheme.text(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(color: selected ? AppTheme.primary : AppTheme.card(context), borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? AppTheme.primary : AppTheme.line(context))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 17, color: fg), const SizedBox(width: 6)],
            Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
