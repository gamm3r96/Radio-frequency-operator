#!/bin/bash

# Script to list and operate RF devices connected via USB
# Author: Gamm3r96

# Global variables
LOG_FILE="/var/log/rf_devices.log"
BAUD_RATE="115200"  # Default baud rate; adjust as needed

# Function to log messages
log_message() {
    local message
    message=$1
    printf "%s: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$message" >>"$LOG_FILE"
}

# Function to list all USB devices
list_usb_devices() {
    printf "Listing all USB devices...\n"
    lsusb
}

# Function to find potential RF devices based on known vendor/product IDs
find_rf_devices() {
    printf "Searching for RF devices...\n"
    local rf_devices
    rf_devices=$(lsusb | grep -i -e "radio" -e "rf" -e "wireless")  # Adjust search terms for your specific devices

    if [[ -z $rf_devices ]]; then
        printf "No RF devices found.\n"
        return 1
    fi

    printf "Found RF devices:\n%s\n" "$rf_devices"
    return 0
}

# Function to interact with a specified device
interact_with_device() {
    local device_port
    device_port=$1

    printf "Initializing communication with device on port %s...\n" "$device_port"

    # Check if the device port exists
    if [[ ! -e $device_port ]]; then
        printf "Error: Device port %s not found.\n" "$device_port" >&2
        return 1
    fi

    # Start minicom session
    minicom -b "$BAUD_RATE" -D "$device_port" -C "$LOG_FILE"
}

# Function to list available serial ports
list_serial_ports() {
    printf "Available serial ports:\n"
    dmesg | grep tty | grep "USB"
}

# Main function
main() {
    list_usb_devices

    if ! find_rf_devices; then
        printf "No RF devices detected. Exiting.\n"
        exit 1
    fi

    list_serial_ports

    # Prompt user to enter the device port for interaction
    printf "Enter the device port to interact with (e.g., /dev/ttyUSB0): "
    read -r device_port

    if ! interact_with_device "$device_port"; then
        printf "Failed to interact with the device on port %s\n" "$device_port" >&2
        exit 1
    fi
}

# Execute the main function
mai
