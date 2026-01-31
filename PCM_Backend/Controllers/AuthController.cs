using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using PCM_Backend.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace PCM_Backend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<Member> _userManager;
        private readonly IConfiguration _configuration;

        public AuthController(UserManager<Member> userManager, IConfiguration configuration)
        {
            _userManager = userManager;
            _configuration = configuration;
        }

        // 1. API Đăng ký: POST /api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterModel model)
        {
            var userExists = await _userManager.FindByNameAsync(model.Email);
            if (userExists != null)
                return StatusCode(StatusCodes.Status500InternalServerError, new { Status = "Error", Message = "Email đã tồn tại!" });

            Member user = new Member()
            {
                Email = model.Email,
                SecurityStamp = Guid.NewGuid().ToString(),
                UserName = model.Email,
                FullName = model.FullName,
                WalletBalance = 0 // Mặc định ví 0 đồng
            };
            var result = await _userManager.CreateAsync(user, model.Password);
            if (!result.Succeeded)
                return StatusCode(StatusCodes.Status500InternalServerError, new { Status = "Error", Message = "Tạo thất bại! Mật khẩu cần có chữ hoa, thường, số và ký tự đặc biệt." });

            return Ok(new { Status = "Success", Message = "Đăng ký thành công!" });
        }

        // 2. API Đăng nhập: POST /api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginModel model)
        {
            var user = await _userManager.FindByNameAsync(model.Email);
            if (user != null && await _userManager.CheckPasswordAsync(user, model.Password))
            {
                var authClaims = new List<Claim>
                {
                    new Claim(ClaimTypes.Name, user.UserName), // Dùng UserName để tìm lại user sau này
                    new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                };

                var authSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));

                var token = new JwtSecurityToken(
                    issuer: _configuration["Jwt:Issuer"],
                    audience: _configuration["Jwt:Audience"],
                    expires: DateTime.Now.AddHours(3),
                    claims: authClaims,
                    signingCredentials: new SigningCredentials(authSigningKey, SecurityAlgorithms.HmacSha256)
                );

                return Ok(new
                {
                    token = new JwtSecurityTokenHandler().WriteToken(token),
                    expiration = token.ValidTo,
                    user = new { user.FullName, user.WalletBalance, user.RankLevel }
                });
            }
            return Unauthorized(new { Status = "Error", Message = "Sai tài khoản hoặc mật khẩu!" });
        }

        // 3. API Lấy thông tin cá nhân: GET /api/auth/me
        [HttpGet("me")]
        [Authorize] // Bắt buộc phải có Token mới gọi được
        public async Task<IActionResult> GetProfile()
        {
            // Lấy User Name từ Token đang đăng nhập
            var username = User.Identity?.Name;
            
            // Tìm trong Database
            var user = await _userManager.FindByNameAsync(username);
            
            if (user == null) return NotFound();

            // Trả về thông tin cần thiết
            return Ok(new { 
                user.Id,
                user.FullName, 
                user.Email, 
                user.WalletBalance, 
                user.RankLevel 
            });
        }

        // --- 4. API Lấy danh sách thành viên (MỚI THÊM) ---
        // GET: api/Auth/members
        [HttpGet("members")]
        public IActionResult GetAllMembers()
        {
            // Lấy danh sách tất cả user để hiển thị lên màn hình Thách đấu
            // Chỉ lấy các trường cần thiết để bảo mật (không lấy PasswordHash)
            var members = _userManager.Users.Select(u => new {
                u.Id,
                u.FullName,
                u.RankLevel,
                u.WalletBalance,
                u.Email
            }).ToList();

            return Ok(members);
        }
    }

    // Class hứng dữ liệu gửi lên
    public class LoginModel
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
    
    public class RegisterModel
    {
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
    }
}