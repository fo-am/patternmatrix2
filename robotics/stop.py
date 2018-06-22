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

radio = NRF24(GPIO, spidev.SpiDev())
radio.begin(0, 17)
time.sleep(1)
radio.setRetries(15,15)
radio.setPayloadSize(32)
radio.setChannel(100)
radio.write_register(NRF24.FEATURE, 0)
radio.setPALevel(NRF24.PA_MAX)
radio.setAutoAck(False)

radio.openWritingPipe(pipes[1])
radio.openReadingPipe(1, pipes[0])
radio.printDetails()

def write_pattern(id,pat):
    servo_id = id
    servo_speed = 50
    servo_length = 4
    servo_pattern = pat    
    dat = struct.pack("cBHH", 'M', servo_id, servo_speed, servo_length)+servo_pattern
    radio.write(dat)

while True:

#    write_pattern(0,"A0a00000000000000000000000")
#    time.sleep(0.5)
#    write_pattern(1,"0A0a0000000000000000000000")
#    time.sleep(0.5)
#    write_pattern(2,"A0a00000000000000000000000")
#    time.sleep(0.5)

    write_pattern(0,"00000000000000000000000000")
    time.sleep(0.5)
    write_pattern(1,"00000000000000000000000000")
    time.sleep(0.5)
    write_pattern(2,"00000000000000000000000000")
    time.sleep(0.5)



