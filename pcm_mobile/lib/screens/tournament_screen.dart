import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcm_mobile/services/api_service.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final ApiService apiService = ApiService();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  late Future<List<dynamic>> _tournamentsFuture;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  void _loadTournaments() {
    setState(() {
      _tournamentsFuture = apiService.getTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Giải Đấu Sắp Tới")),
      body: FutureBuilder<List<dynamic>>(
        future: _tournamentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải danh sách giải đấu"));
          }

          final list = snapshot.data ?? [];
          
          if (list.isEmpty) {
            return const Center(child: Text("Hiện chưa có giải đấu nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        image: item['imageUrl'] != null 
                            ? DecorationImage(image: NetworkImage(item['imageUrl']), fit: BoxFit.cover) 
                            : null,
                      ),
                      child: item['imageUrl'] == null 
                          ? const Center(child: Icon(Icons.emoji_events, size: 50)) 
                          : null,
                    ),
                    ListTile(
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("📍 ${item['location']} - Trình độ: ${item['level']}"),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, 
                          foregroundColor: Colors.white
                        ),
                        onPressed: () => _showRegisterDialog(context, item),
                        child: const Text("Tham gia"),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRegisterDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận phí tham gia"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Giải đấu: ${item['name']}"),
            const SizedBox(height: 10),
            Text(
              "Phí tham gia: ${currencyFormat.format(500000)}", 
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
            ),
            const SizedBox(height: 10),
            const Text("Số tiền này sẽ được trừ trực tiếp từ ví của bạn. Bạn có đồng ý không?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, 
              foregroundColor: Colors.white
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              
              String result = await apiService.registerTournament(item['id']);
              
              if (!mounted) return;

              if (result == "SUCCESS") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đăng ký thành công! Chúc bạn thi đấu tốt."),
                    backgroundColor: Colors.green,
                  )
                );
                // Tải lại danh sách nếu cần cập nhật trạng thái
                _loadTournaments();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result),
                    backgroundColor: Colors.red,
                  )
                );
              }
            },
            child: const Text("Đồng ý"),
          )
        ],
      ),
    );
  }
}