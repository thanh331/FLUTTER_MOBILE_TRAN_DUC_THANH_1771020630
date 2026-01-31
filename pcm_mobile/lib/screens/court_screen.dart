import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pcm_mobile/services/api_service.dart';

class CourtScreen extends StatefulWidget {
  const CourtScreen({super.key});

  @override
  State<CourtScreen> createState() => _CourtScreenState();
}

class _CourtScreenState extends State<CourtScreen> {
  final _apiService = ApiService();
  List<dynamic> _courts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    final courts = await _apiService.getCourts();
    if (mounted) {
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount ?? 0);
  }

  // --- HÀM HIỂN THỊ POPUP ĐẶT SÂN ---
  void _showBookingDialog(dynamic court) {
    int startHour = 14; // Mặc định 14h
    int duration = 1;   // Mặc định 1 tiếng
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Đặt ${court['name']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Chọn khung giờ chơi hôm nay:"),
              const SizedBox(height: 15),
              // Chọn giờ bắt đầu
              DropdownButtonFormField<int>(
                value: startHour,
                decoration: const InputDecoration(labelText: "Giờ bắt đầu", border: OutlineInputBorder()),
                items: List.generate(16, (index) => index + 6) // Từ 6h đến 21h
                    .map((hour) => DropdownMenuItem(value: hour, child: Text("$hour:00")))
                    .toList(),
                onChanged: (val) => startHour = val!,
              ),
              const SizedBox(height: 15),
              // Chọn thời lượng
              DropdownButtonFormField<int>(
                value: duration,
                decoration: const InputDecoration(labelText: "Thời lượng (giờ)", border: OutlineInputBorder()),
                items: [1, 2, 3]
                    .map((d) => DropdownMenuItem(value: d, child: Text("$d giờ")))
                    .toList(),
                onChanged: (val) => duration = val!,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng popup
                
                // Gọi API Đặt sân
                String result = await _apiService.bookCourt(
                  court['id'], 
                  DateTime.now(), // Mặc định đặt cho hôm nay
                  startHour, 
                  startHour + duration
                );

                if (mounted) {
                  if (result == "SUCCESS") {
                    // Hiện thông báo thành công
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Thành công!"),
                        content: const Text("Bạn đã đặt sân thành công. Tiền đã được trừ vào ví."),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
                      ),
                    );
                  } else {
                    // Hiện thông báo lỗi (ví dụ: Không đủ tiền)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              child: const Text("Xác nhận"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt Sân Pickleball")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _courts.length,
              itemBuilder: (context, index) {
                final court = _courts[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh sân
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(
                          court['imageUrl'] ?? '',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.sports_tennis, size: 50, color: Colors.grey)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    court['name'],
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)),
                                  child: Text(court['status'], style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Giá: ${formatCurrency(court['pricePerHour'])} / giờ",
                              style: const TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Gọi hàm hiện Popup đặt sân
                                  _showBookingDialog(court);
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                child: const Text("ĐẶT NGAY"),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}