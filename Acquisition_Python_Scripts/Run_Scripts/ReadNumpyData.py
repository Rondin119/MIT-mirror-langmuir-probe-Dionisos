# Script to read in numpy file created by fission chamber web app

import sys
from matplotlib import pyplot as plt
#from bitstring import BitArray
import numpy as np

# Try to get file from input
try:
    fileName = sys.argv[1]
except IndexError:
    fileName = "MLP_test_data.npy" # Change this for the default file read in

####################################################################
# Function to convert signed binary to the coresponding integer
def signed_conversion(binNumber):
    binConv = ""
    if int(binNumber[0], 2) == 1:
        for bit in binNumber[1::]:
            if bit == "1":
                binConv += "0"
            else:
                binConv += "1"
        intNum = -int(binConv, 2) - 1
    else:
        for bit in binNumber[1::]:
            binConv += bit
        intNum = int(binConv, 2)
    return intNum
#####################################################################

# ########################################################################################
# # Function to plot and save a figure
# def figurePlot(xdata, ydata, title_string, xLabel, yLabel, save_string):

#     save_string = title_string + "_" + save_string
    
#     plt.figure(figsize = (10, 7))
#     plt.plot(xdata, ydata, '.')        
#     plt.title(title_string)
#     plt.xlabel(xLabel)
#     plt.ylabel(yLabel)
#     plt.savefig(save_string)

# ########################################################################################

####### Opening file and extracting data ###################################################
print("Reading file:", fileName)
dataArray = np.load(fileName)

vIn = []
vOut = []
Temp = []
iSat = []
vFloat = []

############################### Reading File ###########################################
for val in dataArray:
    dataPoint = int(val)
    binData = "{0:032b}".format(dataPoint)
    if int(binData[0], 2) == 0:
        vOut.append(signed_conversion(binData[-13::]))
        vIn.append(signed_conversion(binData[-26:-13]))
    elif int(binData[0], 2) == 1:
        vFloat.append(signed_conversion(binData[-9::]))
        iSat.append(signed_conversion(binData[-18:-9]))
        Temp.append(signed_conversion(binData[-26:-18]))
        
#########################################################################################

#########################################################################################
# Function to calculate the expected current output for a given bias
def currCalc(xVal, Temp, vFloat, iSat):
    
    div = (xVal-vFloat)/Temp
    exp = np.exp(div) - 1
    curr = iSat*exp

    #print(div)

    return curr
#######################################################################################

# Comment this section to plot temp/vfloat/isat
plt.plot(Temp)        
plt.plot(iSat, 'k')
plt.plot(vFloat, 'r')
plt.show()

calcArr = []
for i in range(len(vIn)):
    val = currCalc(vIn[i]/2., 100., 0., -100.)
    calcArr.append(val*2)
    
print(np.mean(vIn), np.mean(vOut))

# Comment this section to look at voltages
plt.plot(vIn, 'b', vOut, 'g')#, calcArr, 'y')
plt.show()
        
# for In, Out in zip(vIn,vOut):
#         print("%i,%i\n" % In, Out)        

# # Writes out csv file for voltages
# fileOutName = "MLP_60_full" + ".csv" # change this to change the file name
# print(fileOutName)
# with open(fileOutName, "w") as csv_file:
#     for In, Out in zip(vIn,vOut):
#         csv_file.write("%i" % In)
#         csv_file.write(",") 
#         csv_file.write("%i" % Out)
#         csv_file.write("\n")

# # Writes out csv file for plasma parameters
# fileOutName = fileName[0:-4] + "_temps" ".csv" # change this to change the file name
# print(fileOutName)
# with open(fileOutName, "w") as csv_file:
#     csv_file.write("Temperature,iSat,vFloat\n")
#     for Temps, iSats, vFloats in zip(Temp,iSat,vFloat):
#         csv_file.write("%i" % Temps)
#         csv_file.write(",") 
#         csv_file.write("%i" % iSats)
#         csv_file.write(",") 
#         csv_file.write("%i" % vFloats)
#         csv_file.write("\n")
