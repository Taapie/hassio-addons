# NZBGet: Efficient Usenet downloader
This add-on allows you to run NZBGet to download files from Usenet.

<!-- START_GEN_BADGES -->
 [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=master&label=aarch64&env=ADDON=%22nzbget%22%20ARCH=%22aarch64%22)](https://travis-ci.com/Taapie/hassio-addons) [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=master&label=amd64&env=ADDON=%22nzbget%22%20ARCH=%22amd64%22)](https://travis-ci.com/Taapie/hassio-addons) [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=master&label=armhf&env=ADDON=%22nzbget%22%20ARCH=%22armhf%22)](https://travis-ci.com/Taapie/hassio-addons) [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=master&label=armv7&env=ADDON=%22nzbget%22%20ARCH=%22armv7%22)](https://travis-ci.com/Taapie/hassio-addons)
<!-- END_GEN_BADGES -->

## About

NZBGet is a tool that is able to download file from Usenet servers. This addon builds on top of the Linuxserver images to make it easily fit in with the Homeassistant environment, including ingress access, a sidebar button and easy configuration,

## Configuration

Example configuration:

```json
{
   "TZ": "Europe/London",
   "Server": "<server-url>",
   "Port": 563,
   "Username": "<username>",
   "Password": "<password>",
   "SSL": true,
   "Connections": 20,
   "Retention": 0
}
```

Using TZ you can set your own timezone, which is used in the scheduling options of NZBGet. You can find the available options for TZ on [Wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) under the column 'TZ database name'.

The settings Server, Port, Username, Password and SSL are used to configure the News Server from which you want to download the Usenet messages. 

Connections needs to be set to the maximum number of connections that can be made simultaniously to the same server. 

With Retention you can prevent the download of message that are no longer available on your News Server. Set it to the maximum retention that is available on your News Server - if you do not know the retention you can leave it set to 0.
