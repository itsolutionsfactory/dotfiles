#!/bin/bash

# Function to get battery info if available
get_battery_info() {
    if [ -d "/sys/class/power_supply/BAT0" ]; then
        local battery_level=$(cat /sys/class/power_supply/BAT0/capacity)
        local battery_status=$(cat /sys/class/power_supply/BAT0/status)
        echo "Battery: $battery_level% ($battery_status)"
    fi
}

# Function to get uptime in a human-readable format
get_uptime() {
    local uptime_seconds=$(cat /proc/uptime | awk '{print int($1)}')
    local days=$((uptime_seconds/86400))
    local hours=$((uptime_seconds%86400/3600))
    local minutes=$((uptime_seconds%3600/60))
    
    if [ $days -gt 0 ]; then
        echo "${days}d ${hours}h ${minutes}m"
    elif [ $hours -gt 0 ]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# Function to get CPU info
get_cpu_info() {
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d':' -f2 | sed 's/^[ \t]*//')
    local cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    echo "CPU: $cpu_model ($cpu_cores cores)"
}

# Function to get memory info
get_memory_info() {
    local total_mem=$(free -h | grep Mem | awk '{print $2}')
    local used_mem=$(free -h | grep Mem | awk '{print $3}')
    echo "Memory: $used_mem / $total_mem"
}

# Function to get disk usage
get_disk_info() {
    local disk_usage=$(df -h / | tail -n1 | awk '{print $3 " / " $2 " (" $5 " used)"}')
    echo "Disk: $disk_usage"
}

# Get system information
echo "System Information:"
echo "------------------"
get_cpu_info
get_memory_info
get_disk_info
echo "Uptime: $(get_uptime)"
get_battery_info 