import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  bool _register = false;
  bool _loading = false;
  bool _googleLoading = false;
  bool _appleLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_register) {
        await AuthService.instance.register(
          email: _email.text,
          password: _password.text,
          firstName: _firstName.text,
          lastName: _lastName.text,
          phone: _phone.text,
        );
      } else {
        await AuthService.instance.signIn(email: _email.text, password: _password.text);
      }
    } on Exception catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      await AuthService.instance.signInWithGoogle();
    } on Exception catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _appleSignIn() async {
    setState(() => _appleLoading = true);
    try {
      await AuthService.instance.signInWithApple();
    } on Exception catch (e) {
      _showError(e);
    } finally {
      if (mounted) setState(() => _appleLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avval email kiriting')));
      return;
    }
    try {
      await AuthService.instance.resetPassword(_email.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parol tiklash havolasi emailingizga yuborildi')));
      }
    } on Exception catch (e) {
      _showError(e);
    }
  }

  void _showError(Exception e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_cleanError(e))));
  }

  @override
  Widget build(BuildContext context) {
    final canUseApple = Platform.isIOS || Platform.isMacOS;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.pageGradientOf(context)),
        child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroHeader(register: _register),
                  const SizedBox(height: 18),
                  _SocialButton(
                    title: 'Google bilan kirish',
                    subtitle: 'Telefoningizdagi Google accountlar ko‘rinadi',
                    iconText: 'G',
                    loading: _googleLoading,
                    onPressed: _googleLoading || _loading ? null : _googleSignIn,
                  ),
                  const SizedBox(height: 10),
                  _SocialButton(
                    title: 'Apple bilan kirish',
                    subtitle: canUseApple ? 'Apple ID orqali tez kirish' : 'Apple kirish iPhone/Mac’da ishlaydi',
                    icon: Icons.apple,
                    loading: _appleLoading,
                    onPressed: canUseApple && !_appleLoading && !_loading ? _appleSignIn : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('yoki email bilan', style: TextStyle(color: AppTheme.subtext(context)))),
                      const Expanded(child: Divider()),
                    ]),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(_register ? 'Yangi account' : 'Email orqali kirish', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                                _ModeChip(text: _register ? 'Register' : 'Login'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: _register
                                  ? Column(
                                      key: const ValueKey('register-fields'),
                                      children: [
                                        Row(children: [
                                          Expanded(child: TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'Ism'), validator: _required)),
                                          const SizedBox(width: 10),
                                          Expanded(child: TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Familya'), validator: _required)),
                                        ]),
                                        const SizedBox(height: 12),
                                        TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefon raqam'), validator: _required),
                                        const SizedBox(height: 12),
                                      ],
                                    )
                                  : const SizedBox.shrink(key: ValueKey('login-fields')),
                            ),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (v) => (v == null || !v.contains('@')) ? 'To‘g‘ri email kiriting' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Parol',
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6) ? 'Kamida 6 ta belgi' : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(onPressed: _resetPassword, child: const Text('Parol esdan chiqdimi?')),
                            ),
                            const SizedBox(height: 4),
                            FilledButton.icon(
                              onPressed: _loading ? null : _submit,
                              icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(_register ? Icons.person_add_alt_1 : Icons.login),
                              label: Text(_register ? 'Account yaratish' : 'Kirish'),
                              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: _loading ? null : () => setState(() => _register = !_register),
                              child: Text(_register ? 'Accountim bor, kiraman' : 'Email orqali yangi account ochish'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Majburiy maydon' : null;

  String _cleanError(Exception e) {
    return e
        .toString()
        .replaceAll(RegExp(r'\[firebase_auth/[^\]]+\]'), '')
        .replaceAll('Exception:', '')
        .trim();
  }
}

class _HeroHeader extends StatelessWidget {
  final bool register;
  const _HeroHeader({required this.register});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.18), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 14),
          const Text('To‘y Manager', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            register ? 'Account yarating yoki Google/Apple bilan bir bosishda kiring.' : 'Jadval, arxiv, chat va profil — hammasi bitta joyda.',
            style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? iconText;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.title,
    required this.subtitle,
    this.iconText,
    this.icon,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.line(context)),
            boxShadow: AppTheme.isDark(context) ? null : AppTheme.smallShadow,
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(color: AppTheme.alt(context), borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : icon != null
                          ? Icon(icon, size: 28, color: AppTheme.text(context))
                          : Text(iconText ?? '', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppTheme.subtext(context), fontSize: 12)),
              ])),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.subtext(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String text;
  const _ModeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.1), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}
