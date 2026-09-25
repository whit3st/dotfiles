#!/usr/bin/env python3
import time
from glob import glob


def read_battery():
    for path in sorted(glob("/sys/class/power_supply/BAT*")):
        try:
            with open(f"{path}/capacity") as f:
                return int(f.read().strip())
        except (OSError, ValueError):
            continue
    return None


def read_cpu():
    values = list(map(int, open("/proc/stat").readline().split()[1:]))
    idle = values[3] + values[4]
    total = sum(values)
    return idle, total


idle1, total1 = read_cpu()
time.sleep(0.2)
idle2, total2 = read_cpu()

cpu = 0.0
if total2 > total1:
    cpu = (1 - (idle2 - idle1) / (total2 - total1)) * 100

meminfo = {}
for line in open("/proc/meminfo"):
    key, value, *_ = line.split()
    if key in ("MemTotal:", "MemAvailable:"):
        meminfo[key] = int(value)

mem_total = meminfo.get("MemTotal:", 0)
mem_avail = meminfo.get("MemAvailable:", 0)
mem = 0.0
if mem_total:
    mem = (mem_total - mem_avail) / mem_total * 100

parts = [f"CPU: {cpu:.0f}%", f"MEM: {mem:.0f}%"]
battery = read_battery()
if battery is not None:
    parts.append(f"BAT {battery}%")

print(" ".join(parts))
