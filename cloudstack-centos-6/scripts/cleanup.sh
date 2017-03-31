#!/bin/bash

set -x

# Clean old network interfaces so the new one will become eth0
rm /etc/udev/rules.d/70-persistent-net.rules

fstrim -v /

