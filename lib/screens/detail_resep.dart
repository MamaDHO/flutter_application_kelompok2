import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import '../services/api_service.dart';

class DetailResepApi extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailResepApi({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailResepApi> createState() => _DetailResepApiState();
}

class _DetailResepApiState extends State<DetailResepApi> {
  // ── State ulasan ─────────────────────────────────────────────────────────────
  // Nilai bintang yang sedang dipilih user (0 = belum pilih)
  int _selectedNilai = 0;
  bool _isSubmitting = false;
  final _ulasanCtrl = TextEditingController();

  late List<Map<String, dynamic>> _localUlasans;
  late double _localAvg;
  late int    _localCount;

  @override
  void initState() {
    super.initState();
    final raw = (widget.data['ulasans'] as List?) ?? [];
    _localUlasans = raw.map((e) => Map<String, dynamic>.from(e)).toList();
    _localAvg     = (widget.data['average_rating'] ?? 0).toDouble();
    _localCount   = widget.data['rating_count'] ?? 0;
  }

  @override
  void dispose() {
    _ulasanCtrl.dispose();
    super.dispose();
  }

  // ── Submit ulasan (rating + komentar dalam satu request) ─────────────────────
  Future<void> _submitUlasan() async {
    // Validasi: bintang wajib dipilih
    if (_selectedNilai == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih bintang terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    // Validasi: komentar wajib diisi
    final isi = _ulasanCtrl.text.trim();
    if (isi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis komentar terlebih dahulu.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final newUlasan = await ApiService.addUlasan(
        resepId: widget.data['id'],
        nilai:   _selectedNilai,
        isi:     isi,
      );

      setState(() {
        // Jika user sudah pernah ulasan resep ini, update entry lama
        // (backend sudah updateOrCreate, tinggal sinkronkan di UI)
        final existingIdx = _localUlasans.indexWhere(
          (u) => u['user_id'] == newUlasan['user_id'],
        );
        if (existingIdx >= 0) {
          _localUlasans[existingIdx] = newUlasan;
        } else {
          _localUlasans.insert(0, newUlasan);
        }

        // Hitung ulang rata-rata dari list lokal
        if (_localUlasans.isNotEmpty) {
          _localCount = _localUlasans.length;
          _localAvg   = _localUlasans
                  .map((u) => (u['nilai'] as num).toDouble())
                  .reduce((a, b) => a + b) /
              _localCount;
        }

        _ulasanCtrl.clear();
        _selectedNilai = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLanguage.t('comment_sent')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    final d         = widget.data;
    final gambars   = (d['gambars'] as List?) ?? [];
    final imageUrls = gambars.map((g) => g['url'].toString()).toList();
    final bahan     = (d['bahan']   as List?) ?? [];
    final langkah   = (d['langkah'] as List?) ?? [];
    final videoUrl  = d['video_url'] as String?;

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
                  // Judul
                  Text(d['nama'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Meta: pembuat, waktu, kesulitan, kategori
                  Wrap(spacing: 16, runSpacing: 4, children: [
                    _meta(Icons.person,          d['pembuat']   ?? '', Colors.grey),
                    _meta(Icons.timer,           d['waktu']     ?? '', Colors.orange),
                    _meta(Icons.restaurant_menu, d['kesulitan'] ?? '', Colors.orange),
                    _meta(Icons.label_outline,   d['kategori']  ?? '', Colors.teal),
                  ]),
                  const SizedBox(height: 10),

                  // Rating display (rata-rata)
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                          i < _localAvg.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 20)),
                    const SizedBox(width: 8),
                    Text(
                      _localCount == 0
                          ? appLanguage.t('no_rating')
                          : '${_localAvg.toStringAsFixed(1)} ($_localCount ulasan)',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10)),
                      child:
                          const Icon(Icons.play_circle_fill, color: Colors.red, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appLanguage.t('video_tutorial'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(appLanguage.t('watch_tutorial'),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
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
                                gradient: LinearGradient(colors: [
                                  Colors.red.shade700,
                                  Colors.red.shade400
                                ]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.smart_display,
                                      color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Text(appLanguage.t('open_video'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.open_in_new,
                                      color: Colors.white70, size: 16),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_off,
                                  color: Colors.grey[400], size: 20),
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
                            const Text('• ',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Expanded(
                                child: Text(b.toString(),
                                    style: const TextStyle(fontSize: 14))),
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
                                  color: Colors.orange.shade100,
                                  shape: BoxShape.circle),
                              child: Center(
                                child: Text('${e.key + 1}',
                                    style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ),
                            Expanded(
                                child: Text(e.value.toString(),
                                    style: const TextStyle(height: 1.4))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // ══════════ ULASAN: RATING + KOMENTAR (DISATUKAN) ══════════
                  const Divider(),
                  Text(appLanguage.t('comments'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Rating dan komentar dikirim bersama.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),

                  // ── Form ulasan ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8, offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bintang interaktif
                        const Text('Beri Bintang',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (i) {
                            final filled = i < _selectedNilai;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedNilai = i + 1),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  filled ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 38,
                                ),
                              ),
                            );
                          }),
                        ),
                        if (_selectedNilai > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            _nilaiLabel(_selectedNilai),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.orange),
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Input komentar
                        const Text('Komentar',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ulasanCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: appLanguage.t('leave_comment'),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Colors.orange),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Tombol kirim
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitUlasan,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send_rounded,
                                    color: Colors.white),
                            label: Text(
                              _isSubmitting
                                  ? appLanguage.t('saving')
                                  : appLanguage.t('send'),
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Daftar ulasan ──
                  if (_localUlasans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(appLanguage.t('no_comments'),
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    Column(
                      children:
                          _localUlasans.map((u) => _UlasanItem(data: u)).toList(),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Label teks berdasarkan nilai bintang
  String _nilaiLabel(int nilai) {
    switch (nilai) {
      case 1: return 'Sangat Buruk';
      case 2: return 'Kurang Bagus';
      case 3: return 'Cukup';
      case 4: return 'Bagus';
      case 5: return 'Sangat Bagus!';
      default: return '';
    }
  }

  Widget _meta(IconData icon, String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: color == Colors.grey ? Colors.grey : Colors.black87)),
        ],
      );
}

// ─── ULASAN ITEM ──────────────────────────────────────────────────────────────
class _UlasanItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _UlasanItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final nama      = data['nama']       ?? '';
    final isi       = data['isi']        ?? '';
    final nilai     = (data['nilai'] as num?)?.toInt() ?? 0;
    final avatarUrl = data['avatar_url'] as String?;
    final time      = data['created_at'] != null
        ? _fmt(DateTime.tryParse(data['created_at']) ?? DateTime.now())
        : 'Baru saja';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          avatarUrl != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: Colors.orange.shade100,
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange.shade200,
                  child: Text(
                    nama.isNotEmpty ? nama[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + waktu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(nama,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                // Bintang nilai
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < nilai ? Icons.star : Icons.star_border,
                      color: Colors.amber, size: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Isi komentar
                Text(isi, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'Baru saja';
    if (d.inHours < 1)   return '${d.inMinutes}m lalu';
    if (d.inDays < 1)    return '${d.inHours}j lalu';
    return '${d.inDays}h lalu';
  }
}

// ─── NETWORK CAROUSEL ─────────────────────────────────────────────────────────
class _NetworkCarousel extends StatefulWidget {
  final List<String> urls;
  final double height;
  const _NetworkCarousel({Key? key, required this.urls, this.height = 280})
      : super(key: key);

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
          height: widget.height,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 60));
    }

    return Stack(children: [
      SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _ctrl,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => Image.network(
            widget.urls[i],
            width: double.infinity, height: widget.height, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
                height: widget.height,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 60)),
          ),
        ),
      ),
      if (widget.urls.length > 1)
        Positioned(
          top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)),
            child: Text('${_current + 1} / ${widget.urls.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      if (widget.urls.length > 1)
        Positioned(
          bottom: 14, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.urls.length, (i) {
              final active = _current == i;
              return GestureDetector(
                onTap: () => _ctrl.animateToPage(i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.orange
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.25), blurRadius: 4)
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      if (widget.urls.length > 1)
        Positioned(
          left: 8, top: 0, bottom: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _current > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => _ctrl.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ),
      if (widget.urls.length > 1)
        Positioned(
          right: 8, top: 0, bottom: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _current < widget.urls.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: GestureDetector(
                onTap: () => _ctrl.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.chevron_right,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ),
    ]);
  }
}