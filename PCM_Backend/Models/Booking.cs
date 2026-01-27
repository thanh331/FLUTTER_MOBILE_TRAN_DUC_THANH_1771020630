using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCM_Backend.Models
{
    public class Booking
    {
        [Key]
        public int Id { get; set; }

        public int CourtId { get; set; } // Đặt sân nào
        public string MemberId { get; set; } // Ai đặt

        public DateTime BookingDate { get; set; } // Ngày đặt
        public int StartHour { get; set; } // Giờ bắt đầu (VD: 14h)
        public int EndHour { get; set; } // Giờ kết thúc (VD: 16h)

        public decimal TotalPrice { get; set; } // Tổng tiền
        public string Status { get; set; } = "Confirmed"; // Đã xác nhận
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}