# Caddy Proxy addon for hass.io
[![Build Status](https://travis-ci.org/Taapie/hassio-addons.svg?branch=master)](https://travis-ci.org/Taapie/hassio-addons)[![](https://images.microbadger.com/badges/version/Taapie/armhf-caddy.svg)](https://microbadger.com/images/Taapie/armhf-caddy "Get your own version badge on microbadger.com")

## Description

This addon provide a [Caddy](https://caddyserver.com/) Proxy with multiple vhost support and automatic ssl (obtention and renewal). It should be a easier option than the nginx_proxy and certbot addons.

The simplier way to use it is just to set your external address in the homeassistant field.

## Configuration
### homeassistant (str)

This is a shortcut to set a proxy for homeassistant. If this option is set to "homeassistant.domain.tld" it will set a proxy from https://homeassistant.domain.tld to homeassistant:8123.

### vhosts (list)

This list describes all the virtual host to be proxified.

#### vhost (string)

Full hostname (ie myservice.domain.tld)

#### port (string)

Internal port (ie 8123 for homeassistant, 3000 for grafana)

#### remote (str)

Ip or url for the proxified server. If not set defaults to 172.17.0.1 (docker host).

#### insecure (bool)

Indicates if the remote is insecure and should not be checked for a secure connection. If not set defaults to False.

#### user (str)

Username to be used with basicauth. `pwd` (see below) must also be set.

#### pwd (str)

Password to be used with basicauth. `user` (see above) must also be set.


### email (email)

Email is the email address to use with which to generate a certificate with Let's Encrypt.

### raw_config (list)

#### line (str)
Each line will be added to the caddy configuration file, after the domain proxified with the vhosts section.
