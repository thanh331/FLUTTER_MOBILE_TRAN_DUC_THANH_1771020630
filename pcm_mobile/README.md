<<<<<<< HEAD

📘 HƯỚNG DẪN SỬ DỤNG & GIỚI THIỆU DỰ ÁN
1. Giới thiệu tổng quan (Dành cho phần mở đầu bài làm)
Tên ứng dụng: PCM Pickleball (Pickleball Court Management).

Mục tiêu: Cung cấp giải pháp công nghệ giúp người chơi Pickleball dễ dàng tìm kiếm sân, đặt lịch trực tuyến, quản lý ví cá nhân và theo dõi các giải đấu sắp tới.

Công nghệ sử dụng:

Backend: ASP.NET Core Web API, Entity Framework Core, MySQL.

Frontend: Flutter Framework (Dart) - Chạy đa nền tảng (Web/Mobile).

Tính năng nổi bật: Đặt sân theo thời gian thực, hệ thống phân hạng thành viên (Rank) tự động dựa trên số dư ví, quản lý lịch sử giao dịch minh bạch.

2. Tài khoản dùng thử (Dành cho thầy cô/người chấm bài)
Để thuận tiện cho việc kiểm thử nhanh, bạn có thể cung cấp tài khoản mặc định đã có sẵn tiền trong ví (sau khi bạn đã thực hiện các bước nạp tiền ở các phiên làm việc trước):

Email: admin@gmail.com

Mật khẩu: P@ssword123 (Hoặc mật khẩu bạn đã đăng ký).

Trạng thái: Tài khoản này đã có số dư ví khoảng 12.200.000 đ và đang ở hạng Diamond (Kim Cương).

3. Quy trình Demo ứng dụng (Kịch bản trình bày)
Bạn nên trình bày theo thứ tự 4 bước sau để thể hiện hết logic của app:

Bước 1: Đăng nhập & Khởi tạo (Auth)
Sử dụng giao diện đăng nhập mới (màu Gradient xanh) để tạo ấn tượng ban đầu.

Giải thích về hệ thống bảo mật bằng JWT Token được lưu trữ trong Flutter Secure Storage.

Bước 2: Quản lý ví & Nâng hạng (Wallet & Rank)
Thao tác: Nhấn nút "Nạp tiền", nhập số tiền (ví dụ: 5.000.000đ).

Điểm nhấn: Giải thích logic Backend: Khi số dư ví thay đổi, hệ thống tự động tính toán lại Rank (Đồng -> Bạc -> Vàng -> Kim Cương). Đây là tính năng giữ chân người dùng (Gamification).

Bước 3: Đặt sân & Thanh toán (Booking)
Thao tác: Vào mục "Đặt sân", chọn một sân bất kỳ (ví dụ: Sân VIP 1). Chọn khung giờ và xác nhận.

Điểm nhấn: Hệ thống sẽ tự động trừ tiền trong ví và cập nhật lịch sử. Nếu tiêu quá tay khiến số dư thấp, Rank sẽ tự động bị hạ xuống (đảm bảo tính công bằng).

Bước 4: Giải đấu & Cá nhân (Tournaments & Profile)
Giải đấu: Giới thiệu danh sách giải đấu được lấy động từ API. Nhấn "Tham gia" để đăng ký.

Cá nhân: Hiển thị thông tin thực thể của tài khoản đang đăng nhập, cho phép Đăng xuất an toàn.

4. Hướng dẫn kỹ thuật (Nếu cần cài đặt lại từ đầu)
Backend:

Mở thư mục PCM_Backend trong VS Code.

Chạy dotnet ef database update để khởi tạo database.

Chạy dotnet run để mở Server.

Truy cập Swagger và chạy hàm Seed cho Court và Tournament để có dữ liệu mẫu.

Frontend:

Mở thư mục pcm_mobile.

Đảm bảo baseUrl trong api_service.dart khớp với địa chỉ Server (thường là http://localhost:5098/api).

Nhấn F5 để chạy ứng dụng trên trình duyệt hoặc máy ảo.

5. Tổng kết bài làm
Dự án đã hoàn thiện đầy đủ các yêu cầu về:

CRUD dữ liệu: Quản lý sân, giải đấu, người dùng.

Xử lý nghiệp vụ: Tính toán tiền sân, trừ ví, phân hạng.

Giao diện người dùng (UI/UX): Thiết kế hiện đại, dễ sử dụng, phản hồi nhanh (Hot reload).
=======
# pcm_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
>>>>>>> 95545a2 (Day du Backend va Frontend)
