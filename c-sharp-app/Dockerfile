# Build stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

# Runtime stage with Datadog Tracer injection
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /app

# Copy published app
COPY --from=build /app ./

# Set entrypoint
ENTRYPOINT ["dotnet", "hello-datadog-dotnet.dll"]
