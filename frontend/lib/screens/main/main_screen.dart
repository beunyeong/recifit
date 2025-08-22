import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';
import 'package:recifit_app/widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  @override
  void initState() {
    super.initState();
    _loadMyIngredients();
  }

  Future<void> _loadMyIngredients() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (!ApiService.instance.isLoggedIn) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final list = await ApiService.instance.fetchMyIngredients();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('HTTP 401') || msg.contains('HTTP 403')) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      if (!mounted) return;
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 오늘~N일 이내(포함) 만료 예정 개수 계산 (remainingDays/daysLeft 우선, 없으면 expirationDate 사용)
  int _soonCount(List<Map<String, dynamic>> items, {int days = 3}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    bool isSoon(Map<String, dynamic> m) {
      final raw = m['remainingDays'] ?? m['daysLeft'];
      if (raw != null) {
        final d = raw is int ? raw : int.tryParse('$raw');
        if (d == null) return false;
        return d >= 0 && d <= days;
      }
      final expStr = m['expirationDate'] as String?;
      if (expStr == null || expStr.isEmpty) return false;
      try {
        final d = DateTime.parse(expStr);
        final onlyDate = DateTime(d.year, d.month, d.day);
        final diff = onlyDate.difference(today).inDays;
        return diff >= 0 && diff <= days;
      } catch (_) {
        return false;
      }
    }

    return items.where(isSoon).length;
  }

  (String, Color, Color) _getDaysInfo(int? daysLeft) {
    if (daysLeft == null) return ('기한없음', const Color(0xFFF0F4F8), const Color(0xFF64748B));
    if (daysLeft < 0) return ('만료됨', const Color(0xFFFEE2E2), const Color(0xFFDC2626));
    if (daysLeft == 0) return ('오늘', const Color(0xFFFEF3C7), const Color(0xFFD97706));
    if (daysLeft <= 3) return ('$daysLeft일', const Color(0xFFFEF2F2), const Color(0xFFEF4444));
    return ('$daysLeft일', const Color(0xFFDCFCE7), const Color(0xFF059669));
  }

  String _getStorageText(String? location) {
    switch (location) {
      case 'REFRIGERATED':
        return '냉장';
      case 'FROZEN':
        return '냉동';
      case 'ROOM_TEMPERATURE':
        return '상온';
      default:
        return '보관';
    }
  }

  IconData _getStorageIcon(String? location) {
    switch (location) {
      case 'REFRIGERATED':
        return Icons.ac_unit;
      case 'FROZEN':
        return Icons.severe_cold;
      case 'ROOM_TEMPERATURE':
        return Icons.home;
      default:
        return Icons.inventory_2;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '단백질':
      case '육류':
      case '생선':
        return Colors.red.shade300;
      case '채소':
      case '야채':
      case '과일':
        return _buttonGreen;
      case '유제품':
      case '유제':
        return Colors.blue.shade300;
      case '발효식품':
      case '조미료':
        return Colors.orange.shade300;
      case '곡물':
      case '쌀':
      case '밀가루':
        return Colors.amber.shade300;
      default:
        return _grayText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundBeige,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCard(),
            Expanded(child: _buildIngredientsList()),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final soon = _soonCount(_items, days: 3);
    final subtitle = soon > 0 ? "$soon개 곧 만료! 오늘 활용해볼까요?" : "오늘은 여유 있어요";

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // 냉장고 아이콘 박스
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.kitchen, color: _buttonGreen, size: 24),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "오늘의 재료함",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: _grayText),
                ),
              ],
            ),
          ),

          // 햄버거 메뉴 버튼
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.menu, color: _darkText, size: 20),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final expiringSoon = _soonCount(_items, days: 3);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_buttonGreen, _buttonGreen.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _buttonGreen.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_items.length}개 재료",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expiringSoon > 0 ? "$expiringSoon개 곧 만료" : "모든 재료 신선함",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadMyIngredients,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "새로고침",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_buttonGreen),
            ),
            const SizedBox(height: 16),
            Text(
              "재료를 불러오는 중...",
              style: TextStyle(color: _grayText, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red.shade400),
              ),
              const SizedBox(height: 16),
              Text("재료를 불러올 수 없어요",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _darkText)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: _grayText, fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadMyIngredients,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("다시 시도"),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.kitchen_outlined, size: 48, color: _grayText.withOpacity(0.6)),
              ),
              const SizedBox(height: 20),
              Text("냉장고가 비어있어요",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _darkText)),
              const SizedBox(height: 8),
              Text("아래 버튼을 눌러 재료를 추가해보세요!",
                  textAlign: TextAlign.center, style: TextStyle(color: _grayText, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          final name = (item['ingredientName'] ?? item['name'] ?? '-').toString();
          final description = (item['description'] ?? '').toString();
          final location = (item['storageLocation'] ?? '').toString();

          final rawDays = item['remainingDays'] ?? item['daysLeft'];
          final int? daysLeft = rawDays is int ? rawDays : int.tryParse('$rawDays');

          final itemId = item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}');

          final (daysText, daysColor, daysTextColor) = _getDaysInfo(daysLeft);
          final categoryColor = _getCategoryColor(description);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _warmWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                // 카테고리 색상 인디케이터
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 16),

                // 재료 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkText)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: categoryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              description.isEmpty ? '기타' : description,
                              style: TextStyle(fontSize: 11, color: categoryColor, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(_getStorageIcon(location), size: 14, color: _grayText),
                          const SizedBox(width: 4),
                          Text(_getStorageText(location), style: TextStyle(fontSize: 13, color: _grayText)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 유통기한 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: daysColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    daysText,
                    style: TextStyle(color: daysTextColor, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),

                const SizedBox(width: 8),

                // 삭제 버튼
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                  onPressed: itemId == null ? null : () => _showDeleteDialog(item, index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> item, int index) async {
    final name = (item['ingredientName'] ?? item['name'] ?? '-').toString();
    final itemId = item['id'] is int ? item['id'] as int : int.tryParse('${item['id']}');

    if (itemId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text('재료 삭제'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$name" 재료를 삭제하시겠습니까?'),
            const SizedBox(height: 8),
            Text('삭제된 재료는 복구할 수 없습니다.', style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('취소', style: TextStyle(color: _grayText))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.instance.deleteIngredient(itemId);
        setState(() => _items.removeAt(index));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name이(가) 삭제되었습니다'),
              backgroundColor: _buttonGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    }
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('재료 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/recommendation'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkText,
                  side: BorderSide(color: _lightGray),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, size: 20),
                    SizedBox(width: 8),
                    Text('레시피 검색', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}