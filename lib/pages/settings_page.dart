import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDark = false;
  bool _isLoading = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDark = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rejim o‘zgartirildi: ${value ? "Tungi" : "Kunduzgi"}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _clearAllData() async {
    setState(() => _isLoading = true);

    final ref = FirebaseDatabase.instance.ref('weddings');
    await ref.remove(); // Realtime Database'dagi barcha 'weddings' yozuvlarini o‘chiradi

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcha maʼlumotlar muvaffaqiyatli o‘chirildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Tungi rejim'),
              value: _isDark,
              onChanged: _toggleTheme,
              secondary: const Icon(Icons.brightness_6),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Barcha maʼlumotlarni o‘chirish'),
              onTap: _isLoading ? null : _clearAllData,
              trailing: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : null,
            ),

            const Divider(),
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Ilova haqida'),
              subtitle: Text(
                'To‘y Manager 1.0\nFlutter + Firebase Realtime Database asosida yaratilgan.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
