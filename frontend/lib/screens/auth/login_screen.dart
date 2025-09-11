import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class MinimalFridgeIcon extends StatelessWidget {
  final double size;
  final Color color;

  const MinimalFridgeIcon({
    super.key,
    this.size = 40,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MinimalFridgePainter(color: color)),
    );
  }
}

class _MinimalFridgePainter extends CustomPainter {
  final Color color;
  _MinimalFridgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final strokeW = s * 0.06;

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final left = size.width * 0.18;
    final top = size.height * 0.12;
    final w = size.width * 0.64;
    final h = size.height * 0.76;
    final r = Radius.circular(s * 0.15);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      r,
    );
    canvas.drawRRect(body, line);

    // 냉동/냉장 구분선
    final dividerY = top + h * 0.4;
    final dividerLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(left + s * 0.08, dividerY),
      Offset(left + w - s * 0.08, dividerY),
      dividerLine,
    );

    // 손잡이 디자인
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.9
      ..strokeCap = StrokeCap.round;

    final hx = left + w - s * 0.22;

    // 위(냉동실) 손잡이
    canvas.drawLine(
      Offset(hx, top + s * 0.15),
      Offset(hx, top + s * 0.28),
      handlePaint,
    );

    // 아래(냉장실) 손잡이
    canvas.drawLine(
      Offset(hx, dividerY + s * 0.15),
      Offset(hx, dividerY + s * 0.35),
      handlePaint,
    );

    // 손잡이 끝에 작은 원형 손잡이
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(hx, top + s * 0.21),
      strokeW * 0.3,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(hx, dividerY + s * 0.25),
      strokeW * 0.3,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimalFridgePainter old) => old.color != color;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
          ),
        );
    _controller.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 팔레트
  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _darkText => const Color(0xFF2C2C2C);
  Color get _grayText => const Color(0xFF666666);
  Color get _buttonGreen => const Color(0xFF4CAF50);
  Color get _lightGray => const Color(0xFFF0F0F0);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.instance.login(_email.text.trim(), _password.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('로그인 성공!'),
          backgroundColor: _buttonGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _kakaoLogin() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.instance.startKakaoLoginWeb();
    } catch (e) {
      setState(() => _error = '카카오 로그인 시작 실패: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _backgroundBeige,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _darkText),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '로그인',
            style: TextStyle(
              color: _darkText,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildWelcomeBack(),
                          const SizedBox(height: 40),
                          _buildLoginForm(),
                          const SizedBox(height: 12),
                          _buildKakaoButton(),
                          const SizedBox(height: 20),
                          _buildSignupLink(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badgeRingMinimal(),
            const SizedBox(width: 10),
            Text(
              "ReciFit",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _buttonGreen,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          "스마트한 냉장고 관리의 시작",
          style: TextStyle(fontSize: 14, color: _grayText, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 28),
        Text(
          "다시 만나서 반가워요!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _darkText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "로그인하여 냉장고를 확인해보세요",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: _grayText, height: 1.4),
        ),
      ],
    );
  }

  Widget _badgeRingMinimal() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _buttonGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: _buttonGreen.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: MinimalFridgeIcon(size: 24, color: _buttonGreen),
      ),
    );
  }

  Widget _buildWelcomeBack() {
    return _buildBrandHeader();
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField(
              controller: _email,
              label: '이메일',
              hint: 'example@recifit.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return '이메일을 입력해주세요';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _password,
              label: '비밀번호',
              hint: '비밀번호를 입력해주세요',
              icon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: _grayText,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                final password = value ?? '';
                if (password.isEmpty) return '비밀번호를 입력해주세요';
                if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다';
                return null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(
                            color: Colors.red.shade600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: _grayText.withOpacity(0.3),
                ),
                child: _loading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('로그인 중...',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.login, size: 20),
                    SizedBox(width: 8),
                    Text('로그인',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKakaoButton() {
    const double btnHeight = 52;
    const double radius = 12;

    return Semantics(
      button: true,
      label: '카카오로 로그인',
      child: Opacity(
        opacity: _loading ? 0.6 : 1.0,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: _loading ? null : _kakaoLogin,
            borderRadius: BorderRadius.circular(radius),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SizedBox(
                width: double.infinity,
                height: btnHeight,
                child: Center(
                  child: Image.asset(
                    'assets/images/kakao_login_medium_wide.png',
                    height: btnHeight,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final dark = const Color(0xFF2C2C2C);
    final gray = const Color(0xFF666666);
    final light = const Color(0xFFF0F0F0);
    final green = const Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: dark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16, color: dark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: gray.withOpacity(0.6), fontSize: 15),
            prefixIcon: Icon(icon, color: gray, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: light.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: green, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFE57373), width: 1),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupLink() {
    final green = const Color(0xFF4CAF50);
    final gray = const Color(0xFF666666);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('계정이 없나요? ', style: TextStyle(color: gray, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/signup'),
          child: Text('회원가입',
              style: TextStyle(
                  color: green, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}