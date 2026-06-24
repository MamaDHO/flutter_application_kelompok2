import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'tambah_resep.dart';
import 'detail_resep.dart';

class Beranda extends StatefulWidget {
  const Beranda({Key? key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  String searchQuery    = '';
  String activeCategory = 'all';
  List<Map<String, dynamic>> _resepDariApi = [];
  bool    _isLoading = true;
  String? _errorMsg;

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

  List<Map<String, String>> get _kategoriItems => [
    {'value': 'all',         'label': appLanguage.t('all')},
    {'value': 'Sarapan',     'label': appLanguage.t('breakfast')},
    {'value': 'Makan Siang', 'label': appLanguage.t('lunch')},
    {'value': 'Makan Malam', 'label': appLanguage.t('dinner')},
    {'value': 'Cemilan',     'label': appLanguage.t('snack')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, color: Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              appLanguage.t('app_title'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
                Text(appLanguage.t('hello_chef'),
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(appLanguage.t('what_to_cook'),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

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