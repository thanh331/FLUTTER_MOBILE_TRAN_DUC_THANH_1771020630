using Microsoft.AspNetCore.Identity;

namespace PCM_Backend.Models
{
    // Kế thừa IdentityUser để có sẵn đăng nhập, phân quyền
    public class Member : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public DateTime JoinDate { get; set; } = DateTime.Now;
        public decimal WalletBalance { get; set; } = 0; // Số dư ví
        public string RankLevel { get; set; } = "Bronze"; // Hạng thành viên
    }
}