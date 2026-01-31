import 'package:flutter/material.dart';
import 'package:pcm_mobile/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isObscure = true;

  void _handleRegister() async {
    // 1. Kiểm tra nhập liệu
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu xác nhận không khớp"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Gọi API Đăng ký
    final response = await _apiService.register(
      _emailController.text,
      _passwordController.text,
      _fullNameController.text
    );

    setState(() => _isLoading = false);

    // 3. Xử lý kết quả
    if (response != null && response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Hãy đăng nhập."), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Quay về màn hình đăng nhập
      }
    } else {
      if (mounted) {
        String errorMsg = "Đăng ký thất bại.";
        if (response?.data != null && response?.data['message'] != null) {
          errorMsg = response?.data['message'];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (Giống màn hình Login nhưng nhỏ hơn chút) ---
            Container(
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.person_add, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "TẠO TÀI KHOẢN",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 5),
                    const Text("Gia nhập cộng đồng Pickleball ngay", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),

            // --- FORM ---
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  // Full Name
                  TextField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: "Họ và tên",
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true, fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true, fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: "Mật khẩu",
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _isObscure = !_isObscure),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true, fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: "Nhập lại mật khẩu",
                      prefixIcon: const Icon(Icons.lock_reset, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      filled: true, fillColor: Colors.grey[100],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // Button Đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2193b0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("ĐĂNG KÝ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Đã có tài khoản? Đăng nhập", style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}