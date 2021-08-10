# NZBGet: Efficient Usenet downloader
This add-on allows you to run NZBGet to download files from Usenet.

<!-- START_GEN_BADGES -->
 [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=feature/nzbget&label=armv7&env=ADDON=%22nzbget%22%20ARCH=%22armv7%22)](https://travis-ci.com/Taapie/hassio-addons)
<!-- END_GEN_BADGES -->

## About

NZBGet is a tool that is able to download file from Usenet servers. This addon builds on top of the Linuxserver images to make it easily fit in with the Homeassistant environment, including ingress access, a sidebar button and easy configuration,

## Configuration

Example configuration:

```json
{
   "TZ": "Europe/London"
}
```

Using TZ you can set your own timezone, which is used in the scheduling options of NZBGet. You can find the available options for TZ on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) under the column 'TZ database name'.
