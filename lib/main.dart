// ============================================================
//  DapurKita — main.dart  (Full Laravel API version)
//
//  pubspec.yaml dependencies:
//    image_picker: ^1.0.7
//    url_launcher: ^6.2.5
//    http: ^1.2.1
//    shared_preferences: ^2.2.3
// ============================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/api_service.dart';
import 'screens/login_page.dart';

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
      // 🌟 Menggunakan Routes untuk navigasi 🌟
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => const MainScaffold(),
        '/login': (context) => const LoginPage(),
        '/logout': (context) => const AuthGate(),
      },
    );
  }
}

// ─── Pintu Gerbang (AuthGate) ────────────────────────────────────────────────
// Ini bertugas mengecek token setiap kali aplikasi dibuka dari rute '/'
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
        
        // Jika token ada, arahkan ke /home, jika tidak ke /login
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScaffold();
        }
        return const LoginPage();
      },
    );
  }
}

// ─── MAIN SCAFFOLD ────────────────────────────────────────────────────────────
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    appLanguage.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Beranda(),
      const HalamanProfil(),
      const HalamanSettings(),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: appLanguage.t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), label: appLanguage.t('profile')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings_outlined), label: appLanguage.t('settings')),
        ],
      ),
    );
  }
}

// ─── BERANDA ─────────────────────────────────────────────────────────────────
class Beranda extends StatefulWidget {
  const Beranda({Key? key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // ── State variables ──────────────────────────────────────────────────────
  String searchQuery    = '';
  String activeCategory = 'all';
  List<Map<String, dynamic>> _resepDariApi = [];
  bool    _isLoading = true;
  String? _errorMsg;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    appLanguage.addListener(_rebuild);
    _loadResep();
  }

  @override
  void dispose() {
    appLanguage.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  // ── Fetch data from API ───────────────────────────────────────────────────
  Future<void> _loadResep() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final data = await ApiService.getResep(
        kategori: activeCategory,
        search:   searchQuery,
      );
      setState(() { _resepDariApi = data; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _errorMsg = appLanguage.t('failed_load'); });
    }
  }

