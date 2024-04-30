#!/bin/bash
declare -A temps

#Get Core Temps
for cpu_n in {0..11}; do
	if [ -f "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp${cpu_n}_input" ] && [ -f "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp${cpu_n}_label" ]; then
		core_temp="$(cat "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp${cpu_n}_input")"
		core_name="$(cat "/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp${cpu_n}_label")"
		core_num="$(echo ${core_name} | sed -rn 's/Core ([0-9])/\1/p')"
		if [ ! -z "$core_num" ]; then
			temps[$core_num]="$((core_temp/1000))C"
		fi
	fi
done

#Get thread freqs / core_id
for thread_id in {0..23}; do
	if [ -d "/sys/devices/system/cpu/cpu${thread_id}" ]; then
		thread_freq="$(cat "/sys/devices/system/cpu/cpu${thread_id}/cpufreq/scaling_cur_freq")"
		thread_core="$(cat "/sys/devices/system/cpu/cpu${thread_id}/topology/core_id")"	
		temps[$thread_core]+=", thread: ${thread_id} @ ${thread_freq}Hz"
	fi
done



for k in {0..11}; do
	if [ ! -z "${temps[$k]}" ]; then
		echo "Core $k --> ${temps[$k]}"
	fi
done

	nv_temp="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)"
	nv_clk="$(nvidia-smi --query-gpu=clocks.gr --format=csv,noheader)"

echo "Nvidia --> ${nv_temp}C, ${nv_clk}"

fan_path=""
for dev in "$(find /sys/devices/virtual/hwmon -name "name")"; do
	if [ -f "$dev" ]; then
		if [ "$(cat $dev)" = "dell_smm" ]; then
			fan_path="$(dirname "$dev")"
		fi
	fi
done

for fan_n in {1..2}; do
	if [ ! -z "$fan_path" ]; then
		echo "Fan ${fan_n} --> $(cat "${fan_path}/fan${fan_n}_input") RPM"
	fi
done
