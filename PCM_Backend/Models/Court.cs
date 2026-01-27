using System.ComponentModel.DataAnnotations;

namespace PCM_Backend.Models
{
    public class Court
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; } // Tên sân (VD: Sân 1)
        public string ImageUrl { get; set; } // Ảnh sân
        public decimal PricePerHour { get; set; } // Giá tiền 1 giờ
        public string Status { get; set; } = "Active"; // Trạng thái: Active/Maintenance
    }
}