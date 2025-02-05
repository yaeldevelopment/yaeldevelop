# השתמש בתמונה של .NET Runtime מבוססת Alpine (קטנה יותר)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# קביעת תיקיית העבודה
WORKDIR /app

# הגדרת משתנה סביבה למניעת בעיות עם תרבויות
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# התקנת חבילות נדרשות עבור Umbraco
RUN apk add --no-cache \
    libc6-compat \
    icu-libs \
    zlib \
    && rm -rf /var/cache/apk/*

# העתקת קבצי הבנייה מהשלב הקודם
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
