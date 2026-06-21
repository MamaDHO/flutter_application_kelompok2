import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'tambah_resep.dart';
import 'detail_resep.dart';

class HalamanProfil extends StatefulWidget {
  const HalamanProfil({Key? key}) : super(key: key);
  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  Map<String, dynamic>? _user;
  bool    _isLoadingUser = true;
  String? _userError;

  List<Map<String, dynamic>> _myRecipes = [];
  bool    _isLoadingRecipes = true;
  String? _recipesError;

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