import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AppUser?> getCurrentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _usersRef.child(user.uid).get();
    if (!snap.exists || snap.value is! Map) {
      await _upsertProfileFromFirebaseUser(user, provider: _providerOf(user));
      final created = await _usersRef.child(user.uid).get();
      if (!created.exists || created.value is! Map) return null;
      return AppUser.fromMap(Map<dynamic, dynamic>.from(created.value as Map), user.uid);
    }
    return AppUser.fromMap(Map<dynamic, dynamic>.from(snap.value as Map), user.uid);
  }

  Stream<AppUser?> profileStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _usersRef.child(user.uid).onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return null;
      return AppUser.fromMap(Map<dynamic, dynamic>.from(value), user.uid);
    });
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password.trim());
    await _upsertProfileFromFirebaseUser(credential.user, provider: 'password');
    return credential;
  }

  Future<UserCredential> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    await cred.user?.updateDisplayName('$firstName $lastName'.trim());
    await updateProfile(firstName: firstName, lastName: lastName, phone: phone, provider: 'password');
    return cred;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(scopes: const ['email', 'profile']).signIn();
    if (googleUser == null) throw Exception('Google orqali kirish bekor qilindi');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _upsertProfileFromFirebaseUser(userCredential.user, provider: 'google');
    return userCredential;
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    final firstName = appleCredential.givenName?.trim() ?? '';
    final lastName = appleCredential.familyName?.trim() ?? '';
    if ((firstName + lastName).trim().isNotEmpty) {
      await userCredential.user?.updateDisplayName('$firstName $lastName'.trim());
    }
    await _upsertProfileFromFirebaseUser(
      userCredential.user,
      provider: 'apple',
      fallbackFirstName: firstName,
      fallbackLastName: lastName,
    );
    return userCredential;
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    String? provider,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Foydalanuvchi topilmadi');
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await getCurrentProfile();
    final data = AppUser(
      uid: user.uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      email: user.email ?? existing?.email ?? '',
      role: existing?.role ?? 'user',
      provider: provider ?? existing?.provider ?? _providerOf(user),
      photoUrl: user.photoURL ?? existing?.photoUrl,
      createdAt: existing?.createdAt == 0 || existing?.createdAt == null ? now : existing!.createdAt,
      updatedAt: now,
    );
    await _usersRef.child(user.uid).update(data.toMap());
    await user.updateDisplayName(data.fullName);
  }

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> _upsertProfileFromFirebaseUser(
    User? user, {
    required String provider,
    String fallbackFirstName = '',
    String fallbackLastName = '',
  }) async {
    if (user == null) return;
    final ref = _usersRef.child(user.uid);
    final snap = await ref.get();
    final now = DateTime.now().millisecondsSinceEpoch;
    final existingMap = snap.value is Map ? Map<dynamic, dynamic>.from(snap.value as Map) : <dynamic, dynamic>{};
    final existing = existingMap.isEmpty ? null : AppUser.fromMap(existingMap, user.uid);

    final names = _splitDisplayName(user.displayName);
    final firstName = (existing?.firstName.isNotEmpty == true)
        ? existing!.firstName
        : (names.$1.isNotEmpty ? names.$1 : fallbackFirstName);
    final lastName = (existing?.lastName.isNotEmpty == true)
        ? existing!.lastName
        : (names.$2.isNotEmpty ? names.$2 : fallbackLastName);

    final profile = AppUser(
      uid: user.uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: existing?.phone ?? user.phoneNumber ?? '',
      email: user.email ?? existing?.email ?? '',
      role: existing?.role ?? 'user',
      provider: provider,
      photoUrl: user.photoURL ?? existing?.photoUrl,
      createdAt: existing?.createdAt == 0 || existing?.createdAt == null ? now : existing!.createdAt,
      updatedAt: now,
    );
    await ref.update(profile.toMap());
  }

  (String, String) _splitDisplayName(String? displayName) {
    final clean = (displayName ?? '').trim();
    if (clean.isEmpty) return ('', '');
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, '');
    return (parts.first, parts.skip(1).join(' '));
  }

  String _providerOf(User user) {
    if (user.providerData.any((p) => p.providerId == 'google.com')) return 'google';
    if (user.providerData.any((p) => p.providerId == 'apple.com')) return 'apple';
    return 'password';
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
