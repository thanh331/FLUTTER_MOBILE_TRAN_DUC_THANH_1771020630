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
    public class TournamentController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<Member> _userManager;

        public TournamentController(ApplicationDbContext context, UserManager<Member> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        [HttpGet]
        public async Task<IActionResult> GetTournaments()
        {
            return Ok(await _context.Tournaments.ToListAsync());
        }

        // API ĐĂNG KÝ VÀ THU PHÍ GIẢI ĐẤU
        [Authorize]
        [HttpPost("register/{id}")]
        public async Task<IActionResult> RegisterTournament(int id)
        {
            // 1. Lấy thông tin User (Đảm bảo lấy dữ liệu mới nhất từ DB)
            var username = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return Unauthorized();

            // 2. Lấy thông tin Giải đấu
            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null) return NotFound(new { Message = "Giải đấu không tồn tại" });

            // Mức phí tham gia bạn yêu cầu: 500.000đ
            decimal entryFee = 500000; 

            // 3. Kiểm tra số dư ví
            if (user.WalletBalance < entryFee)
            {
                return BadRequest(new { Message = $"Số dư không đủ! Cần {entryFee:N0}đ để tham gia giải này." });
            }

            // 4. Thực hiện trừ tiền trong bộ nhớ và tính lại hạng (Rank)
            user.WalletBalance -= entryFee;

            // Đồng bộ logic RankLevel
            if (user.WalletBalance >= 10000000) user.RankLevel = "Diamond (Kim Cương)";
            else if (user.WalletBalance >= 5000000) user.RankLevel = "Gold (Vàng)";
            // Sửa dòng else if bị gạch đỏ
            else if (user.WalletBalance >= 1000000) user.RankLevel = "Silver (Bạc)";
            else user.RankLevel = "Standard (Hội viên)";

            // 5. Tạo bản ghi lịch sử giao dịch ví
            var transaction = new WalletTransaction
            {
                MemberId = user.Id,
                Amount = -entryFee,
                Type = "Tournament Fee",
                Description = $"Phí tham gia giải: {tournament.Name}",
                Status = "Completed",
                CreatedDate = DateTime.Now
            };

            // 6. LƯU THAY ĐỔI (QUAN TRỌNG: Thứ tự lệnh lưu)
            _context.WalletTransactions.Add(transaction);

            // Cập nhật thông tin User (bao gồm WalletBalance và RankLevel mới)
            var updateResult = await _userManager.UpdateAsync(user);
            if (!updateResult.Succeeded)
            {
                return StatusCode(500, new { Message = "Lỗi khi cập nhật ví trên hệ thống." });
            }

            // Lưu transaction vào DB
            await _context.SaveChangesAsync();

            return Ok(new { 
                Message = "Đăng ký thành công và đã trừ phí tham gia!", 
                NewBalance = user.WalletBalance,
                Rank = user.RankLevel
            });
        }

        [HttpPost("seed")]
        public async Task<IActionResult> SeedData()
        {
            if (!_context.Tournaments.Any())
            {
                _context.Tournaments.AddRange(new List<Tournament>
                {
                    new Tournament { Name = "Giải Vô Địch Mùa Hè 2026", StartDate = DateTime.Now.AddDays(10), Location = "Sân VIP 1", Level = "Pro (A)", Prize = 10000000, ImageUrl = "https://cdn.shopify.com/s/files/1/0268/1297/3191/files/Pickleball_Tournament_600x600.jpg" },
                    new Tournament { Name = "Giao Lưu Tân Thủ K15", StartDate = DateTime.Now.AddDays(20), Location = "Sân Tập Luyện", Level = "Newbie (C)", Prize = 2000000, ImageUrl = "https://i.ytimg.com/vi/S36H69vO_jY/maxresdefault.jpg" }
                });
                await _context.SaveChangesAsync();
                return Ok(new { Message = "Đã tạo giải đấu mẫu!" });
            }
            return Ok(new { Message = "Dữ liệu đã có." });
        }
    }
}