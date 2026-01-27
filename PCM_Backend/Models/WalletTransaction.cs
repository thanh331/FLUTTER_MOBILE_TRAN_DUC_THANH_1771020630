using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCM_Backend.Models
{
    public class WalletTransaction
    {
        [Key]
        public int Id { get; set; }

        public string MemberId { get; set; } // ID người nạp
        public decimal Amount { get; set; } // Số tiền
        public string Type { get; set; } = "Deposit"; // Loại: Nạp tiền
        public string Status { get; set; } = "Completed"; // Trạng thái: Thành công luôn
        public DateTime CreatedDate { get; set; } = DateTime.Now;
        public string? Description { get; set; }
    }
}