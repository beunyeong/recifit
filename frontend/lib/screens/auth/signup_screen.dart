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

    // 본체
    final left = size.width * 0.18;
    final top = size.height * 0.12;
    final w = size.width * 0.64;
    final h = size.height * 0.76;
    final r = Radius.circular(s * 0.15);

    final body = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, w, h), r);
    canvas.drawRRect(body, line);

    // 구분선
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

    // 손잡이(세로)
    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW * 0.9
      ..strokeCap = StrokeCap.round;

    final hx = left + w - s * 0.22;
    canvas.drawLine(Offset(hx, top + s * 0.15), Offset(hx, top + s * 0.28), handlePaint);
    canvas.drawLine(Offset(hx, dividerY + s * 0.15), Offset(hx, dividerY + s * 0.35), handlePaint);

    // 손잡이 끝 점
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(hx, top + s * 0.21), strokeW * 0.3, dotPaint);
    canvas.drawCircle(Offset(hx, dividerY + s * 0.25), strokeW * 0.3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _MinimalFridgePainter old) => old.color != color;
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();

  final RegExp passwordRe =
  RegExp(r'^(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-\+=]).{8,12}$');

  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack)),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _nickname.dispose();
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final success = await ApiService.instance.signup(
        email: _email.text.trim(),
        password: _password.text.trim(),
        nickname: _nickname.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('회원가입 성공! 로그인 해주세요.'),
            backgroundColor: _buttonGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      setState(() => _error = e.toString());
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
          title: Text('회원가입',
              style: TextStyle(color: _darkText, fontWeight: FontWeight.w600, fontSize: 18)),
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
                          _buildBrandHeader(),
                          const SizedBox(height: 40),
                          _buildSignupForm(),
                          const SizedBox(height: 20),
                          _buildLoginLink(),
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
          "시작할 준비 되셨나요?",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: _darkText, letterSpacing: -0.5),
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
          BoxShadow(color: _buttonGreen.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Center(child: MinimalFridgeIcon(size: 24, color: _buttonGreen)),
    );
  }

  Widget _buildSignupForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _warmWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8)),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return '이메일을 입력해주세요';
                if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _password,
              label: '비밀번호',
              hint: '영문 소문자, 숫자, 특수문자 포함 8~12자',
              icon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _grayText),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (value) {
                final p = (value ?? '').trim();
                if (p.isEmpty) return '비밀번호를 입력해주세요';
                if (!passwordRe.hasMatch(p)) {
                  return '비밀번호는 영문 소문자, 숫자, 특수문자를 포함한 8~12자여야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _nickname,
              label: '닉네임',
              hint: '사용할 닉네임을 입력해주세요',
              icon: Icons.person_outlined,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _loading ? null : _signup(),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) return '닉네임을 입력해주세요';
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
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error!, style: TextStyle(color: Colors.red.shade600, fontSize: 14)),
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
                onPressed: _loading ? null : _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  disabledBackgroundColor: _grayText.withOpacity(0.3),
                ),
                child: _loading
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                    SizedBox(width: 12),
                    Text('가입 중...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                )
                    : const Text('회원가입', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
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
    String? Function(String?)? validator,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    void Function(String)? onFieldSubmitted,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _darkText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, color: _darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _grayText.withOpacity(0.6), fontSize: 15),
            prefixIcon: Icon(icon, color: _grayText, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _lightGray.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _buttonGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFE57373), width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('이미 계정이 있나요? ', style: TextStyle(color: _grayText, fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text('로그인',
              style: TextStyle(color: _buttonGreen, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}