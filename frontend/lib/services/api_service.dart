import 'dart:async' show unawaited;
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';

enum MemberType { SINGLE, COUPLE, FAMILY, HOBBYIST, PET_OWNER }
enum CookingLevel { BEGINNER, INTERMEDIATE, ADVANCED }
enum PostCategory { RECIPE, TIP }

class ApiService {
  ApiService._();
  static final instance = ApiService._();

  // 백엔드 주소
  static const String _defaultBaseUrl =
  String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  // 카카오 REST API 키(인가 코드 발급용)
  static const String _kakaoRestApiKey =
  String.fromEnvironment('KAKAO_REST_API_KEY', defaultValue: '');

  // 웹 Redirect URI (콘솔 등록값과 정확히 일치)
  static const String _webRedirectUri =
  String.fromEnvironment('KAKAO_WEB_REDIRECT_URI', defaultValue: 'http://localhost:3000/oauth');

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _defaultBaseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  String? _accessToken;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken?.isNotEmpty == true;

  // (선택) JWT 디코드 사용 시
  Map<String, dynamic>? get currentClaims {
    final t = _accessToken;
    if (t == null) return null;
    try { return JwtDecoder.decode(t); } catch (_) { return null; }
  }
  String? get currentEmail => currentClaims?['email'] as String?;
  String? get currentNickname =>
      (currentClaims?['nickname'] ?? currentClaims?['name'] ?? currentClaims?['username']) as String?;
  int? get currentMemberId {
    final raw = currentClaims?['memberId'] ?? currentClaims?['id'] ?? currentClaims?['sub'];
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final t = sp.getString('accessToken');
    if (t != null && t.isNotEmpty) setAccessToken(t);
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

  Future<void> _persistToken(String? token) async {
    final sp = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await sp.remove('accessToken');
    } else {
      await sp.setString('accessToken', token);
    }
  }

  // ---------------- 이메일/비번 로그인 ----------------
  Future<String> login(String email, String password) async {
    final res = await _dio.post('/api/auth/login', data: {
      'email': email, 'password': password,
    });
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final body = res.data;
    final data = (body is Map) ? body['data'] : null;
    final access = (data is Map) ? data['accessToken'] : null;
    if (access is String && access.isNotEmpty) {
      setAccessToken(access);
      return access;
    }
    throw Exception('로그인 응답에 accessToken이 없습니다: $body');
  }

  // ① 카카오 인가 코드 받으러 이동(웹)
  Future<void> startKakaoLoginWeb() async {
    await AuthCodeClient.instance.authorize(
      clientId: _kakaoRestApiKey,                    // REST API 키
      redirectUri: _webRedirectUri,                  // http://localhost:3000/oauth
      scopes: const ['profile_nickname','profile_image','account_email'],
    );
  }

  // ② /oauth에서 받은 code를 서버에 교환
  Future<String> exchangeKakaoCode(String code) async {
    final res = await _dio.post('/api/auth/login/kakao', queryParameters: {'code': code});
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final body = res.data; // CommonResponseDto<LoginResponseDto>
    final data = (body is Map) ? body['data'] : null;
    final access = (data is Map) ? data['accessToken'] : null;

    if (access is String && access.isNotEmpty) {
      setAccessToken(access);
      return access;
    }
    throw Exception('카카오 로그인 응답에 accessToken이 없습니다: $body');
  }

