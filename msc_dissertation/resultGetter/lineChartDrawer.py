# Line chart drawer
import seaborn as sns
import os
import pandas as pd
import matplotlib.pyplot as plt
import re

def read_txt(path):  # Read txt file
    with open(path, "r") as f:
        lines = f.readlines()
    return lines


# Get PDR from the txt file
def getPDR(lines):
    # Store all total PDR percentage into a list
    pdrList = []
    node = 0  # Count the number of nodes to stop when 10 nodes
    for line in lines:
        if node == 10:  # Stop when 10 nodes
            break
        if "Total Packet delivery ratio" in line:
            node += 1
            # Find the index of the '=' character
            equals_index = line.index("=")

            # Extract the substring after the '=' character
            number = line[equals_index + 1 :]

            # Remove any non-numeric characters
            number = "".join(filter(str.isdigit, number))

            # Convert the string to an integer
            pdrList.append(int(number))
    return pdrList


# Get the throughput from the txt file
def getThroughput(lines):
    # Store all total throughput into a list
    throughputList = []
    node = 0  # Count the number of nodes to stop when 10 nodes
    for line in lines:
        if node == 10:
            break
        if "Average Throughput" in line:
            node += 1

            # Find the index of the '=' character
            equals_index = line.index("=")

            # Extract the substring after the '=' character
            numberString = line[equals_index + 1 :]

            # Remove any non-numeric characters
            match = re.search(r"(\d+\.\d+)", numberString)
            value = float(match.group(1))

            # Store the throughput
            throughputList.append(value)
    return throughputList

# Get the end-to-end delay from the txt file
def getE2EDelay(lines):
    # Store all total E2EDelay into a list
    e2eDelayList = []
    lineCount = 0  # Count E2EDelay lines
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

            # Store the E2EDelay
            e2eDelayList.append(time_sec)

    return e2eDelayList # Return the average E2EDelay

title = "AODV vs DSDV PDR 50 nodes without attack and Flooding attack"


# AODV vs DSDV without attack 100 topologies result comparison
def drawLineChart(aodvList, dsdvList, aodv30NodesList=None, dsdv30NodesList=None, aodv50NodesList=None, dsdv50NodesList=None):
    df = pd.DataFrame(
        {
            "AODV": aodvList,
            "DSDV": dsdvList,
            "AODV with Flooding": aodv30NodesList,
            "DSDV with Flooding": dsdv30NodesList,
            # "AODV 50 Nodes": aodv50NodesList,
            # "DSDV 50 Nodes": dsdv50NodesList,
        }
    )

    # Prepare the graph
    plt.figure(figsize=(15, 8))
    ax = sns.lineplot(data=df)
    ax.set(xlabel="Sample", ylabel="Throughput (kbps)")
    ax.set_title(title)
    ax.grid(True)

    # Show the graph
    plt.show()


# Save the line chart
def saveLineChart():
    folder = "charts"
    if not os.path.exists(folder):
        os.makedirs(folder, exist_ok=True)

    # Save
    # plt.savefig(f"{folder}/{title}.png")


if __name__ == "__main__":
    # Path of Desktop
    desktopPath = "/home/simonlai/Desktop/getResult/resultDataTxt"

    # Read aodv txt file
    aodvPath = os.path.join(desktopPath, "resultsFrom0to9-AODV-50nodes-without-attack.txt")
    print(f"Reading from: {aodvPath}")
    aodvLines = read_txt(aodvPath)

    # Get PDR from the aodv txt file
    aodvPdrList = getThroughput(aodvLines)
    print(aodvPdrList)

    # Read dsdv txt file
    dsdvPath = os.path.join(desktopPath, "resultsFrom0to9-DSDV-50nodes-without-attack.txt")
    print(f"Reading from: {dsdvPath}")
    dsdvLines = read_txt(dsdvPath)

    # Get PDR from the dsdv txt file
    dsdvPdrList = getThroughput(dsdvLines)
    print(dsdvPdrList)

    # Read aodv without attack 30nodes txt file
    aodv30NodesPath = os.path.join(desktopPath, "resultsFrom0to9-AODV-50nodes-with-Flooding.txt")
    print(f"Reading from: {aodv30NodesPath}")
    aodv30NodesLines = read_txt(aodv30NodesPath)

    # Get PDR from the aodv without attack 30nodes txt file
    aodv30NodesPdrList = getThroughput(aodv30NodesLines)
    print(aodv30NodesPdrList)

    # Read dsdv without attack 30nodes txt file
    dsdv30NodesPath = os.path.join(desktopPath, "resultsFrom0to9-DSDV-50nodes-with-Flooding.txt")
    print(f"Reading from: {dsdv30NodesPath}")
    dsdv30NodesLines = read_txt(dsdv30NodesPath)

    # Get PDR from the dsdv without attack 30nodes txt file
    dsdv30NodesPdrList = getThroughput(dsdv30NodesLines)
    print(dsdv30NodesPdrList)

    # Read aodv without attack 50nodes txt file
    aodv50NodesPath = os.path.join(desktopPath, "resultsFrom0to9-AODV-50nodes-with-Blackhole.txt")
    print(f"Reading from: {aodv50NodesPath}")
    aodv50NodesLines = read_txt(aodv50NodesPath)

    # Get PDR from the aodv without attack 50nodes txt file
    aodv50NodesPdrList = getPDR(aodv50NodesLines)
    print(aodv50NodesPdrList)

    # Read dsdv without attack 50nodes txt file
    dsdv50NodesPath = os.path.join(desktopPath, "resultsFrom0to9-DSDV-50nodes-with-Blackhole.txt")
    print(f"Reading from: {dsdv50NodesPath}")
    dsdv50NodesLines = read_txt(dsdv50NodesPath)

    # Get PDR from the dsdv without attack 50nodes txt file
    dsdv50NodesPdrList = getPDR(dsdv50NodesLines)
    print(dsdv50NodesPdrList)

    # # Read aodv blackhole attack txt file
    # aodvBlackholePath = os.path.join(
    #     desktopPath, "resultsFrom0to9-AODV-10nodes-with-Blackhole.txt"
    # )
    # print(f"Reading from: {aodvBlackholePath}")
    # aodvBlackholeLines = read_txt(aodvBlackholePath)

    # # Get PDR from the aodv blackhole attack txt file
    # aodvBlackholePdrList = getPDR(aodvBlackholeLines)
    # print(aodvBlackholePdrList)

    # # Read dsdv blackhole attack txt file
    # dsdvBlackholePath = os.path.join(
    #     desktopPath, "resultsFrom0to9-DSDV-10nodes-with-Blackhole.txt"
    # )
    # print(f"Reading from: {dsdvBlackholePath}")
    # dsdvBlackholeLines = read_txt(dsdvBlackholePath)

    # # Get PDR from the dsdv blackhole attack txt file
    # dsdvBlackholePdrList = getPDR(dsdvBlackholeLines)
    # print(dsdvBlackholePdrList)

    # Draw line chart
    drawLineChart(aodvPdrList, dsdvPdrList, aodv30NodesPdrList, dsdv30NodesPdrList)
    # drawLineChart(aodvPdrList, dsdvPdrList, aodvBlackholePdrList, dsdvBlackholePdrList)

    # Save the line chart
    saveLineChart()

    # Get the throughput from the txt file
    # throughput = getThroughput(lines)
