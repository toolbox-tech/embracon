FROM openjdk:11-jre-slim

# Set the working directory
WORKDIR /app

# Copy the application JAR file
COPY target/myapp.jar myapp.jar

# Expose the application port
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "myapp.jar"]