# Lego: Let's Encrypt client and ACME library written in Go

This add-on allows you to get certificates from Let's Encrypt using the DNS challenge type.

<!-- START_GEN_BADGES -->
 [![Build Status](https://badges.herokuapp.com/travis.com/Taapie/hassio-addons?branch=master&label=armv7&env=ADDON=%22lego%22%20ARCH=%22armv7%22)](https://travis-ci.com/Taapie/hassio-addons)
<!-- END_GEN_BADGES -->

## About

There are several add-ons voor Hass.io that get Let's Encrypt certificates using the HTTP challenge type. This challenge type requires you to open up port 80 of your Hass.io installation to the internet. Let's Encrypt also allows users to use their DNS entries to retrieve a certificate and thereby allowing you to keep port 80 closed.

Lego is a tool that implements this DNS challenge type for a lot of DNS services. This add-on utilizes Lego to get your certificate. 

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Lego add-on configuration:

```json
{
  "email": "name@domain.com",
  "domains": [
    "hassio.domain.com",
    "cloud9.domain.com"
  ],
  "dns": "transip",
  "env": [
    "TRANSIP_BLA=value"
  ],
  "interval": 24
}
```

**Note**: _This is just an example, don't copy and paste it! Create your own!_

