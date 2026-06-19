// ============================================================
//  lib/services/api_service.dart
//
//  Catatan penting soal upload gambar:
//  Flutter Web TIDAK mendukung dart:io (File, File.openRead, dll).
//  Karena itu http.MultipartFile.fromPath() — yang membaca lewat
//  dart:io di balik layar — akan GAGAL di web.
//
//  Solusi: gunakan XFile.readAsBytes() (cross-platform, jalan di
//  Web/Android/iOS/Desktop) lalu kirim dengan
//  http.MultipartFile.fromBytes(), yang aman untuk semua platform.
// ============================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Emulator Android : http://10.0.2.2:8000/api
  // Emulator iOS/Web  : http://127.0.0.1:8000/api atau http://localhost:8000/api
  // HP fisik          : http://<IP-LAPTOP-KAMU>:8000/api
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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
    throw Exception('Gagal memuat resep (${response.statusCode})');
  }

  // ── POST resep baru (multipart, web-safe) ─────────────────────────────────
  static Future<Map<String, dynamic>> createResep({
    required String nama,
    required String pembuat,
    required String waktu,
    required String kesulitan,
    required String kategori,
    String? videoUrl,
    required List<String> bahan,
    required List<String> langkah,
    List<XFile> gambars = const [],
  }) async {
    final uri = Uri.parse('$baseUrl/resep');
    final request = http.MultipartRequest('POST', uri);

    request.fields['nama']      = nama;
    request.fields['pembuat']   = pembuat;
    request.fields['waktu']     = waktu;
    request.fields['kesulitan'] = kesulitan;
    request.fields['kategori']  = kategori;
    if (videoUrl != null) request.fields['video_url'] = videoUrl;

    // Laravel butuh format array: bahan[0], bahan[1], dst.
    for (int i = 0; i < bahan.length; i++) {
      request.fields['bahan[$i]'] = bahan[i];
    }
    for (int i = 0; i < langkah.length; i++) {
      request.fields['langkah[$i]'] = langkah[i];
    }

    // ── Upload gambar: baca sebagai bytes, BUKAN lewat path file ──
    // Ini yang membuatnya jalan di Web sekaligus Mobile/Desktop.
    for (int i = 0; i < gambars.length; i++) {
      final bytes = await gambars[i].readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'gambars[$i]',
          bytes,
          filename: gambars[i].name.isNotEmpty ? gambars[i].name : 'image_$i.jpg',
        ),
      );
    }

    final streamed = await request.send();
    final response  = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal menyimpan resep (${response.statusCode}): ${response.body}');
  }

  // ── POST rating ─────────────────────────────────────────────────────────
  static Future<void> addRating(int resepId, int nilai) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resep/$resepId/rating'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nilai': nilai}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal kirim rating (${response.statusCode})');
    }
  }

  // ── POST komentar ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> addKomentar(
    int resepId,
    String nama,
    String isi,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resep/$resepId/komentar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nama': nama, 'isi': isi}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Gagal kirim komentar (${response.statusCode})');
  }
}