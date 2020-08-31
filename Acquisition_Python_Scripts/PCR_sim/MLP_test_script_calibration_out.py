import sys
import time
from datetime import datetime
import numpy as np
import os
import csv
import matplotlib.pyplot as plt

from MLP import MLP

from koheron import connect

from test_script_funcs import *


# Setting up the MLP system
MLP_host = os.getenv('HOST', '198.125.182.105')
MLP_client = connect(MLP_host, name='mirror-langmuir-probe')
MLP_driver = MLP(MLP_client)

#vfloatArray = ReadCSVfile("./Test_2/Vf.csv")
#isatArray = ReadCSVfile("./Test_2/Isat.csv")
#tempArray = ReadCSVfile("./Test_2/Te.csv")

# Plotting the input plasma parameters
# plt.plot(tempArray)
# plt.plot(isatArray, 'k')
# plt.plot(vfloatArray, 'y')
# plt.show()

#BRAMdata = data2load(vfloatArray, tempArray, isatArray)

AcqTime = int(1e4)# Number of microseconds to run acquisition for

###################### Setting the MLP parameters ###########################################################

MLP_driver.set_scale_PC(int(1.1*1024))
MLP_driver.set_offset_PC(int(int2signed(94), 2))

MLP_driver.set_scale_LB(int(1.1*1024))
MLP_driver.set_offset_LB(int(int2signed(180), 2))

MLP_driver.set_scale_Out(int(1*1024))
MLP_driver.set_offset_Out(int(int2signed(0), 2))


MLP_driver.set_lower_temp_lim(639)
MLP_driver.set_upper_temp_lim(640)
MLP_driver.set_Const_voltage(000)
MLP_driver.set_Const_switch(2)  # 0 is normal operation mode 2 is calibration operation mode


MLP_driver.set_period(300) # set voltage level period in number of clock cyles
MLP_driver.set_acquisition_length(AcqTime) # Aquisition time in microseconds
##################################################################################

Temp = 10
iSat = 10
vFloat = 10

###################### Setting the PCR parameters ###########################################################

MLPArray = []

#PCS_driver.set_trigger()
#MLP_driver.set_trigger()





while True:
    try:
        MLP_driver.set_Const_voltage(-4000)
        time.sleep(.1)
        V1 = MLP_driver.get_Volt_1()
        V2 = MLP_driver.get_Volt_2()
        if V1 > 8191:
            V1 = V1 - 16384
        if V2 > 8191:
            V2 = V2 - 16384
#        V1 = V1 / 8.1920
#        V2 = V2 / 8.1920

        print(V1,V2)
    except KeyboardInterrupt:
        break

