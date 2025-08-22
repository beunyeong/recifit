import 'dart:async' show unawaited;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MemberType { SINGLE, COUPLE, FAMILY, HOBBYIST, PET_OWNER }
enum CookingLevel { BEGINNER, INTERMEDIATE, ADVANCED }
enum PostCategory { RECIPE, TIP }

extension _PostMap on Map {
  String s(String key, [String def = '']) => (this[key] ?? def).toString();
  int i(String key, [int def = 0]) => int.tryParse('${this[key] ?? def}') ?? def;
}

class ApiService {

  // JWT 전체 클레임 (있으면)
  Map<String, dynamic>? get currentClaims {
    if (_accessToken == null) return null;
    try {
      return JwtDecoder.decode(_accessToken!);
    } catch (_) {
      return null;
    }
  }

  // 닉네임/이메일 등 보조 비교용
  String? get currentNickname {
    final c = currentClaims;
    final n = c?['nickname'] ?? c?['name'] ?? c?['username'];
    return n is String ? n : null;
  }

  String? get currentEmail {
    final c = currentClaims;
    final e = c?['email'];
    return e is String ? e : null;
  }

  ApiService._();
  static final instance = ApiService._();

  // 웹/ios는 localhost, 안드로이드는 10.0.2.2
  // flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8080
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  String? _accessToken;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken?.isNotEmpty == true;

  int? get currentMemberId {
    if (_accessToken == null) return null;
    try {
      final decoded = JwtDecoder.decode(_accessToken!);
      final id = decoded['memberId'] ?? decoded['id'] ?? decoded['sub'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
      return null;
    } catch (_) {
      return null;
    }
  }

  // 앱 시작 시 토큰 복원
  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString('accessToken');
    if (t != null && t.isNotEmpty) setAccessToken(t);
  }

