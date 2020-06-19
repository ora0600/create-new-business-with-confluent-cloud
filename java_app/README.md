# MacBooc Sale Java Application 
This is a Spring Boot Java that connets to ksqlDB server and queries the stored price in the ksqlDB KTable 

## Requirements
  * Java 8
  * Maven

## Run the application
You can run it at any environment where java and maven are installed

Default arguments and their values
  * Tomcat server port --server.port=8080
  * ksqlDB server url --ksql.url=http://localhost:8088

Run the app with the default arguments 
```
mvn spring-boot:run
```

Run the app with your specific arguments (all three options displayed)
```
mvn spring-boot:run -Dspring-boot.run.arguments=--ksql.url=http://localhost:8088
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8080
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8080 --ksql.url=http://localhost:8088"
```

## Access the web app
If you are running it localy and have not changed the Tomcat port http://localhost:8080/sale.html

## Debug
Console will give you the ksqlDB server response.

