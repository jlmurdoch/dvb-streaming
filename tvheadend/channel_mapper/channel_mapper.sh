#!/bin/bash

USERNAME=admin
PASSWORD=testpass
HOST=localhost

CHANNEL_NUM=$1
if ! [[ $1 =~ ^[0-9]+$ ]] 
then
    echo "Not a valid starting number: $1"
    exit 1
fi

SERVICE_LIST=$2

if [ -z "$SERVICE_LIST" ] || [ ! -f "$SERVICE_LIST" ]
then
    echo "Not a valid file for channel mapping"
    exit 1
fi

# Download the list of services from tvheadend
curl -u $USERNAME:$PASSWORD http://$HOST:9981/api/raw/export?class=service \
    | jq -r '.[] | [.uuid, .sid, .svcname] | @tsv' > /tmp/temp-servicelist.tsv

# For each line in the channel mapping file...
while read LINE; 
do
    # Check the data to make sure it starts with a number and a tab
    if ! [[ $LINE =~ ^[0-9]+.*$ ]]
    then
        echo "Skipping"
        exit 1
    fi

    # Get the matching service
    SERVICE_UUID=$(grep -m 1 "$LINE" temp.tsv | awk '{print $1}')

    # Build the channel mapping payload
    CONF_PAYLOAD="conf={\"enabled\":true,\"number\":$CHANNEL_NUM,\"services\":[\"$SERVICE_UUID\"]}"
 
    # Map the channel over the API
    curl -u $USERNAME:$PASSWORD http://$HOST:9981/api/channel/create \
         -d $CONF_PAYLOAD

    # Print out the channel and details for troubleshooting
    echo " - $CHANNEL_NUM $LINE"

    # Increment the channel number
    ((CHANNEL_NUM=CHANNEL_NUM+1))
done < $SERVICE_LIST

rm /tmp/temp-servicelist.tsv
