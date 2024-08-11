#!/bin/bash

# RF Monitoring Script
# Author: Gamm3r96

# Global variables
DEVICE_PORT="/dev/ttyUSB0"  # Default serial port; adjust as needed
LOG_FILE="/var/log/rf_monitor.log"
BAUD_RATE="115200"          # Default baud rate; adjust as needed

# Function to log messages
log_message() {
    local message
    message=$1
    printf "%s: %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "$message" >>"$LOG_FILE"
}

# Function to initialize the serial port for monitoring
initialize_serial_port() {
    if [[ ! -e $DEVICE_PORT ]]; then
        printf "Error: Device port %s not found.\n" "$DEVICE_PORT" >&2
        exit 1
    fi

    printf "Initializing RF monitoring on port %s...\n" "$DEVICE_PORT"
    stty -F "$DEVICE_PORT" "$BAUD_RATE" cs8 -cstopb -parenb
}

# Function to monitor the RF device and log data
monitor_rf_device() {
    printf "Monitoring RF device on %s. Press Ctrl+C to stop.\n" "$DEVICE_PORT"
    
    # Open the device port for reading
    while read -r line; do
        log_message "$line"
        printf "Received: %s\n" "$line"
    done < "$DEVICE_PORT"
}

# Main function
main() {
    initialize_serial_port
    monitor_rf_device
}

# Handle script termination to clean up resources
trap 'printf "\nStopping RF monitoring.\n"; exit 0' SIGINT SIGTERM

# Execute the main function
main "$@"
