FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /app

# הגדרת מיקום ספציפי לחבילות NuGet
ENV NUGET_PACKAGES=/root/.nuget/fallbackpackages

# העתקת קובצי הפרויקט בלבד
COPY yael_project.csproj ./
RUN dotnet nuget locals all --clear
RUN dotnet restore --packages $NUGET_PACKAGES --disable-parallel

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
