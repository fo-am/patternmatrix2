#!/usr/bin/python
# -*- coding: utf-8 -*-
#
# Example program to send packets to the radio link
#


import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
from lib_nrf24 import NRF24
import time
import spidev
import struct


pipes = [[0x01, 0x01, 0x01, 0x1, 0x01], [0xa7, 0xa7, 0xa7, 0xa7, 0xa7]]


def start_radio():
    radio = NRF24(GPIO, spidev.SpiDev())
    radio.begin(0, 17)
    time.sleep(1)
    radio.setRetries(15,15)
    radio.setPayloadSize(32)
    radio.setChannel(100)
    radio.write_register(NRF24.FEATURE, 0)
    radio.setPALevel(NRF24.PA_MIN)
    radio.setAutoAck(False)

    radio.openWritingPipe(pipes[1])
    radio.openReadingPipe(1, pipes[0])
    radio.printDetails()
    return radio

def write_pattern(radio,speed,length,smoothing,pat):
    dat = struct.pack("cBHH", 'M', 0, speed, length)+pat
    print("sending "+str(len(dat)))
    radio.write(dat)

def write_sync(radio):
    dat = struct.pack("c", 'S');
    radio.write(dat)






