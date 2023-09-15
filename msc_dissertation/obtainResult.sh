#!/bin/bash

output_file="$HOME/Desktop/resultsFrom0to10.txt"
protocol_value=$1
malicious_node_value=$2
stream_index_value=$3

# Function to display the help message
display_help() {
    echo "Usage: ./script_name.sh [protocol_value] [malicious_node_value] [stream_index_value]"
    echo "Options:"
    echo "  protocol_value        Specify the protocol value"
    echo "  malicious_node_value  Specify the enable_malicious_node value"
    echo "  stream_index_value    Specify the streamIndex value"
    echo
}

# Check if the script is called with the help option
if [[ $1 == "--help" || $1 == "-h" ]]; then
    display_help
    exit 0
fi

# Check if the number of arguments is correct
if [[ $# -ne 3 ]]; then
    echo "Error: Incorrect number of arguments."
    display_help
    exit 1
fi

output_file="$HOME/Desktop/resultsFrom0to$stream_index_value-DSDV-50nodes-with-Blackhole.txt"


# Remove the output file if it already exists
rm -f "$output_file"

for ((index=0; index<=$stream_index_value; index++))
do
    ./ns3 run aodv-and-dsdv-compare -- --protocol=$protocol_value --enable_malicious_node=$malicious_node_value --streamIndex=$index >> "$output_file" 2>&1
done
