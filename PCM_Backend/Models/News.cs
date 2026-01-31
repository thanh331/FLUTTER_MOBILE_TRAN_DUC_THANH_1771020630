using System;
using System.ComponentModel.DataAnnotations;

namespace PCM_Backend.Models
{
    public class News
    {
        [Key]
        public int Id { get; set; }

        public string Title { get; set; } // Tiêu đề tin tức

        public string Content { get; set; } // Nội dung chi tiết (nếu cần)

        public string ImageUrl { get; set; } // Link ảnh

        public DateTime CreatedDate { get; set; } = DateTime.Now; // Ngày tạo mặc định là hiện tại
    }
}