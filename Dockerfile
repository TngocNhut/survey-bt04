FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B -ntp clean package

FROM tomcat:9.0-jdk21-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/ch04survey.war /usr/local/tomcat/webapps/ROOT.war
ENV JAVA_OPTS="-Xms64m -Xmx256m"
EXPOSE 8080
CMD ["sh", "-c", "sed -i 's/port=\"8080\"/port=\"'${PORT:-8080}'\"/' /usr/local/tomcat/conf/server.xml && exec catalina.sh run"]
