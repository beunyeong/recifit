import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Timer? _ticker;

  // 로딩/에러 & 탭별 리스트
  bool _loading = false;
  String? _error;

  final List<_PostItem> _listAll = [];
  final List<_PostItem> _listRecipe = [];
  final List<_PostItem> _listTip = [];

  // ── 페이지네이션 상태 (탭별)
  int _pageAll = 0, _totalPagesAll = 1;
  int _pageRecipe = 0, _totalPagesRecipe = 1;
  int _pageTip = 0, _totalPagesTip = 1;

  // 서버 페이지 크기(원하면 조절)
  static const int _pageSize = 10;

  // 팔레트
  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _lightGrayText => const Color(0xFF999999);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 초기: 전체 0페이지 로드
    _loadPageForTab(0, 0);

    // 탭 전환 시 해당 탭 첫 로드(비어있으면)
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final t = _tabController.index;
      if (_dataOfTab(t).isEmpty) {
        _loadPageForTab(t, 0);
      } else {
        setState(() {}); // 상대시간만 갱신
      }
    });

    // 상대시간 라벨 자동 갱신 (1분마다)
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // ───────────────────────── Utils

  List<_PostItem> _dataOfTab(int tab) {
    switch (tab) {
      case 1:
        return _listRecipe;
      case 2:
        return _listTip;
      default:
        return _listAll;
    }
  }

  (int page, int total) _pageStateOfTab(int tab) {
    switch (tab) {
      case 1:
        return (_pageRecipe, _totalPagesRecipe);
      case 2:
        return (_pageTip, _totalPagesTip);
      default:
        return (_pageAll, _totalPagesAll);
    }
  }

  void _setPageStateOfTab(int tab, int page, int total) {
    switch (tab) {
      case 1:
        _pageRecipe = page;
        _totalPagesRecipe = total;
        break;
      case 2:
        _pageTip = page;
        _totalPagesTip = total;
        break;
      default:
        _pageAll = page;
        _totalPagesAll = total;
    }
  }

  PostCategory? _categoryOfTab(int tab) {
    switch (tab) {
      case 1:
        return PostCategory.RECIPE;
      case 2:
        return PostCategory.TIP;
      default:
        return null;
    }
  }

  // 상대 시간 포맷터
  String formatRelativeTime(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}개월 전';
    return '${(diff.inDays / 365).floor()}년 전';
  }

  DateTime _parseCreatedAt(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      final dt = DateTime.parse(raw.toString());
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      try {
        final ms = int.parse(raw.toString());
        return DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  // 숫자 변환 헬퍼
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  // 서버 응답에서 "작성자 id" 찾기
  int? _extractAuthorId(Map<String, dynamic> d) {
    // 평면 키
    final k1 = _toInt(d['authorId']);
    final k2 = _toInt(d['memberId']);
    final k3 = _toInt(d['writerId']);
    final k4 = _toInt(d['userId']);
    if (k1 != null) return k1;
    if (k2 != null) return k2;
    if (k3 != null) return k3;
    if (k4 != null) return k4;

    // 중첩 객체 { member: { id: ... } }, { author: { id: ... } } 등
    final m = d['member'];
    if (m is Map) {
      final km =
          _toInt(m['id']) ?? _toInt(m['memberId']) ?? _toInt(m['userId']);
      if (km != null) return km;
    }
    final a = d['author'];
    if (a is Map) {
      final ka =
          _toInt(a['id']) ?? _toInt(a['memberId']) ?? _toInt(a['userId']);
      if (ka != null) return ka;
    }
    return null;
  }

  _PostItem _mapFromResponse(Map<String, dynamic> data) {
    final cat = (data['postCategory'] ?? '').toString();
    final title = (data['title'] ?? '').toString();
    final content = (data['content'] ?? '').toString();
    final nickname =
    (data['nickname'] ?? data['name'] ?? data['writer'] ?? '익명')
        .toString();
    final likeCount = int.tryParse('${data['likeCount'] ?? 0}') ?? 0;
    final commentCount = int.tryParse('${data['commentCount'] ?? 0}') ?? 0;
    final postId = int.tryParse('${data['id'] ?? data['postId'] ?? ''}');
    final createdAt = _parseCreatedAt(data['createdAt']);

    // isMine 계산
    final currentId = ApiService.instance.currentMemberId;
    final authorId = _extractAuthorId(data);
    bool isMine = false;

    if (data['mine'] == true) {
      isMine = true;
    }
    if (!isMine && currentId != null && authorId != null) {
      isMine = currentId == authorId;
    }
    if (!isMine) {
      final myNick = ApiService.instance.currentNickname?.trim();
      final myEmail = ApiService.instance.currentEmail?.trim();
      final nickEq =
      (myNick != null && myNick.isNotEmpty && myNick == nickname.trim());
      final emailEq = (myEmail != null &&
          myEmail.isNotEmpty &&
          myEmail ==
              (data['email'] ?? data['writerEmail'] ?? '').toString().trim());
      if (nickEq || emailEq) isMine = true;
    }

    return _PostItem(
      postId: postId,
      username: nickname,
      createdAt: createdAt,
      category: cat,
      title: title,
      content: content,
      likes: likeCount,
      comments: commentCount,
      imageEmoji: null,
      isMine: isMine,
    );
  }

  // ───────────────────────── Data Load (Paged)

  Future<void> _loadPageForTab(int tabIndex, int page) async {
    final target = _dataOfTab(tabIndex);

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final cat = _categoryOfTab(tabIndex);
      final resp = await ApiService.instance.fetchPostsPaged(
        category: cat,
        mine: false,
        page: page,
        size: _pageSize,
        sort: 'createdAt,desc',
      );

      final items = resp.content.map(_mapFromResponse).toList();

      setState(() {
        target
          ..clear()
          ..addAll(items);
        _setPageStateOfTab(tabIndex, resp.number, resp.totalPages);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 당겨서 새로고침 (현재 페이지 유지)
  Future<void> _refreshCurrentTab() async {
    final tab = _tabController.index;
    final (p, _) = _pageStateOfTab(tab);
    await _loadPageForTab(tab, p);
  }

  // 작성/수정 후: 현재 탭 첫 페이지로 리셋하거나, 현재 페이지 재로드
  Future<void> _afterEditReload({bool resetToFirst = true}) async {
    final tab = _tabController.index;
    final (p, _) = _pageStateOfTab(tab);
    await _loadPageForTab(tab, resetToFirst ? 0 : p);
  }

  // ───────── 단건 조회 & 상세 이동

  Future<void> _openPostDetail(int? postId) async {
    if (postId == null) return;

    try {
      final detail = await ApiService.instance.fetchPost(postId);

      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        '/post-detail',
        arguments: {'postId': postId},
      );

      // 상세에서 수정/삭제 후 돌아왔을 때를 대비해 현재 페이지 재로딩
      if (mounted) await _afterEditReload(resetToFirst: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글을 불러오지 못했어요: $e')),
      );
    }
  }

  // ───────── 삭제 UX (커스텀 다이얼로그)

  Future<bool> _confirmDelete(BuildContext context) async {
    final text = Theme.of(context).textTheme;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: _warmWhite,
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
                // 아이콘 컨테이너
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.red.shade100,
                        Colors.red.shade50,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 36,
                    color: Colors.red.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // 제목
                Text(
                  '정말로 삭제하시겠어요?',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 설명
                Text(
                  '삭제된 게시글은 복구할 수 없습니다.\n게시글을 삭제하시겠습니까?.',
                  style: text.bodyMedium?.copyWith(
                    color: _grayText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // 버튼들
                Row(
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _lightGray,
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
                                  color: _grayText,
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

                    // 삭제 버튼
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red.shade500,
                              Colors.red.shade600,
                            ],
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

  Future<void> _deletePostAndReload(_PostItem item) async {
    if (item.postId == null) return;

    try {
      await ApiService.instance.deletePost(item.postId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('게시글이 삭제되었습니다.')),
      );
      await _afterEditReload(resetToFirst: false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
    }
  }

  // ───────────────────────── UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundBeige,
      appBar: AppBar(
        backgroundColor: _warmWhite,
        elevation: 0,
        title: Text('커뮤니티',
            style: TextStyle(color: _darkText, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: _darkText),
            onPressed: () {
              // TODO: 검색
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _buttonGreen,
          unselectedLabelColor: _grayText,
          indicatorColor: _buttonGreen,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [Tab(text: '전체'), Tab(text: '레시피'), Tab(text: '팁')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPagedTab(0, _listAll),
          _buildPagedTab(1, _listRecipe),
          _buildPagedTab(2, _listTip),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/write-post');
          await _afterEditReload(resetToFirst: true);
          if (result != null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('변경 사항이 반영되었습니다.')),
            );
          }
        },
        backgroundColor: _buttonGreen,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildPagedTab(int tabIndex, List<_PostItem> data) {
    final (currentPage, totalPages) = _pageStateOfTab(tabIndex);

    return Column(
      children: [
        Expanded(child: _buildList(data)),
        _NumberPaginationBar(
          currentPage: currentPage,
          totalPages: totalPages,
          onTapPage: (p) => _loadPageForTab(tabIndex, p),
          onPrev: currentPage > 0
              ? () => _loadPageForTab(tabIndex, currentPage - 1)
              : null,
          onNext: (currentPage + 1 < totalPages)
              ? () => _loadPageForTab(tabIndex, currentPage + 1)
              : null,
          primary: _buttonGreen,
          textColor: _darkText,
          disabledColor: _lightGray,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // 리스트 공통 (로딩/에러 포함)
  Widget _buildList(List<_PostItem> data) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _refreshCurrentTab,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Text('오류가 발생했어요\n$_error',
                style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 12),
            Text('당겨서 새로고침으로 다시 시도해보세요.',
                style: TextStyle(color: _lightGrayText)),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshCurrentTab,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 64),
            _emptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCurrentTab,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final p = data[index];
          return _buildPostCard(
            item: p,
            index: index,
            username: p.username,
            time: formatRelativeTime(p.createdAt),
            category: p.category == 'RECIPE' ? '레시피' : '팁',
            title: p.title,
            content: p.content,
            likes: p.likes,
            comments: p.comments,
            imageUrl: p.imageEmoji,
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.forum_outlined, size: 48, color: _lightGrayText),
          const SizedBox(height: 8),
          Text('아직 등록된 글이 없어요',
              style: TextStyle(color: _darkText, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('첫 글을 올려보세요!', style: TextStyle(color: _lightGrayText)),
        ],
      ),
    );
  }

  // 카드: 전체 탭 시 단건 조회
  Widget _buildPostCard({
    required _PostItem item,
    required int index,
    required String username,
    required String time,
    required String category,
    required String title,
    required String content,
    required int likes,
    required int comments,
    String? imageUrl,
  }) {
    return InkWell(
      onTap: () => _openPostDetail(item.postId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _warmWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _buttonGreen.withOpacity(0.1),
                child: Text(
                  username.isNotEmpty ? username[0] : '?',
                  style: TextStyle(
                    color: _buttonGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username,
                        style: TextStyle(
                            color: _darkText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    Text(time,
                        style:
                        TextStyle(color: _lightGrayText, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category == '레시피'
                      ? Colors.blue.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: category == '레시피'
                        ? Colors.blue.shade600
                        : Colors.orange.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(
                  color: _darkText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(content,
              style:
              TextStyle(color: _grayText, fontSize: 14, height: 1.4)),

          if (imageUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: _lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                  child:
                  Text(imageUrl, style: const TextStyle(fontSize: 32))),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.favorite_border,
                        color: _lightGrayText, size: 18),
                    const SizedBox(width: 4),
                    Text(likes.toString(),
                        style: TextStyle(
                            color: _lightGrayText, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        color: _lightGrayText, size: 18),
                    const SizedBox(width: 4),
                    Text(comments.toString(),
                        style: TextStyle(
                            color: _lightGrayText, fontSize: 12)),
                  ],
                ),
              ),
              const Spacer(),
              if (item.isMine)
                InkWell(
                  onTap: () => _showPostActionSheet(item, index),
                  child: Icon(Icons.more_horiz,
                      color: _lightGrayText, size: 18),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> _showPostActionSheet(_PostItem item, int index) async {
    if (!item.isMine) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 그랩 핸들
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 12),

                // 제목
                Row(
                  children: [
                    Text('게시글 옵션',
                        style: TextStyle(
                          color: _darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        )),
                    const Spacer(),
                    Text(item.category == 'RECIPE' ? '레시피' : '팁',
                        style: TextStyle(
                          color: item.category == 'RECIPE'
                              ? Colors.blue.shade600
                              : Colors.orange.shade600,
                          fontWeight: FontWeight.w700,
                        )),
                  ],
                ),
                const SizedBox(height: 14),

                // ▶ 수정하기
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('수정하기',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final result = await Navigator.pushNamed(
                      context,
                      '/write-post',
                      arguments: {
                        'mode': 'edit',
                        'postId': item.postId,
                        'title': item.title,
                        'content': item.content,
                        'postCategory': item.category,
                      },
                    );
                    if (!mounted) return;
                    await _afterEditReload(resetToFirst: false);
                    if (result != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('게시글이 수정되었습니다.')),
                      );
                    }
                  },
                ),

                // ▶ 삭제하기
                ListTile(
                  leading:
                  Icon(Icons.delete_outline, color: Colors.red.shade600),
                  title: Text(
                    '삭제하기',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade600),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final ok = await _confirmDelete(context);
                    if (ok) await _deletePostAndReload(item);
                  },
                ),

                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('닫기',
                      style: TextStyle(
                        color: _grayText,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ───────── 페이지네이션 ─────────
class _NumberPaginationBar extends StatelessWidget {
  const _NumberPaginationBar({
    required this.currentPage, // 0-based
    required this.totalPages,
    required this.onTapPage,
    required this.onPrev,
    required this.onNext,
    required this.primary,
    required this.textColor,
    required this.disabledColor,
  });

  final int currentPage; // 0-based
  final int totalPages; // 1..N (0이면 표시 X)
  final void Function(int page) onTapPage;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final Color primary;
  final Color textColor;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();

    // 보여줄 페이지 버튼 범위 계산 (현재 기준 ±2, 총 5개)
    const int visibleCount = 5;
    int start, end;
    if (totalPages <= visibleCount) {
      start = 0;
      end = totalPages; // [0, total)
    } else {
      start = currentPage - (visibleCount ~/ 2);
      if (start < 0) start = 0;
      end = start + visibleCount;
      if (end > totalPages) {
        end = totalPages;
        start = end - visibleCount;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _navButton(Icons.chevron_left,
              enabled: onPrev != null, onTap: onPrev),
          for (int i = start; i < end; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: i == currentPage ? null : () => onTapPage(i),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                    i == currentPage ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: i == currentPage ? Colors.white : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          _navButton(Icons.chevron_right,
              enabled: onNext != null, onTap: onNext),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon,
      {required bool enabled, required VoidCallback? onTap}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? primary : disabledColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// UI 모델
class _PostItem {
  final int? postId;
  final String username;
  final DateTime createdAt; // ← timeLabel 대신 DateTime 저장
  final String category; // 'RECIPE' or 'TIP'
  final String title;
  final String content;
  final int likes;
  final int comments;
  final String? imageEmoji;

  // 추가: 내 글 여부
  final bool isMine;

  _PostItem({
    required this.postId,
    required this.username,
    required this.createdAt,
    required this.category,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    this.imageEmoji,
    this.isMine = false,
  });
}