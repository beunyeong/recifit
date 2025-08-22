import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Color get _backgroundWhite => Colors.white;
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _lightGrayText => const Color(0xFF999999);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF8F9FA);
  Color get _borderGray => const Color(0xFFE9ECEF);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _backgroundWhite,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMenuSection(context),
                    const SizedBox(height: 24),
                    _buildSettingsSection(context),
                    const SizedBox(height: 24),
                    _buildVersionInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lightGray,
        border: Border(
          bottom: BorderSide(color: _borderGray, width: 1),
        ),
      ),
      child: Row(
        children: [
          // 심플한 프로필 아바타
          CircleAvatar(
            radius: 24,
            backgroundColor: _buttonGreen.withOpacity(0.1),
            child: Icon(
              Icons.person_outline,
              color: _buttonGreen,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '닉네임',
                  style: TextStyle(
                    color: _darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'email@example.com',
                  style: TextStyle(
                    color: _grayText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(Icons.edit_outlined, color: _grayText, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '메뉴',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _lightGrayText,
              letterSpacing: 0.5,
            ),
          ),
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.person_outline,
          title: '마이페이지',
          subtitle: '프로필 및 활동 관리',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/mypage');
          },
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.kitchen_outlined,
          title: '내 냉장고',
          subtitle: '보관중인 재료 확인',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/main');
          },
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.restaurant_menu_outlined,
          title: '레시피 검색',
          subtitle: 'AI 맞춤 레시피 추천',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/recommendation');
          },
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.people_outline,
          title: '커뮤니티',
          subtitle: '요리 팁과 경험 공유',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/community');
          },
          showBadge: false,
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '설정',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _lightGrayText,
              letterSpacing: 0.5,
            ),
          ),
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.settings_outlined,
          title: '설정',
          subtitle: '앱 환경설정',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/coming');
          },
          showBadge: false,
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.help_outline,
          title: '도움말',
          subtitle: '사용법 및 FAQ',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/coming');
          },
          showBadge: false,
        ),

        _buildMenuItem(
          context: context,
          icon: Icons.feedback_outlined,
          title: '피드백',
          subtitle: '의견 및 건의사항',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/coming');
          },
          showBadge: false,
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showBadge = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Icon(
          icon,
          color: _grayText,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: _darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: _grayText,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showBadge && (title == '마이페이지' || title == '커뮤니티'))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200, width: 0.5),
                ),
                child: Text(
                  '준비중',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade600,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: _lightGrayText, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _lightGrayText, size: 18),
          const SizedBox(width: 8),
          Text(
            'Recifit v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: _lightGrayText,
            ),
          ),
        ],
      ),
    );
  }
}