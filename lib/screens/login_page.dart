import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_page.dart';

// Ganti 'MainScaffold' dengan nama class halaman beranda kamu jika berbeda
// Contoh: import '../main.dart'; atau import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _prosesLogin() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    // Panggil API Login
    bool sukses = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    
    setState(() => _isLoading = false);

    if (sukses) {
      if (mounted) {
        // 🌟 PASTIKAN 'MainScaffold' adalah nama widget utama di aplikasi kamu.
        // Jika namanya berbeda (misal HomePage), ubah di bawah ini.
        Navigator.pushReplacementNamed(context, '/home'); 
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login Gagal! Cek email & password.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🍳', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 16),
                const Text(
                  'Masuk ke DapurKita', 
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 32),
                
                // Form Email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Form Password
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.orange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _prosesLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text(
                            'Login', 
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const RegisterPage())
                    );
                  },
                  child: const Text('Belum punya akun? Daftar di sini', style: TextStyle(color: Colors.orange)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
