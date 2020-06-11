# Create webshop in Oracle APEX
Create an account in apex.oracle.com. It is free of charge.
go to [apex.oracle.com](https://apex.oracle.com/en/learn/getting-started/) and request a new workspace.
Login into apex via [apex login](https://apex.oracle.com/pls/apex/f?p=4550) with your created credentials.
In Application Builder import the Apex app[my webshop MVP](f32002.sql) into Oracle Apex.
In SQL Workshop->SQL Command execute the plsql functions script [getlowestPriceFromCC](plsql_pricechecker.sql).
Please be aware to use the right setting for connecting the KSQLDB APP REST. The output of cluster creation show you the right setting. Please replace with existing code:
```bash
# replace
  l_clob := apex_web_service.make_rest_request(
        p_url => 'KSQLDB APP Endpoint a laa https://.europe-west1.gcp.confluent.cloud:443/query',
        p_username => 'KSQLDBAPIKEX',
        p_password => 'KSQDBAPISECRET',
        p_http_method => 'POST',
        p_body => l_payload
   );
# with the output from 00_create_ccloudcluster.sh looks like this
l_clob := apex_web_service.make_rest_request(
        p_url => 'https://....confluent.cloud:443/query',
        p_username => 'XXXXXXXXXX',
        p_password => 'ZZZZZZZZZZZZZZZZZZZZZ',
        p_http_method => 'POST',
        p_body => l_payload
   );
```
If the application missed the data, please use this one [my Macbook Air](macbookair.png). You upload this picture into your application under Application Builder->Application 32002 - The -1% under Competition Price Webshop->Shared components. Please upload the file here under Files-> Static application files.

That's all your webshop is running.