  Future<void> _persistToken(String? token) async {
    final sp = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await sp.remove('accessToken');
    } else {
      await sp.setString('accessToken', token);
    }
  }

  void setAccessToken(String token) {
    _accessToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    unawaited(_persistToken(token));
  }

  void clearAccessToken() {
    _accessToken = null;
    _dio.options.headers.remove('Authorization');
    unawaited(_persistToken(null));
  }

  // ----------------- 인증 -----------------
  Future<String> login(String email, String password) async {
    try {
      final res = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      if ((res.statusCode ?? 500) >= 300) {
        throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
      }
      final data = res.data;
      final token = (data is Map)
          ? (data['data']?['accessToken'] ?? data['accessToken'])
          : null;
      if (token is String && token.isNotEmpty) {
        setAccessToken(token);
        return token;
      }
      throw Exception('로그인 응답에 accessToken이 없습니다: $data');
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final res = await _dio.post('/api/auth/signup', data: {
        'email': email, 'password': password, 'nickname': nickname,
      });
      if ((res.statusCode ?? 500) >= 300) {
        throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
      }
      return true;
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  // ----------------- 커뮤니티 게시글 -----------------
  Future<List<Map<String, dynamic>>> fetchPosts({
    PostCategory? category,
    bool mine = false,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final query = <String, dynamic>{
      if (category != null) 'postCategory': category.name, // RECIPE/TIP
      if (mine) 'mine': true,
      'page': page,
      'size': size,
      'sort': sort,
    };

    final resp = await _dio.get('/posts', queryParameters: query);

    // 구조: { code, message, data: { content: [...], ... } }
    final raw = resp.data;
    final unwrapped = (raw is Map) ? (raw['data'] ?? raw) : raw;

    if (unwrapped is List) {
      return unwrapped.cast<Map<String, dynamic>>();
    }

    if (unwrapped is Map && unwrapped['content'] is List) {
      return (unwrapped['content'] as List).cast<Map<String, dynamic>>();
    }

    return const <Map<String, dynamic>>[];
  }

  // 페이지 메타 필요 시
  Future<({
  List<Map<String, dynamic>> content,
  int totalElements,
  int totalPages,
  int number,
  int size,
  bool last,
  })> fetchPostsPaged({
    PostCategory? category,
    bool mine = false,
    int page = 0,
    int size = 20,
    String sort = 'createdAt,desc',
  }) async {
    final query = <String, dynamic>{
      if (category != null) 'postCategory': category.name,
      if (mine) 'mine': true,
      'page': page,
      'size': size,
      'sort': sort,
    };

    final resp = await _dio.get('/posts', queryParameters: query);

    final raw = resp.data;
    final unwrapped = (raw is Map) ? (raw['data'] ?? raw) : raw;

    if (unwrapped is List) {
      return (
      content: unwrapped.cast<Map<String, dynamic>>(),
      totalElements: unwrapped.length,
      totalPages: 1,
      number: 0,
      size: unwrapped.length,
      last: true,
      );
    }

    if (unwrapped is Map && unwrapped['content'] is List) {
      return (
      content: (unwrapped['content'] as List).cast<Map<String, dynamic>>(),
      totalElements: (unwrapped['totalElements'] ?? 0) as int,
      totalPages: (unwrapped['totalPages'] ?? 1) as int,
      number: (unwrapped['number'] ?? page) as int,
      size: (unwrapped['size'] ?? size) as int,
      last: (unwrapped['last'] ?? false) as bool,
      );
    }

    return (
    content: const <Map<String, dynamic>>[],
    totalElements: 0,
    totalPages: 0,
    number: 0,
    size: size,
    last: true,
    );
  }

  // 게시글 등록
  Future<Map<String, dynamic>> addPost({
    required PostCategory category,
    required String title,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.post('/posts/add', data: {
        'postCategory': category.name,
        'title': title,
        'content': content,
      });

      final status = res.statusCode ?? 500;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }

      final body = res.data; // CommonResponseDto 가정
      final data = (body is Map) ? (body['data'] ?? body) : body;
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  // 게시글 수정
  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.patch('/posts/$postId', data: {
        'title': title,
        'content': content,
      });

      final status = res.statusCode ?? 500;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }

      final body = res.data;
      final data = (body is Map) ? (body['data'] ?? body) : body;
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  // 게시글 삭제
  Future<void> deletePost(int postId) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.delete('/posts/$postId');
      final status = res.statusCode ?? 500;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }
    } on DioException catch (e) {
      throw Exception(
        'HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}',
      );
    }
  }

  // ----------------- 공공데이터 재료 검색 -----------------
  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    final res = await _dio.get('/api/ingredients/search', queryParameters: {'query': query});
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final data = res.data;
    if (data is! List) return <Map<String, dynamic>>[];

    return data.map<Map<String, dynamic>>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final name = m['foodNmKr'] ?? m['foodName'] ?? m['식품명'] ?? m['name'] ?? '-';
      final category = m['dbGrpNm'] ?? m['groupName'] ?? m['식품 그룹명'] ?? m['category'] ?? '기타';
      final code = m['foodCd'] ?? m['식품코드'];
      return {...m, 'name': name, 'category': category, if (code != null) 'code': code};
    }).toList();
  }

  // 게시글 단건 조회
  Future<Map<String, dynamic>> fetchPost(int postId) async {
    final res = await _dio.get('/posts/$postId');
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final raw = res.data;
    final data = (raw is Map) ? (raw['data'] ?? raw) : raw;

    // 서버가 PostResponseDto 한 건을 내려줌
    if (data is Map<String, dynamic>) return data;

    throw Exception('Unexpected response for GET /posts/$postId: $data');
  }

  // ----------------- 내 재료 (인증 필요) -----------------
  Future<void> addIngredient({
    required String ingredientName,
    required String description,
    required String storageLocation,
    required DateTime storageDate,
    required DateTime expirationDate,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.post('/api/ingredients/add', data: {
        'ingredientName': ingredientName,
        'description': description,
        'storageLocation': storageLocation,
        'storageDate': storageDate.toIso8601String().split('T').first,
        'expirationDate': expirationDate.toIso8601String().split('T').first,
      });
      if ((res.statusCode ?? 500) >= 300) {
        throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
      }
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  Future<void> deleteIngredient(int id) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    final res = await _dio.delete('/api/ingredients/$id');

    final status = res.statusCode ?? 500;
    if (status == 204) return; // No Content도 정상
    if (status >= 300) {
      throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyIngredients() async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    final res = await _dio.get('/api/ingredients/my');
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final data = res.data;
    if (data is! List) return <Map<String, dynamic>>[];

    return data.map<Map<String, dynamic>>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      final normalized = {
        ...m,
        'name': m['ingredientName'] ?? m['name'] ?? '-',
        'category': m['description'] ?? '기타',
        'remainingDays': m['remainingDays'] ?? m['daysLeft'],
      };
      return normalized;
    }).toList();
  }

  // ----------------- AI 레시피 추천 (인증 필요) -----------------
  Future<String> recommendRecipes({
    MemberType memberType = MemberType.SINGLE,
    CookingLevel cookingLevel = CookingLevel.BEGINNER,
    List<String> expiringIngredients = const [],
    List<String>? availableIngredients,
    String? recipeId,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');

    final payload = <String, dynamic>{
      'memberType': memberType.name,
      'cookingLevel': cookingLevel.name,
      'expiringIngredients': expiringIngredients,
      'availableIngredients': availableIngredients ?? [],
      if (recipeId != null) 'recipeId': recipeId,
    };

    debugPrint('Auth header = ${_dio.options.headers['Authorization']}');

    final res = await _dio.post('/api/recipes/recommendations', data: payload);
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }

    final data = res.data;
    final content = (data is Map) ? (data['data'] ?? data['content'] ?? data['message']) : data;
    return content is String ? content : content.toString();
  }

  // ----------------- 기타 -----------------
  Future<List<Map<String, dynamic>>> fetchIngredients({String? query}) async {
    final q = (query ?? '').trim();
    return searchIngredients(q);
  }

  Future<bool> ping() async {
    try {
      final res = await _dio.get('/actuator/health');
      return (res.statusCode ?? 500) < 400;
    } catch (_) {
      return false;
    }
  }
}