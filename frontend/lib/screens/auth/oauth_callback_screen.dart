import 'package:flutter/material.dart';
import 'package:recifit_app/services/api_service.dart';

class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({super.key});

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _handle();
  }

  Future<void> _handle() async {
    final uri = Uri.base;
    final error = uri.queryParameters['error'];
    if (error != null) {
      setState(() => _error = '카카오 오류: $error');
      return;
    }
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      setState(() => _error = '인가 코드가 없습니다.');
      return;
    }
    try {
      await ApiService.instance.exchangeKakaoCode(code);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '로그인 처리 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('로그인 오류')),
        body: Center(child: Text(_error!, textAlign: TextAlign.center)),
      );
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
