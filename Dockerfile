# ---------------------------------------
# 1) Build Stage
# ---------------------------------------
FROM maven:3.9.16-eclipse-temurin-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src/ ./src/

RUN mvn clean package -DskipTests

# ---------------------------------------
# 2) Runtime Stage (Using OpenTelemetry Java Agent)
# ---------------------------------------
FROM eclipse-temurin:17-jre

RUN addgroup --system oneretail && adduser --system --ingroup oneretail oneretail

WORKDIR /app

# Download OpenTelemetry Java Agent
RUN curl -sSL -o /app/splunk-otel-javaagent.jar https://github.com/signalfx/splunk-otel-java/releases/download/v2.12.0/splunk-otel-javaagent.jar

COPY --from=builder /app/target/oneretail-1.0.0.jar /app/oneretail.jar

USER oneretail

EXPOSE 8080
ENV environment=production

# Run the app with OpenTelemetry Java Agent
ENTRYPOINT ["java", "-javaagent:/app/splunk-otel-javaagent.jar", "-jar", "/app/oneretail.jar"]
#ENTRYPOINT ["java", "-jar", "/app/oneretail.jar"]
