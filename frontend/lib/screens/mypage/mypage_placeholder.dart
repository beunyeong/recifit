import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recifit_app/screens/mypage/recipe_memo_list_screen.dart';

class MyPagePlaceholder extends StatefulWidget {
  const MyPagePlaceholder({super.key});

  @override
  State<MyPagePlaceholder> createState() => _MyPagePlaceholderState();
}

class _MyPagePlaceholderState extends State<MyPagePlaceholder> {
  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  // ── 메모 로컬 스토리지 ────────────────────────────────────────────────
  static const _memoKey = 'recipe_memos';
  List<_Memo> _memos = [];

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_memoKey);
    if (jsonStr == null || jsonStr.isEmpty) return;
    final raw = json.decode(jsonStr) as List;
    setState(() {
      _memos = raw.map((e) => _Memo.fromJson(Map<String, dynamic>.from(e))).toList();
      _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // 최신순
    });
  }

  Future<void> _saveMemos() async {
    final sp = await SharedPreferences.getInstance();
    final payload = json.encode(_memos.map((e) => e.toJson()).toList());
    await sp.setString(_memoKey, payload);
  }

  Future<void> _openMemoEditor({_Memo? memo}) async {
    final titleCtrl = TextEditingController(text: memo?.title ?? '');
    final bodyCtrl = TextEditingController(text: memo?.content ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  children: [
                    Text(
                      memo == null ? '새 메모' : '메모 수정',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty && bodyCtrl.text.trim().isEmpty) {
                          Navigator.pop(ctx);
                          return;
                        }
                        final now = DateTime.now();
                        if (memo == null) {
                          _memos.add(_Memo(
                            id: now.millisecondsSinceEpoch.toString(),
                            title: titleCtrl.text.trim().isEmpty ? '제목 없음' : titleCtrl.text.trim(),
                            content: bodyCtrl.text.trim(),
                            createdAt: now,
                            updatedAt: now,
                          ));
                        } else {
                          memo.title = titleCtrl.text.trim().isEmpty ? '제목 없음' : titleCtrl.text.trim();
                          memo.content = bodyCtrl.text.trim();
                          memo.updatedAt = now;
                        }
                        setState(() {
                          _memos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                        });
                        _saveMemos();
                        Navigator.pop(ctx);
                      },
                      child: const Text('저장', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 제목
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: '메모 제목',
                    filled: true,
                    fillColor: _lightGray.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // 내용
                Container(
                  decoration: BoxDecoration(
                    color: _lightGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: bodyCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      hintText: '재료, 비율, 과정 등 자유롭게 기록하세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(_Memo memo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('메모 삭제'),
        content: const Text('삭제한 메모는 되돌릴 수 없어요. 계속할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소', style: TextStyle(color: _grayText))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _memos.removeWhere((m) => m.id == memo.id));
      _saveMemos();
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return '방금';
    if (d.inHours < 1) return '${d.inMinutes}분 전';
    if (d.inDays < 1) return '${d.inHours}시간 전';
    if (d.inDays < 7) return '${d.inDays}일 전';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  // ── UI ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundBeige,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileSection(),
                    _buildStatsSection(),
                    _buildMyPostsSection(),
                    _buildMemoSection(),
                    _buildComingSoonSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // 뒤로가기
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: _darkText, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text('마이페이지',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -0.5)),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: _darkText, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_buttonGreen, _buttonGreen.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: _buttonGreen.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 5))],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('닉네임', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText)),
              const SizedBox(height: 6),
              Text('요리하는 것을 좋아해요 🍳', style: TextStyle(fontSize: 14, color: _grayText)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: _lightGray, borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.edit_outlined, size: 16, color: _darkText),
              const SizedBox(width: 4),
              Text('수정', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _darkText)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('팔로워', '0', Icons.people_outline)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('팔로잉', '0', Icons.person_add_outlined)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('내 글', '3', Icons.article_outlined)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: _buttonGreen, size: 24),
          const SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: _grayText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMyPostsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 8, bottom: 16), child: Text('내가 작성한 글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText))),
          ...['오늘 만든 오트밀', '사과로 만든 파이', '냉장고 파먹기 후기'].map((title) => _buildPostCard(title)),
        ],
      ),
    );
  }

  Widget _buildPostCard(String title) {
    final Map<String, Map<String, int>> dummyStats = {
      '오늘 만든 오트밀': {'likes': 24, 'comments': 8},
      '사과로 만든 파이': {'likes': 156, 'comments': 32},
      '냉장고 파먹기 후기': {'likes': 89, 'comments': 15},
    };
    final stats = dummyStats[title] ?? {'likes': 0, 'comments': 0};

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: _lightGray, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.image_outlined, color: _grayText, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkText)),
                  const SizedBox(height: 4),
                  Text('현재 준비중인 블로그 기능입니다.', style: TextStyle(fontSize: 13, color: _grayText)),
                ]),
              ),
              Icon(Icons.chevron_right, color: _grayText, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _lightGray.withOpacity(0.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(children: [Icon(Icons.favorite_outline, color: Colors.red.shade300, size: 16), const SizedBox(width: 4), Text('${stats['likes']}', style: TextStyle(fontSize: 13, color: _grayText, fontWeight: FontWeight.w500))]),
              const SizedBox(width: 16),
              Row(children: [Icon(Icons.chat_bubble_outline, color: Colors.blue.shade300, size: 16), const SizedBox(width: 4), Text('${stats['comments']}', style: TextStyle(fontSize: 13, color: _grayText, fontWeight: FontWeight.w500))]),
              const Spacer(),
              Text('2일 전', style: TextStyle(fontSize: 12, color: _grayText.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  // TODO: 메모 기능
  Widget _buildMemoSection() {
    final top3 = _memos.take(3).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('나만의 레시피 메모',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText)),
              ),
              if (_memos.length > 3)
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RecipeMemoListScreen()),
                    );
                    await _loadMemos();
                  },
                  child: const Text('더보기'),
                ),
              TextButton.icon(
                onPressed: () => _openMemoEditor(),
                icon: Icon(Icons.add, size: 18, color: _buttonGreen),
                label: Text('메모 추가',
                    style: TextStyle(color: _buttonGreen, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (top3.isEmpty) _emptyMemoCard() else Column(children: top3.map(_buildMemoCard).toList()),
        ],
      ),
    );
  }

  // 빈 메모 상태 카드
  Widget _emptyMemoCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _buttonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.note_add_outlined, color: _buttonGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아직 메모가 없어요',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '레시피 비율, 팁 등을 메모로 남겨보세요.',
                  style: TextStyle(fontSize: 13, color: _grayText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _openMemoEditor(),
            icon: Icon(Icons.add, size: 18, color: _buttonGreen),
            label: Text('메모 추가',
                style: TextStyle(color: _buttonGreen, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoCard(_Memo m) {
    return GestureDetector(
      onTap: () => _openMemoEditor(memo: m),
      onLongPress: () => _confirmDelete(m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _warmWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: _buttonGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.sticky_note_2_outlined, color: _buttonGreen)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _darkText)),
                const SizedBox(height: 4),
                Text(m.content.isEmpty ? '내용 없음' : m.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: _grayText)),
              ]),
            ),
            const SizedBox(width: 8),
            Text(_timeAgo(m.updatedAt), style: TextStyle(fontSize: 11, color: _grayText.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_buttonGreen.withOpacity(0.1), _buttonGreen.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _buttonGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(color: _buttonGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(30)), child: Icon(Icons.auto_awesome, color: _buttonGreen, size: 28)),
          const SizedBox(height: 16),
          Text('새로운 기능 준비중', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText)),
          const SizedBox(height: 8),
          Text('블로그, 커뮤니티, 레시피 공유 등\n다양한 기능들이 곧 공개됩니다 ✨', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: _grayText, height: 1.4)),
        ],
      ),
    );
  }
}

// ── 메모 VO ────────────────────────────────────────────────────────────────
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