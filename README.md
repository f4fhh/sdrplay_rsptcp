# sdrplay_rsptcp
Docker container for rsp_tcp, a linux I/Q stream server for SDRPlay RSP1, RSP1A, RSP2, RSPDuo (single tuner mode)

It works with compatible devices including:
* RSP1, RSP1A, RSP2, RSPDuo (single tuner mode) SDRPlay devices

### Defaults
* Port 1234/tcp is used for the I/Q data stream and is exposed by default

### User Configured Environment Variables
Defaults:
* PORT=1234
* GAIN_REDUCTION=34
* GAIN_AUTO=-34
* GAIN_LOOP=0
* LNA=2
* DEVICE=1
* ANTENNA=1

#### Example docker run

```
docker run -d \
-e GAIN_REDUCTION=30 \
--restart unless-stopped \
--name='sdrplay_rsptcp' \
--device=/dev/bus/usb \
f4fhh/sdrplay_rsptcp
```
### HISTORY
 - Version 0.1.0: Initial build

### Credits
 - [SDRPlay](https://github.com/SDRplay) for the SDK of the RSP devices
 - [Bas ON5HB](https://github.com/ON5HB) for rsp_tcp fixes and enhancements