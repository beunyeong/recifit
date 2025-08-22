import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recifit_app/services/api_service.dart';

class RecipeRecommendScreen extends StatefulWidget {
  const RecipeRecommendScreen({super.key});

  @override
  State<RecipeRecommendScreen> createState() => _RecipeRecommendScreenState();
}

class _RecipeRecommendScreenState extends State<RecipeRecommendScreen> {
  bool _loading = false;
  String? _error;
  String? _result;

  MemberType _memberType = MemberType.PET_OWNER;
  CookingLevel _cookingLevel = CookingLevel.ADVANCED;

  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _softGreen => const Color(0xFFB8E6B8);
  Color get _peachPink => const Color(0xFFFFD4C4);
  Color get _lightYellow => const Color(0xFFFFF2C7);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ApiService.instance.isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  List<String> _parseRecipes(String text) {
    final t = text.trim();

    // 구분자로 레시피 분리
    final dashSplit = RegExp(r'^\s*[-–—]{3,}\s*$', multiLine: true);
    var parts = t
        .split(dashSplit)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      final titleSplit = RegExp(r'(?=^이 요리는)', multiLine: true);
      parts = t
          .split(titleSplit)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return parts;
  }

  Future<void> _fetch() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final text = await ApiService.instance.recommendRecipes(
        memberType: _memberType,
        cookingLevel: _cookingLevel,
        expiringIngredients: const [],
      );
      if (!mounted) return;
      setState(() => _result = text);
      HapticFeedback.lightImpact();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
      HapticFeedback.heavyImpact();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _memberTypeLabel(MemberType v) {
    switch (v) {
      case MemberType.SINGLE: return '자취생';
      case MemberType.COUPLE: return '커플/신혼';
      case MemberType.FAMILY: return '가족';
      case MemberType.HOBBYIST: return '취미 요리';
      case MemberType.PET_OWNER: return '반려인';
    }
  }

  String _cookingLevelLabel(CookingLevel v) {
    switch (v) {
      case CookingLevel.BEGINNER: return '초급';
      case CookingLevel.INTERMEDIATE: return '중급';
      case CookingLevel.ADVANCED: return '고급';
    }
  }

  IconData _memberTypeIcon(MemberType v) {
    switch (v) {
      case MemberType.SINGLE: return Icons.person;
      case MemberType.COUPLE: return Icons.favorite;
      case MemberType.FAMILY: return Icons.family_restroom;
      case MemberType.HOBBYIST: return Icons.palette;
      case MemberType.PET_OWNER: return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI 레시피 추천',
          style: TextStyle(
            color: _darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetch,
        color: _buttonGreen,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 히어로 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _warmWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _softGreen.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: _buttonGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI 맞춤 레시피',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _darkText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '냉장고 재료로 만드는 특별한 요리',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _grayText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _lightGray.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _loading ? null : _fetch,
                            icon: _loading
                                ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(_buttonGreen),
                              ),
                            )
                                : Icon(
                              Icons.refresh,
                              color: _buttonGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 생활 유형 선택
              Text(
                '생활 유형',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: MemberType.values.length,
                  itemBuilder: (context, index) {
                    final type = MemberType.values[index];
                    final isSelected = _memberType == type;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == MemberType.values.length - 1 ? 0 : 12,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _memberType = type);
                          _fetch();
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? _buttonGreen : _warmWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? _buttonGreen : _lightGray,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : _lightGray.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _memberTypeIcon(type),
                                  color: isSelected ? Colors.white : _grayText,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _memberTypeLabel(type),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: isSelected ? Colors.white : _grayText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 요리 실력
              Text(
                '요리 실력',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(4),
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
                  children: CookingLevel.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final level = entry.value;
                    final isSelected = _cookingLevel == level;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _cookingLevel = level);
                          _fetch();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? _buttonGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _cookingLevelLabel(level),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : _grayText,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // CTA 버튼
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _fetch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBackgroundColor: _grayText.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_loading) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ] else ...[
                        Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _loading ? '레시피 생성 중...' : '새로운 레시피 추천받기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 결과 표시
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '오류가 발생했습니다',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (_result == null && !_loading)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
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
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _lightGray.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: _grayText,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '맞춤 레시피를 기다리고 있어요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '위에서 옵션을 선택하고 추천받기 버튼을 눌러주세요',
                        style: TextStyle(color: _grayText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else if (_result != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _warmWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _lightYellow.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: Colors.orange.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '오늘의 추천 레시피 ✨',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_memberTypeLabel(_memberType)} · ${_cookingLevelLabel(_cookingLevel)} 맞춤',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: _grayText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 레시피 내용
                        Builder(builder: (context) {
                          final recipes = _parseRecipes(_result ?? '');
                          if (recipes.isEmpty) {
                            return Text(
                              '표시할 레시피가 없어요.',
                              style: TextStyle(color: _grayText),
                            );
                          }

                          return Column(
                            children: [
                              ...recipes.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final recipe = entry.value;

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: idx == recipes.length - 1 ? 0 : 16,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _lightGray.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: _lightGray),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _buttonGreen.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '레시피 ${idx + 1}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: _buttonGreen,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: Icon(
                                                Icons.copy,
                                                size: 18,
                                                color: _grayText,
                                              ),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: recipe));
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('레시피를 복사했어요!'),
                                                    backgroundColor: _buttonGreen,
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        SelectableText(
                                          recipe,
                                          style: TextStyle(
                                            height: 1.6,
                                            fontSize: 15,
                                            color: _darkText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),

                              const SizedBox(height: 20),

                              // 하단 액션 버튼들
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _lightGray.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: (_result ?? '').isEmpty ? null : () {
                                          Clipboard.setData(ClipboardData(text: _result!));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('전체 레시피를 복사했어요!'),
                                              backgroundColor: _buttonGreen,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.copy, size: 16, color: _grayText),
                                        label: Text(
                                          '전체 복사',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _grayText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _lightGray.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: TextButton.icon(
                                        onPressed: (_result ?? '').isEmpty ? null : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('공유 기능은 곧 업데이트될 예정이에요!'),
                                              backgroundColor: _buttonGreen,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.share, size: 16, color: _grayText),
                                        label: Text(
                                          '공유하기',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _grayText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}