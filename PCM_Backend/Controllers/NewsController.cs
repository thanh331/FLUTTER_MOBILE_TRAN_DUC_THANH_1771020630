using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PCM_Backend.Data;
using PCM_Backend.Models;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NewsController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public NewsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // 1. Lấy danh sách tin tức (Sắp xếp tin mới nhất lên đầu)
        [HttpGet]
        public async Task<IActionResult> GetNews()
        {
            var newsList = await _context.News
                                         .OrderByDescending(n => n.CreatedDate) // Tin mới lên đầu
                                         .ToListAsync();
            return Ok(newsList);
        }

        // 2. Thêm tin tức mới (Dành cho Admin hoặc dùng Postman/Swagger test)
        [HttpPost]
        public async Task<IActionResult> CreateNews([FromBody] News news)
        {
            if (news == null) return BadRequest();

            news.CreatedDate = DateTime.Now;
            _context.News.Add(news);
            await _context.SaveChangesAsync();

            return Ok(new { Message = "Thêm tin tức thành công!", Data = news });
        }

        // 3. API Tạo dữ liệu mẫu (Chạy cái này 1 lần để có data test trên App)
        [HttpPost("seed")]
        public async Task<IActionResult> SeedNews()
        {
            // Kiểm tra nếu chưa có tin tức nào thì mới thêm
            if (!_context.News.Any())
            {
                var sampleNews = new List<News>
                {
                    new News 
                    { 
                        Title = "Khai trương cụm sân Pickleball chuẩn quốc tế tại Quận 7", 
                        Content = "Sân mới với mặt sân đạt chuẩn, hệ thống đèn LED hiện đại...",
                        ImageUrl = "https://img.freepik.com/free-photo/pickleball-court-sunset_23-2151121544.jpg" 
                    },
                    new News 
                    { 
                        Title = "Giải đấu mở rộng tháng 2: Đăng ký ngay!", 
                        Content = "Giải đấu dành cho mọi trình độ với tổng giải thưởng lên đến 50 triệu đồng.",
                        ImageUrl = "https://img.freepik.com/free-photo/player-hitting-pickleball_23-2151121550.jpg" 
                    },
                    new News 
                    { 
                        Title = "Mẹo chọn vợt Pickleball cho người mới bắt đầu", 
                        Content = "Hướng dẫn chi tiết cách chọn vợt phù hợp với lực tay và lối đánh...",
                        ImageUrl = "https://img.freepik.com/free-photo/pickleball-paddle-ball-court_23-2151121532.jpg" 
                    }
                };

                _context.News.AddRange(sampleNews);
                await _context.SaveChangesAsync();
                return Ok(new { Message = "Đã tạo 3 tin tức mẫu thành công!" });
            }
            return Ok(new { Message = "Dữ liệu tin tức đã tồn tại, không cần tạo thêm." });
        }
    }
}