using System.ComponentModel.DataAnnotations;

namespace PCM_Backend.Models
{
    public class Tournament
    {
        [Key]
        public int Id { get; set; }
        public string Name { get; set; } // Tên giải
        public DateTime StartDate { get; set; } // Ngày bắt đầu
        public string Location { get; set; } // Địa điểm
        public string Level { get; set; } // Trình độ (A, B, C)
        public decimal Prize { get; set; } // Giải thưởng
        public string ImageUrl { get; set; } // Ảnh banner
    }
}