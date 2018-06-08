import RPi.GPIO as GPIO
from lib_nrf24 import NRF24
import time
import spidev

GPIO.setmode(GPIO.BCM)

pipes = [[0xF0, 0xF0, 0xF0, 0xF0, 0xF0],[0x01, 0x01, 0x01, 0x01, 0x01]]

radio = NRF24(GPIO, spidev.SpiDev())
radio.begin(0, 17)

radio.setPayloadSize(32)
radio.setChannel(0x74)
#radio.setDataRate(NRF24.BR_1MBPS)
radio.setPALevel(NRF24.PA_MIN)

radio.setAutoAck(True)
radio.enableDynamicPayloads()
radio.enableAckPayload()

radio.openWritingPipe(pipes[1])
radio.openReadingPipe(1, pipes[0])

radio.printDetails()

#radio.startListening()

message = list("ON")
while len(message) < 32:
    message.append(0)

    while(1):

        #while not radio.available(pipes[0]):
        #    print("no radio")
        #    time.sleep(1)

        #recv_buffer = []
        #radio.read(recv_buffer, radio.getDynamicPayloadSize())
        #print ("Received:") ,
        #print (recv_buffer)
        #time.sleep(1)

        
        radio.write(message)
        print("Sent the message: {}".format(message))
        time.sleep(1)
