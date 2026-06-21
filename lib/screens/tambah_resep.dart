import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../services/api_service.dart';

class TambahResepPage extends StatefulWidget {
  final VoidCallback onSave;
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

              _label(appLanguage.t('recipe_name')),
              _field(_namaCtrl, appLanguage.t('recipe_name')),
              const SizedBox(height: 14),
              _label(appLanguage.t('recipe_author')),
              _field(_pembuatCtrl, appLanguage.t('recipe_author')),
              const SizedBox(height: 14),
              _label(appLanguage.t('cook_time')),
              _field(_waktuCtrl, 'Contoh: 30 Menit'),
              const SizedBox(height: 14),

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

              _label(appLanguage.t('ingredients')),
              _dynamicList(_bahanCtrls, appLanguage.t('ingredient_hint'), appLanguage.t('add_ingredient')),
              const SizedBox(height: 16),

              _label(appLanguage.t('steps')),
              _dynamicList(_langkahCtrls, appLanguage.t('step_hint'), appLanguage.t('add_step')),
              const SizedBox(height: 40),

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