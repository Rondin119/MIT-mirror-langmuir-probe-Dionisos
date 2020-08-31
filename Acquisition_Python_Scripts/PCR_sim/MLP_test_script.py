import sys
import time
from datetime import datetime
import numpy as np
import os
import csv
import matplotlib.pyplot as plt

from MLP import MLP
from PCS import PCS
from koheron import connect

from test_script_funcs import *


# Setting up the MLP system
MLP_host = os.getenv('HOST', 'rp1')
MLP_client = connect(MLP_host, name='mirror-langmuir-probe')
MLP_driver = MLP(MLP_client)

PCS_host = os.getenv('HOST', 'rp3')
PCS_client = connect(PCS_host, name='plasma-current-response-synth')
PCS_driver = PCS(PCS_client)



#vfloatArray = ReadCSVfile("./Test_2/Vf.csv")
#isatArray = ReadCSVfile("./Test_2/Isat.csv")
#tempArray = ReadCSVfile("./Test_2/Te.csv")

# Plotting the input plasma parameters
# plt.plot(tempArray)
# plt.plot(isatArray, 'k')
# plt.plot(vfloatArray, 'y')
# plt.show()

#BRAMdata = data2load(vfloatArray, tempArray, isatArray)

AcqTime = int(1e3)# Number of microseconds to run acquisition for

###################### Setting the MLP parameters ###########################################################


#MLP_driver.set_scale_PC(int(1.1*1024))
#MLP_driver.set_offset_PC(int(int2signed(90), 2))

#MLP_driver.set_scale_LB(int(1.1*1024))
#MLP_driver.set_offset_LB(int(int2signed(164), 2))

#MLP_driver.set_scale_Out(int(1*1024))
#MLP_driver.set_offset_Out(int(int2signed(0), 2))


MLP_driver.set_scale_PC(int(1.13*1024))
MLP_driver.set_offset_PC(int(int2signed(93), 2))

MLP_driver.set_scale_LB(int(1.13*1024))
MLP_driver.set_offset_LB(int(int2signed(168), 2))

MLP_driver.set_scale_Out(int(0.969*1024))
MLP_driver.set_offset_Out(int(int2signed(24), 2))


MLP_driver.set_lower_temp_lim(64)
MLP_driver.set_upper_temp_lim(1280)
MLP_driver.set_Const_voltage(5000)
MLP_driver.set_Const_switch(0)


MLP_driver.set_period(150) # set voltage level period in number of clock cyles
MLP_driver.set_acquisition_length(AcqTime) # Aquisition time in microseconds
##################################################################################

Temp = 10
iSat = 10
vFloat = 10

###################### Setting the PCR parameters ###########################################################
PCS_driver.set_LB_Esat(int(553))
PCS_driver.set_LB_zero(int(0))
PCS_driver.set_LB_Isat(int(-2714))
PCS_driver.set_Esat(int(1974))
PCS_driver.set_Isat(int(-1974))

PCS_driver.set_Calibration_scale_1(int(.962*1024))
PCS_driver.set_Calibration_offset_1(int(int2signed(-90), 2))

PCS_driver.set_Calibration_scale_2(int(.963*1024))
PCS_driver.set_Calibration_offset_2(int(int2signed(-48), 2))



##############################################################################################################

MLPArray = []
time.sleep(0.002)
MLP_driver.set_trigger(1)
time.sleep(0.002)
MLP_driver.set_trigger(0)

# While loop to collect the data from the instruments
while True:
    try:
        # Collecting data
        time.sleep(0.2)
        samples = MLP_driver.get_buffer_length()
        MLPArrayNew = MLP_driver.get_MLP_data()
        LB = MLP_driver.get_Volt_1()
        Cur = MLP_driver.get_Volt_2()

        # Checking for filled arrays
        if len(MLPArrayNew) > 0:
            MLPArray = MLPArrayNew


       # Break from loop if data obtained
        if len(MLPArray) > 0:
           break
       
        print(samples, len(MLPArray), LB, Cur)
    except KeyboardInterrupt:
        break








print(len(MLPArray))

saveTime = datetime.now().utctimetuple()
saveSuffix = ("Shot_1_cal")



MLPsaveStr = "MLP_test_data_" + saveSuffix
print(MLPsaveStr)
np.save(MLPsaveStr, MLPArray) # save as numpy file



MLPvIn, MLPvOut, MLPTemp, MLPiSat, MLPvFloat, MLPtTimestamp, MLPvTimestamp = ReadData(MLPArray)


# MLPtTimestamp = CorrectTimestamps(MLPtTimestamp)
# MLPvTimestamp = CorrectTimestamps(MLPvTimestamp)
# PCSvTimestamp = CorrectTimestamps(PCSvTimestamp)
# PCStTimestamp = CorrectTimestamps(PCStTimestamp)

#plt.plot(PCSvOut,'r', MLPvIn,'b' )


#plt.show()
#plt.plot(MLPTemp, 'b', PCSTemp, 'b--')        
#plt.plot(MLPiSat, 'k', PCSiSat, 'k--')
#plt.plot(MLPvFloat, 'r', PCSvFloat, 'r--')
#plt.show()



#plt.plot(PCSTemp, 'b--')        
#plt.plot(PCSiSat, 'k--')
#plt.plot(PCSvFloat, 'r--')
#plt.show()

# plt.plot(MLPtTimestamp, MLPvTimestamp)
# plt.show()
    
# Writes out csv file for voltages
fileOutName = MLPsaveStr + ".csv" # change this to change the file name
print(fileOutName)
with open(fileOutName, "w") as csv_file:
    csv_file.write("Timestamp,PCR Voltage,Loopback Voltage\n")
    for Time, In, Out in zip(MLPvTimestamp,MLPvIn,MLPvOut):
        csv_file.write("%f" % Time)
        csv_file.write(",")
        csv_file.write("%f" % In)
        csv_file.write(",") 
        csv_file.write("%f" % Out)
        csv_file.write("\n")

# Writes out csv file for plasma parameters
fileOutName = MLPsaveStr + "_temps" ".csv" # change this to change the file name
print(fileOutName)
with open(fileOutName, "w") as csv_file:
    csv_file.write("Timestamp,Temperature,iSat,vFloat\n")
    for Time, Temps, iSats, vFloats in zip(MLPtTimestamp,MLPTemp,MLPiSat,MLPvFloat):
        csv_file.write("%f" % Time)
        csv_file.write(",") 
        csv_file.write("%f" % Temps)
        csv_file.write(",") 
        csv_file.write("%f" % iSats)
        csv_file.write(",") 
        csv_file.write("%f" % vFloats)
        csv_file.write("\n")
        