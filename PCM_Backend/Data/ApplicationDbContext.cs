using Microsoft.AspNetCore.Identity; // <--- Dòng này quan trọng, lúc nãy bị thiếu
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using PCM_Backend.Models;

namespace PCM_Backend.Data
{
    public class ApplicationDbContext : IdentityDbContext<Member>
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<WalletTransaction> WalletTransactions { get; set; }

        public DbSet<Court> Courts { get; set; }
        public DbSet<Booking> Bookings { get; set; }

        public DbSet<Tournament> Tournaments { get; set; }
        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            
            // Đổi tên các bảng
            builder.Entity<Member>().ToTable("630_Members");
            builder.Entity<IdentityRole>().ToTable("630_Roles");
            builder.Entity<IdentityUserRole<string>>().ToTable("630_UserRoles");

            builder.Entity<WalletTransaction>().ToTable("630_WalletTransactions");
            builder.Entity<Tournament>().ToTable("630_Tournaments");
        }
    }
}