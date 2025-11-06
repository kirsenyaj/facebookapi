# Stage 1 — build the application
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy only pom first to cache dependencies
COPY pom.xml .
RUN mvn -B -e -T1C dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn -B -e -T1C package -DskipTests

# Stage 2 — runtime image
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app
COPY --from=build /workspace/target/*-SNAPSHOT.jar app.jar
RUN chown appuser:appgroup /app/app.jar
USER appuser

EXPOSE 8080

ENV JAVA_OPTS=""

ENTRYPOINT [ "sh", "-c", "java $JAVA_OPTS -jar /app/app.jar" ]