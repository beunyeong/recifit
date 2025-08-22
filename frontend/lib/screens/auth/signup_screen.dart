import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();

  final RegExp passwordRe = RegExp(
    r'^(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-\+=]).{8,12}$',
  );

  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Color get _backgroundBeige => const Color(0xFFF7F5F3);
  Color get _warmWhite => const Color(0xFFFFFFFE);
  Color get _softGreen => const Color(0xFFB8E6B8);
  Color get _peachPink => const Color(0xFFFFD4C4);
  Color get _lightYellow => const Color(0xFFFFF2C7);
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
          '회원가입',
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildWelcomeSection(),
              const SizedBox(height: 40),
              _buildSignupForm(),
              const SizedBox(height: 20),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _warmWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.kitchen_outlined,
                  size: 40,
                  color: _buttonGreen,
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _grayText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          "Recifit에 오신 걸 환영해요!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _darkText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "냉장고 속 재료로 맛있는 요리를 시작해보세요",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: _grayText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
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
          ),
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
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: _grayText,
                ),
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
              onFieldSubmitted: (_) => _loading ? null : _signup(), // 엔터로 가입 하기
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
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 14,
                        ),
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
                onPressed: _loading ? null : _signup,
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
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '가입 중...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
                    : const Text(
                  '회원가입',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 16,
            color: _darkText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: _grayText.withOpacity(0.6),
              fontSize: 15,
            ),
            prefixIcon: Icon(icon, color: _grayText, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _lightGray.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _buttonGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
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
        Text(
          '이미 계정이 있나요? ',
          style: TextStyle(
            color: _grayText,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(
            '로그인',
            style: TextStyle(
              color: _buttonGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}