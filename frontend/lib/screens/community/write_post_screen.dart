import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});
  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  PostCategory _category = PostCategory.RECIPE;
  bool _submitting = false;
  String? _error;

  bool _isEdit = false;
  int? _postId;

  Color get _bg => const Color(0xFFF7F5F3);
  Color get _card => const Color(0xFFFFFFFE);
  Color get _text => const Color(0xFF2C2C2C);
  Color get _hintText => const Color(0xFF9E9E9E);
  Color get _primary => const Color(0xFF4CAF50);
  Color get _divider => const Color(0xFFF0F0F0);

  bool _argsLoaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final mode = (args['mode'] ?? 'create').toString().toLowerCase();
      _isEdit = mode == 'edit';
      if (_isEdit) {
        _postId = int.tryParse('${args['postId']}');
        _titleCtrl.text = (args['title'] ?? '').toString();
        _contentCtrl.text = (args['content'] ?? '').toString();
        final cat = (args['postCategory'] ?? 'RECIPE').toString();
        _category = cat == 'TIP' ? PostCategory.TIP : PostCategory.RECIPE;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() { _submitting = true; _error = null; });

    try {
      Map<String, dynamic> data;
      if (_isEdit) {
        if (_postId == null) throw Exception('postId가 없습니다');
        data = await ApiService.instance.updatePost(
          postId: _postId!,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
        data['postCategory'] ??= _category.name;
      } else {
        data = await ApiService.instance.addPost(
          category: _category,
          title: _titleCtrl.text.trim(),
          content: _contentCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catIsRecipe = _category == PostCategory.RECIPE;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? '게시글 수정' : '새 글 쓰기',
            style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      bottomNavigationBar: _EditorBottomBar(
        primaryLabel: _isEdit ? '저장' : '등록',
        disabled: _submitting,
        onCancel: () => Navigator.pop(context),
        onPrimary: _submit,
        loading: _submitting,
        primaryColor: _primary,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              _SectionCard(
                icon: Icons.category_outlined,
                title: '카테고리',
                trailing: _isEdit
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.lock_outline, size: 14, color: _hintText),
                  const SizedBox(width: 4),
                  Text('수정 불가', style: TextStyle(color: _hintText, fontSize: 12)),
                ])
                    : null,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: '레시피',
                      selected: catIsRecipe,
                      onTap: _isEdit ? null : () => setState(() => _category = PostCategory.RECIPE),
                    ),
                    const SizedBox(width: 8),
                    _CategoryChip(
                      label: '팁',
                      selected: !catIsRecipe,
                      onTap: _isEdit ? null : () => setState(() => _category = PostCategory.TIP),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.title,
                title: '제목',
                child: Stack(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      maxLength: 50,
                      decoration: _inputDeco('제목을 입력해주세요'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '제목은 필수입니다' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text('${_titleCtrl.text.characters.length}/50',
                          style: TextStyle(color: _hintText, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                icon: Icons.notes_outlined,
                title: '내용',
                child: Stack(
                  children: [
                    TextFormField(
                      controller: _contentCtrl,
                      maxLines: 10,
                      maxLength: 1000,
                      decoration: _inputDeco('내용을 입력해주세요\n\n예시:\n• 재료: 계란 3개, 우유 2스푼\n• 만드는 법: ...\n• 팁: ...'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '내용은 필수입니다' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Text('${_contentCtrl.text.characters.length}/1000',
                          style: TextStyle(color: _hintText, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: _hintText),
    filled: true,
    fillColor: _card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _primary, width: 1.5),
    ),
    counterText: '',
    contentPadding: const EdgeInsets.all(14),
  );
}

class _EditorBottomBar extends StatelessWidget {
  const _EditorBottomBar({
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    required this.primaryColor,
    this.loading = false,
    this.disabled = false,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onCancel;
  final Color primaryColor;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: const Color(0xFF000000).withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: disabled ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF666666),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: disabled ? null : onPrimary,
              icon: loading
                  ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check, size: 18),
              label: Text(primaryLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon, this.trailing});
  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFFFFFFFE);
    const titleColor = Color(0xFF2C2C2C);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF000000).withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.black.withOpacity(0.5)),
            const SizedBox(width: 8),
          ],
          Text(title, style: const TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final off = const Color(0xFFEAEAEA);
    final baseColor = selected ? Colors.blue : const Color(0xFF666666);
    final bg = selected ? Colors.blue.shade50 : off;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? Colors.blue : off, width: 1.2),
          ),
          child: Text(label, style: TextStyle(color: baseColor, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}