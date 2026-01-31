import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcm_mobile/services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _apiService = ApiService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _apiService.getMyBookings();
    if (mounted) setState(() { _bookings = data; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đặt sân")),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : 
      _bookings.isEmpty 
        ? const Center(child: Text("Chưa có lịch sử đặt sân nào"))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              final item = _bookings[index];
              final date = DateTime.parse(item['bookingDate']);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.sports_tennis, color: Colors.blue),
                  ),
                  title: Text(item['courtName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${DateFormat('dd/MM/yyyy').format(date)} | ${item['startHour']}h - ${item['endHour']}h"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(NumberFormat.currency(locale: 'vi', symbol: 'đ').format(item['totalPrice']), 
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Text(item['status'], style: const TextStyle(color: Colors.green, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
}