import 'package:flutter/material.dart';
import 'package:pcm_mobile/services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _apiService = ApiService();
  List<dynamic> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _apiService.getIncomingChallenges();
    if (mounted) setState(() => _challenges = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lời mời thách đấu"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: _challenges.isEmpty 
        ? const Center(child: Text("Chưa có lời mời nào"))
        : ListView.builder(
            itemCount: _challenges.length,
            itemBuilder: (context, index) {
              final c = _challenges[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.flash_on, color: Colors.orange, size: 30),
                  title: Text("${c['senderName']} muốn thách đấu bạn!"),
                  subtitle: Text(c['status']),
                  trailing: ElevatedButton(
                    onPressed: () {}, // Sau này làm chức năng Chấp nhận
                    child: const Text("Xem"),
                  ),
                ),
              );
            },
          ),
    );
  }
}