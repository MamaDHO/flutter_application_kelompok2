import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // ── MANAJEMEN TOKEN (Dompet KTP User) ──────────────────────────────────────
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> hapusToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ── HEADER OTOMATIS (Wajib Login) ─────────────────────────────────────────
  static Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTHENTICATION ────────────────────────────────────────────────────────
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']);
      return true;
    }
    return false;
  }

  static Future<bool> register(String name, String email, String password, String passwordConf) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name, 'email': email, 'password': password, 'password_confirmation': passwordConf,
      }),
    );
    if (response.statusCode == 201) {
      await saveToken(jsonDecode(response.body)['access_token']);
      return true;
    }
    return false;
  }

  // ── PROFIL USER ───────────────────────────────────────────────────────────
  // GET /api/user — data user yang sedang login (butuh token)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await http.get(Uri.parse('$baseUrl/user'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Gagal memuat profil (${response.statusCode})');
  }

  // POST /api/user/avatar — upload/ganti foto profil (multipart, web-safe)
  static Future<Map<String, dynamic>> uploadAvatar(XFile file) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user/avatar'));
    request.headers.addAll(await _getHeaders());

    request.files.add(http.MultipartFile.fromBytes(
      'avatar',
      await file.readAsBytes(),
      filename: file.name.isNotEmpty ? file.name : 'avatar.jpg',
    ));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] as Map<String, dynamic>;
    }
    throw Exception('Gagal upload foto profil (${response.statusCode}): ${response.body}');
  }

  // ── GET semua resep (publik, untuk Beranda) ────────────────────────────────
  static Future<List<Map<String, dynamic>>> getResep({String? kategori, String? search}) async {
    final params = <String, String>{};
    if (kategori != null && kategori != 'all') params['kategori'] = kategori;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/resep').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    }
    throw Exception('Gagal memuat resep');
  }

  // ── GET resep milik user yang login (untuk halaman Profil) ─────────────────
  static Future<List<Map<String, dynamic>>> getMyResep() async {
    final response = await http.get(Uri.parse('$baseUrl/resep-saya'), headers: await _getHeaders());
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    }
    throw Exception('Gagal memuat resep saya (${response.statusCode})');
  }

  // ── POST resep baru ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createResep({
    required String nama, required String pembuat, required String waktu,
    required String kesulitan, required String kategori, String? videoUrl,
    required List<String> bahan, required List<String> langkah,
    List<XFile> gambars = const [],
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/resep'));
    request.headers.addAll(await _getHeaders());

    request.fields.addAll({'nama': nama, 'pembuat': pembuat, 'waktu': waktu, 'kesulitan': kesulitan, 'kategori': kategori});
    if (videoUrl != null) request.fields['video_url'] = videoUrl;

    for (int i = 0; i < bahan.length; i++) request.fields['bahan[$i]'] = bahan[i];
    for (int i = 0; i < langkah.length; i++) request.fields['langkah[$i]'] = langkah[i];

    for (var gambar in gambars) {
      request.files.add(http.MultipartFile.fromBytes(
        'gambars[]', await gambar.readAsBytes(),
        filename: gambar.name.isNotEmpty ? gambar.name : 'image.jpg',
      ));
    }

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode == 201) return jsonDecode(response.body)['data'];
    throw Exception('Gagal menyimpan: ${response.body}');
  }

  // ── PUT update resep (hanya milik sendiri, dicek di backend) ───────────────
  static Future<Map<String, dynamic>> updateResep({
    required int id,
    required String nama, required String pembuat, required String waktu,
    required String kesulitan, required String kategori, String? videoUrl,
    required List<String> bahan, required List<String> langkah,
  }) async {
    final headers = await _getHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http.put(
      Uri.parse('$baseUrl/resep/$id'),
      headers: headers,
      body: jsonEncode({
        'nama': nama, 'pembuat': pembuat, 'waktu': waktu,
        'kesulitan': kesulitan, 'kategori': kategori,
        if (videoUrl != null) 'video_url': videoUrl,
        'bahan': bahan, 'langkah': langkah,
      }),
    );

    if (response.statusCode == 200) return jsonDecode(response.body)['data'];
    if (response.statusCode == 403) throw Exception('Kamu tidak punya izin mengubah resep ini.');
    throw Exception('Gagal mengubah resep (${response.statusCode}): ${response.body}');
  }

  // ── DELETE resep (hanya milik sendiri, dicek di backend) ───────────────────
  static Future<void> deleteResep(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/resep/$id'), headers: await _getHeaders());
    if (response.statusCode == 403) throw Exception('Kamu tidak punya izin menghapus resep ini.');
    if (response.statusCode != 200) throw Exception('Gagal menghapus resep (${response.statusCode})');
  }

  // ── POST rating & komentar ────────────────────────────────────────────────
  static Future<void> addRating(int resepId, int nilai) async {
    await http.post(Uri.parse('$baseUrl/resep/$resepId/rating'),
        headers: await _getHeaders()..['Content-Type'] = 'application/json',
        body: jsonEncode({'nilai': nilai}));
  }

  static Future<Map<String, dynamic>> addKomentar(int resepId, String nama, String isi) async {
    final response = await http.post(Uri.parse('$baseUrl/resep/$resepId/komentar'),
        headers: await _getHeaders()..['Content-Type'] = 'application/json',
        body: jsonEncode({'nama': nama, 'isi': isi}));
    return jsonDecode(response.body)['data'];
  }
}