  // ── Category items ────────────────────────────────────────────────────────
  List<Map<String, String>> get _kategoriItems => [
    {'value': 'all',         'label': appLanguage.t('all')},
    {'value': 'Sarapan',     'label': appLanguage.t('breakfast')},
    {'value': 'Makan Siang', 'label': appLanguage.t('lunch')},
    {'value': 'Makan Malam', 'label': appLanguage.t('dinner')},
    {'value': 'Cemilan',     'label': appLanguage.t('snack')},
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appLanguage.t('app_title')),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),        // ← override icon
        actionsIconTheme: const IconThemeData(color: Colors.white), // ← override icon di actions
        titleTextStyle: const TextStyle(                            // ← override teks judul
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TambahResepPage(onSave: _loadResep),
          ),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon:  const Icon(Icons.add),
        label: Text(appLanguage.t('add_recipe')),
      ),
      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: _loadResep,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Text(appLanguage.t('hello_chef'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(appLanguage.t('what_to_cook'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2, blurRadius: 5, offset: const Offset(0, 3),
                    )],
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() => searchQuery = v);
                      _loadResep();
                    },
                    decoration: InputDecoration(
                      hintText:   appLanguage.t('search_hint'),
                      prefixIcon: const Icon(Icons.search, color: Colors.orange),
                      border:     InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category chips
                Text(appLanguage.t('category'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _kategoriItems.map((item) {
                      final sel = activeCategory == item['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => activeCategory = item['value']!);
                          _loadResep();
                        },
                        child: Container(
                          margin:  const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:        sel ? Colors.orange : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border:       Border.all(
                              color: sel ? Colors.orange : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(item['label']!,
                              style: TextStyle(
                                color:      sel ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Recipe list header with count badge
                Row(children: [
                  Text(appLanguage.t('popular_recipes'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  if (!_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${_resepDariApi.length}',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                ]),
                const SizedBox(height: 12),

                // ── Main content: loading / error / empty / list ──
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  )
                else if (_errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(children: [
                        const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(_errorMsg!,
                            style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadResep,
                          icon:  const Icon(Icons.refresh),
                          label: Text(appLanguage.t('retry')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        ),
                      ]),
                    ),
                  )
                else if (_resepDariApi.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(appLanguage.t('recipe_not_found'),
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    physics:    const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:  _resepDariApi.length,
                    itemBuilder: (ctx, i) =>
                        _KartuResepApi(data: _resepDariApi[i]),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── KARTU RESEP (dari API) ───────────────────────────────────────────────────
class _KartuResepApi extends StatelessWidget {
  final Map<String, dynamic> data;
  const _KartuResepApi({required this.data});

  @override
  Widget build(BuildContext context) {
    final gambars  = (data['gambars'] as List?) ?? [];
    final thumbUrl = gambars.isNotEmpty ? (gambars[0]['url'] ?? '') : '';
    final avg      = (data['average_rating'] ?? 0).toDouble();
    final count    = data['rating_count'] ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailResepApi(data: data)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2),
          )],
        ),
        child: Row(children: [
          // Thumbnail + badges
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft:    Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Stack(children: [
              thumbUrl.isNotEmpty
                  ? Image.network(thumbUrl,
                      width: 100, height: 120, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder())
                  : _imgPlaceholder(),
              // Photo count badge
              if (gambars.length > 1)
                Positioned(
                  bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.photo_library, color: Colors.white, size: 10),
                      const SizedBox(width: 3),
                      Text('${gambars.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ]),
                  ),
                ),
              // Video badge
              if (data['video_url'] != null)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 12),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['nama'] ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${appLanguage.t('by')} ${data['pembuat'] ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 6),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color:  Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(data['kategori'] ?? '',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  // Stars
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                          i < avg.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 14)),
                    const SizedBox(width: 4),
                    Text(count == 0 ? '-' : avg.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(data['waktu'] ?? '', style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.restaurant_menu, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(data['kesulitan'] ?? '', style: const TextStyle(fontSize: 12)),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
      width: 100, height: 120,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported));
}

// ─── IMAGE CAROUSEL (network URLs) ───────────────────────────────────────────
class _NetworkCarousel extends StatefulWidget {
  final List<String> urls;
  final double height;
  const _NetworkCarousel({required this.urls, this.height = 280});

  @override
  State<_NetworkCarousel> createState() => _NetworkCarouselState();
}

class _NetworkCarouselState extends State<_NetworkCarousel> {
  final _ctrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.urls.isEmpty) {
      return Container(
        height: widget.height, color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 60));
    }

    return Stack(children: [
      SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _ctrl,
          itemCount:  widget.urls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => Image.network(
            widget.urls[i],
            width: double.infinity, height: widget.height, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: widget.height, color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 60)),
          ),
        ),
      ),
      // Counter top-right
      if (widget.urls.length > 1)
        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${_current + 1} / ${widget.urls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      // Dot indicators
      if (widget.urls.length > 1)
        Positioned(
          bottom: 14, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.urls.length, (i) {
              final active = _current == i;
              return GestureDetector(
                onTap: () => _ctrl.animateToPage(
                  i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.orange : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 4)],
                  ),
                ),
              );
            }),
          ),
        ),
      // Arrow left
      if (widget.urls.length > 1)
        Positioned(
          left: 8, top: 0, bottom: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _current > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => _ctrl.previousPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ),
      // Arrow right
      if (widget.urls.length > 1)
        Positioned(
          right: 8, top: 0, bottom: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _current < widget.urls.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => _ctrl.nextPage(
                  duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}

// ─── DETAIL RESEP (dari API) ──────────────────────────────────────────────────
class DetailResepApi extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailResepApi({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailResepApi> createState() => _DetailResepApiState();
}

class _DetailResepApiState extends State<DetailResepApi> {
  double  _userRating = 0;
  bool    _ratingSubmitting = false;
  bool    _commentSubmitting = false;
  final   _commentCtrl = TextEditingController();
  final   _nameCtrl    = TextEditingController();

  // Local copy of comments so UI updates instantly
  late List<Map<String, dynamic>> _localComments;
  late double _localAvg;
  late int    _localCount;

  @override
  void initState() {
    super.initState();
    final raw = (widget.data['komentars'] as List?) ?? [];
    _localComments = raw.map((e) => Map<String, dynamic>.from(e)).toList();
    _localAvg      = (widget.data['average_rating'] ?? 0).toDouble();
    _localCount    = widget.data['rating_count'] ?? 0;
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRating(double nilai) async {
    if (_ratingSubmitting) return;
    setState(() { _ratingSubmitting = true; _userRating = nilai; });
    try {
      await ApiService.addRating(widget.data['id'], nilai.toInt());
      // Update local average optimistically
      final newCount = _localCount + 1;
      final newAvg   = ((_localAvg * _localCount) + nilai) / newCount;
      setState(() { _localAvg = newAvg; _localCount = newCount; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appLanguage.t('rating_sent')),
          backgroundColor: Colors.green,
        ));
      }
    } catch (_) {
      setState(() => _userRating = 0);
    } finally {
      setState(() => _ratingSubmitting = false);
    }
  }

  Future<void> _submitComment() async {
    final isi  = _commentCtrl.text.trim();
    final nama = _nameCtrl.text.trim();
    if (isi.isEmpty || _commentSubmitting) return;
    setState(() => _commentSubmitting = true);
    try {
      final newComment = await ApiService.addKomentar(
        widget.data['id'],
        nama.isEmpty ? appLanguage.t('anonymous') : nama,
        isi,
      );
      setState(() {
        _localComments.insert(0, newComment);
        _commentCtrl.clear();
        _nameCtrl.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appLanguage.t('comment_sent')),
          backgroundColor: Colors.green,
        ));
      }
    } catch (_) {}
    finally { setState(() => _commentSubmitting = false); }
  }

  Future<void> _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka video.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d        = widget.data;
    final gambars  = (d['gambars'] as List?) ?? [];
    final imageUrls = gambars.map((g) => g['url'].toString()).toList();
    final bahan    = (d['bahan']   as List?) ?? [];
    final langkah  = (d['langkah'] as List?) ?? [];
    final videoUrl = d['video_url'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(d['nama'] ?? '')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Carousel ──
            _NetworkCarousel(urls: imageUrls),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['nama'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Meta chips
                  Wrap(spacing: 16, runSpacing: 4, children: [
                    _meta(Icons.person,           d['pembuat']  ?? '', Colors.grey),
                    _meta(Icons.timer,            d['waktu']    ?? '', Colors.orange),
                    _meta(Icons.restaurant_menu,  d['kesulitan']?? '', Colors.orange),
                    _meta(Icons.label_outline,    d['kategori'] ?? '', Colors.teal),
                  ]),
                  const SizedBox(height: 10),

                  // Rating display
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                          i < _localAvg.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _localCount == 0
                          ? appLanguage.t('no_rating')
                          : '${_localAvg.toStringAsFixed(1)} ($_localCount)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // ── Video Tutorial ──
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLanguage.t('video_tutorial'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(appLanguage.t('watch_tutorial'),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 12),
                  videoUrl != null
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _openVideo(videoUrl),
                            borderRadius: BorderRadius.circular(14),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red.shade700, Colors.red.shade400]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.smart_display, color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Text(appLanguage.t('open_video'),
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.open_in_new, color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off, color: Colors.grey[400], size: 20),
                              const SizedBox(width: 8),
                              Text(appLanguage.t('no_video'),
                                  style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                  const SizedBox(height: 24),

                  // ── Bahan ──
                  const Divider(),
                  Text(appLanguage.t('ingredients'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...bahan.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 16)),
                        Expanded(child: Text(b.toString(), style: const TextStyle(fontSize: 14))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // ── Langkah ──
                  Text(appLanguage.t('steps'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...langkah.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24, height: 24,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100, shape: BoxShape.circle),
                          child: Center(child: Text('${e.key + 1}',
                              style: const TextStyle(
                                  color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))),
                        ),
                        Expanded(child: Text(e.value.toString(),
                            style: const TextStyle(height: 1.4))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),

                  // ── Rating input ──
                  const Divider(),
                  Text(appLanguage.t('your_rating'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    ...List.generate(5, (i) => GestureDetector(
                      onTap: _ratingSubmitting ? null : () => _submitRating((i + 1).toDouble()),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          i < _userRating ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 36),
                      ),
                    )),
                    if (_ratingSubmitting)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.orange)),
                      ),
                  ]),
                  const SizedBox(height: 24),

                  // ── Komentar ──
                  const Divider(),
                  Text(appLanguage.t('comments'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Name field
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(
                      hintText:  appLanguage.t('anonymous'),
                      labelText: 'Nama',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Comment + send
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: appLanguage.t('leave_comment'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _commentSubmitting ? null : _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _commentSubmitting
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(appLanguage.t('send'),
                              style: const TextStyle(color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Comment list
                  _localComments.isEmpty
                      ? Text(appLanguage.t('no_comments'),
                          style: const TextStyle(color: Colors.grey))
                      : Column(
                          children: _localComments.map((k) => _KomentarItem(k)).toList()),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(
          fontSize: 13, color: color == Colors.grey ? Colors.grey : Colors.black87)),
    ],
  );
}

// ─── KOMENTAR ITEM ────────────────────────────────────────────────────────────
class _KomentarItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _KomentarItem(this.data);

  @override
  Widget build(BuildContext context) {
    final nama = data['nama'] ?? '';
    final isi  = data['isi']  ?? '';
    final time = data['created_at'] != null
        ? _fmt(DateTime.tryParse(data['created_at']) ?? DateTime.now())
        : 'Baru saja';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18, backgroundColor: Colors.orange.shade200,
            child: Text(
              nama.isNotEmpty ? nama[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              Text(isi),
            ],
          )),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1)  return 'Baru saja';
    if (d.inHours   < 1)  return '${d.inMinutes}m lalu';
    if (d.inDays    < 1)  return '${d.inHours}j lalu';
    return '${d.inDays}h lalu';
  }
}

// ─── THUMBNAIL GAMBAR LOKAL (web-safe) ────────────────────────────────────────
// Image.file() TIDAK didukung di Flutter Web karena dart:io tidak punya akses
// filesystem di browser. Widget ini membaca XFile sebagai bytes lalu
// menampilkannya dengan Image.memory(), yang berjalan di semua platform
// (Web, Android, iOS, Desktop) tanpa error.
class XFileThumbnail extends StatelessWidget {
  final XFile file;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const XFileThumbnail({
    Key? key,
    required this.file,
    this.width = 100,
    this.height = 100,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.connectionState != ConnectionState.done) {
          child = Container(
            width: width, height: height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
              ),
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          child = Container(
            width: width, height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        } else {
          child = Image.memory(
            snapshot.data!,
            width: width, height: height, fit: BoxFit.cover,
          );
        }
        return borderRadius != null
            ? ClipRRect(borderRadius: borderRadius!, child: child)
            : child;
      },
    );
  }
}

// ─── THUMBNAIL BUNDAR UNTUK AVATAR (web-safe) ────────────────────────────────
class XFileCircleAvatar extends StatelessWidget {
  final XFile file;
  final double radius;
  const XFileCircleAvatar({Key? key, required this.file, this.radius = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.orange.shade100,
            child: const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: radius, color: Colors.white),
          );
        }
        return CircleAvatar(radius: radius, backgroundImage: MemoryImage(snapshot.data!));
      },
    );
  }
}

