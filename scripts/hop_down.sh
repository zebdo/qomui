#!/bin/bash

/sbin/route del -net $1 netmask 255.255.255.255 gw _gateway
