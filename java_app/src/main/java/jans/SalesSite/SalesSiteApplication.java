package jans.SalesSite;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

//RUN IT: mvn spring-boot:run
//RUN IT WITH PARAMETERS: mvn spring-boot:run -Dspring-boot.run.arguments=--ksql.url=http://localhost:8088
//ACCESS IT: http://localhost:8080/sale.html

@SpringBootApplication
public class SalesSiteApplication {

	public static void main(String[] args) {
		SpringApplication.run(SalesSiteApplication.class, args);
	}

}
