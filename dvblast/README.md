# DVBlast

## Enabling Multicast
To stream data, on the host system:
- Enable multicast kernel options if not done so (CONFIG_IP_MULTICAST, CONFIG_IP_MROUTE 
- Add the route for multicast traffic:
```
$ sudo route add -net 239.255.0.0 netmask 255.255.255.0 wlan0
```

On any intermediate router / firewall, disabling **IGMP snooping** is required.

## Stream transmission
To stream a channel using DVBlast, create a configuration with the channel SID, this being TGCom24 Italian news channel:
```
$ cat tgcom24.conf 
239.255.0.1:1234  1  128 	# Free to air Italian news on SID 128
```

The following command will stream with the respective properties:
   - Second adapter
   - DiSEqC port 3 of 4
   - 11432MHz tuning frequency
   - 29900k symbols/sec
   - Vertical polarisation (13 volts)
```
$ dvblast -a 1 -S 3 -f 11432000 -s 29900000 -v 13 -c tgcom24.conf
```

## Stream reception
On VLC, open up `rtp://@239.255.0.1:1234` to access the stream.

## Conditional Access Module access
If a Conditional Access Module (CAM) is inserted into a Common Interface (CI) slot to perform decryption, it should work out of the box with DVBlast.

If there are issues with the CAM, it can be interacted with as follows:

Open up a socket in one shell:
```
dvblast -a 1 -S 3 -f 11432000 -s 29900000 -v 13 -r /tmp/dvblast.sock
```

Then access the CAM menu in another shell:
```
dvblast_mmi.sh -r /tmp/dvblast.sock
```
