import sys
import time
from datetime import datetime
import numpy as np
import os
import csv
import matplotlib.pyplot as plt

#########################################################
# Function for converting an integer to a signed binary
def int2signed(convInt):
    convInt = int(np.floor(convInt))
    if convInt < 0:
        retBin = '{:032b}'.format(convInt & 0xffffffff)
    else:
        retBin = '{:032b}'.format(convInt)
        
    return retBin
##########################################################

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

########################################################################
# Function to read an input csv file
def ReadCSVfile(fileName):
    valArray = []
    with open(fileName, newline='') as csvfile:
        valreader = csv.reader(csvfile, delimiter=',')
        for row in valreader:
            for col in row:
                valArray.append(int(col))

    return valArray
#########################################################################

##########################################################################
# Function to create data to load into the BRAM
def data2load(array1, array2, array3):

    retArray = ['00' + int2signed(val1)[-10::] + int2signed(val2)[-10::] + int2signed(val3)[-10::]
                for val1, val2, val3 in zip(array1, array2, array3)]
    
    return retArray
############################################################################

############################### Reading MLP data ###########################################
# Function to read data returned by FPGA
def ReadData(DataArray):
    vIn = []
    vOut = []
    Temp = []
    iSat = []
    vFloat = []
    tTimestamp = []
    vTimestamp = []
    for val in DataArray:
        dataPoint = int(val)
        binData = "{0:032b}".format(dataPoint)
        if int(binData[0], 2) == 0:
            vOut.append(signed_conversion(binData[-13::]))
            vIn.append(signed_conversion(binData[-26:-13]))
            vTimestamp.append(int(binData[-31:-26], 2))
        elif int(binData[0], 2) == 1:
            vFloat.append(signed_conversion(binData[-9::]))
            iSat.append(signed_conversion(binData[-18:-9]))
            Temp.append(int(binData[-26:-18], 2))
            tTimestamp.append(int(binData[-31:-26], 2))

    return vIn, vOut, Temp, iSat, vFloat, tTimestamp, vTimestamp
#########################################################################################

###################################### Correcting timestamps ##################################
# Function to correct timestamps from MLP data
def CorrectTimestamps(TimestampArray):
    rollover = 0
    print(len(TimestampArray))
    for i in range(0, len(TimestampArray) - 1):
        if TimestampArray[i] == TimestampArray[i + 1]:
            TimestampArray[i+1::] = [float(val) + 1./5. for val in TimestampArray[i+1::]]
        # else:
        #     TimestampArray[i] = TimestampArray[i] + 32*rollover
            
        if TimestampArray[i] > TimestampArray[i+1]:            
            TimestampArray[i+1::] = [val + 32  for val in TimestampArray[i+1::]]
            # rollover = rollover + 1
            
    #TimestampArray[-1] = TimestampArray[-1] + 32*rollover 

    return TimestampArray
################################################################################################
