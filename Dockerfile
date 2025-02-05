# שימוש בתמונה עדכנית ויציבה יותר
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# הגדרת מיקום ספציפי לחבילות NuGet
ENV NUGET_PACKAGES=/app/packages

# העתקת קובצי הפרויקט בלבד
COPY *.csproj ./
RUN dotnet restore --no-cache --force-evaluate --packages /app/packages

# העתקת שאר הקבצים
COPY . ./

# בניית האפליקציה
RUN dotnet publish -c Release -o /app/publish --no-restore

# שלב הריצה
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

WORKDIR /app

# העתקת האפליקציה
COPY --from=build /app/publish .

# הרצת האפליקציה
ENTRYPOINT ["dotnet", "yael_project.dll"]
