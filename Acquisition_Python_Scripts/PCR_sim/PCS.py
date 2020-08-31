#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import math
import numpy as np

from koheron import command

class PCS(object):
    def __init__(self, client):
        self.client = client
        # self.n_pts = 16384
        self.n_pts = 8192
        self.fs = 125e6 # sampling frequency (Hz)

        self.adc = np.zeros((2, self.n_pts))
        self.dac = np.zeros((3, self.n_pts))

    @command()
    def trig_pulse(self):
        pass

    @command()
    def set_led(self, led):
        pass

    @command()
    def set_Isat(self, Isat):
        pass

    @command()
    def set_Esat(self, Esat):
        pass


    @command()
    def set_LB_Esat(self, LB_Esat):
        pass

    @command()
    def set_LB_Isat(self, LB_Isat):
        pass

    @command()
    def set_LB_zero(self, LB_zero):
        pass

    @command()
    def set_Calibration_offset_1(self, Calibration_offset_1):
        pass

    @command()
    def set_Calibration_scale_1(self, Calibration_scale_1):
        pass

    @command()
    def set_Calibration_offset_2(self, Calibration_offset_2):
        pass

    @command()
    def set_Calibration_scale_2(self, Calibration_scale_2):
        pass


    @command()
    def get_Current(self):
        return self.client.recv_uint32()

    @command()
    def get_Bias(self):
        return self.client.recv_uint32()

    @command()
    def get_fifo_length(self):
        return self.client.recv_uint32()

    @command()
    def get_buffer_length(self):
        return self.client.recv_uint32()

    @command()
    def get_PCR_data(self):
        return self.client.recv_vector(dtype='uint32')

    def set_dac(self):
        @command()
        def set_dac_data(self, data):
            pass
        dac_data_1 = np.uint32(np.floor(self.dac[0, :]))
        dac_data_2 = np.uint32(np.floor(self.dac[1, :]))
        dac_data_3 = np.uint32(np.floor(self.dac[3, :]))
        set_dac_data(self, dac_data_1 + (2^10 * dac_data_2) + (2^20 * dac_data_3))





