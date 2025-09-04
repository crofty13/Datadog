using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace DatadogChecker.Controllers;

[ApiController]
[Route("api/[controller]")]
public class StatusController : ControllerBase
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<StatusController> _logger;

    public StatusController(HttpClient httpClient, ILogger<StatusController> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    [HttpPost("check-datadog")]
    public async Task<IActionResult> CheckDatadog()
    {
        _logger.LogInformation("CheckDatadog endpoint called");
        return await CheckWebsite("www.datadoghq.com", "Datadog");
    }

    [HttpPost("check-datacat")]
    public async Task<IActionResult> CheckDatacat()
    {
        _logger.LogInformation("CheckDatacat endpoint called");
        return await CheckWebsite("www.datacat.com", "Datacat");
    }

    [HttpGet("traces")]
    public IActionResult GetTraces()
    {
        _logger.LogInformation("GetTraces endpoint called");
        
        try
        {
            var response = new {
                message = "Standard logging is active (no distributed tracing)",
                timestamp = DateTime.UtcNow,
                environment = System.Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "not-set",
                version = "1.0.0",
                loggingProvider = "Serilog"
            };
            
            return Ok(response);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetTraces endpoint");
            return StatusCode(500, new { error = "Internal server error", message = ex.Message });
        }
    }

    [HttpGet("debug")]
    public async Task<IActionResult> Debug()
    {
        _logger.LogInformation("Debug endpoint called");
        
        var diagnostics = new
        {
            timestamp = DateTime.UtcNow,
            environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"),
            machineName = Environment.MachineName,
            workingDirectory = Directory.GetCurrentDirectory(),
            networkTests = new List<object>()
        };

        // Test basic network connectivity
        try
        {
            using var httpClient = new HttpClient();
            httpClient.Timeout = TimeSpan.FromSeconds(5);
            
            var response = await httpClient.GetAsync("https://www.datadoghq.com");
            diagnostics.networkTests.Add(new
            {
                url = "https://www.datadoghq.com",
                success = true,
                statusCode = (int)response.StatusCode,
                responseTime = "< 5s"
            });
        }
        catch (Exception ex)
        {
            diagnostics.networkTests.Add(new
            {
                url = "https://www.datadoghq.com",
                success = false,
                error = ex.Message,
                errorType = ex.GetType().Name
            });
        }

        return Ok(diagnostics);
    }

    private async Task<IActionResult> CheckWebsite(string url, string serviceName)
    {
        var requestId = Guid.NewGuid().ToString("N")[..8]; // Generate simple request ID
        
        try
        {
            var stopwatch = Stopwatch.StartNew();
            
            try
            {
                _logger.LogInformation("Starting health check for {ServiceName} at {Url} [RequestId: {RequestId}]", 
                    serviceName, url, requestId);
                
                // Configure HTTP client for container environment
                using var httpClient = new HttpClient();
                httpClient.Timeout = TimeSpan.FromSeconds(10);
                httpClient.DefaultRequestHeaders.Add("User-Agent", "StatusChecker/1.0");
                
                var response = await httpClient.GetAsync($"https://{url}");
                stopwatch.Stop();
                
                var result = new
                {
                    status = response.IsSuccessStatusCode ? "online" : "offline",
                    service = serviceName,
                    statusCode = (int)response.StatusCode,
                    responseTime = stopwatch.ElapsedMilliseconds,
                    requestId = requestId,
                    timestamp = DateTime.UtcNow
                };
                
                if (response.IsSuccessStatusCode)
                {
                    _logger.LogInformation("{ServiceName} is online. Status: {StatusCode}, Response time: {ResponseTime}ms [RequestId: {RequestId}]", 
                        serviceName, response.StatusCode, stopwatch.ElapsedMilliseconds, requestId);
                }
                else
                {
                    _logger.LogError("{ServiceName} returned error status. Status: {StatusCode}, Response time: {ResponseTime}ms [RequestId: {RequestId}]", 
                        serviceName, response.StatusCode, stopwatch.ElapsedMilliseconds, requestId);
                }
                
                return Ok(result);
            }
            catch (TaskCanceledException ex) when (ex.InnerException is TimeoutException)
            {
                stopwatch.Stop();
                _logger.LogError("Timeout while checking {ServiceName} at {Url}. Response time: {ResponseTime}ms [RequestId: {RequestId}]. Error: {ErrorMessage}", 
                    serviceName, url, stopwatch.ElapsedMilliseconds, requestId, ex.Message);
                
                return Ok(new { 
                    status = "offline", 
                    service = serviceName,
                    error = "Request timeout",
                    responseTime = stopwatch.ElapsedMilliseconds,
                    requestId = requestId,
                    timestamp = DateTime.UtcNow
                });
            }
            catch (HttpRequestException ex)
            {
                stopwatch.Stop();
                _logger.LogError(ex, "HTTP error while checking {ServiceName} at {Url}. Response time: {ResponseTime}ms [RequestId: {RequestId}]. Error: {ErrorMessage}", 
                    serviceName, url, stopwatch.ElapsedMilliseconds, requestId, ex.Message);
                
                return Ok(new { 
                    status = "offline", 
                    service = serviceName,
                    error = ex.Message,
                    responseTime = stopwatch.ElapsedMilliseconds,
                    requestId = requestId,
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                stopwatch.Stop();
                _logger.LogError(ex, "Unexpected error while checking {ServiceName} at {Url}. Response time: {ResponseTime}ms [RequestId: {RequestId}]. Error: {ErrorMessage}", 
                    serviceName, url, stopwatch.ElapsedMilliseconds, requestId, ex.Message);
                
                return StatusCode(500, new { 
                    status = "error", 
                    service = serviceName,
                    error = "Internal server error",
                    responseTime = stopwatch.ElapsedMilliseconds,
                    requestId = requestId,
                    timestamp = DateTime.UtcNow
                });
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Critical error in CheckWebsite method for {ServiceName} [RequestId: {RequestId}]", serviceName, requestId);
            return StatusCode(500, new { 
                error = "Critical error", 
                message = ex.Message,
                service = serviceName,
                requestId = requestId,
                timestamp = DateTime.UtcNow
            });
        }
    }
}
