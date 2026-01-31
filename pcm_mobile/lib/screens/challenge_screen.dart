import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Cần import Dio để bắt lỗi chi tiết
import 'package:pcm_mobile/services/api_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _apiService = ApiService();
  List<dynamic> _members = [];
  String? _myId; // Biến lưu ID của bản thân
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải song song: Danh sách thành viên + Thông tin bản thân
  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _apiService.getAllMembers(), // [0] Lấy danh sách
        _apiService.getUserInfo(),   // [1] Lấy thông tin mình (để biết ID)
      ]);

      if (mounted) {
        setState(() {
          _members = results[0] as List<dynamic>;
          
          // Lấy ID của mình từ kết quả trả về
          final myInfo = results[1];
          if (myInfo != null && (myInfo as dynamic).data != null) {
            _myId = (myInfo as dynamic).data['id']; // Backend đã sửa trả về id
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm Đối Thủ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final m = _members[index];
                
                // Kiểm tra xem đây có phải là mình không
                bool isMe = _myId != null && (m['id'] == _myId);

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  // Nếu là mình thì đổi màu nền nhẹ để nhận biết
                  color: isMe ? Colors.blue[50] : Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMe ? Colors.blue[100] : Colors.orange[100],
                      child: Text(
                        (m['fullName'] != null && m['fullName'].isNotEmpty)
                            ? m['fullName'][0].toUpperCase()
                            : "?",
                        style: TextStyle(color: isMe ? Colors.blue : Colors.deepOrange),
                      ),
                    ),
                    title: Text(
                      m['fullName'] ?? "No Name",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isMe ? "Bạn (Đang online)" : "Rank: ${m['rankLevel'] ?? 'Standard'}"
                    ),
                    // Nếu là mình thì ẩn nút Thách đấu đi
                    trailing: isMe 
                        ? const Icon(Icons.person, color: Colors.blue) 
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _handleChallenge(m),
                            child: const Text("Thách đấu"),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _handleChallenge(dynamic member) async {
    // Gọi API gửi thách đấu
    bool success = await _apiService.sendChallenge(
      member['id'], 
      member['fullName']
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đã gửi lời thách đấu tới ${member['fullName']}!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Thông báo lỗi chung (Nếu muốn chi tiết hơn cần sửa ApiService trả về String error)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gửi thất bại! Hãy kiểm tra lại kết nối."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}