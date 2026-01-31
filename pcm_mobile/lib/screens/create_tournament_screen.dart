import 'package:flutter/material.dart';
import 'package:pcm_mobile/services/api_service.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _prizeController = TextEditingController();
  String _selectedLevel = 'Newbie (C)';
  final _apiService = ApiService();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "name": _nameController.text,
        "location": _locationController.text,
        "level": _selectedLevel,
        "prize": double.tryParse(_prizeController.text) ?? 0,
        "startDate": DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        "imageUrl": "" // Để trống backend tự thêm ảnh
      };

      bool success = await _apiService.createTournament(data);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tạo giải thành công!"), backgroundColor: Colors.green));
        Navigator.pop(context, true); // Quay về và reload
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi tạo giải"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tạo Giải Đấu Mới"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên giải đấu", border: OutlineInputBorder(), prefixIcon: Icon(Icons.emoji_events)),
                validator: (v) => v!.isEmpty ? "Cần nhập tên giải" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Địa điểm / Sân", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v!.isEmpty ? "Cần nhập địa điểm" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _prizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Tổng giải thưởng (VNĐ)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: "Trình độ", border: OutlineInputBorder(), prefixIcon: Icon(Icons.bar_chart)),
                items: ['Newbie (C)', 'Intermediate (B)', 'Pro (A)', 'Open'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedLevel = v!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text("Xác nhận tạo giải", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}