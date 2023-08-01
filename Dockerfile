FROM openjdk:17-alpine

WORKDIR /app

COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar /app/spring-petclinic-3.1.0-SNAPSHOT.jar
RUN chown nobody:nogroup /app/spring-petclinic-3.1.0-SNAPSHOT.jar
RUN mkdir -p logs
RUN chown nobody:nogroup /app/logs/

EXPOSE 8080

USER nobody

CMD ["sh", "-c", "java -jar spring-petclinic-3.1.0-SNAPSHOT.jar | tee /app/logs/logs.txt"]
# RUN java -jar spring-petclinic-3.1.0-SNAPSHOT.jar | tee /app/logs/logs.txt