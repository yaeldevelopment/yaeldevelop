# השתמש בתמונה הרשמית של .NET SDK לבניית האפליקציה
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# קביעת תיקיית העבודה
WORKDIR /app

# שימוש בתיקיית NuGet מותאמת לשיפור השימוש במטמון של הבנייה
ENV NUGET_PACKAGES=/root/.nuget/packages

# העתקת קבצי .csproj ראשונים כדי לשחזר את התלויות
COPY *.csproj ./ 
RUN dotnet restore

# העתקת שאר הקוד של האפליקציה
COPY . ./ 

# פרסום האפליקציה במצב Release
RUN dotnet publish -c Release -o /app/publish

# השתמש בתמונה הרשמית של .NET Runtime להפעלת האפליקציה
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# התקנת תלויות עבור Alpine
RUN apk add --no-cache \
    libc6-compat \
    icu-libs \
    zlib

# קביעת תיקיית העבודה
WORKDIR /app

# העתקת תוצרי הבנייה משלב הבנייה
COPY --from=build /app/publish . 

# יצירת ספריות נדרשות עבור Umbraco והגדרת הרשאות
RUN mkdir -p /app/wwwroot/media /app/wwwroot/css /app/wwwroot/js /app/wwwroot/lib /app/App_Data \
    && mkdir -p /app/Logs /app/Temp /app/Umbraco /app/Config \
    && chmod -R 777 /app/wwwroot /app/App_Data /app/Logs /app/Temp /app/Umbraco /app/Config

# קביעת משתנה הסביבה של ASP.NET Core URLs
ENV ASPNETCORE_URLS=http://+:8080

# חשיפת פורטים
EXPOSE 8080

# הפעלת האפליקציה
ENTRYPOINT ["dotnet", "yael_project.dll"]
