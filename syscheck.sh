#!/bin/bash

# Define thresholds
CPU_THRESHOLD=90  # 90% CPU usage
MEM_THRESHOLD=90  # 90% memory usage
DISK_THRESHOLD=90  # 90% disk usage

# Define your Discord webhook URL
DISCORD_WEBHOOK_URL="https://discordapp.com/api/webhooks/YOUR_WEBHOOK_KEY"

# Define the device name
DEVICE_NAME="Your Device Name"

# Get CPU and memory usage
CPU_LOAD=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
MEMORY_USED=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

# Get disk usage (of the root partition)
DISK_USED=$(df -h / | grep / | awk '{print $5}' | sed 's/%//')

# Round the CPU and memory values
CPU_LOAD=$(printf "%.0f" $CPU_LOAD)
MEMORY_USED=$(printf "%.0f" $MEMORY_USED)

# Output the current CPU, memory, and disk usage (logged by cron)
echo "$(date): CPU usage: $CPU_LOAD%, Memory usage: $MEMORY_USED%, Disk usage: $DISK_USED%"

# Discord alert function
send_discord_alert() {
    local message=$1
    curl -H "Content-Type: application/json" \
    -X POST \
    -d "{\"content\": \"$message\"}" \
    $DISCORD_WEBHOOK_URL
}

# Check if CPU load exceeds threshold
if [ "$CPU_LOAD" -gt "$CPU_THRESHOLD" ]; then
    send_discord_alert "\u26A0\uFE0F High CPU usage detected on $DEVICE_NAME: $CPU_LOAD% (Threshold: $CPU_THRESHOLD%)"
    echo "$(date): High CPU usage detected on $DEVICE_NAME: $CPU_LOAD% (Threshold: $CPU_THRESHOLD%)"
fi

# Check if memory usage exceeds threshold
if [ "$MEMORY_USED" -gt "$MEM_THRESHOLD" ]; then
    send_discord_alert "\u26A0\uFE0F High memory usage detected on $DEVICE_NAME: $MEMORY_USED% (Threshold: $MEM_THRESHOLD%)"
    echo "$(date): High memory usage detected on $DEVICE_NAME: $MEMORY_USED% (Threshold: $MEM_THRESHOLD%)"
fi

# Check if disk usage exceeds threshold
if [ "$DISK_USED" -gt "$DISK_THRESHOLD" ]; then
    send_discord_alert "\u26A0\uFE0F High disk usage detected on $DEVICE_NAME: $DISK_USED% (Threshold: $DISK_THRESHOLD%)"
    echo "$(date): High disk usage detected on $DEVICE_NAME: $DISK_USED% (Threshold: $DISK_THRESHOLD%)"
fi
