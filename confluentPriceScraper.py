# see youtube video https://youtu.be/Bg9r_yLk7VY
# pip3 install requests bs4 confluent_kafka uuid
# create topic competitionprices
# The -1 percent Webshop
import sys
import uuid
import requests
from bs4 import BeautifulSoup
from confluent_kafka import Producer
import time
from datetime import datetime
import os

command = sys.argv[0] # prints python_script.py
cluster = sys.argv[1] # cluster
key     = sys.argv[2] # API Key
secret  = sys.argv[3] # API Secret

# Product competition
SHOP= 'Apple'
#URL = 'https://www.amazon.de/Apple-MacBook-dual-core-Prozessor-10-Generation/dp/B0863YN36M'
#URL = 'https://www.amazon.de/Apple-MacBook-dual-core-Prozessor-10-Generation/dp/B0863ZJ1T3/'
URL = 'https://www.apple.com/de/shop/buy-mac/macbook-air'
productName = 'Apple MacBook Air 13 Zoll'
title = productName
# Browser user-agent simulation
headers = {"User-Agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36'}
# topicname
topic= 'competitionprices'
p = Producer({
    'bootstrap.servers': cluster,
    'sasl.mechanism': 'PLAIN',
    'security.protocol': 'SASL_SSL',
    'sasl.username': key,
    'sasl.password': secret
})

def acked(err, msg):
    """Delivery report callback called (from flush()) on successful or failed delivery of the message."""
    if err is not None:
        print("failed to deliver message: {}".format(err.str()))
    else:
        print("produced to: {} [{}] @ {}".format(msg.topic(), msg.partition(), msg.offset()))

print("~ Price Tracker for the Webshop 1% under "+SHOP+" ~")
print("~~ Get price from "+SHOP+": ")
iters = 0  # counts the number of price checks done
while True:
    iters += 1
    print("\nCheck #", iters, "on:", datetime.today())
    # call website
    page    = requests.get(URL, headers=headers)
    soup    = BeautifulSoup(page.content, 'html.parser')
    # Get title
    #title   = soup.find(id="productTitle")
    titles   = soup.select('#model-selection > bundle-selection > store-provider > div.as-l-container.as-bundleselection-container > div > div.as-bundleselection-modelvariationsbox.row > div > div.as-macbundle.column.large-4.small-12.as-macbundle-offset2 > div > bundle-selector > div.as-slide-swapper.as-macbtr-details > div.as-macbtr-options.as-bundleselection-modelshown.acc_MWTJ2D\/A.rs-noAnimation > div > h3')
    title_text = productName
    for title in titles:
        title_text = title.get_text(strip=True)
    # Get price
    #price   = soup.find(id="priceblock_ourprice")
    prices = soup.select('#model-selection > bundle-selection > store-provider > div.as-l-container.as-bundleselection-container > div > div.as-bundleselection-modelvariationsbox.row > div > div.as-macbundle.column.large-4.small-12.as-macbundle-offset2 > div > bundle-selector > div.as-slide-swapper.as-macbtr-details > div.as-macbtr-options.as-bundleselection-modelshown.acc_MWTJ2D\/A.rs-noAnimation > div > div.as-price > span.as-price-currentprice > span')
    price_text = 'No price'
    price1 = 1199.00
    for price in prices:
        price_text = price.get_text(strip=True)
        price1  = float(price_text[0:8].replace(".","").replace(",","."))
    # Get the data
    print(SHOP + " for product "+productName)
    print("===> "+title_text)
    print("===> "+price_text)
    print("===> "+ str(price1))
    print("===> our price: " + str(price1-(price1/100)))
    # produce
    # Serve on_delivery callbacks from previous calls to produce()
    p.poll(0.0)
    try:
            msg_key   = productName
            msg_value = '{ "shop":"'+ SHOP +'","title":"' + title_text +'","pricestr":"'+ price_text +'","pricefloat":'+ str(price1) +'}'
            print(msg_value)
            p.produce(topic=topic, key=msg_key, value=msg_value, on_delivery=acked)
            time.sleep(30)
    except KeyboardInterrupt:
        break

print("\nFlushing {} records...".format(len(p)))
p.flush()



# Now produce Data in Kafka