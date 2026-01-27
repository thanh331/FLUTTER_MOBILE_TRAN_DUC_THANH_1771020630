using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using PCM_Backend.Data;
using PCM_Backend.Models;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Bắt buộc đăng nhập mới được nạp
    public class WalletController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<Member> _userManager;

        public WalletController(ApplicationDbContext context, UserManager<Member> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // API: POST /api/wallet/deposit
        [HttpPost("deposit")]
        public async Task<IActionResult> Deposit([FromBody] DepositModel model)
        {
            if (model.Amount <= 0) return BadRequest(new { Message = "Số tiền phải lớn hơn 0" });

            // 1. Lấy user đang đăng nhập
            var username = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return Unauthorized();

            // 2. Tạo lịch sử giao dịch
            var transaction = new WalletTransaction
            {
                MemberId = user.Id,
                Amount = model.Amount,
                Description = "Nạp tiền qua App",
                Status = "Completed" // Cho thành công luôn để demo
            };
            _context.WalletTransactions.Add(transaction);

            // 3. Cộng tiền vào ví User
            user.WalletBalance += model.Amount;

            // --- CẬP NHẬT HẠNG (LOGIC ĐỒNG BỘ VỚI BOOKING) ---
            if (user.WalletBalance >= 10000000) // Trên 10 triệu
            {
                user.RankLevel = "Diamond (Kim Cương)";
            }
            else if (user.WalletBalance >= 5000000) // Trên 5 triệu
            {
                user.RankLevel = "Gold (Vàng)";
            }
            else if (user.WalletBalance >= 1000000) // Trên 1 triệu
            {
                user.RankLevel = "Silver (Bạc)";
            }
            else 
            {
                user.RankLevel = "Standard (Hội viên)"; // Dưới 1 triệu về hạng thường
            }
            // ----------------------------------------------------
            
            // 4. Lưu tất cả vào Database
            await _context.SaveChangesAsync();
            await _userManager.UpdateAsync(user);

            return Ok(new { Message = "Nạp tiền thành công!", NewBalance = user.WalletBalance });
        }
    }

    public class DepositModel
    {
        public decimal Amount { get; set; }
    }
}