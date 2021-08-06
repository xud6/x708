#!/bin/bash

SHUTDOWN=5
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600
PLDPULSEMINMUM=600

echo "$SHUTDOWN" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction
BOOT=12
echo "$BOOT" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$BOOT/direction
echo "1" > /sys/class/gpio/gpio$BOOT/value
PLD=6
echo "$PLD" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$PLD/direction

echo "X708 PWR started"

while [ 1 ]; do
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
  pldSignal=$(cat /sys/class/gpio/gpio$PLD/value)
  if [ $shutdownSignal = 0 ] && [ $pldSignal = 0 ]; then
    /bin/sleep 0.2
  else
    pulseStart=$(date +%s%N | cut -b1-13)
    if [ $pldSignal = 1 ]; then
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $PLDPULSEMINMUM ]; then
        echo "X708 PLD Shutting down", PLD, ", halting Rpi ..."
        sudo x708softsd.sh
        sudo poweroff
        exit
      fi
      pldSignal=$(cat /sys/class/gpio/gpio$PLD/value)
    fi
    pulseStart=$(date +%s%N | cut -b1-13)
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 0.02
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
        echo "X708 Shutting down", SHUTDOWN, ", halting Rpi ..."
        sudo poweroff
        exit
      fi
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
    done
  fi
done