// ─── TAMBAH / EDIT RESEP (kirim ke API) ───────────────────────────────────────
class TambahResepPage extends StatefulWidget {
  final VoidCallback onSave;
  // Jika null → mode TAMBAH. Jika diisi data resep → mode EDIT.
  final Map<String, dynamic>? existingData;
  const TambahResepPage({Key? key, required this.onSave, this.existingData}) : super(key: key);

  @override
  State<TambahResepPage> createState() => _TambahResepPageState();
}

class _TambahResepPageState extends State<TambahResepPage> {
  final _formKey     = GlobalKey<FormState>();
  final _namaCtrl    = TextEditingController();
  final _pembuatCtrl = TextEditingController();
  final _waktuCtrl   = TextEditingController();
  final _videoCtrl   = TextEditingController();
  String _kesulitan  = 'Mudah';
  String _kategori   = 'Sarapan';
  final List<TextEditingController> _bahanCtrls   = [TextEditingController()];
  final List<TextEditingController> _langkahCtrls = [TextEditingController()];

  final List<XFile> _selectedImages = [];
  final _picker = ImagePicker();
  bool _isSaving = false;

  bool get _isEditMode => widget.existingData != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final d = widget.existingData!;
      _namaCtrl.text    = (d['nama'] ?? '').toString();
      _pembuatCtrl.text = (d['pembuat'] ?? '').toString();
      _waktuCtrl.text   = (d['waktu'] ?? '').toString();
      _videoCtrl.text   = (d['video_url'] ?? '').toString();
      _kesulitan = (d['kesulitan'] ?? 'Mudah').toString();
      _kategori  = (d['kategori'] ?? 'Sarapan').toString();

