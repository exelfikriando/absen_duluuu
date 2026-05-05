# Stage 1: Build
FROM eclipse-temurin:21-jdk-jammy AS build
WORKDIR /app

# Copy seluruh project (karena struktur folder Anda bersarang)
COPY . .

# Pindah ke folder attendance-api dan beri izin eksekusi pada mvnw
WORKDIR /app/absen_dulu/attendance-api
RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# Stage 2: Run
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Ambil hasil build jar dari stage sebelumnya
COPY --from=build /app/absen_dulu/attendance-api/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
