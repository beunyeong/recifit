import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:recifit_app/services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;
  late final Animation<Offset> _slideIn;

  bool _isPressed = false;
  bool _busy = false;         // ← 콜백 처리 중 로딩
  String? _error;             // ← 에러 메시지 표시용

  Color get _bg => const Color(0xFFF7F5F3);
  Color get _card => const Color(0xFFFFFFFE);
  Color get _text => const Color(0xFF2C2C2C);
  Color get _sub => const Color(0xFF666666);
  Color get _chipGreen => const Color(0xFFBFEFCC);
  Color get _chipPeach => const Color(0xFFFFD8C8);
  Color get _chipLemon => const Color(0xFFFFF2B8);
  Color get _primary => const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _controller.forward();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await ApiService.instance.init();

      if (kIsWeb) {
        final uri = Uri.base; // 현재 주소 (예: /oauth?code=...)
        if (uri.path == '/oauth') {
          final error = uri.queryParameters['error'];
          final code = uri.queryParameters['code'];

          if (error != null && error.isNotEmpty) {
            setState(() => _error = '카카오 로그인 실패: $error');
            await Future.delayed(const Duration(milliseconds: 600));
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
            return;
          }

          if (code != null && code.isNotEmpty) {
            setState(() => _busy = true);
            try {
              await ApiService.instance.exchangeKakaoCode(code);
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/main');
              return;
            } catch (e) {
              setState(() => _error = '토큰 교환 실패: $e');
              await Future.delayed(const Duration(milliseconds: 600));
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
              return;
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          }

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      }
    } catch (e) {
      setState(() => _error = '초기화 오류: $e');
    }
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleIn = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutQuart),
      ),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.9, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateNext() {
    final hasToken = ApiService.instance.accessToken != null;
    Navigator.pushReplacementNamed(context, hasToken ? '/main' : '/signup');
    // 로그인 먼저 보여주려면 '/signup' 대신 '/login' 사용 가능
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _busy ? null : _navigateNext, // 콜백 처리 중엔 탭 비활성화
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // 1) 소프트 그라디언트 블롭 배경
            _BackgroundBlobs(primary: _primary),

            // 2) 컨텐츠
            SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _fadeIn,
                      child: SlideTransition(
                        position: _slideIn,
                        child: ScaleTransition(
                          scale: _scaleIn,
                          child: Column(
                            children: [
                              const Spacer(flex: 2),

                              // 냉장고 카드
                              _FridgeCard(card: _card, text: _sub),

                              const SizedBox(height: 42),
                              _brand(),
                              const SizedBox(height: 20),
                              _chipsRow(),

                              const Spacer(flex: 3),
                              _subtitle(),
                              const SizedBox(height: 28),
                              _ctaButton(),
                              const SizedBox(height: 14),
                              _hint(),
                              if (_error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // 3) OAuth 처리 중 로딩 오버레이
            if (_busy)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                  child: const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          '스마트한 요리 생활의 시작',
          style: TextStyle(
            color: _sub,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _chipsRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip('신선함', _chipGreen, Icons.energy_savings_leaf_outlined),
        _chip('편리함', _chipPeach, Icons.touch_app_outlined),
        _chip('절약', _chipLemon, Icons.savings_outlined),
      ],
    );
  }

  Widget _chip(String label, Color bg, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _text),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _text,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _subtitle() {
    return Text(
      '냉장고를 열면, 한 끼가 보여요\n오늘 먹기 좋은 레시피를 추천해요',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _sub,
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _ctaButton() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _busy ? null : _navigateNext,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _primary.withOpacity(_isPressed ? 0.20 : 0.28),
              blurRadius: _isPressed ? 10 : 18,
              offset: Offset(0, _isPressed ? 4 : 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.door_front_door_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              '냉장고 열기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint() {
    return Text(
      '화면을 터치해서 시작하세요',
      style: TextStyle(
        color: _sub.withOpacity(0.75),
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// 배경 그라디언트
class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 큰 그라디언트
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: const [
                  Color(0xFFF8F6F3),
                  Color(0xFFF6F9F6),
                ],
              ),
            ),
          ),
        ),
        // 블롭 1
        Positioned(
          top: -40,
          left: -30,
          child: _blob(
            const Size(160, 160),
            const [Color(0xFFE6F6E9), Color(0xFFF8F6F3)],
            blur: 16,
          ),
        ),
        // 블롭 2
        Positioned(
          bottom: -50,
          right: -20,
          child: _blob(
            const Size(200, 200),
            [primary.withOpacity(0.15), const Color(0xFFDFF5E4)],
            blur: 18,
          ),
        ),
        // 중앙 은은한 유리 효과
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 240,
                  height: 240,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Size size, List<Color> colors, {double blur = 12}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size.width),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: colors,
              radius: 0.85,
            ),
          ),
        ),
      ),
    );
  }
}

