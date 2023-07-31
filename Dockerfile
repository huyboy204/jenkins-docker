# Use the official Alpine base image with OpenJDK 17 JRE
FROM adoptopenjdk:17-jre-hotspot-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the Spring Boot application JAR file into the container and change ownership to the 'nobody' user
COPY target/spring-petclinic-3.1.0-SNAPSHOT.jar /app/spring-petclinic-3.1.0-SNAPSHOT.jar
RUN chown nobody:nogroup /app/spring-petclinic-3.1.0-SNAPSHOT.jar

# Expose the port on which the Spring Boot application will run
EXPOSE 8080

# Switch to the 'nobody' user before running the application
USER nobody

# Set the command to run the Spring Boot application when the container starts
CMD ["java", "-jar", "spring-petclinic-3.1.0-SNAPSHOT.jar"]