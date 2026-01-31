import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để format tiền
import 'package:pcm_mobile/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Hàm lấy thông tin cá nhân từ Server
  Future<void> _loadProfile() async {
    final response = await _apiService.getUserInfo();
    if (mounted) {
      setState(() {
        if (response != null && response.statusCode == 200) {
          _userData = response.data;
        }
        _isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin cá nhân")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text("Không tải được thông tin"))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blueAccent, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Tên & Email (Dữ liệu thật)
                      Text(
                        _userData!['fullName'] ?? "Người dùng",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _userData!['email'] ?? "",
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 30),

                      // Thẻ thông tin chi tiết
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              _buildInfoTile(Icons.star, "Hạng thành viên", _userData!['rankLevel'] ?? "Standard", Colors.orange),
                              const Divider(height: 1),
                              _buildInfoTile(Icons.account_balance_wallet, "Số dư ví", formatCurrency(_userData!['walletBalance']), Colors.green),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Nút Đăng xuất
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Xử lý đăng xuất
                              await _apiService.logout();
                              if (mounted) {
                                // Xóa hết lịch sử màn hình cũ và về trang Login
                                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text("Đăng xuất", style: TextStyle(fontSize: 18)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[50], // Nền đỏ nhạt
                              foregroundColor: Colors.red, // Chữ đỏ
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}