#!/bin/bash

###### set environment variables
source env-vars
# CCloud environment CMWORKSHOPS
CCLOUD_ENVID=$(sed 's/|//g' environment | awk '/Id/{print $NF}')
CCLOUD_KSQLDB_ID=$(sed 's/|//g' ksqldbid | awk '/Id/{print $NF}')
CCLOUD_CLUSTERID1=$(awk '/id:/{print $NF}' clusterid1)
CCLOUD_CLUSTERID1_BOOTSTRAP=$(awk '/endpoint: SASL_SSL:\/\//{print $NF}' clusterid1 | sed 's/SASL_SSL:\/\///g')
CCLOUD_KEY1=$(awk '/key/{print $NF}' apikey1)
CCLOUD_KSQLDBKEY1=$(sed 's/|//g' ksqldbapi | awk '/API Key/{print $NF}')
MICROSERVICE=$(jobs -l | grep mvn | cut -c6-10)

#kill microservice
kill -9 $MICROSERVICE

# DELETE CCLOUD cluster 
ccloud login
# use environment 
ccloud environment use $CCLOUD_ENVID
# drop topic in ccloud
ccloud kafka topic delete competitionprices --cluster $CCLOUD_CLUSTERID1
ccloud kafka topic delete orders --cluster $CCLOUD_CLUSTERID1
# delete KSQLDB APP
ccloud api-key delete $CCLOUD_KSQLDBKEY1
ccloud ksql app delete $CCLOUD_KSQLDB_ID
# delete API Key
ccloud api-key delete $CCLOUD_KEY1
# Delete cluster
ccloud kafka cluster delete $CCLOUD_CLUSTERID1
# delete environment
ccloud environment delete $CCLOUD_ENVID
# Delete files
rm basedir
rm apikey1
rm ccloud_user1.properties
rm clusterid1
rm environment
rm ksqldbapi
rm ksqldbid
# Finish
echo "Cluster $XX_CCLOUD_CLUSTERNAME dropped"
