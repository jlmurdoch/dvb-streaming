# TVHeadend

## Obtaining Software

Most distros have something that can work out-of-the-box:
```
sudo apt install tvheadend
```

If cutting edge is required, go to the [TVHeadend Downloads page](https://tvheadend.org/p/downloads) to get a dedicated repo. This is what can be used to set up a Debian-based package repo:
```
$ curl -1sLf 'https://dl.cloudsmith.io/public/tvheadend/tvheadend/setup.deb.sh' | sudo -E bash
```

## Initial Configuration

The user will be prompted for a admin password if installing at the command-line. 

Once running, TVHeadend is available on HTTP at port 9981:
http://192.168.1.244:9981/extjs.html

An setup wizard will greet the user - this can mostly be bypassed if the muxes are known.

Recommended **manual** setup steps are:
- Create a dedicated no-auth user if this is on a home network
  - Users > Access Entries:
    - Username: `*`
    - Change parameters: `Rights`
  - Users > Passwords:
    - Username: `*`
    - Password: `<blank>`
- Disable digest auth - it doesn't work on iOS devices.
  - General > Base:
    - Authentication type: `Plain`

If access is problematic because of the digest authentication, the following can be edited:
```
$ vi /var/lib/tvheadend/config
{
    ...
    "digest": 0
    ...
}
```

## DVB Input Setup

Generally the flow for setting up is to assign a multiplex to a network, which is then attached to an adapter or switch assigned to an adapter. 

This is a worked example of adding a mux down to the DiSEqC switch:

#### Step 1: Adapter setup example
- Configuration
  - DVB Inputs
    - TV adapters
      - Adapter
        - Enabled: `true`
        - Satellite config: `4-port Switch`
      - Conditional Access Module (CAM)
        - Enabled: `true`

#### Step 2: Network setup example
- Configuration
  - DVB Inputs
    - Networks
      - Add
        - Enabled: `true`
        - Name: `19.2E: Astra`
        - Orbital postion: `19.2E : ...`

#### Step 3: Mux Setup example
- Configuration
  - DVB Inputs
    - Muxes
      - Add
        - Network: `19.2E: Astra`
          - Delivery system: `DVB-S2`
          - Frequency (kHz): `10758000`
          - Symbol rate (Sym/s): `22000000`
          - Polarisation: `V`

#### Step 4: Enabling it all
- Configuration
  - DVB Inputs
    - TV adapters
      - Adapter
        - 4-port-switch
          - AB: `19.2E: Astra`

A scan should be then initiated. if not...

#### Step 5: Forcing a scan
- Configuration
  - DVB Inputs
    - Networks
      - Click `19.2E: Astra`
      - Click **Force Scan**

## Creating Channels

To publish discovered services as channels, there's a button that can do it all:
- Configuration
  - DVB Inputs
    - Services
      - Click **Map services**

[Here is a channel mapper script](channel_mapper/README.md) that allows a pre-defined service list to be imported in order using the TVHeadend API.