This is a dirty script to map a list services as channels in TVHeadend.
 - It will order the channels using a starting number.
 - The services need to exist in TVHeadend

The list looks like this, with SID, Name and the order to be mapped:
```
10301	Das Erste HD
11110	ZDF HD
12003	RTL Television
17500	SAT.1
17501	ProSieben
```

It then can be applied like this, starting from channel number 3001:
./channel_mapper.sh 3001 svc-de-free.tsv

If a full list of SIDs and channel names are needed, the following will help: 
```
curl -u admin:password http://localhost:9981/api/raw/export?class=service \
    | jq -r '.[] | [.sid, .svcname] | @tsv' > master-list.tsv
```
