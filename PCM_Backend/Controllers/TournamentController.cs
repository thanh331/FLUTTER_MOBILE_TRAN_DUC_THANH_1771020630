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

        // GET: api/Tournament
        // Lấy danh sách giải đấu
        [HttpGet]
        public async Task<IActionResult> GetTournaments()
        {
            // Sắp xếp giải mới nhất lên đầu
            return Ok(await _context.Tournaments.OrderByDescending(t => t.StartDate).ToListAsync());
        }

        // --- MỚI THÊM: API TẠO GIẢI ĐẤU ---
        // POST: api/Tournament/create
        [HttpPost("create")]
        public async Task<IActionResult> CreateTournament([FromBody] Tournament model)
        {
            if (model == null) return BadRequest(new { Message = "Dữ liệu không hợp lệ" });

            // Kiểm tra các trường bắt buộc (Tùy chọn)
            if (string.IsNullOrEmpty(model.Name) || string.IsNullOrEmpty(model.Location))
            {
                return BadRequest(new { Message = "Tên giải và địa điểm không được để trống" });
            }

            // Gán ảnh mặc định nếu người dùng không nhập link ảnh
            if (string.IsNullOrEmpty(model.ImageUrl))
            {
                model.ImageUrl = "https://img.freepik.com/free-photo/pickleball-court-sunset_23-2151121544.jpg";
            }

            try
            {
                _context.Tournaments.Add(model);
                await _context.SaveChangesAsync();
                
                return Ok(new { 
                    Message = "Tạo giải đấu thành công!", 
                    Data = model 
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Lỗi Server: " + ex.Message });
            }
        }
        // ------------------------------------

        // POST: api/Tournament/register/{id}
        // Đăng ký tham gia giải
        [Authorize]
        [HttpPost("register/{id}")]
        public async Task<IActionResult> RegisterTournament(int id)
        {
            var username = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(username);
            if (user == null) return Unauthorized();

            var tournament = await _context.Tournaments.FindAsync(id);
            if (tournament == null) return NotFound(new { Message = "Giải đấu không tồn tại" });

            decimal entryFee = 500000; 

            if (user.WalletBalance < entryFee)
            {
                return BadRequest(new { Message = $"Số dư không đủ! Cần {entryFee:N0}đ để tham gia giải này." });
            }

            // Trừ tiền và cập nhật Rank Level
            user.WalletBalance -= entryFee;

            if (user.WalletBalance >= 10000000) user.RankLevel = "Diamond (Kim Cương)";
            else if (user.WalletBalance >= 5000000) user.RankLevel = "Gold (Vàng)";
            else if (user.WalletBalance >= 1000000) user.RankLevel = "Silver (Bạc)";
            else user.RankLevel = "Standard (Hội viên)";

            // Lưu giao dịch ví
            var transaction = new WalletTransaction
            {
                MemberId = user.Id,
                Amount = -entryFee,
                Type = "Tournament Fee",
                Description = $"Phí tham gia giải: {tournament.Name}",
                Status = "Completed",
                CreatedDate = DateTime.Now
            };

            _context.WalletTransactions.Add(transaction);

            // Cập nhật User và Transaction vào Database
            var updateResult = await _userManager.UpdateAsync(user);
            if (!updateResult.Succeeded)
            {
                return StatusCode(500, new { Message = "Lỗi khi cập nhật ví trên hệ thống." });
            }

            await _context.SaveChangesAsync();

            return Ok(new { 
                Message = "Đăng ký thành công!", 
                NewBalance = user.WalletBalance,
                Rank = user.RankLevel
            });
        }

        // API tạo dữ liệu mẫu
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