  // ---------------- 회원가입 ----------------
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

// ---------------- 커뮤니티/재료 등 나머지 API ----------------

// 1) 리스트형(비페이지)
  Future<List<Map<String, dynamic>>> fetchPosts({
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
      return unwrapped
          .cast<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (unwrapped is Map && unwrapped['content'] is List) {
      return (unwrapped['content'] as List)
          .cast<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

// 2) 페이지형 - CommunityScreen에서 사용하는 메서드
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

    // 1) 응답이 List인 경우(비페이지 응답)
    if (unwrapped is List) {
      final list = unwrapped
          .cast<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return (
      content: list,
      totalElements: list.length,
      totalPages: 1,
      number: 0,
      size: list.length,
      last: true,
      );
    }

    // 2) Spring Page 형태인 경우
    if (unwrapped is Map && unwrapped['content'] is List) {
      final contentList = (unwrapped['content'] as List)
          .cast<Map>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      return (
      content: contentList,
      totalElements: (unwrapped['totalElements'] ?? 0) as int,
      totalPages: (unwrapped['totalPages'] ?? 1) as int,
      number: (unwrapped['number'] ?? page) as int,
      size: (unwrapped['size'] ?? size) as int,
      last: (unwrapped['last'] ?? false) as bool,
      );
    }

    // 3) 예외 케이스
    return (
    content: const <Map<String, dynamic>>[],
    totalElements: 0,
    totalPages: 0,
    number: 0,
    size: size,
    last: true,
    );
  }

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
      final body = res.data;
      final data = (body is Map) ? (body['data'] ?? body) : body;
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  Future<Map<String, dynamic>> updatePost({
    required int postId,
    required String title,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.patch('/posts/$postId', data: {
        'title': title, 'content': content,
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

  Future<void> deletePost(int postId) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.delete('/posts/$postId');
      final status = res.statusCode ?? 500;
      if (status == 204) return;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments({
    required int postId,
    bool mine = false,
  }) async {
    final res = await _dio.get('/posts/$postId/comments', queryParameters: { if (mine) 'mine': true });
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final raw = res.data;
    final data = (raw is Map) ? (raw['data'] ?? raw) : raw;
    if (data is List) {
      return data.cast<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>> addComment({
    required int postId,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.post('/posts/$postId/comments', data: {'content': content});
      final status = res.statusCode ?? 500;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }
      final raw = res.data;
      final data = (raw is Map) ? (raw['data'] ?? raw) : raw;
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  Future<Map<String, dynamic>> updateComment({
    required int postId,
    required int commentId,
    required String content,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.patch(
        '/posts/$postId/comments/$commentId',
        data: {'content': content},
      );
      final status = res.statusCode ?? 500;
      if (status >= 300) {
        throw Exception('HTTP $status ${res.requestOptions.uri}\n${res.data}');
      }
      final raw = res.data;
      final data = (raw is Map) ? (raw['data'] ?? raw) : raw;
      if (data is Map<String, dynamic>) return data;
      return {'raw': data};
    } on DioException catch (e) {
      throw Exception('HTTP ${e.response?.statusCode} ${e.requestOptions.uri}\n${e.response?.data}');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    if (!isLoggedIn) throw Exception('로그인이 필요합니다');
    try {
      final res = await _dio.delete('/posts/$postId/comments/$commentId');

      // 백엔드가 200 OK + data:null 로 내려보내므로 2xx는 모두 성공 처리
      final status = res.statusCode ?? 500;
      if (status >= 300) {
        // 서버 표준 응답(예: CommonResponseDto)에서 메시지 뽑기
        final msg = _extractServerMessage(res.data) ?? '댓글 삭제에 실패했어요.';
        throw Exception('HTTP $status ${res.requestOptions.uri}\n$msg');
      }
      return;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = _extractServerMessage(e.response?.data) ??
          'HTTP $status ${e.requestOptions.uri}\n${e.response?.data}';
      throw Exception(msg);
    }
  }

  // 서버 표준 응답에서 message / errorMessage를 뽑아주는 헬퍼
  String? _extractServerMessage(dynamic raw) {
    if (raw is Map) {
      final m = raw['message'] ?? raw['errorMessage'] ?? raw['error'] ?? raw['msg'];
      if (m is String && m.isNotEmpty) return m;
      final data = raw['data'];
      if (data is Map) {
        final dm = data['message'] ?? data['errorMessage'];
        if (dm is String && dm.isNotEmpty) return dm;
      }
    }
    return null;
  }

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

  Future<Map<String, dynamic>> fetchPost(int postId) async {
    final res = await _dio.get('/posts/$postId');
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }
    final raw = res.data;
    final data = (raw is Map) ? (raw['data'] ?? raw) : raw;
    if (data is Map<String, dynamic>) return data;
    throw Exception('Unexpected response for GET /posts/$postId: $data');
  }

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
    if (status == 204) return;
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

    final res = await _dio.post('/api/recipes/recommendations', data: payload);
    if ((res.statusCode ?? 500) >= 300) {
      throw Exception('HTTP ${res.statusCode} ${res.requestOptions.uri}\n${res.data}');
    }

    final data = res.data;
    final content = (data is Map) ? (data['data'] ?? data['content'] ?? data['message']) : data;
    return content is String ? content : content.toString();
  }

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