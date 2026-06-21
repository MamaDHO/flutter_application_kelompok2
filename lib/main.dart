import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/main_scaffold.dart';

void main() {
  runApp(const DapurKitaApp());
}

// ─── LANGUAGE PROVIDER ───────────────────────────────────────────────────────
class AppLanguage extends ChangeNotifier {
  String _locale = 'id';
  String get locale => _locale;

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }

  String t(String key) => _translations[_locale]?[key] ?? key;

  static const Map<String, Map<String, String>> _translations = {
    'id': {
      'app_title': '🍳 DapurKita',
      'hello_chef': 'Halo, Chef!',
      'what_to_cook': 'Masak apa hari ini chef?',
      'search_hint': 'Cari resep favoritmu...',
      'category': 'Kategori',
      'popular_recipes': 'Resep Populer',
      'recipe_not_found': 'Resep tidak ditemukan.',
      'home': 'Beranda',
      'profile': 'Profil',
      'add_recipe': 'Tambah Resep',
      'ingredients': 'Bahan-bahan',
      'steps': 'Langkah-langkah',
      'comments': 'Komentar',
      'by': 'Oleh',
      'save': 'Simpan',
      'recipe_name': 'Nama Resep',
      'recipe_author': 'Nama Pembuat',
      'cook_time': 'Waktu Masak',
      'difficulty': 'Tingkat Kesulitan',
      'add_ingredient': 'Tambah Bahan',
      'add_step': 'Tambah Langkah',
      'ingredient_hint': 'Contoh: 2 Butir Telur',
      'step_hint': 'Contoh: Panaskan minyak di wajan.',
      'settings': 'Pengaturan',
      'language': 'Bahasa',
      'about': 'Tentang Aplikasi',
      'version': 'Versi 1.0.0',
      'leave_comment': 'Tulis komentar...',
      'send': 'Kirim',
      'easy': 'Mudah',
      'medium': 'Menengah',
      'hard': 'Sulit',
      'breakfast': 'Sarapan',
      'lunch': 'Makan Siang',
      'dinner': 'Makan Malam',
      'snack': 'Cemilan',
      'category_label': 'Kategori',
      'form_required': 'Field ini wajib diisi',
      'recipe_added': 'Resep berhasil ditambahkan!',
      'your_rating': 'Beri Rating',
      'no_comments': 'Belum ada komentar. Jadilah yang pertama!',
      'anonymous': 'Anonim',
      'add_images': 'Tambah Foto',
      'from_gallery': 'Dari Galeri',
      'from_camera': 'Dari Kamera',
      'max_images': 'Maksimal 3 gambar',
      'video_url': 'URL Video Tutorial (YouTube)',
      'video_tutorial': 'Video Tutorial',
      'watch_tutorial': 'Tonton tutorial memasak',
      'no_video': 'Tidak ada video tutorial.',
      'open_video': 'Buka di YouTube',
      'all': 'Semua',
      'photo_recipe': 'Foto Resep',
      'no_rating': 'Belum ada rating',
      'retry': 'Coba Lagi',
      'failed_load': 'Gagal memuat data.',
      'rating_sent': 'Rating berhasil dikirim!',
      'comment_sent': 'Komentar berhasil dikirim!',
      'failed_save': 'Gagal menyimpan resep.',
      'saving': 'Menyimpan...',
    },
    'en': {
      'app_title': '🍳 DapurKita',
      'hello_chef': 'Hello, Chef!',
      'what_to_cook': 'What are we cooking today?',
      'search_hint': 'Search your favorite recipe...',
      'category': 'Category',
      'popular_recipes': 'Popular Recipes',
      'recipe_not_found': 'No recipes found.',
      'home': 'Home',
      'profile': 'Profile',
      'add_recipe': 'Add Recipe',
      'ingredients': 'Ingredients',
      'steps': 'Steps',
      'comments': 'Comments',
      'by': 'By',
      'save': 'Save',
      'recipe_name': 'Recipe Name',
      'recipe_author': 'Author Name',
      'cook_time': 'Cook Time',
      'difficulty': 'Difficulty',
      'add_ingredient': 'Add Ingredient',
      'add_step': 'Add Step',
      'ingredient_hint': 'e.g. 2 Eggs',
      'step_hint': 'e.g. Heat oil in a pan.',
      'settings': 'Settings',
      'language': 'Language',
      'about': 'About App',
      'version': 'Version 1.0.0',
      'leave_comment': 'Write a comment...',
      'send': 'Send',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'breakfast': 'Breakfast',
      'lunch': 'Lunch',
      'dinner': 'Dinner',
      'snack': 'Snack',
      'category_label': 'Category',
      'form_required': 'This field is required',
      'recipe_added': 'Recipe successfully added!',
      'your_rating': 'Rate This',
      'no_comments': 'No comments yet. Be the first!',
      'anonymous': 'Anonymous',
      'add_images': 'Add Photos',
      'from_gallery': 'From Gallery',
      'from_camera': 'From Camera',
      'max_images': 'Maximum 3 images',
      'video_url': 'Video Tutorial URL (YouTube)',
      'video_tutorial': 'Video Tutorial',
      'watch_tutorial': 'Watch cooking tutorial',
      'no_video': 'No video tutorial available.',
      'open_video': 'Open in YouTube',
      'all': 'All',
      'photo_recipe': 'Recipe Photos',
      'no_rating': 'No ratings yet',
      'retry': 'Try Again',
      'failed_load': 'Failed to load data.',
      'rating_sent': 'Rating submitted!',
      'comment_sent': 'Comment submitted!',
      'failed_save': 'Failed to save recipe.',
      'saving': 'Saving...',
    },
  };
}

final AppLanguage appLanguage = AppLanguage();

class DapurKitaApp extends StatefulWidget {
  const DapurKitaApp({Key? key}) : super(key: key);

  @override
  State<DapurKitaApp> createState() => _DapurKitaAppState();
}

class _DapurKitaAppState extends State<DapurKitaApp> {
  @override
  void initState() {
    super.initState();
    appLanguage.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DapurKita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => const MainScaffold(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/logout': (context) => const AuthGate(),
      },
    );
  }
}

// ─── Pintu Gerbang (AuthGate) ────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: ApiService.getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScaffold();
        }
        return const LoginPage();
      },
    );
  }
}