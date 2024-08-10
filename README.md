# DVB Streaming

## Overview

This is the process to follow get DVB streaming system going:

- Antenna / Dish Setup
- Software Setup
- Alignment & Discovery
  - Hardware constellation / transmitter locating
  - Software multiplex identification / scanning
  - Software fine-tuning with DVBlast / frontend monitoring
  - Further multiplex discovery
- Stream Transmission
  - DVBlast
  - TVHeadend
- Stream Reception
  - VLC
  - Kodi

## Antenna / Dish Setup

### Terrestrial DVB-T
For DVB-T, a half-wavelength dipole antenna is good enough.
```
------------  ------------
     ¼     |  |     ¼
          |G| S |G|
```

### Satellite DVB-S
For DVB-S, this is my current LNB setup using DiSEqC with a Triax dish and multi-LNB arm:

```
 GB       DE    IT  East
28.2     19.2  13.0 9.0
  O--------OA----O---O-
            H
```
## Hardware Setup

This will not be discussed in detail here, but this is a verified setup:

Example DVB-S2 hardware:
- Raspberry Pi Compute Module 4 + IO Board
- Alfa AWUS036ACH 
  - [Realtek 8812AU](https://github.com/morrownr/8812au-20210820)
- [TurboSight TBS6910 DVB-S2 Dual Tuner/CI PCI-E x1](https://github.com/jlmurdoch/dvb-pcie-tbs6910)
  - TAS2101 demodulator
  - AV201x tuner
- OR [TurboSight TBS QBox2 CI USB2.0](https://github.com/jlmurdoch/dvb-usb-tbsqbox2ci)
  - STV0903 demodulator
  - STB6100 tuner

## Software Setup
Install these packages to get DVB tested:
   - dvb-tools - frontend monitoring
   - dvblast - testing streams / CAM work
   - w-scan or w-scan-cpp - scanning

Also install the appropriate DVB kernel drivers (if needed).

## Alignment & Discovery

### Hardware constellation / transmitter locating
 
Hardware-aided location is recommended, as it is generally low-latency and can be placed next to the antenna as the physical adjustments are being made.

**Terrestrial**: Use a powered hardware finder or use an RTL-SDR.

**Satellite**: Use a in-line hardware finder: more responsive than software. A power-source and tuner are required, such as a TV or Set-Top Box (STB). Please see DVBlast below if an DVB-S adapter is to be used instead to tune into a frequency.

### Software multiplex identification / scanning
It is not guaranteed the antenna is pointing at the right constellation or transmitter, so verification is needed.

The software that can help identify the current position is `w_scan` or `w_scan_cpp`, as it does not need detailed initial tuning information:
```
# Terrestrial (DVB-T), British frequency (sweep scan, 8MHz [0 or +/-167kHz])
$ w_scan -c GB

# Satellite (DVB-S), Adapter 2, DiSEqC committed port 4, constellation 9.0E
$ w_scan -f s -a 1 -D 3c -s S9E0
```

If this is not the expected source, move the antenna / dish accordingly, repeating with the hardware scanner.

### Software fine-tuning with DVBlast / frontend monitoring

If the right multiplex is returned and the results are as expected, it is time to do some fine-tuning.

A strong signal might be received, but the quality of the transmission could be poor and needs to be rectified (e.g rotate an LNB to get better horizontal or vertical).

A configless tuner like dvblast can be used to tune-in and then a frontend monitor such as dvb-fe-tool can be used to look at signal quality:

#### DVB-T
```
# DVB-T on 506MHz
$ dvblast -f 498000000
$ dvb-fe-tool -m
```

#### DVB-S

```
# Adapter 2, DiSEqC 4/4, DVB-S2, Freq: 11938MHz, Horizontal, 27500k symbols
$ dvblast -a 1 -S 4 -5 DVBS2 -f 11938000 -v 18 -s 27500000
$ dvb-fe-tool -a 1 -m
```

### Further multiplex discovery

Sometimes a scan will not pick up every multiplex (mux) because of poor signal, etc. There should however be a master mux containing a Network Information Table (NIT), a listing of other multiplexes. Whatever the platform, it is good to find out at least one of these master muxes.

Both the w-scan and dvbv5-scan tools can accept the legacy format as follows:
```
$ w_scan -I <FILE> <other options>
$ dvbv5-scan -I CHANNEL <FILE> <other options>
```

Legacy DVB format with a few examples for DVB-T & DVB-S:
#### DVB-T
```
# Type Freq      BW   FECh FECl Trans  Mod Guard Hier PLP
T      498000000 8MHz 2/3  NONE QAM64  8k  1/32  NONE      # DVB-T
T2     474167000 8MHz 2/3  NONE QAM256 32k 1/128 NONE 0    # DVB-T2
```

#### DVB-S
```
# Type Freq     Pol Symbol   FEC Mod
S2     10773250 H   23000000 3/4 8PSK     # Astra 28.2 East
S2     10759000 V   22000000 2/3 8PSK     # Astra 19.2 East
S2     10719000 V   27500000 3/4 8PSK     # Hotbird 13.0 East
```

Minimal DVBV5 format for dvbv5-scan:

#### DVB-T
```
[DVBT2MUX]
	DELIVERY_SYSTEM = DVBT2
	FREQUENCY = 474167000
	BANDWIDTH_HZ = 8000000
```

#### DVB-S
```
[DVBS2MUX]
	LNB = EXTENDED
	DELIVERY_SYSTEM = DVBS2
	FREQUENCY = 10773000
	POLARIZATION = HORIZONTAL
	SYMBOL_RATE = 23000000
```

## Streaming Transmission

### DVBlast

DVBlast is useful not only for temporary tuning, but also for CAM testing or multicasting a set of channels over a local network. 

See the [separate DVBlast guide here](dvblast/README.md).

### TVHeadend

If a more permanent, organised and curatable streaming solution is needed, TVHeadend provides a solution with publishing and EPG services.

See the [separate TVHeadend guide here](tvheadend/README.md).

## Stream Reception

There are apps available for TVHeadend reception, but the following are more useful for laptop and SBC streaming:

### VLC

VLC can open both DVBlast and TVHeadend streams:
* DVBblast: `rtp://@<multicast-addr>:<port>`
* TVHeadend: `http://<host>:9981/playlist/channels`

### Kodi

There is a [TVHeadend HTSP Client](https://kodi.tv/addons/omega/pvr.hts/) add-on for the PVR functionality for Kodi. Just add host details, username and password.

#### LIRC
If an IR remote is to be used in Kodi (i.e. if it's a monitor or old TV where no HDMI-CEC is available), here is an example of an [LIRC config with mapping](kodi/).

#### Firmware playback optimisation
On some old SBC's, we can tweak the firmware blob using a HEX editor like `hexer` to improve performance. 

Process to patch the firmware: 
- Open up the `start*.elf` using `hexer`
- Search for the string `462H` or hex `47 E9 34 36 32 48`
- After `0x3C` or `0x1D`, look for `0x18`
- Swap the `0x18` with `0x1F`
  - use **x** to delete and **i** to insert, if using `hexer`
