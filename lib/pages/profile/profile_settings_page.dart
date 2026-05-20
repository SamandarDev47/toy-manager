import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;
  String? _loadedUid;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _fill(AppUser user) {
    if (_loadedUid == user.uid) return;
    _loadedUid = user.uid;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    _phone.text = user.phone;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(
        firstName: _firstName.text,
        lastName: _lastName.text,
        phone: _phone.text,
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Yo‘q')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ha, tozalash')),
        ],
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chiqish')),
        ],
      ),
    );
    if (ok == true) await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final email = firebaseUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Profil va sozlanmalar', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: StreamBuilder<AppUser?>(
        stream: AuthService.instance.profileStream(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null) _fill(user);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              _ProfileHeader(user: user, email: email, photoUrl: firebaseUser?.photoURL),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Shaxsiy ma’lumotlar',
                subtitle: 'Google/Apple orqali kirganda ism va email avtomatik saqlanadi. Telefonni o‘zingiz qo‘shishingiz mumkin.',
                child: Column(children: [
                  Row(children: [
                    Expanded(child: TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Ism'))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Familya'))),
                  ]),
                  const SizedBox(height: 12),
                  TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon raqam')),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
                    label: const Text('Profilni saqlash'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Ilova sozlamalari',
                child: Column(children: [
                  _SettingsTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Kirish turi',
                    subtitle: _providerTitle(user?.provider ?? 'password'),
                  ),
                  const Divider(height: 1),
                  const _SettingsTile(
                    icon: Icons.archive_outlined,
                    title: 'Avtomatik arxiv',
                    subtitle: 'To‘y kuni o‘tgach, asosiy ro‘yxatdan history bo‘limiga ko‘chadi',
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.delete_outline,
                    iconColor: Colors.red,
                    title: 'Asosiy jadvalni tozalash',
                    subtitle: 'Arxiv va chatga tegmaydi',
                    onTap: _clearWeddings,
                  ),
                  const Divider(height: 1),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Accountdan chiqish',
                    subtitle: 'Keyin yana Google, Apple yoki email orqali kirishingiz mumkin',
                    onTap: _logout,
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              const Text('Firebase branchlar: users, weddings, history, chats/main/messages, chats/main/typing, userTokens.', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
            ],
          );
        },
        ),
      ),
    );
  }

  String _providerTitle(String provider) {
    switch (provider) {
      case 'google':
        return 'Google account orqali ulangan';
      case 'apple':
        return 'Apple ID orqali ulangan';
      default:
        return 'Email va parol orqali ulangan';
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(.2),
            backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null || avatarUrl.isEmpty
                ? Text(user?.initials ?? 'U', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.fullName ?? 'Foydalanuvchi', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(email.isEmpty ? 'Email topilmadi' : email, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(999)),
                child: Text('Lavozim: ${user?.role ?? 'user'}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: AppTheme.muted, height: 1.35)),
          ],
          const SizedBox(height: 14),
          child,
        ]),
      ),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: (iconColor ?? AppTheme.primary).withOpacity(.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: iconColor ?? AppTheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
      onTap: onTap,
    );
  }
}
