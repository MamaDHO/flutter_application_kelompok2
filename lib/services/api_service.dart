import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti dengan IP komputer saat pakai HP fisik, atau 10.0.2.2 untuk emulator Android
  static const String baseUrl = 'http://localhost:8000/api';

  // ── GET semua resep (dengan filter opsional) ──────────────────────────────
  static Future<List<Map<String, dynamic>>> getResep({
    String? kategori,
    String? search,
  }) async {
    final params = <String, String>{};
    if (kategori != null && kategori != 'all') params['kategori'] = kategori;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/resep').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body['data']);
    }
    throw Exception('Gagal memuat resep');
  }

  // ── POST resep baru (multipart dengan gambar) ─────────────────────────────
  static Future<Map<String, dynamic>> createResep({
    required String nama,
    required String pembuat,
    required String waktu,
    required String kesulitan,
    required String kategori,
    String? videoUrl,
    required List<String> bahan,
    required List<String> langkah,
    List<File> gambars = const [],
  }) async {
    final uri = Uri.parse('$baseUrl/resep');
    final request = http.MultipartRequest('POST', uri);

    request.fields['nama']      = nama;
    request.fields['pembuat']   = pembuat;
    request.fields['waktu']     = waktu;
    request.fields['kesulitan'] = kesulitan;
    request.fields['kategori']  = kategori;
    if (videoUrl != null) request.fields['video_url'] = videoUrl;

    // Array fields untuk Laravel: bahan[0], bahan[1], ...
    for (int i = 0; i < bahan.length; i++) {
      request.fields['bahan[$i]'] = bahan[i];
    }
    for (int i = 0; i < langkah.length; i++) {
      request.fields['langkah[$i]'] = langkah[i];
    }

    // Upload file gambar
    for (int i = 0; i < gambars.length; i++) {
      request.files.add(await http.MultipartFile.fromPath(
        'gambars[$i]',
        gambars[i].path,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal menyimpan resep: ${response.body}');
  }

  // ── POST rating ───────────────────────────────────────────────────────────
  static Future<void> addRating(int resepId, int nilai) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resep/$resepId/rating'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nilai': nilai}),
    );
    if (response.statusCode != 200) throw Exception('Gagal kirim rating');
  }

  // ── POST komentar ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> addKomentar(
      int resepId, String nama, String isi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resep/$resepId/komentar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'isi': isi}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal kirim komentar');
  }
}