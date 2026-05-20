import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../state/app_settings.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_shell.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _role = TextEditingController();
  bool _saving = false;
  String? _loadedUid;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _role.dispose();
    super.dispose();
  }

  void _fill(AppUser user) {
    if (_loadedUid == user.uid) return;
    _loadedUid = user.uid;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _phone.text = user.phone;
    _role.text = user.role == 'user' ? '' : user.role;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        firstName: _firstName.text,
        lastName: _lastName.text,
        phone: _phone.text,
        role: _role.text.trim().isEmpty ? 'user' : _role.text.trim(),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil saqlandi')));
    } on Exception catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _clearWeddings() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('To‘ylarni o‘chirish'),
        content: const Text('Faqat asosiy jadvaldagi to‘ylar o‘chadi. Arxiv va chat saqlanadi. Davom etasizmi?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo‘q')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha, tozalash'))],
      ),
    );
    if (ok == true) {
      await FirebaseDatabase.instance.ref('weddings').remove();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Asosiy jadval tozalandi')));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accountdan chiqish'),
        content: const Text('Haqiqatan ham chiqmoqchimisiz?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chiqish'))],
      ),
    );
    if (ok == true) await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final email = firebaseUser?.email ?? '';
    return AppShell(
      title: 'Profil',
      subtitle: 'Account, sozlamalar va xavfsizlik',
      icon: Icons.person_rounded,
      child: StreamBuilder<AppUser?>(
        stream: AuthService.instance.profileStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) _fill(user);
          return Column(children: [
            _ProfileHeader(user: user, email: email, photoUrl: firebaseUser?.photoURL),
            const SizedBox(height: 14),
            AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle(title: 'Shaxsiy ma’lumotlar', subtitle: 'Google/Apple ma’lumotlari avtomatik saqlanadi, xohlasangiz tahrirlaysiz.'),
              Row(children: [
                Expanded(child: TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Ism'))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Familya'))),
              ]),
              const SizedBox(height: 12),
              TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon raqam', prefixIcon: Icon(Icons.phone_rounded))),
              const SizedBox(height: 12),
              TextField(controller: _role, decoration: const InputDecoration(labelText: 'Lavozim', hintText: 'Kiritilmasa user bo‘lib turadi', prefixIcon: Icon(Icons.badge_rounded))),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded), label: const Text('Profilni saqlash'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52))),
            ])),
            const SizedBox(height: 14),
            AppCard(child: Column(children: [
              ValueListenableBuilder<ThemeMode>(
                valueListenable: AppSettings.themeMode,
                builder: (context, mode, _) => _SettingsTile(
                  icon: mode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  title: 'Dark / Light mode',
                  subtitle: mode == ThemeMode.dark ? 'Dark mode yoqilgan' : 'Light mode yoqilgan',
                  trailing: Switch(value: mode == ThemeMode.dark, onChanged: AppSettings.setDark),
                ),
              ),
              const Divider(height: 1),
              _SettingsTile(icon: Icons.verified_user_outlined, title: 'Kirish turi', subtitle: _providerTitle(user?.provider ?? 'password')),
              const Divider(height: 1),
              const _SettingsTile(icon: Icons.archive_outlined, title: 'Avtomatik arxiv', subtitle: 'Sana o‘tgach to‘y history bo‘limiga ko‘chadi', trailing: Icon(Icons.check_circle, color: Colors.green)),
              const Divider(height: 1),
              _SettingsTile(icon: Icons.delete_outline, iconColor: AppTheme.danger, title: 'Asosiy jadvalni tozalash', subtitle: 'Arxiv va chatga tegmaydi', onTap: _clearWeddings),
              const Divider(height: 1),
              _SettingsTile(icon: Icons.logout_rounded, title: 'Accountdan chiqish', subtitle: 'Keyin yana Google, Apple yoki email orqali kirishingiz mumkin', onTap: _logout),
            ])),
            const SizedBox(height: 14),
            // Text('Firebase: users, weddings, history, chats/main/messages, chats/main/typing, userTokens.', style: TextStyle(color: AppTheme.subtext(context), fontSize: 12)),
          ]);
        },
      ),
    );
  }

  String _providerTitle(String provider) {
    switch (provider) {
      case 'google': return 'Google account orqali ulangan';
      case 'apple': return 'Apple ID orqali ulangan';
      default: return 'Email va parol orqali ulangan';
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser? user;
  final String email;
  final String? photoUrl;
  const _ProfileHeader({required this.user, required this.email, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.photoUrl ?? photoUrl;
    final role = (user?.role.trim().isEmpty ?? true) ? 'user' : user!.role;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppTheme.mainGradient, borderRadius: BorderRadius.circular(30), boxShadow: AppTheme.softShadow),
      child: Row(children: [
        CircleAvatar(radius: 36, backgroundColor: Colors.white.withOpacity(.2), backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null, child: avatarUrl == null || avatarUrl.isEmpty ? Text(user?.initials ?? 'U', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white)) : null),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user?.fullName ?? 'Foydalanuvchi', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(email.isEmpty ? 'Email topilmadi' : email, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(999)), child: Text('Lavozim: $role', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
        ])),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, this.iconColor, required this.title, required this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = iconColor ?? AppTheme.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(height: 42, width: 42, decoration: BoxDecoration(color: c.withOpacity(.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: c)),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
      onTap: onTap,
    );
  }
}
