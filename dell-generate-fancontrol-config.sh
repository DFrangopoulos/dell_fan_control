#!/bin/bash

fan_path=""
for dev in "$(find /sys/devices/virtual/hwmon -name "name")"; do
        if [ -f "$dev" ]; then
                if [ "$(cat $dev)" = "dell_smm" ]; then
                        fan_path="$(dirname "$dev")"
                fi
        fi
done

pkg_path=""
for dev in "$(find /sys/devices/platform/coretemp.0/hwmon/ -name "name")"; do
        if [ -f "$dev" ]; then
                if [ "$(cat $dev)" = "coretemp" ]; then
                        pkg_path="$(dirname "$dev")"
                fi
        fi
done

if [ ! -z "$fan_path" ] && [ ! -z "$pkg_path" ]; then

	cfile="/etc/fancontrol"
	> $cfile
	echo "INTERVAL=1" >> $cfile
	echo "FCTEMPS=${fan_path}/pwm2=${pkg_path}/temp1_input ${fan_path}/pwm1=${pkg_path}/temp1_input" >> $cfile
	echo "FCFANS=${fan_path}/pwm2=${fan_path}/fan2_input ${fan_path}/pwm1=${fan_path}/fan1_input" >> $cfile
	echo "MINTEMP=${fan_path}/pwm2=40 ${fan_path}/pwm1=40" >> $cfile
	echo "MAXTEMP=${fan_path}/pwm2=66 ${fan_path}/pwm1=66" >> $cfile
	echo "MINSTART=${fan_path}/pwm2=150 ${fan_path}/pwm1=150" >> $cfile
	echo "MINSTOP=${fan_path}/pwm2=60 ${fan_path}/pwm1=60" >> $cfile
	echo "MINPWM=${fan_path}/pwm2=60 ${fan_path}/pwm1=60" >> $cfile
	chmod 644 $cfile
	exit 0
else
	exit 1
fi



