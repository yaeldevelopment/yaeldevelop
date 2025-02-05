# שלב הבנייה עם תמונת SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# הגדרת תיקיית עבודה
WORKDIR /app

# שימוש ב-NuGet cache לשיפור ביצועים
ENV NUGET_PACKAGES=/root/.nuget/packages

# העתקת קבצי הפרויקט ושימוש ב-caching עבור restore
COPY *.csproj ./
RUN dotnet restore --no-cache

# העתקת שאר קבצי הקוד
COPY . ./

# פרסום עם אופטימיזציות ReadyToRun ו-Trimming
RUN dotnet publish -c Release -o /app/publish \
    -p:PublishTrimmed=true -p:PublishReadyToRun=true \
    --self-contained false

# שלב הריצה עם תמונה קטנה יותר
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# הגדרת תיקיית עבודה
WORKDIR /app

# העתקת התוצאה מהשלב הקודם
COPY --from=build /app/publish .

# יצירת ספריות הדרושות והגדרת הרשאות
RUN mkdir -p /app/wwwroot/media /app/wwwroot/css /app/wwwroot/js /app/wwwroot/lib /app/App_Data \
    && mkdir -p /app/Logs /app/Temp /app/Umbraco /app/Config \
    && chmod -R 777 /app/wwwroot /app/App_Data /app/Logs /app/Temp /app/Umbraco /app/Config

# הגדרת משתני סביבה
ENV ASPNETCORE_URLS=http://+:8080 \
    DOTNET_GCServer=0 \
    DOTNET_System_Globalization_Invariant=true

# חשיפת הפורט
EXPOSE 8080

# הפחתת ספריות מיותרות
RUN apt-get update && apt-get install -y --no-install-recommends \
    libc6-dev libicu-dev && rm -rf /var/lib/apt/lists/*

# הפעלת האפליקציה
ENTRYPOINT ["dotnet", "yael_project.dll"]