      final bahan = (d['bahan'] as List?) ?? [];
      if (bahan.isNotEmpty) {
        _bahanCtrls.clear();
        _bahanCtrls.addAll(bahan.map((b) => TextEditingController(text: b.toString())));
      }

      final langkah = (d['langkah'] as List?) ?? [];
      if (langkah.isNotEmpty) {
        _langkahCtrls.clear();
        _langkahCtrls.addAll(langkah.map((l) => TextEditingController(text: l.toString())));
      }
    }
  }

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final picked = await _picker.pickMultiImage(imageQuality: 80);
        setState(() {
          for (final img in picked) {
            if (_selectedImages.length < 3) _selectedImages.add(img);
          }
        });
      } else {
        final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
        if (picked != null && _selectedImages.length < 3) {
          setState(() => _selectedImages.add(picked));
        }
      }
    } catch (_) {}
  }

  void _removeImage(int idx) => setState(() => _selectedImages.removeAt(idx));

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(appLanguage.t('add_images'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(appLanguage.t('max_images'),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.photo_library, color: Colors.orange),
            ),
            title: Text(appLanguage.t('from_gallery')),
            onTap: () { Navigator.pop(context); _pickImages(ImageSource.gallery); },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt, color: Colors.blue),
            ),
            title: Text(appLanguage.t('from_camera')),
            onTap: () { Navigator.pop(context); _pickImages(ImageSource.camera); },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    try {
      if (_isEditMode) {
        // ── MODE EDIT: kirim PUT, tanpa ubah foto (foto dikelola terpisah) ──
        await ApiService.updateResep(
          id:        widget.existingData!['id'],
          nama:      _namaCtrl.text.trim(),
          pembuat:   _pembuatCtrl.text.trim(),
          waktu:     _waktuCtrl.text.trim(),
          kesulitan: _kesulitan,
          kategori:  _kategori,
          videoUrl:  _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
          bahan:     _bahanCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          langkah:   _langkahCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        );
      } else {
        // ── MODE TAMBAH ──
        await ApiService.createResep(
          nama:      _namaCtrl.text.trim(),
          pembuat:   _pembuatCtrl.text.trim(),
          waktu:     _waktuCtrl.text.trim(),
          kesulitan: _kesulitan,
          kategori:  _kategori,
          videoUrl:  _videoCtrl.text.trim().isEmpty ? null : _videoCtrl.text.trim(),
          bahan:     _bahanCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          langkah:   _langkahCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
          gambars:   _selectedImages,
        );
      }
      widget.onSave();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditMode ? 'Resep berhasil diperbarui!' : appLanguage.t('recipe_added')),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(appLanguage.t('failed_save')),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kesMap = {'Mudah': appLanguage.t('easy'), 'Menengah': appLanguage.t('medium'), 'Sulit': appLanguage.t('hard')};
    final katMap = {
      'Sarapan':     appLanguage.t('breakfast'),
      'Makan Siang': appLanguage.t('lunch'),
      'Makan Malam': appLanguage.t('dinner'),
      'Cemilan':     appLanguage.t('snack'),
    };

    // Pastikan _kesulitan/_kategori valid terhadap map (mencegah error dropdown saat data API tak sesuai)
    if (!kesMap.containsKey(_kesulitan)) _kesulitan = 'Mudah';
    if (!katMap.containsKey(_kategori))  _kategori  = 'Sarapan';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Resep' : appLanguage.t('add_recipe')),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange))
                : Text(appLanguage.t('save'),
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Picker (hanya muncul di mode TAMBAH) ──
              if (!_isEditMode) ...[
                _label(appLanguage.t('photo_recipe')),
                const SizedBox(height: 4),
                Text(appLanguage.t('max_images'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_selectedImages.length < 3)
                        GestureDetector(
                          onTap: _showSourceSheet,
                          child: Container(
                            width: 100, height: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.shade300, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    color: Colors.orange.shade300, size: 32),
                                const SizedBox(height: 4),
                                Text(appLanguage.t('add_images'),
                                    style: TextStyle(fontSize: 10, color: Colors.orange.shade400),
                                    textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        ),
                      ..._selectedImages.asMap().entries.map((e) => Stack(children: [
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 100, height: 100,
                          child: XFileThumbnail(
                            file: e.value,
                            width: 100, height: 100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Positioned(
                          top: 4, right: 14,
                          child: GestureDetector(
                            onTap: () => _removeImage(e.key),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 12),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6, left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${e.key + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ])),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // ── Mode edit: tampilkan foto lama (read-only) ──
                _label(appLanguage.t('photo_recipe')),
                const SizedBox(height: 8),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ...(((widget.existingData!['gambars'] as List?) ?? []).map((g) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                g['url'] ?? '',
                                width: 90, height: 90, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 90, height: 90, color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported)),
                              ),
                            ),
                          ))),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Foto belum bisa diubah lewat halaman edit ini.',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 20),
              ],

              // ── Basic fields ──
              _label(appLanguage.t('recipe_name')),
              _field(_namaCtrl, appLanguage.t('recipe_name')),
              const SizedBox(height: 14),
              _label(appLanguage.t('recipe_author')),
              _field(_pembuatCtrl, appLanguage.t('recipe_author')),
              const SizedBox(height: 14),
              _label(appLanguage.t('cook_time')),
              _field(_waktuCtrl, 'Contoh: 30 Menit'),
              const SizedBox(height: 14),

              // ── Video URL ──
              _label(appLanguage.t('video_url')),
              TextFormField(
                controller: _videoCtrl,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText:   'https://youtube.com/watch?v=...',
                  prefixIcon: const Icon(Icons.smart_display, color: Colors.red),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),

              // ── Dropdowns ──
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(appLanguage.t('difficulty')),
                    DropdownButtonFormField<String>(
                      value: _kesulitan,
                      items: kesMap.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _kesulitan = v!),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label(appLanguage.t('category_label')),
                    DropdownButtonFormField<String>(
                      value: _kategori,
                      items: katMap.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _kategori = v!),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 22),

              // ── Bahan ──
              _label(appLanguage.t('ingredients')),
              _dynamicList(_bahanCtrls, appLanguage.t('ingredient_hint'), appLanguage.t('add_ingredient')),
              const SizedBox(height: 16),

              // ── Langkah ──
              _label(appLanguage.t('steps')),
              _dynamicList(_langkahCtrls, appLanguage.t('step_hint'), appLanguage.t('add_step')),
              const SizedBox(height: 40),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_isEditMode ? 'Update Resep' : appLanguage.t('save'),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));

  Widget _field(TextEditingController ctrl, String hint, {bool req = true}) =>
      TextFormField(
        controller: ctrl,
        validator: req
            ? (v) => (v == null || v.trim().isEmpty) ? appLanguage.t('form_required') : null
            : null,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      );

  Widget _dynamicList(
      List<TextEditingController> ctrls, String hint, String addLabel) {
    return Column(children: [
      ...ctrls.asMap().entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
            child: Center(child: Text('${e.key + 1}',
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          Expanded(child: TextFormField(
            controller: e.value,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          )),
          if (ctrls.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () => setState(() => ctrls.removeAt(e.key)),
            ),
        ]),
      )),
      TextButton.icon(
        onPressed: () => setState(() => ctrls.add(TextEditingController())),
        icon:  const Icon(Icons.add, color: Colors.orange),
        label: Text(addLabel, style: const TextStyle(color: Colors.orange)),
      ),
    ]);
  }
}

