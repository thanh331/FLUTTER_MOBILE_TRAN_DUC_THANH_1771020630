import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcm_mobile/services/api_service.dart';
import 'package:pcm_mobile/screens/court_screen.dart';
import 'package:pcm_mobile/screens/history_screen.dart';
import 'package:pcm_mobile/screens/tournament_screen.dart';
import 'package:pcm_mobile/screens/profile_screen.dart';
import 'package:pcm_mobile/screens/create_tournament_screen.dart';
import 'package:pcm_mobile/screens/challenge_screen.dart';
import 'package:pcm_mobile/screens/notification_screen.dart'; // <--- MỚI IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  Map<String, dynamic>? _userData;
  List<dynamic> _newsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _apiService.getUserInfo(),
      _apiService.getNews(),
    ]);

    if (!mounted) return;

    setState(() {
      final userResponse = results[0];
      if (userResponse != null && (userResponse as dynamic).statusCode == 200) {
        _userData = (userResponse as dynamic).data;
      }

      final newsResponse = results[1];
      if (newsResponse != null && newsResponse is List) {
        _newsList = newsResponse;
      }
      
      _isLoading = false;
    });
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('PCM Pickleball', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            // --- SỰ KIỆN MỞ THÔNG BÁO ---
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NotificationScreen())
              );
            },
            // -----------------------------
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserHeader(),
                    const SizedBox(height: 20),
                    _buildWalletCard(),
                    
                    // --- KHỐI THAO TÁC NHANH ---
                    const SizedBox(height: 20),
                    _buildQuickActions(),

                    // --- PHẦN TIN TỨC ---
                    const SizedBox(height: 25),
                    _buildNewsSection(),
                    
                    const SizedBox(height: 25),
                    const Text(
                      "Khám phá dịch vụ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    _buildGridMenu(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        // Ô Tạo giải đấu
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.add_circle_outline_rounded,
            title: "Tạo giải đấu",
            color: Colors.blue[700]!,
            bgColor: Colors.blue[50]!,
            onTap: () async {
              final result = await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const CreateTournamentScreen())
              );
              
              if (result == true) {
                _loadData(); 
              }
            },
          ),
        ),
        const SizedBox(width: 15),
        // Ô Thách đấu
        Expanded(
          child: _buildQuickActionItem(
            icon: Icons.flash_on_rounded, 
            title: "Thách đấu",
            color: Colors.deepOrange,
            bgColor: Colors.orange[50]!,
            onTap: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => const ChallengeScreen())
               );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon, 
    required String title, 
    required Color color, 
    required Color bgColor,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: bgColor.withOpacity(0.5)),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800])
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_newsList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            const Text("Tin tức nổi bật", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {}, 
              child: const Text("Xem tất cả", style: TextStyle(fontSize: 13))
            ),
          ],
        ),
        SizedBox(
          height: 210, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _newsList.length,
            itemBuilder: (context, index) {
              final news = _newsList[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 15, bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        news['imageUrl'] ?? 'https://via.placeholder.com/300x150',
                        height: 115,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 115, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news['title'] ?? 'Tin tức mới',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            news['createdDate'] != null 
                              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(news['createdDate']))
                              : 'Vừa xong',
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withOpacity(0.2), width: 2),
          ),
          child: const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chào bạn, ${_userData?['fullName'] ?? 'Người chơi'}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                child: Text("Hạng: ${_userData?['rankLevel'] ?? 'Standard'}", style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () async {
             await _apiService.logout();
             if (mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        )
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2193b0).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Số dư trong ví", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            formatCurrency(_userData?['walletBalance']),
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showDepositDialog,
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
            label: const Text("Nạp tiền ngay", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2193b0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
            ),
          )
        ],
      ),
    );
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nạp tiền vào ví"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nhập số tiền (VNĐ)",
            hintText: "Ví dụ: 500000",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.money),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                bool success = await _apiService.depositMoney(amount);
                if (success) {
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nạp tiền thành công!"), backgroundColor: Colors.green));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nạp tiền thất bại"), backgroundColor: Colors.red));
                  }
                }
              }
            },
            child: const Text("Xác nhận"),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildMenuItem(Icons.calendar_today_rounded, "Đặt sân", Colors.orange),
        _buildMenuItem(Icons.emoji_events_rounded, "Giải đấu", Colors.purple),
        _buildMenuItem(Icons.history_rounded, "Lịch sử", Colors.green),
        _buildMenuItem(Icons.person_rounded, "Cá nhân", Colors.teal),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return InkWell(
      onTap: () async {
        Widget destination;
        bool needUpdate = false;

        switch (title) {
          case "Đặt sân":
            destination = const CourtScreen();
            needUpdate = true;
            break;
          case "Giải đấu":
            destination = const TournamentScreen();
            needUpdate = true;
            break;
          case "Lịch sử":
            destination = const HistoryScreen();
            break;
          case "Cá nhân":
            destination = const ProfileScreen();
            needUpdate = true;
            break;
          case "Thông báo":
            destination = const NotificationScreen();
            break;
          default:
            return;
        }

        await Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        if (needUpdate) _loadData();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}