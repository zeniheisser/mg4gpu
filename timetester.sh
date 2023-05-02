#!/bin/bash

# Check if the correct number of arguments are provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 -lhe=<value> -rwgt=<value> -out=<value>"
    exit 1
fi

# Set the number of runs
num_runs=5

# Get the flag values from the script arguments
lhe_flag=$1
rwgt_flag=$2
out_flag=$3

# Extract the value for the -out flag and set the output file name
out_value=$(echo "$out_flag" | cut -d'=' -f2)
output_file="runtime_${out_value}.txt"

# Extract the value for the -rwgt flag
rwgt_value=$(echo "$rwgt_flag" | cut -d'=' -f2)

# Remove the output file if it already exists
if [ -e "$output_file" ]; then
    rm "$output_file"
fi

# Initialize two empty arrays to store user and system times
user_times=()
sys_times=()

# Run the program 5 times and record the CPU time in seconds
for i in $(seq 1 $num_runs); do
    # Run the program and capture the output of the 'time' command
    TIME_OUTPUT=$( { time -p ./runner.exe "$lhe_flag" "$rwgt_flag" "$out_flag"; } 2>&1 )
    
    # Extract the user and system times in seconds
    USER_TIME=$(echo "$TIME_OUTPUT" | grep 'user' | awk '{print $2}')
    SYSTEM_TIME=$(echo "$TIME_OUTPUT" | grep 'sys' | awk '{print $2}')
    
    # Add the times to the respective arrays
    user_times+=("$USER_TIME")
    sys_times+=("$SYSTEM_TIME")
done

# Save the user_times and sys_times arrays to the output file
echo "${rwgt_value}_user_times = [ ${user_times[*]} ]" > "$output_file"
echo "${rwgt_value}_sys_times = [ ${sys_times[*]} ]" >> "$output_file"

echo "Runtime results have been saved to $output_file"

