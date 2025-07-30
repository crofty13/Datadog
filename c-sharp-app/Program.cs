using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Hosting;
using System.Net.Http;

var app = WebApplication.Create(args);
app.MapGet("/", () => "Hello from Datadog-instrumented .NET app!");
app.MapGet("/call-external", async context =>
{
    using var http = new HttpClient();
    var result = await http.GetStringAsync("https://httpbin.org/get");
    await context.Response.WriteAsync(result);
});
app.Run();

