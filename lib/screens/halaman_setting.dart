import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class HalamanSettings extends StatefulWidget {
  const HalamanSettings({Key? key}) : super(key: key);
  @override
  State<HalamanSettings> createState() => _HalamanSettingsState();
}

class _HalamanSettingsState extends State<HalamanSettings> {
  bool _notifResep = true;
  bool _notifKomen = false;

  @override
  void initState() {
    super.initState();
    appLanguage.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appLanguage.t('settings'))),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          _sec(appLanguage.t('language')),
          RadioListTile<String>(
            title: const Text('🇮🇩  Bahasa Indonesia'),
            value: 'id',
            groupValue: appLanguage.locale,
            activeColor: Colors.orange,
            onChanged: (v) => appLanguage.setLocale(v!),
          ),
          RadioListTile<String>(
            title: const Text('🇬🇧  English'),
            value: 'en',
            groupValue: appLanguage.locale,
            activeColor: Colors.orange,
            onChanged: (v) => appLanguage.setLocale(v!),
          ),
          const Divider(),
          _sec('Notifikasi'),
          SwitchListTile(
            title: const Text('Notifikasi Resep Baru'),
            subtitle: const Text('Dapatkan pemberitahuan resep terbaru'),
            value: _notifResep,
            activeColor: Colors.orange,
            onChanged: (v) => setState(() => _notifResep = v),
          ),
          SwitchListTile(
            title: const Text('Notifikasi Komentar'),
            subtitle: const Text('Pemberitahuan komentar pada resepmu'),
            value: _notifKomen,
            activeColor: Colors.orange,
            onChanged: (v) => setState(() => _notifKomen = v),
          ),
          const Divider(),
          _sec(appLanguage.t('about')),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.orange),
            title: Text(appLanguage.t('app_title')),
            subtitle: Text(appLanguage.t('version')),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.orange),
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.orange),
            title: const Text('Syarat & Ketentuan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await ApiService.hapusToken();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _sec(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(label,
            style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5)),
      );
}