// ignore: unused_import
import 'dart:io'; 
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late Dio _dio;
  final _storage = const FlutterSecureStorage();

  // ⚠️ CẤU HÌNH ĐỊA CHỈ API:
  // Lưu ý: Nếu chạy máy ảo Android hãy đổi localhost thành 10.0.2.2
  //static const String baseUrl = 'http://localhost:5098/api';
  static const String baseUrl = 'http://103.123.456.78:5098/api';
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Tự động gắn Token vào mỗi request nếu đã đăng nhập
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // 1. Hàm Đăng nhập
  Future<Response?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/Auth/login',
        data: {'email': email, 'password': password},
      );
      return response;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return null;
    }
  }

  // 2. Hàm Đăng ký (POST /Auth/register)
  Future<Response?> register(String email, String password, String fullName) async {
    try {
      final response = await _dio.post(
        '/Auth/register',
        data: {
          'email': email, 
          'password': password,
          'fullName': fullName
        },
      );
      return response;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      if (e is DioException) {
        return e.response;
      }
      return null;
    }
  }

  // 3. Hàm Lấy thông tin cá nhân
  Future<Response?> getUserInfo() async {
    try {
      final response = await _dio.get('/Auth/me');
      return response;
    } catch (e) {
      print('Lỗi lấy thông tin User: $e');
      return null;
    }
  }

  // 4. Hàm lưu Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // 5. Hàm đăng xuất
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  // 6. Hàm Nạp tiền
  Future<bool> depositMoney(double amount) async {
    try {
      final response = await _dio.post('/Wallet/deposit', data: {
        'amount': amount
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi nạp tiền: $e');
      return false;
    }
  }

  // 7. Hàm Lấy danh sách sân
  Future<List<dynamic>> getCourts() async {
    try {
      final response = await _dio.get('/Court');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách sân: $e');
      return [];
    }
  }

  // 8. Hàm Đặt sân (Booking)
  Future<String> bookCourt(int courtId, DateTime date, int start, int end) async {
    try {
      final response = await _dio.post('/Booking/book', data: {
        'courtId': courtId,
        'bookingDate': date.toIso8601String(),
        'startHour': start,
        'endHour': end
      });
      
      if (response.statusCode == 200) {
        return "SUCCESS";
      }
      return "Lỗi không xác định";
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ?? "Lỗi đặt sân";
      }
      return "Lỗi kết nối Server";
    }
  }

  // 9. Lấy lịch sử đặt sân
  Future<List<dynamic>> getMyBookings() async {
    try {
      final response = await _dio.get('/Booking/my-bookings');
      return response.statusCode == 200 ? response.data : [];
    } catch (e) {
      return [];
    }
  }

  // 10. Lấy danh sách giải đấu
  Future<List<dynamic>> getTournaments() async {
    try {
      final response = await _dio.get('/Tournament');
      return response.statusCode == 200 ? response.data : [];
    } catch (e) {
      return [];
    }
  }

  // 11. Đăng ký tham gia giải đấu (POST /api/Tournament/register/{id})
  Future<String> registerTournament(int tournamentId) async {
    try {
      final response = await _dio.post('/Tournament/register/$tournamentId');
      if (response.statusCode == 200) {
        return "SUCCESS";
      }
      return "Lỗi đăng ký không xác định";
    } on DioException catch (e) {
      // Bắt lỗi từ Backend (Ví dụ: "Số dư không đủ! Cần 500.000đ để tham gia")
      if (e.response != null && e.response!.data != null) {
        return e.response!.data['message'] ?? "Lỗi khi đăng ký giải đấu";
      }
      return "Lỗi kết nối đến Server";
    }
  }

  // --- MỚI THÊM: 12. Lấy danh sách Tin tức (GET /api/News) ---
  Future<List<dynamic>> getNews() async {
    try {
      final response = await _dio.get('/News');
      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print('Lỗi lấy danh sách tin tức: $e');
      return [];
    }
  }
  // 13. Tạo giải đấu mới
  Future<bool> createTournament(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/Tournament/create', data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi tạo giải: $e');
      return false;
    }
  }

  // 14. Lấy danh sách thành viên để thách đấu
  Future<List<dynamic>> getAllMembers() async {
    try {
      final response = await _dio.get('/Auth/members');
      return response.statusCode == 200 ? response.data : [];
    } catch (e) {
      return [];
    }
  }
  // 15. Gửi lời thách đấu
  Future<bool> sendChallenge(String receiverId, String receiverName) async {
    try {
      final response = await _dio.post('/Challenge/send', data: {
        "receiverId": receiverId,
        "receiverName": receiverName
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 16. Lấy danh sách lời thách đấu (Để hiển thị thông báo)
  Future<List<dynamic>> getIncomingChallenges() async {
    try {
      final response = await _dio.get('/Challenge/my-challenges');
      return response.statusCode == 200 ? response.data : [];
    } catch (e) {
      return [];
    }
  }
}