// ─── HALAMAN PROFIL ────────────────────────────────────────────────────────────
class HalamanProfil extends StatefulWidget {
  const HalamanProfil({Key? key}) : super(key: key);
  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  // ── State user ──────────────────────────────────────────────────────────
  Map<String, dynamic>? _user;
  bool    _isLoadingUser = true;
  String? _userError;

  // ── State resep saya ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _myRecipes = [];
  bool    _isLoadingRecipes = true;
  String? _recipesError;

  // ── Upload avatar ──────────────────────────────────────────────────────
  final _picker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadUser(), _loadMyRecipes()]);
  }

  Future<void> _loadUser() async {
    setState(() { _isLoadingUser = true; _userError = null; });
    try {
      final data = await ApiService.getCurrentUser();
      setState(() { _user = data; _isLoadingUser = false; });
    } catch (e) {
      setState(() { _isLoadingUser = false; _userError = 'Gagal memuat profil.'; });
    }
  }

  Future<void> _loadMyRecipes() async {
    setState(() { _isLoadingRecipes = true; _recipesError = null; });
    try {
      final data = await ApiService.getMyResep();
      setState(() { _myRecipes = data; _isLoadingRecipes = false; });
    } catch (e) {
      setState(() { _isLoadingRecipes = false; _recipesError = 'Gagal memuat resep kamu.'; });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Ganti Foto Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.photo_library, color: Colors.orange),
            ),
            title: Text(appLanguage.t('from_gallery')),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.camera_alt, color: Colors.blue),
            ),
            title: Text(appLanguage.t('from_camera')),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final updatedUser = await ApiService.uploadAvatar(picked);
      setState(() => _user = updatedUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunggah foto.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _goToEdit(Map<String, dynamic> resep) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahResepPage(
          existingData: resep,
          onSave: _loadMyRecipes,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> resep) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Resep?'),
        content: Text('Resep "${resep['nama']}" akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ApiService.deleteResep(resep['id']);
      setState(() => _myRecipes.removeWhere((r) => r['id'] == resep['id']));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep berhasil dihapus.'), backgroundColor: Colors.green),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus resep.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username  = _user?['name']       ?? '...';
    final email     = _user?['email']      ?? '';
    final avatarUrl = _user?['avatar_url'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(appLanguage.t('profile'))),
      body: RefreshIndicator(
        color: Colors.orange,
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══════════ SECTION 1: PROFIL ══════════
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
                color: Colors.white,
                child: _isLoadingUser
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : _userError != null
                        ? Column(children: [
                            Icon(Icons.wifi_off, size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(_userError!, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton(onPressed: _loadUser, child: const Text('Coba Lagi')),
                          ])
                        : Column(
                            children: [
                              Stack(children: [
                                _isUploadingAvatar
                                    ? const CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.orange,
                                        child: SizedBox(
                                          width: 28, height: 28,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        ),
                                      )
                                    : (avatarUrl != null
                                        ? CircleAvatar(
                                            radius: 48,
                                            backgroundColor: Colors.orange.shade100,
                                            backgroundImage: NetworkImage(avatarUrl),
                                          )
                                        : CircleAvatar(
                                            radius: 48,
                                            backgroundColor: Colors.orange,
                                            child: Text(
                                              username.isNotEmpty ? username[0].toUpperCase() : '?',
                                              style: const TextStyle(
                                                  fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: GestureDetector(
                                    onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 16),
                              Text(username,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(email, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
              ),

              Container(height: 8, color: Colors.grey[100]),

              // ══════════ SECTION 2: RESEP SAYA ══════════
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('Resep Saya',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      if (!_isLoadingRecipes)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
                          child: Text('${_myRecipes.length}',
                              style: const TextStyle(
                                  color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.orange),
                        tooltip: appLanguage.t('add_recipe'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TambahResepPage(onSave: _loadMyRecipes),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),

                    if (_isLoadingRecipes)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                      )
                    else if (_recipesError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Column(children: [
                          Icon(Icons.wifi_off, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(_recipesError!, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          TextButton(onPressed: _loadMyRecipes, child: const Text('Coba Lagi')),
                        ])),
                      )
                    else if (_myRecipes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Column(children: [
                          Icon(Icons.menu_book_outlined, size: 56, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text('Kamu belum menambahkan resep.',
                              style: TextStyle(color: Colors.grey[500])),
                        ])),
                      )
                    else
                      ..._myRecipes.map((r) => _KartuResepSaya(
                            data: r,
                            onEdit: () => _goToEdit(r),
                            onDelete: () => _confirmDelete(r),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── KARTU RESEP SAYA (dengan tombol Edit & Hapus) ───────────────────────────
class _KartuResepSaya extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _KartuResepSaya({required this.data, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final gambars  = (data['gambars'] as List?) ?? [];
    final thumbUrl = gambars.isNotEmpty ? (gambars[0]['url'] ?? '') : '';
    final avg      = (data['average_rating'] ?? 0).toDouble();
    final count    = data['rating_count'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailResepApi(data: data))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: thumbUrl.isNotEmpty
                  ? Image.network(thumbUrl, width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder())
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['nama'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(data['kategori'] ?? '',
                        style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                          i < avg.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 13)),
                    const SizedBox(width: 4),
                    Text(count == 0 ? '-' : avg.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                ],
              ),
            ),
            Column(children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                onPressed: onEdit,
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
                tooltip: 'Hapus',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
      width: 80, height: 80, color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported, size: 24));
}

// ─── SETTINGS ─────────────────────────────────────────────────────────────────
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
          // ── Tombol Logout ──
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Keluar (Logout)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              await ApiService.hapusToken();
              if (context.mounted) {
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