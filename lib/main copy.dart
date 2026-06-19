import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() => runApp(const DapurKitaApp());

// ─── 1. APP ROOT ─────────────────────────────────────────────────────────────
class DapurKitaApp extends StatelessWidget {
  const DapurKitaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

// ─── 2. AUTH GATE (Pintu Masuk) ─────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return (snapshot.hasData && snapshot.data != null) 
            ? const MainScaffold() 
            : const LoginPage();
      },
    );
  }
}

// ─── 3. LOGIN PAGE ───────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  
  void _login() async {
    bool sukses = await ApiService.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
    if (sukses && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'), 
              child: const Text("Belum punya akun? Daftar di sini")
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 4. REGISTER PAGE ────────────────────────────────────────────────────────
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confCtrl = TextEditingController();

  void _register() async {
    bool sukses = await ApiService.register(
      _nameCtrl.text, _emailCtrl.text, _passCtrl.text, _confCtrl.text
    );
    if (sukses && mounted) {
      Navigator.pop(context); // Kembali ke login
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil daftar!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama')),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: _confCtrl, decoration: const InputDecoration(labelText: 'Konfirmasi Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("Daftar Sekarang")),
          ],
        ),
      ),
    );
  }
}

// ─── 5. MAIN SCAFFOLD (Dashboard) ──────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Ini Dashboard/Home")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ApiService.hapusToken();
          Navigator.pushReplacementNamed(context, '/'); // Logout
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}