# שלב הבנייה - שימוש ב-Alpine לשמירת זיכרון
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

# הגדרת סביבת העבודה
WORKDIR /app

# שימוש בזיכרון יעיל ל-NuGet
ENV NUGET_PACKAGES=/root/.nuget/packages

# העתקת הקבצים הדרושים לשלב ה-Restore בלבד (מונע החזקת קבצים מיותרים)
COPY *.csproj ./
RUN dotnet restore

# העתקת שאר קבצי הפרויקט
COPY . ./

# בניית הפרויקט ושמירה על קבצים מינימליים בלבד
RUN dotnet publish -c Release -o /app/publish --no-restore \
    && rm -rf /root/.nuget/packages \
    && rm -rf /app/bin /app/obj  # ניקוי קבצי בנייה

# שלב ההרצה - שימוש ב-Alpine כדי לחסוך בזיכרון
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

# הגדרת סביבת העבודה
WORKDIR /app

# העתקת התוצאה מהשלב הקודם
COPY --from=build /app/publish .

# יצירת תיקיות הכרחיות ואבטחת הרשאות
RUN mkdir -p /app/wwwroot/media /app/wwwroot/css /app/wwwroot/js /app/wwwroot/lib /app/App_Data \
    && mkdir -p /app/Logs /app/Temp /app/Umbraco /app/Config \
    && chmod -R 777 /app/wwwroot /app/App_Data /app/Logs /app/Temp /app/Umbraco /app/Config \
    && rm -rf /app/wwwroot/media/* /app/App_Data/TEMP/* /app/Logs/*  # ניקוי קבצים מיותרים

# הפחתת צריכת זיכרון ב-.NET
ENV DOTNET_gcServer 1
ENV DOTNET_GCHeapHardLimit 400000000
ENV DOTNET_GCConserveMemory 1
ENV DOTNET_GCHeapHardLimitPercent 80

# מניעת בעיות ב-HTTP2 מול שרתים חיצוניים
ENV DOTNET_SYSTEM_NET_HTTP_SOCKETSHTTPHANDLER_HTTP2UNENCRYPTEDSUPPORT false

# התקנת תלות מינימלית בלבד
RUN apk add --no-cache libc6-compat icu-libs

# הגדרת הפורט להפעלה
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# הרצת האפליקציה
ENTRYPOINT ["dotnet", "yael_project.dll"]