/// 유리(Glass) 카드 풍의 냉장고 일러스트
class _FridgeCard extends StatelessWidget {
  const _FridgeCard({required this.card, required this.text});
  final Color card;
  final Color text;

  @override
  Widget build(BuildContext context) {
    const doorBorder = Color(0x11000000);
    const shelfColor = Color(0x14000000);
    const bottle = Color(0xFFB7E4C7);
    const bottleCap = Color(0xFF74C69D);
    const carrot = Color(0xFFFFC8A2);
    const carrotLeaf = Color(0xFF8BD49A);
    const egg = Color(0xFFF5F5F5);
    const memo = Color(0xFFFFF1C4);
    const magnetBlue = Color(0xFFBFD7FF);
    const magnetPink = Color(0xFFFFC7D6);

    return Container(
      width: 178,
      height: 214,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: doorBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 상단 하이라이트(빛 반사)
          Positioned(
            left: 12,
            right: 12,
            top: 10,
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.7),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 문짝 안쪽 가스켓(안쪽 라인)
          Positioned.fill(
            left: 8,
            right: 8,
            top: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
            ),
          ),

          // 냉장실/냉동실 경계
          Positioned(
            top: 124,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black.withOpacity(0.08)),
          ),

          // ───── 내부 선반(두 줄)
          Positioned(
            top: 70,
            left: 18,
            right: 18,
            child: Container(height: 2, color: shelfColor),
          ),
          Positioned(
            top: 96,
            left: 18,
            right: 18,
            child: Container(height: 2, color: shelfColor),
          ),

          // ───── 내부 소품: 병
          Positioned(
            top: 58,
            left: 26,
            child: _bottle(bottle, bottleCap),
          ),

          // ───── 내부 소품: 당근
          Positioned(
            top: 86,
            right: 28,
            child: _carrot(carrot, carrotLeaf),
          ),

          // ───── 내부 소품: 달걀
          Positioned(
            top: 86,
            left: 70,
            child: _egg(egg),
          ),

          // 손잡이 (상/하)
          Positioned(right: 14, top: 64, child: _handle(text)),
          Positioned(right: 14, top: 158, child: _handle(text, small: true)),

          // ───── 문짝 데코: 메모지 + 자석
          Positioned(
            top: 34,
            right: 48,
            child: _memoNote(memo),
          ),
          // 자석 점 2개
          Positioned(top: 28, right: 38, child: _magnetDot(magnetBlue)),
          Positioned(top: 46, right: 62, child: _magnetDot(magnetPink)),

          // 작은 브랜드 배지
          Positioned(
            left: 14,
            top: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'RECIFIT',
                style: TextStyle(
                  letterSpacing: 1.1,
                  fontSize: 9,
                  color: text.withOpacity(0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // 하단 발(다리)
          Positioned(
            bottom: -4,
            left: 28,
            child: _foot(),
          ),
          Positioned(
            bottom: -4,
            right: 28,
            child: _foot(),
          ),

          // 하단 살짝 그림자
          Positioned(
            left: 10,
            right: 10,
            bottom: -10,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======= 작은 파츠들 =======

  Widget _handle(Color text, {bool small = false}) {
    return Container(
      width: 3,
      height: small ? 26 : 32,
      decoration: BoxDecoration(
        color: text,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _bottle(Color body, Color cap) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 6,
          decoration: BoxDecoration(
            color: cap,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 14,
          height: 22,
          decoration: BoxDecoration(
            color: body,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _carrot(Color body, Color leaf) {
    return Row(
      children: [
        // 잎
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: leaf,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 3),
        // 몸통(삼각 느낌)
        Transform.rotate(
          angle: -0.3,
          child: Container(
            width: 16,
            height: 10,
            decoration: BoxDecoration(
              color: body,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _egg(Color c) {
    return Container(
      width: 14,
      height: 18,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
    );
  }

  Widget _memoNote(Color c) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        width: 30,
        height: 22,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 10,
            height: 6,
            margin: const EdgeInsets.only(right: 3, bottom: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.08),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _magnetDot(Color c) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  Widget _foot() {
    return Container(
      width: 22,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.12),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}