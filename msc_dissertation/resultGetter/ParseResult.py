# Find all "Total Packet delivery ratio" percentage in txt file

import os
import re
import sys


def read_txt(path):  # Read txt file
    with open(path, "r") as f:
        lines = f.readlines()
    return lines


# Find all "Total Packet delivery ratio" percentage in txt file
def find_Avg_PDR_percentage(lines):
    lineCount = 0  # Count PDR lines
    result = 0  # Sum of PDR percentage
    lowest = 100  # Lowest PDR percentage
    highest = 0  # Highest PDR percentage
    for line in lines:
        if lineCount == 10:  # Stop when 10 nodes:
            break
        if "Total Packet delivery ratio" in line:
            lineCount += 1

            # Find the index of the '=' character
            equals_index = line.index("=")

            # Extract the substring after the '=' character
            number = line[equals_index + 1 :]

            # Remove any non-numeric characters
            number = "".join(filter(str.isdigit, number))

            # Store the lowest PDR percentage
            if int(number) < lowest:
                lowest = int(number)

            # Store the highest PDR percentage
            if int(number) > highest:
                highest = int(number)

            print(f"number: {number}")
            # Convert the string to an integer
            result += int(number)

    # Print the number of PDR lines
    print(f"Total Packet delivery ratio lines: {lineCount}")
    # Print the lowest PDR percentage
    # print(f"Lowest PDR percentage: {lowest}%")
    # Print the highest PDR percentage
    # print(f"Highest PDR percentage: {highest}%")
    return result / lineCount  # Return the average PDR


# Find all "End to End Delay" in txt file
def find_Avg_E2EDelay(lines):
    lineCount = 0  # Count E2EDelay lines
    result = 0.0  # Sum of E2EDelay
    lowest = sys.float_info.max  # Lowest E2EDelay
    highest = 0.0  # Highest E2EDelay
    for line in lines:
        if lineCount == 10:  # Stop when 10 nodes:
            break
        if "Average End to End Delay" in line:
            lineCount += 1

            # Find the index of the '=' character
            equals_index = line.index("=")

            # Extract the substring after the '=' character
            timeString = line[equals_index + 1 :]

            # Parse the number part
            match = re.search(r"([+-]?\d+\.\d+)e([+-]\d+)", timeString)
            num = float(match.group(1))
            exp = int(match.group(2))

            # Calculate value
            val = num * pow(10, exp)

            # Convert to seconds
            time_sec = val * 1e-9

            # Store the lowest E2EDelay
            if float(time_sec) < lowest:
                lowest = float(time_sec)

            # Store the highest E2EDelay
            if float(time_sec) > highest:
                highest = float(time_sec)

            # Convert the string to an integer
            result += float(time_sec)

    # Print the number of E2EDelay lines
    print(f"End to End Delay lines: {lineCount}")
    # Print the lowest E2EDelay
    # print(f"Lowest E2EDelay: {lowest}")
    # Print the highest E2EDelay
    # print(f"Highest E2EDelay: {highest}")
    return result / lineCount  # Return the average E2EDelay


# Find all "Average Throughput" in txt file
def find_Avg_Throughput(lines):
    lineCount = 0  # Count Throughput lines
    result = 0.0  # Sum of Throughput
    lowest = sys.float_info.max  # Lowest Throughput
    highest = 0.0  # Highest Throughput
    for line in lines:
        if lineCount == 10:  # Stop when 10 nodes
            break
        if "Average Throughput" in line:
            lineCount += 1

            # Find the index of the '=' character
            equals_index = line.index("=")

            # Extract the substring after the '=' character
            numberString = line[equals_index + 1 :]

            # Remove any non-numeric characters
            match = re.search(r"(\d+\.\d+)", numberString)
            value = float(match.group(1))

            # Store the lowest Throughput
            if float(value) < lowest:
                lowest = float(value)

            # Store the highest Throughput
            if float(value) > highest:
                highest = float(value)

            # Convert the string to an integer
            result += float(value)

    # Print the number of Throughput lines
    print(f"Throughput lines: {lineCount}")
    # Print the lowest Throughput
    # print(f"Lowest Throughput: {lowest}")
    # Print the highest Throughput
    # print(f"Highest Throughput: {highest}")
    return result / lineCount  # Return the average Throughput


if __name__ == "__main__":
    # Path of Desktop
    desktopPath = "/home/simonlai/Desktop/getResult/resultDataTxt"

    # Read txt file
    path = os.path.join(desktopPath, "resultsFrom0to9-AODV-10nodes-without-attack.txt")
    print(path)
    lines = read_txt(path)

    # Find all "Total Packet delivery ratio" percentage in txt file
    print(f"Average PDR percentage: {find_Avg_PDR_percentage(lines)}%")

    # Find all "Average End to End Delay" in txt file
    print(f"Average End to End Delay: {find_Avg_E2EDelay(lines)}")

    # Find all "Average Throughput" in txt file
    print(f"Average Throughput: {find_Avg_Throughput(lines)}")
