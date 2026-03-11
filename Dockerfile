# ─────────────────────────────────────────────────────────────
# Stage 1: Build WAR with Maven
# ─────────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Cache dependencies layer separately
COPY pom.xml .
RUN mvn dependency:go-offline -B -q

# Build (skip test compilation to speed up image build)
COPY src ./src
RUN mvn clean package -DskipTests -B -q

# ─────────────────────────────────────────────────────────────
# Stage 2: Run on Tomcat 10 (required for Jakarta EE 6)
# ─────────────────────────────────────────────────────────────
FROM tomcat:10.1-jdk17-temurin

# Remove default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Deploy as ROOT so app is served at / instead of /ClickEat2
COPY --from=build /app/target/ClickEat2-1.0-SNAPSHOT.war \
                  /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
