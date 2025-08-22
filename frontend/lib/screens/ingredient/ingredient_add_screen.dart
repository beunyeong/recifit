import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class IngredientAddScreen extends StatefulWidget {
  const IngredientAddScreen({super.key});

  @override
  State<IngredientAddScreen> createState() => _IngredientAddScreenState();
}

class _IngredientAddScreenState extends State<IngredientAddScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> searchResults = [];
  bool _isSearching = false;

  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _softGreen => const Color(0xFFB8E6B8);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchIngredient() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final list = await ApiService.instance.searchIngredients(keyword);
      setState(() {
        searchResults = list.map<Map<String, String>>((item) => {
          'name': (item['foodNmKr'] ??
              item['foodName'] ??
              item['name'] ??
              '')
              .toString(),
          'category':
          (item['dbGrpNm'] ??
              item['groupName'] ??
              item['category'] ??
              '기타')
              .toString(),
        }).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("재료 검색 실패: $e"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _submitIngredient({
    required String ingredientName,
    required String description,
    required String storageLocation,
    required DateTime storageDate,
    required DateTime expirationDate,
  }) async {
    try {
      await ApiService.instance.addIngredient(
        ingredientName: ingredientName,
        description: description,
        storageLocation: storageLocation,
        storageDate: storageDate,
        expirationDate: expirationDate,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$ingredientName 재료가 추가되었습니다!"),
          backgroundColor: _buttonGreen,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("재료 추가 실패: $e"),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _showAddIngredientBottomSheet(Map<String, String> ingredient) {
    String selectedStorage = 'REFRIGERATED';
    DateTime? storageDate;
    DateTime? expirationDate;

    // 수기 입력 (기본값: 전달받은 값/검색어)
    final nameCtrl = TextEditingController(text: ingredient['name'] ?? '');
    final descCtrl = TextEditingController(text: ingredient['category'] ?? '기타');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: _backgroundBeige,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 핸들 바
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _grayText.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 제목
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _softGreen.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart,
                          color: _buttonGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "재료 추가",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _darkText,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 재료명 입력
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "재료명",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: "예) 사과",
                      filled: true,
                      fillColor: _warmWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _lightGray),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 설명(선택)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "설명 (선택)",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descCtrl,
                    decoration: InputDecoration(
                      hintText: "예) 과일 / 유기농 등",
                      filled: true,
                      fillColor: _warmWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _lightGray),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 보관 방법 선택
                  _buildDropdownField(
                    label: "보관 방법",
                    value: selectedStorage,
                    items: const [
                      DropdownMenuItem(value: "REFRIGERATED", child: Text("냉장")),
                      DropdownMenuItem(value: "FROZEN", child: Text("냉동")),
                      DropdownMenuItem(
                          value: "ROOM_TEMPERATURE", child: Text("상온")),
                    ],
                    onChanged: (v) => setModalState(() => selectedStorage = v!),
                  ),

                  const SizedBox(height: 20),

                  // 보관일 선택
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: _buttonGreen,
                                surface: _warmWhite,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setModalState(() => storageDate = picked);
                    },
                    child: _buildDatePickerTile(
                        "보관일", storageDate, Icons.calendar_today),
                  ),

                  const SizedBox(height: 16),

                  // 유통기한 선택
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 3)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: _buttonGreen,
                                surface: _warmWhite,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() => expirationDate = picked);
                      }
                    },
                    child: _buildDatePickerTile(
                        "유통기한", expirationDate, Icons.event_available),
                  ),

                  const SizedBox(height: 28),

                  // 추가 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("재료명을 입력하세요."),
                              backgroundColor: Colors.orange.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }
                        if (storageDate == null || expirationDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("날짜를 모두 선택해주세요."),
                              backgroundColor: Colors.orange.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        _submitIngredient(
                          ingredientName: nameCtrl.text.trim(),
                          description: (descCtrl.text.trim().isEmpty)
                              ? '기타'
                              : descCtrl.text.trim(),
                          storageLocation: selectedStorage,
                          storageDate: storageDate!,
                          expirationDate: expirationDate!,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "냉장고에 추가",
                            style: TextStyle(
                              fontSize: 16,
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
          }),
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _warmWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _lightGray),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            style: TextStyle(
              fontSize: 16,
              color: _darkText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile(String label, DateTime? date, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: _warmWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _lightGray),
          ),
          child: Row(
            children: [
              Icon(icon, color: _grayText, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  date != null
                      ? "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}"
                      : "날짜를 선택해주세요",
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? _darkText : _grayText.withOpacity(0.6),
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: _grayText, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
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
      backgroundColor: _backgroundBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '재료 추가',
          style: TextStyle(
            color: _darkText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색 섹션
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _softGreen.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.search,
                        color: _buttonGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "재료 검색",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          fontSize: 16,
                          color: _darkText,
                        ),
                        decoration: InputDecoration(
                          hintText: "재료명을 입력해주세요",
                          hintStyle: TextStyle(
                            color: _grayText.withOpacity(0.6),
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: _lightGray.withOpacity(0.5),
                          prefixIcon:
                          Icon(Icons.kitchen, color: _grayText, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        onSubmitted: (_) => _searchIngredient(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSearching ? null : _searchIngredient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSearching
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          "검색",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // "직접 등록" 버튼
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showAddIngredientBottomSheet({
                        'name': _searchController.text.trim(),
                        'category': '기타',
                      });
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("직접 등록"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _buttonGreen,
                      side: BorderSide(color: _buttonGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 검색 결과
          Expanded(
            child: searchResults.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _lightGray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 40,
                      color: _grayText.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "검색 결과가 없습니다.",
                    style: TextStyle(
                      fontSize: 16,
                      color: _grayText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "직접 등록하시겠습니까?",
                    style: TextStyle(
                      fontSize: 14,
                      color: _grayText.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showAddIngredientBottomSheet({
                        'name': _searchController.text.trim(),
                        'category': '기타',
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "직접 등록",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: searchResults.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = searchResults[index];
                final categoryColor =
                _getCategoryColor(item['category']!);

                return Container(
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
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['category']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _showAddIngredientBottomSheet(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "추가",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}