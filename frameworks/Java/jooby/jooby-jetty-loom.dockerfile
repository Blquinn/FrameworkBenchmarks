FROM maven:3-eclipse-temurin-19-focal as maven

WORKDIR /jooby-jetty-loom
RUN apt -qq update && apt -qq install -y git && \
    git clone https://github.com/Blquinn/jooby-jetty-loom.git && \
    cd jooby-jetty-loom && \
    mvn -q install

WORKDIR /jooby
COPY pom.xml pom.xml
COPY src src
COPY public public
RUN mvn package -q -P jetty-loom

FROM eclipse-temurin:19-jre-focal
WORKDIR /jooby
COPY --from=maven /jooby/target/jooby.jar app.jar
COPY conf conf

EXPOSE 8080

CMD ["java", "-server", "-Xms4g", "-Xmx4g", "-XX:+UseStringDeduplication", "-XX:+UseNUMA", "-XX:+UseParallelGC", "--enable-preview", "-jar", "app.jar"]
