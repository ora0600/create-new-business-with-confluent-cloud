# Special Sale Java Application 
This is a Spring Boot Java that connects to ksqlDB server and queries the stored price in the ksqlDB KTable 

![Application Screenshot](/java_app/specialSaleApp.png)

Java code exectutes this query:
```
curl -X POST \
    http://localhost:8088/query \
    -H 'content-type: application/vnd.ksql.v1+json; charset=utf-8' \
    -d '{"ksql":"SELECT lowestprice_1minutes-(lowestprice_1minutes/100) as ourPrice from competitionprices_table emit changes limit 1;", "streamsProperties": {
      "ksql.streams.auto.offset.reset": "earliest"
    }}
```

## Requirements
  * Java 8
  * Maven

## Run the application
You can run it at any environment where java and maven are installed

Default arguments and their values
  * Tomcat server port --server.port=8080
  * ksqlDB server url --ksql.url=http://localhost:8088


You can run the app with the default arguments.
```
mvn spring-boot:run
```

Or you can overwrite the arguments if needed:
```
mvn spring-boot:run -Dspring-boot.run.arguments=--ksql.url=http://localhost:8088
mvn spring-boot:run -Dspring-boot.run.arguments=--server.port=8080
mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8080 --ksql.url=http://localhost:8088"
```

## Access the web app
If you are running it localy and have not changed the Tomcat port http://localhost:8080/sale.html

## Debug
Console will give you the ksqlDB server response.

