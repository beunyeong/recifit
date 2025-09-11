import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeMemoListScreen extends StatefulWidget {
  const RecipeMemoListScreen({super.key});

  @override
  State<RecipeMemoListScreen> createState() => _RecipeMemoListScreenState();
}

class _RecipeMemoListScreenState extends State<RecipeMemoListScreen> {
  Color get _bg => const Color(0xFFF7F5F3);
  Color get _card => const Color(0xFFFFFFFE);
  Color get _text => const Color(0xFF2C2C2C);
  Color get _muted => const Color(0xFF666666);
  Color get _green => const Color(0xFF4CAF50);
  Color get _border => const Color(0xFFF0F0F0);

  static const _memoKey = 'recipe_memos';
  List<_Memo> _memos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final str = sp.getString(_memoKey);
    if (str == null || str.isEmpty) return;
    final raw = json.decode(str) as List;
    setState(() {
      _memos = raw.map((e) => _Memo.fromJson(Map<String, dynamic>.from(e))).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  Future<void> _save() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_memoKey, json.encode(_memos.map((e) => e.toJson()).toList()));
  }

  Future<void> _edit({_Memo? memo}) async {
    final title = TextEditingController(text: memo?.title ?? '');
    final body  = TextEditingController(text: memo?.content ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
              color: _card, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Text(memo == null ? '새 메모' : '메모 수정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _text)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  final now = DateTime.now();
                  if (memo == null) {
                    if (title.text.trim().isEmpty && body.text.trim().isEmpty) {
                      Navigator.pop(ctx); return;
                    }
                    _memos.add(_Memo(
                      id: now.millisecondsSinceEpoch.toString(),
                      title: title.text.trim().isEmpty ? '제목 없음' : title.text.trim(),
                      content: body.text.trim(),
                      createdAt: now, updatedAt: now,
                    ));
                  } else {
                    memo
                      ..title = title.text.trim().isEmpty ? '제목 없음' : title.text.trim()
                      ..content = body.text.trim()
                      ..updatedAt = now;
                  }
                  setState(() => _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));
                  _save();
                  Navigator.pop(ctx);
                },
                child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8),
            TextField(
              controller: title,
              decoration: InputDecoration(
                hintText: '메모 제목',
                filled: true,
                fillColor: _border.withOpacity(0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: _border.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: body, maxLines: 10,
                decoration: const InputDecoration(
                    hintText: '재료/비율/팁 등을 자유롭게 적으세요', border: InputBorder.none),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _delete(_Memo m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('메모 삭제'),
        content: const Text('삭제한 메모는 복구할 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _memos.removeWhere((e) => e.id == m.id));
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('전체 메모', style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(),
        backgroundColor: _green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _memos.isEmpty
          ? Center(child: Text('저장된 메모가 없어요', style: TextStyle(color: _muted)))
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _memos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final m = _memos[i];
          return ListTile(
            tileColor: _card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _text, fontWeight: FontWeight.w700)),
            subtitle: Text(
              m.content.isEmpty ? '내용 없음' : m.content,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _muted),
            ),
            trailing: PopupMenuButton<int>(
              onSelected: (v) => v == 0 ? _edit(memo: m) : _delete(m),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 0, child: Text('수정')),
                PopupMenuItem(value: 1, child: Text('삭제')),
              ],
            ),
            onTap: () => _edit(memo: m),
          );
        },
      ),
    );
  }
}

class _Memo {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;

  _Memo({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _Memo.fromJson(Map<String, dynamic> j) => _Memo(
    id: j['id'] as String,
    title: j['title'] as String? ?? '제목 없음',
    content: j['content'] as String? ?? '',
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}