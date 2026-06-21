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
  double  _userRating = 0;
  bool    _ratingSubmitting = false;
  bool    _commentSubmitting = false;
  final   _commentCtrl = TextEditingController();
  final   _nameCtrl    = TextEditingController();

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
            _NetworkCarousel(urls: imageUrls),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['nama'] ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Wrap(spacing: 16, runSpacing: 4, children: [
                    _meta(Icons.person,           d['pembuat']  ?? '', Colors.grey),
                    _meta(Icons.timer,            d['waktu']    ?? '', Colors.orange),
                    _meta(Icons.restaurant_menu,  d['kesulitan']?? '', Colors.orange),
                    _meta(Icons.label_outline,    d['kategori'] ?? '', Colors.teal),
                  ]),
                  const SizedBox(height: 10),

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

                  const Divider(),
                  Text(appLanguage.t('comments'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
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

class _NetworkCarousel extends StatefulWidget {
  final List<String> urls;
  final double height;
  const _NetworkCarousel({Key? key, required this.urls, this.height = 280}) : super(key: key);

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