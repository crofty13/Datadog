# Use the official .NET 9.0 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["DatadogChecker.csproj", "./"]
RUN dotnet restore "DatadogChecker.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "DatadogChecker.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "DatadogChecker.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Use the official .NET 9.0 runtime image for running
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app

# Create logs directory
RUN mkdir -p /app/logs

# Copy published application
COPY --from=publish /app/publish .

# Set environment variables for ASP.NET Core
ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080

# Expose port
EXPOSE 8080

# Set the entry point
ENTRYPOINT ["dotnet", "DatadogChecker.dll"]
