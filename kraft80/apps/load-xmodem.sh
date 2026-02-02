#!/bin/sh
echo ""
echo "Sending $1 via XModem @ ttyUSB0 19200 BPS"
echo ""
stty -F /dev/ttyUSB0 19200
sx $1 < /dev/ttyUSB0 > /dev/ttyUSB0

