#!/usr/bin/bash

if older_1h 'nfnty/arch-mini:latest'; then
    "${SCRIPTDIR}/../../containers/bootstrap/scripts/run.sh"
fi
update 'nfnty/arch-mini:latest'

update 'nfnty/arch-devel:latest'
update 'nfnty/arch-java:jre8-openjdk-headless'
update 'nfnty/arch-nodejs:latest'

update 'nfnty/arch-bootstrap:latest'
update 'nfnty/arch-builder:latest'
update 'nfnty/arch-dovecot:latest'
update 'nfnty/arch-elasticsearch:latest'
update 'nfnty/arch-exim:latest'
update 'nfnty/arch-hostapd:latest'
update 'nfnty/arch-kea:latest'
update 'nfnty/arch-kibana:latest'
update 'nfnty/arch-logstash:latest'
update 'nfnty/arch-nginx:latest'
update 'nfnty/arch-ntp:latest'
update 'nfnty/arch-openhab:latest'
update 'nfnty/arch-openvpn:latest'
update 'nfnty/arch-postgresql:latest'
update 'nfnty/arch-powerdns-recursor:latest'
update 'nfnty/arch-samba:latest'
update 'nfnty/arch-transmission:latest'
