import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:recifit_app/services/api_service.dart';
import 'package:recifit_app/screens/main/splash_screen.dart';
import 'package:recifit_app/screens/auth/login_screen.dart';
import 'package:recifit_app/screens/auth/signup_screen.dart';
import 'package:recifit_app/screens/auth/oauth_callback_screen.dart';
import 'package:recifit_app/screens/main/main_screen.dart';
import 'package:recifit_app/screens/ingredient/ingredient_add_screen.dart';
import 'package:recifit_app/screens/mypage/recipe_recommend_screen.dart';
import 'package:recifit_app/screens/mypage/mypage_placeholder.dart';
import 'package:recifit_app/screens/mypage/coming_soon_screen.dart';
import 'package:recifit_app/screens/community/community_screen.dart';
import 'package:recifit_app/screens/mypage/recipe_memo_list_screen.dart';
import 'package:recifit_app/screens/community/write_post_screen.dart';
import 'package:recifit_app/screens/community/post_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    javaScriptAppKey: const String.fromEnvironment('KAKAO_JS_KEY'),
  );

  await ApiService.instance.init();

  runApp(const RecifitApp());
}

class RecifitApp extends StatelessWidget {
  const RecifitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recifit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2ECC71)),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/oauth': (_) => const OAuthCallbackScreen(),
        '/main': (_) => const MainScreen(),
        '/add': (_) => const IngredientAddScreen(),
        '/recommendation': (_) => const RecipeRecommendScreen(),
        '/mypage': (_) => const MyPagePlaceholder(),
        '/coming': (_) => const ComingSoonScreen(title: '현재 준비중'),
        '/community': (_) => const CommunityScreen(),
        '/memos': (_) => const RecipeMemoListScreen(),
        '/write-post': (_) => const WritePostScreen(),
        '/post-detail': (_) => const PostDetailScreen(),
      },
    );
  }
}