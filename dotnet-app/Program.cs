using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure application URL - allow port override via command line or environment
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
var urls = args.FirstOrDefault(arg => arg.StartsWith("--urls="))?.Split('=')[1] 
           ?? $"http://0.0.0.0:{port}";
builder.WebHost.UseUrls(urls);

// Configure Serilog for Datadog - JSON Structured Logging
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .Enrich.FromLogContext()
    .Enrich.WithProperty("service", "datadog-checker")
    .Enrich.WithProperty("version", "1.0.0")
    .Enrich.WithProperty("environment", Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Development")
    .Enrich.WithEnvironmentName()
    .WriteTo.Console(new Serilog.Formatting.Compact.CompactJsonFormatter())
    .WriteTo.File(new Serilog.Formatting.Compact.CompactJsonFormatter(), "./logs/app-.txt", rollingInterval: RollingInterval.Day)
    .CreateLogger();

builder.Host.UseSerilog();

// Add services
builder.Services.AddControllers();
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure middleware
app.UseStaticFiles();
app.UseRouting();

app.MapControllers();
app.MapFallbackToFile("index.html");

// Add health check endpoint
app.MapGet("/health", () => 
{
    Log.Information("Health check endpoint called");
    return Results.Ok(new { 
        status = "healthy", 
        timestamp = DateTime.UtcNow,
        port = port,
        environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Unknown",
        version = "1.0.0"
    });
});

Log.Information("Application starting on {Urls}...", urls);

app.Run();
