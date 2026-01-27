using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using PCM_Backend.Data;
using PCM_Backend.Models;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// --- 1. CẤU HÌNH CORS (QUAN TRỌNG ĐỂ CHẠY WEB) ---
// Thêm đoạn này để cho phép Flutter Web kết nối vào API
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()  // Cho phép mọi nguồn (localhost, web, mobile...)
              .AllowAnyMethod()  // Cho phép mọi method (GET, POST, PUT...)
              .AllowAnyHeader(); // Cho phép mọi header
    });
});
// ------------------------------------------------

// 2. KẾT NỐI MYSQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// 3. CẤU HÌNH IDENTITY (Đăng nhập/Đăng ký)
builder.Services.AddIdentity<Member, IdentityRole>()
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

// 4. CẤU HÌNH JWT (Token bảo mật)
builder.Services.AddAuthentication(options => {
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options => {
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
    };
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Bật Swagger để test API
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// --- KÍCH HOẠT CORS (PHẢI ĐẶT Ở ĐÂY) ---
app.UseCors("AllowAll"); 
// ---------------------------------------

app.UseAuthentication(); // Bắt buộc có dòng này
app.UseAuthorization();

app.MapControllers();

app.Run();