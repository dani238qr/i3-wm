#!/bin/bash

# centered_time.sh

# Get the current date and time
datetime=$(date '+%Y-%m-%d %I:%M %p')

# Calculate padding to center the text
padding="                    "  # 20 spaces
p1="    				" # 19 spaces
centered_datetime="$padding$datetime$padding$padding$p1"

# Output the centered date and time
echo "$centered_datetime"


