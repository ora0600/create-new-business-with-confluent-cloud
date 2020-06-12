#!/bin/bash

###### set environment variables
# CCloud environment CMWORKSHOPS, have to be created before
source env-vars

pwd > basedir
export BASEDIR=$(cat basedir)
echo $BASEDIR

###### Create cluster automatically

# CREATE CCLOUD cluster 
ccloud update
ccloud login
# create environment 
echo "Create new environment $XX_CCLOUD_ENVNAME"
ccloud environment create $XX_CCLOUD_ENVNAME > environment
export CCLOUD_ENVID=$(sed 's/|//g' environment | awk '/Id/{print $NF}')
ccloud environment use $CCLOUD_ENVID
# Cluster1
echo "Create new cluster $XX_CCLOUD_CLUSTERNAME"
ccloud kafka cluster create $XX_CCLOUD_CLUSTERNAME --cloud 'gcp' --region 'europe-west1' --type basic -o yaml > clusterid1
# set cluster id as parameter
export CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
export CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')
echo $CCLOUD_CLUSTERID1
echo $CCLOUD_CLUSTERID1_BOOTSTRAP
ccloud kafka cluster use $CCLOUD_CLUSTERID1
ccloud kafka cluster describe $CCLOUD_CLUSTERID1 -o human
# create API Keys
ccloud api-key create --resource $CCLOUD_CLUSTERID1 --description "API Key for cluster user" -o yaml > apikey1
export CCLOUD_KEY1=$(awk '/key/{print $NF}' apikey1)
export CCLOUD_SECRET1=$(awk '/secret/{print $NF}' apikey1)
echo $CCLOUD_KEY1
echo $CCLOUD_SECRET1
# create property-file for ccloud user1
echo "ssl.endpoint.identification.algorithm=https
sasl.mechanism=PLAIN
request.timeout.ms=20000
bootstrap.servers=$CCLOUD_CLUSTERID1_BOOTSTRAP
retry.backoff.ms=500
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"$CCLOUD_KEY1\" password=\"$CCLOUD_SECRET1\";
security.protocol=SASL_SSL" > ccloud_user1.properties
echo "************************************************"

echo "⌛ Cluster is created give it 2 Minutes to start..."
sleep 120

# create topic
# topic in ccloud
echo "Create topics in cluster"
ccloud kafka topic create competitionprices --cluster $CCLOUD_CLUSTERID1
echo "Topic competitionprices created"
ccloud kafka topic create orders --cluster $CCLOUD_CLUSTERID1
echo "Topic orders created"

# open Price Checker
echo "Open microserice Terminal with iterm...."
open -a iterm
sleep 10
osascript 01_pricechecker.scpt $BASEDIR $CCLOUD_CLUSTERID1_BOOTSTRAP $CCLOUD_KEY1 $CCLOUD_SECRET1
echo ">>>>>>>>>> Start Microservice to check prices..."
echo ">>>>>>>>>> Now switch to iTerm 2 and see producing and consuming"
echo ">>>>>>>>>> login into ccloud to show prices from competition and later orders"

# Create KSQLDB APP
echo "create ksqldb APP"
ccloud ksql app create realtimeprices --cluster $CCLOUD_CLUSTERID1 > ksqldbid
export CCLOUD_KSQLDB_REST=$(sed 's/|//g' ksqldbid | awk '/Endpoint/{print $NF}')
export CCLOUD_KSQLDB_ID=$(sed 's/|//g' ksqldbid | awk '/Id/{print $NF}')
echo "************************************************"
echo "⌛ Give KSQLDB APP 12 Minutes to start...in the meatime I explain web scraping"
sleep 720

echo "Add acl to topics for ksqldb"
ccloud ksql app configure-acls $CCLOUD_KSQLDB_ID order competitionprices --cluster $CCLOUD_CLUSTERID1
echo "Create API Key for REST Access"
ccloud api-key create --resource $CCLOUD_KSQLDB_ID --description "API KEY for KSQLDB cluster $CCLOUD_KSQLDB_ID" > ksqldbapi
export CCLOUD_KSQLDBKEY1=$(sed 's/|//g' ksqldbapi | awk '/API Key/{print $NF}')
export CCLOUD_KSQLDBSECRET1=$(sed 's/|//g' ksqldbapi | awk '/Secret/{print $NF}')
echo "#########  Following actions for you ############"
echo "Add the following Code to KSQLDB to add a stream and a table"
PRETTY_CODE="\e[1;100;37m"
printf "${PRETTY_CODE}%s\e[0m\n" "${1}"
# Add streams to KSQLDB
STREAM="CREATE STREAM competitionprices
  (rowkey STRING KEY,
   shop VARCHAR,
   title VARCHAR,
   pricestr VARCHAR,
   pricefloat DOUBLE)
  WITH (KAFKA_TOPIC='competitionprices',
        VALUE_FORMAT='JSON');"
printf "${PRETTY_CODE}%s\e[0m\n" "${STREAM}"
TABLE="CREATE TABLE competitionprices_table AS
  SELECT title as productname, shop, min(pricefloat) AS lowestprice_1minutes
  FROM competitionprices WINDOW TUMBLING (SIZE 1 MINUTES)
  GROUP BY title,shop
  EMIT CHANGES;"        
printf "${PRETTY_CODE}%s\e[0m\n" "${TABLE}"
QUERY="SELECT ROWKEY,productname, shop, lowestprice_1minutes-(lowestprice_1minutes/100) as ourPrice from competitionprices_table emit changes limit 1;"
printf "${PRETTY_CODE}%s\e[0m\n" "${QUERY}"
echo "Try ksqldb cli..."
KSQLCLI="ksql -u $CCLOUD_KSQLDBKEY1  -p $CCLOUD_KSQLDBSECRET1 $CCLOUD_KSQLDB_REST"
printf "${PRETTY_CODE}%s\e[0m\n" "${KSQLCLI}"
echo "Try ksqldb rest via curl..."
CURLREST="curl -X \"POST\" \"$CCLOUD_KSQLDB_REST/query\" \
     -H \"Content-Type: application/vnd.ksql.v1+json; charset=utf-8\" \
     -u '$CCLOUD_KSQLDBKEY1:$CCLOUD_KSQLDBSECRET1' \
     -d $'{
           \"ksql\": \"SELECT lowestprice_5minutes-(lowestprice_5minutes/100) as ourPrice from competitionprices_table emit changes limit 1;\",
           \"streamsProperties\": {}
        }'|jq"
printf "${PRETTY_CODE}%s\e[0m\n" "${CURLREST}"
echo "Replace in APEX function getlowestPriceFromCC"
APEX="l_clob := apex_web_service.make_rest_request(
        p_url => '$CCLOUD_KSQLDB_REST/query',
        p_username => '$CCLOUD_KSQLDBKEY1',
        p_password => '$CCLOUD_KSQLDBSECRET1',
        p_http_method => 'POST',
        p_body => l_payload
   );"
printf "${PRETTY_CODE}%s\e[0m\n" "${APEX}"
# Finish
echo "Cluster $XX_CCLOUD_CLUSTERNAME created"
