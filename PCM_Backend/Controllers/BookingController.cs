using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PCM_Backend.Data;
using PCM_Backend.Models;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Phải đăng nhập mới được đặt
    public class BookingController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<Member> _userManager;

        public BookingController(ApplicationDbContext context, UserManager<Member> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // 1. API Đặt sân: POST: api/booking/book
        [HttpPost("book")]
        public async Task<IActionResult> BookCourt([FromBody] BookingRequest request)
        {
            // a. Lấy thông tin User
            var username = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return Unauthorized();

            // b. Lấy thông tin Sân
            var court = await _context.Courts.FindAsync(request.CourtId);
            if (court == null) return NotFound(new { Message = "Sân không tồn tại" });

            // c. Tính tiền
            int duration = request.EndHour - request.StartHour;
            if (duration <= 0) return BadRequest(new { Message = "Thời gian đặt không hợp lệ" });

            decimal totalAmount = court.PricePerHour * duration;

            // d. Kiểm tra số dư ví
            if (user.WalletBalance < totalAmount)
            {
                return BadRequest(new { Message = "Số dư không đủ! Vui lòng nạp thêm tiền." });
            }

            // e. Trừ tiền và Lưu Booking
            // - Trừ tiền ví
            user.WalletBalance -= totalAmount;

            // --- MỚI THÊM: LOGIC CẬP NHẬT HẠNG (Tự động lên/xuống hạng) ---
            if (user.WalletBalance >= 10000000)
            {
                user.RankLevel = "Diamond (Kim Cương)";
            }
            else if (user.WalletBalance >= 5000000)
            {
                user.RankLevel = "Gold (Vàng)";
            }
            else if (user.WalletBalance >= 1000000)
            {
                user.RankLevel = "Silver (Bạc)";
            }
            else
            {
                user.RankLevel = "Standard (Hội viên)"; // Rớt hạng nếu hết tiền
            }
            // ----------------------------------------------------------------

            // - Tạo đơn đặt sân
            var booking = new Booking
            {
                CourtId = request.CourtId,
                MemberId = user.Id,
                BookingDate = request.BookingDate,
                StartHour = request.StartHour,
                EndHour = request.EndHour,
                TotalPrice = totalAmount,
                Status = "Confirmed",
                CreatedAt = DateTime.Now
            };

            // - Lưu lịch sử giao dịch (để user biết tại sao bị trừ tiền)
            var transaction = new WalletTransaction
            {
                MemberId = user.Id,
                Amount = -totalAmount, // Số âm vì là chi tiền
                Type = "Payment",
                Description = $"Đặt sân {court.Name} ({request.StartHour}h - {request.EndHour}h)",
                Status = "Completed",
                CreatedDate = DateTime.Now
            };

            _context.Bookings.Add(booking);
            _context.WalletTransactions.Add(transaction);
            
            // Lưu tất cả vào DB
            await _userManager.UpdateAsync(user);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Đặt sân thành công!", NewBalance = user.WalletBalance });
        }

        // --- 2. API Xem Lịch sử Đặt sân: GET api/booking/my-bookings ---
        [HttpGet("my-bookings")]
        public async Task<IActionResult> GetMyBookings()
        {
            var username = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return Unauthorized();

            var bookings = await _context.Bookings
                .Where(b => b.MemberId == user.Id)
                .OrderByDescending(b => b.BookingDate) // Mới nhất lên đầu
                .Select(b => new 
                {
                    b.Id,
                    b.BookingDate,
                    b.StartHour,
                    b.EndHour,
                    b.TotalPrice,
                    b.Status,
                    CourtName = _context.Courts.FirstOrDefault(c => c.Id == b.CourtId).Name // Lấy tên sân để hiển thị
                })
                .ToListAsync();

            return Ok(bookings);
        }
    }

    // Class nhận dữ liệu từ Mobile gửi lên
    public class BookingRequest
    {
        public int CourtId { get; set; }
        public DateTime BookingDate { get; set; }
        public int StartHour { get; set; }
        public int EndHour { get; set; }
    }
}