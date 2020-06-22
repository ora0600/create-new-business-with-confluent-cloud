package jans.SalesSite;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.client.RestTemplate;

@Controller
public class WebController {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${ksql.url}")
    private String uri;

    @Value("${ksql.user}")
    private String user;

    @Value("${ksql.password}")
    private String password;

    @RequestMapping(value = "/special", method = RequestMethod.GET)
    public String showSale(Model uiModel) {
        Double price = 0.0;

        //set http headers
        HttpHeaders httpHeaders = new HttpHeaders();
        httpHeaders.set("Content-Type", "application/vnd.ksql.v1+json; charset=utf-8");
        httpHeaders.setBasicAuth(user, password);

        // create the HTTP POST request with JSON KSQL query
        String body = new String("{\"ksql\": \"SELECT lowestprice_1minutes-(lowestprice_1minutes/100) as ourPrice from competitionprices_table emit changes limit 1;\", \"streamsProperties\": {\"ksql.streams.auto.offset.reset\": \"earliest\"} }");
        HttpEntity<String> request = new HttpEntity<String>(body, httpHeaders);

        // call it using REST
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> responseEntityStr = restTemplate.
                postForEntity(uri + "/query", request, String.class);

        System.out.println(responseEntityStr.getBody());

        // parse th response to JSON and query it
        try {
            JsonNode root = objectMapper.readTree(responseEntityStr.getBody());
            price = root.get(1).fields().next().getValue().fields().next().getValue().get(0).asDouble();

        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }

        // add the price to UI model
        uiModel.addAttribute("price", price);
        return "special";
    }
}
