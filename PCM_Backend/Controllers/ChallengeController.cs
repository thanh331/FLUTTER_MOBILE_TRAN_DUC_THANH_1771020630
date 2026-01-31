using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using PCM_Backend.Data;
using PCM_Backend.Models;
using System.Security.Claims;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize] // Bắt buộc đăng nhập mới được dùng
    public class ChallengeController : ControllerBase
    {
        private readonly ApplicationDbContext _context;
        private readonly UserManager<Member> _userManager;

        public ChallengeController(ApplicationDbContext context, UserManager<Member> userManager)
        {
            _context = context;
            _userManager = userManager;
        }

        // 1. Gửi lời thách đấu
        [HttpPost("send")]
        public async Task<IActionResult> SendChallenge([FromBody] Challenge model)
        {
        var senderEmail = User.Identity?.Name;
        var sender = await _userManager.FindByNameAsync(senderEmail);

        // 1. Kiểm tra tự thách đấu
        if (sender.Id == model.ReceiverId)
        {
        return BadRequest(new { Message = "Bạn không thể tự thách đấu chính mình!" });
        }

        model.SenderId = sender.Id;
        model.SenderName = sender.FullName;
        model.CreatedDate = DateTime.Now;
        model.Status = "Pending";

        _context.Challenges.Add(model);
        await _context.SaveChangesAsync();

        return Ok(new { Message = "Đã gửi lời thách đấu!" });
        }

        // 2. Xem danh sách lời thách đấu gửi đến mình
        [HttpGet("my-challenges")]
        public async Task<IActionResult> GetMyChallenges()
        {
            var userEmail = User.Identity?.Name;
            var user = await _userManager.FindByNameAsync(userEmail);

            // Tìm những lời thách đấu mà ReceiverId là mình
            var list = await _context.Challenges
                                     .Where(c => c.ReceiverId == user.Id)
                                     .OrderByDescending(c => c.CreatedDate)
                                     .ToListAsync();
            return Ok(list);
        }
    }
}