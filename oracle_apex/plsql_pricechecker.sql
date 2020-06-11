create or replace function getlowestPriceFromCC return varchar2 as
    l_clob        CLOB;
    l_payload     varchar2(4000) := NULL;
    l_price       varchar2(4000) := NULL;
BEGIN
   
  -- build the rest call service call
  apex_web_service.g_request_headers(1).name := 'Content-Type';
  apex_web_service.g_request_headers(1).value := 'application/vnd.ksql.v1+json; charset=utf-8';
  -- create payload
  l_payload := '{
           "ksql": "SELECT lowestprice_1minutes-(lowestprice_1minutes/100) as ourPrice from competitionprices_table emit changes limit 1;",
           "streamsProperties": {}
        }';
  l_clob := apex_web_service.make_rest_request(
        p_url => 'KSQLDB APP Endpoint a laa https://.europe-west1.gcp.confluent.cloud:443/query',
        p_username => 'KSQLDBAPIKEX',
        p_password => 'KSQDBAPISECRET',
        p_http_method => 'POST',
        p_body => l_payload
   );
   -- Get the correct price, the output would like this
   -- [{"header":{"queryId":"none","schema":"`OURPRICE` DOUBLE"}}, {"row":{"columns":[1107.81]}}, {"finalMessage":"Limit Reached"}]
   --  substr only the price
   l_price := replace(replace(replace(replace(replace(regexp_replace(l_clob, '[^0-9].[^0-9]', ''),
                                      '[',''),
                              ',',''),
                      ':'),''),
              ']','')||' EUR';
return l_price;
exception 
WHEN OTHERS THEN
      raise_application_error (-20002,'An error has occurred during REST-CALL');
      return 'ERROR';
END;
/