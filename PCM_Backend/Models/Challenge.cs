using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCM_Backend.Models
{
    public class Challenge
    {
        [Key]
        public int Id { get; set; }

        public string SenderId { get; set; } // Người gửi
        public string SenderName { get; set; } 

        public string ReceiverId { get; set; } // Người nhận
        public string ReceiverName { get; set; }

        public string Status { get; set; } = "Pending"; // Pending, Accepted, Rejected
        public DateTime CreatedDate { get; set; } = DateTime.Now;
    }
}