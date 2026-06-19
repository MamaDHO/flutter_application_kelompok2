import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _prosesRegister() async {
    // 1. Validasi sederhana
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      _showError('Semua field wajib diisi!');
      return;
    }

    if (_passCtrl.text != _confCtrl.text) {
      _showError('Password tidak cocok!');
      return;
    }

    // 2. Proses Pendaftaran
    setState(() => _isLoading = true);
    
    bool sukses = await ApiService.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _confCtrl.text.trim(),
    );
    
    setState(() => _isLoading = false);

    // 3. Arahkan ke Dashboard/MainScaffold jika sukses
    if (sukses) {
      if (mounted) {
        // Hapus semua riwayat halaman sebelumnya agar user tidak bisa balik ke register saat sudah login
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } else {
      _showError('Registrasi gagal. Coba gunakan email lain.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Daftar Akun', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                _field(_nameCtrl, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 16),
                _field(_emailCtrl, 'Email', Icons.email_outlined),
                const SizedBox(height: 16),
                _field(_passCtrl, 'Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 16),
                _field(_confCtrl, 'Konfirmasi Password', Icons.lock_outline, obscure: true),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _prosesRegister,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Daftar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool obscure = false}) => TextField(
    controller: ctrl,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}