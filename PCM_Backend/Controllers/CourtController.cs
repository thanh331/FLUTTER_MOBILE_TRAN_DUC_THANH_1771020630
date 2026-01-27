using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PCM_Backend.Data;
using PCM_Backend.Models;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CourtController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CourtController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. API Lấy danh sách sân: GET /api/court
        [HttpGet]
        public async Task<IActionResult> GetCourts()
        {
            var courts = await _context.Courts.ToListAsync();
            return Ok(courts);
        }

        // 2. API Tạo dữ liệu mẫu (Chạy 1 lần thôi): POST /api/court/seed
        [HttpPost("seed")]
        public async Task<IActionResult> SeedData()
        {
            if (!_context.Courts.Any()) // Nếu chưa có sân nào thì mới tạo
            {
                var sampleCourts = new List<Court>
                {
                    new Court { Name = "Sân Pickleball VIP 1", PricePerHour = 100000, ImageUrl = "https://media.istockphoto.com/id/1453284913/photo/blue-and-green-pickleball-court.jpg?s=612x612&w=0&k=20&c=6k5sXJO20e0G3XoWvV6Q7eN5u5W7h8q4d4k9l5m3n2o=" },
                    new Court { Name = "Sân Tiêu Chuẩn A", PricePerHour = 50000, ImageUrl = "https://pickleballers.io/wp-content/uploads/2022/07/Pickleball-Court-Dimensions.jpg" },
                    new Court { Name = "Sân Tiêu Chuẩn B", PricePerHour = 50000, ImageUrl = "https://www.pickleballportal.com/wp-content/uploads/2019/07/pickleball-court-dimensions-diagram.jpg" },
                    new Court { Name = "Sân Tập Luyện", PricePerHour = 30000, ImageUrl = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Pickleball_Court.jpg/1200px-Pickleball_Court.jpg" }
                };

                _context.Courts.AddRange(sampleCourts);
                await _context.SaveChangesAsync();
                return Ok(new { Message = "Đã tạo 4 sân mẫu thành công!" });
            }
            return Ok(new { Message = "Dữ liệu đã có sẵn, không cần tạo thêm." });
        }
    }
}