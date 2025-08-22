import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Map<String, dynamic>? _post;
  List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _commentsLoading = false;
  String? _error;

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();

  Color get _bg => const Color(0xFFF7F5F3);
  Color get _card => const Color(0xFFFFFFFE);
  Color get _text => const Color(0xFF2C2C2C);
  Color get _sub => const Color(0xFF666666);
  Color get _muted => const Color(0xFF999999);
  Color get _primary => const Color(0xFF4CAF50);
  Color get _light => const Color(0xFFF0F0F0);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final postId = (args is Map) ? int.tryParse('${args['postId']}') : null;
    if (postId == null) {
      setState(() {
        _loading = false;
        _error = '잘못된 요청입니다 (postId 없음)';
      });
      return;
    }
    _fetch(postId);
    _fetchComments(postId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _fetch(int postId) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.instance.fetchPost(postId);
      setState(() {
        _post = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchComments(int postId) async {
    setState(() => _commentsLoading = true);
    try {
      // TODO: 실제 댓글 API 연결
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _comments = [
          {
            'id': 1,
            'content': '정말 유용한 정보네요! 감사합니다 😊',
            'nickname': '건강지킴이',
            'createdAt': '2024-03-15T10:30:00',
            'isMine': false,
          },
          {
            'id': 2,
            'content': '저도 이 방법으로 해봤는데 정말 효과가 좋더라고요. 추천드려요!',
            'nickname': '운동매니아',
            'createdAt': '2024-03-15T11:15:00',
            'isMine': false,
          },
          {
            'id': 3,
            'content': '혹시 초보자도 따라할 수 있을까요?',
            'nickname': '운동초보',
            'createdAt': '2024-03-15T14:20:00',
            'isMine': true,
          },
        ];
      });
    } finally {
      if (mounted) setState(() => _commentsLoading = false);
    }
  }

  bool get _isMine {
    final d = _post;
    if (d == null) return false;
    if (d['mine'] == true) return true;

    final currentId = ApiService.instance.currentMemberId;
    int? authorId;
    final rawMemberId = d['memberId'] ?? d['authorId'] ?? d['writerId'];
    if (rawMemberId is int) {
      authorId = rawMemberId;
    } else if (rawMemberId is String) {
      authorId = int.tryParse(rawMemberId);
    }
    return (currentId != null && authorId != null && currentId == authorId);
  }

  String _formatRelativeTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return '방금 전';
      if (diff.inHours < 1) return '${diff.inMinutes}분 전';
      if (diff.inDays < 1) return '${diff.inHours}시간 전';
      if (diff.inDays < 7) return '${diff.inDays}일 전';
      return '${date.month}월 ${date.day}일';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildCommentInput(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _bg,
      elevation: 0,
      floating: true,
      pinned: false,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        if (_isMine && _post != null)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.more_horiz, color: _sub),
              onPressed: _showActionSheet, // 커스텀 액션시트 호출
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SizedBox(
        height: 400,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Container(
        height: 400,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('오류가 발생했어요', style: TextStyle(color: _text, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('$_error', style: TextStyle(color: _sub, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    if (_post == null) {
      return const SizedBox(
        height: 400,
        child: Center(child: Text('데이터가 없습니다.')),
      );
    }

    return Column(
      children: [
        _buildPostContent(),
        const SizedBox(height: 12),
        _buildCommentsSection(),
      ],
    );
  }

  Widget _buildPostContent() {
    final p = _post!;
    final title = (p['title'] ?? '').toString();
    final content = (p['content'] ?? '').toString();
    final nickname = (p['nickname'] ?? p['name'] ?? '익명').toString();
    final category = (p['postCategory'] ?? '').toString() == 'RECIPE' ? '레시피' : '팁';
    final likeCount = int.tryParse('${p['likeCount'] ?? 0}') ?? 0;
    final commentCount = int.tryParse('${p['commentCount'] ?? 0}') ?? 0;
    final createdAt = (p['createdAt'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리와 시간
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: category == '레시피'
                        ? [Colors.blue.shade50, Colors.blue.shade100]
                        : [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: category == '레시피'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: category == '레시피' ? Colors.blue.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatRelativeTime(createdAt),
                style: TextStyle(color: _muted, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 제목
          Text(
            title,
            style: TextStyle(
              color: _text,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // 작성자
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    nickname.isNotEmpty ? nickname[0] : '?',
                    style: TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                nickname,
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (_isMine) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '내 글',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // 내용
          Text(
            content,
            style: TextStyle(
              color: _text,
              height: 1.7,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 24),

          // 구분선
          Container(
            height: 1,
            color: _light,
          ),

          const SizedBox(height: 16),

          // 좋아요, 댓글 수
          Row(
            children: [
              _buildInteractionButton(
                icon: Icons.favorite_border_rounded,
                count: likeCount,
                onTap: () {
                  // TODO: 좋아요 기능
                },
              ),
              const SizedBox(width: 20),
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline_rounded,
                count: commentCount,
                onTap: () {
                  _commentFocus.requestFocus();
                },
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.share_outlined, color: _muted, size: 20),
                onPressed: () {
                  // TODO: 공유 기능
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _sub),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                color: _sub,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  '댓글',
                  style: TextStyle(
                    color: _text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_comments.length}',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_commentsLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: _muted),
                  const SizedBox(height: 12),
                  Text(
                    '아직 댓글이 없어요',
                    style: TextStyle(color: _text, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '첫 댓글을 남겨보세요!',
                    style: TextStyle(color: _muted, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: _comments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final content = comment['content'] ?? '';
    final nickname = comment['nickname'] ?? '익명';
    final createdAt = comment['createdAt'] ?? '';
    final isMine = comment['isMine'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMine ? _primary.withOpacity(0.05) : _light.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: isMine ? Border.all(color: _primary.withOpacity(0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isMine ? _primary.withOpacity(0.2) : _sub.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    nickname.isNotEmpty ? nickname[0] : '?',
                    style: TextStyle(
                      color: isMine ? _primary : _sub,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                nickname,
                style: TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '내 댓글',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                _formatRelativeTime(createdAt),
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: _text,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _light,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '댓글을 입력하세요...',
                    hintStyle: TextStyle(color: _muted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  ),
                  style: TextStyle(color: _text),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(22),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  final text = _commentController.text.trim();
                  if (text.isNotEmpty) {
                    _submitComment(text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment(String content) async {
    // TODO: 실제 댓글 등록 API 호출
    setState(() {
      _comments.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'content': content,
        'nickname': '나',
        'createdAt': DateTime.now().toIso8601String(),
        'isMine': true,
      });
    });

    _commentController.clear();
    _commentFocus.unfocus();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글이 등록되었습니다.')),
    );
  }

  Future<void> _goEdit() async {
    final p = _post;
    if (p == null) return;
    final postId = int.tryParse('${p['id']}');
    if (postId == null) return;

    final postCategory = (p['postCategory'] ?? 'RECIPE').toString();
    final result = await Navigator.pushNamed(
      context,
      '/write-post',
      arguments: {
        'mode': 'edit',
        'postId': postId,
        'title': (p['title'] ?? '').toString(),
        'content': (p['content'] ?? '').toString(),
        'postCategory': postCategory,
      },
    );
    if (!mounted) return;
    if (result != null) {
      await _fetch(postId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 수정되었습니다.')),
      );
    }
  }

  Future<void> _delete() async {
    final p = _post;
    if (p == null) return;
    final postId = int.tryParse('${p['id']}');
    if (postId == null) return;

    try {
      await ApiService.instance.deletePost(postId);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  Future<bool> _confirmDelete() async {
    final text = Theme.of(context).textTheme;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.red.shade100, Colors.red.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
                  ),
                  child: Icon(Icons.delete_outline_rounded, size: 36, color: Colors.red.shade600),
                ),
                const SizedBox(height: 24),
                Text(
                  '정말로 삭제하시겠어요?',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _text,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '삭제된 게시글은 복구할 수 없습니다.\n신중하게 결정해 주세요.',
                  style: text.bodyMedium?.copyWith(
                    color: _sub,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _light,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx, false),
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  color: _sub,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.red.shade500, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(ctx, true),
                            borderRadius: BorderRadius.circular(16),
                            child: const Center(
                              child: Text(
                                '삭제하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ) ??
        false;
  }

  // ───────────────────────── 커스텀 액션시트 (수정/삭제)
  Future<void> _showActionSheet() async {
    final p = _post;
    if (p == null) return;

    final category = (p['postCategory'] ?? '').toString() == 'RECIPE' ? '레시피' : '팁';

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // grab handle
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 12),

                // 헤더
                Row(
                  children: [
                    Text(
                      '게시글 옵션',
                      style: TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: category == '레시피' ? Colors.blue.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: category == '레시피' ? Colors.blue.shade600 : Colors.orange.shade600,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 수정하기
                _ActionTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_outlined),
                  ),
                  title: '수정하기',
                  subtitle: '내용을 수정하고 다시 게시해요',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _goEdit();
                  },
                ),

                const SizedBox(height: 8),

                // 삭제하기
                _ActionTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade100, Colors.red.shade200],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  title: '삭제하기',
                  subtitle: '삭제하면 되돌릴 수 없어요',
                  titleStyle: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w800,
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await _confirmDelete();
                    if (ok) await _delete();
                  },
                ),

                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: _sub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 액션시트용 공용 타일
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleStyle,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ??
                        const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}