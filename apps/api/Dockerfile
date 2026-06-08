FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY PendlerPuls.sln .
COPY apps/api/PendlerPuls.Api.csproj apps/api/
RUN dotnet restore apps/api/PendlerPuls.Api.csproj

COPY apps/api/ apps/api/
RUN dotnet publish apps/api/PendlerPuls.Api.csproj \
    --configuration Release \
    --output /app/publish \
    --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "PendlerPuls.Api.dll"]

