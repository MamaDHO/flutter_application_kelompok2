import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Wajib untuk cek Web

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // Sesuaikan port Laravel-mu

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

  static Future<void> createResep({
    required String nama,
    required String pembuat,
    required String waktu,
    required String kesulitan,
    required String kategori,
    String? videoUrl,
    required List<String> bahan,
    required List<String> langkah,
    required List<XFile> gambars,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/resep'));

    // 1. Masukkan data teks biasa
    request.fields['nama'] = nama;
    request.fields['pembuat'] = pembuat;
    request.fields['waktu'] = waktu;
    request.fields['kesulitan'] = kesulitan;
    request.fields['kategori'] = kategori;
    if (videoUrl != null) request.fields['video_url'] = videoUrl;

    // 2. Masukkan data Array (Laravel membaca array di form-data melalui indeks)
    for (int i = 0; i < bahan.length; i++) {
      request.fields['bahan[$i]'] = bahan[i];
    }
    for (int i = 0; i < langkah.length; i++) {
      request.fields['langkah[$i]'] = langkah[i];
    }

    // 3. Masukkan File Gambar (Kompatibel untuk Web & Mobile)
    for (int i = 0; i < gambars.length; i++) {
      final file = gambars[i];
      if (kIsWeb) {
        // Jika di jalankan di Chrome/Web, WAJIB pakai bytes
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'gambars[$i]', // Sesuai aturan validasi Laravel 'gambars.*'
          bytes,
          filename: file.name,
        ));
      } else {
        // Jika di jalankan di Emulator Android / Device fisik
        request.files.add(await http.MultipartFile.fromPath(
          'gambars[$i]',
          file.path,
        ));
      }
    }

    // 4. Tambahkan header Accept agar error dari Laravel terbaca format JSON
    request.headers.addAll({'Accept': 'application/json'});

    // 5. Kirim Request
    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    // 6. Cek Hasil
    if (response.statusCode != 201 && response.statusCode != 200) {
      print("Error API: ${response.statusCode} - $responseData");
      throw Exception('Gagal menyimpan resep');
    }
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
