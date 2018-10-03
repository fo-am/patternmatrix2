EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:location-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "noname.sch"
Date "25 may 2017"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L SS411P Q1
U 1 1 5922F002
P 5050 2600
F 0 "Q1" H 5300 2500 50  0000 C CNN
F 1 "SS411P" H 5300 2750 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-92_Horizontal1_Inline_Narrow_Oval" H 5050 2600 60  0001 C CNN
F 3 "" H 5050 2600 60  0000 C CNN
	1    5050 2600
	1    0    0    -1  
$EndComp
$Comp
L SS411P Q2
U 1 1 5922F011
P 5850 2600
F 0 "Q2" H 6100 2500 50  0000 C CNN
F 1 "SS411P" H 6100 2750 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-92_Horizontal1_Inline_Narrow_Oval" H 5850 2600 60  0001 C CNN
F 3 "" H 5850 2600 60  0000 C CNN
	1    5850 2600
	1    0    0    -1  
$EndComp
$Comp
L SS411P Q4
U 1 1 5922F020
P 5050 3100
F 0 "Q4" H 5300 3000 50  0000 C CNN
F 1 "SS411P" H 5300 3250 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-92_Horizontal1_Inline_Narrow_Oval" H 5050 3100 60  0001 C CNN
F 3 "" H 5050 3100 60  0000 C CNN
	1    5050 3100
	1    0    0    1   
$EndComp
$Comp
L SS411P Q3
U 1 1 5922F02F
P 5850 3100
F 0 "Q3" H 6100 3000 50  0000 C CNN
F 1 "SS411P" H 6100 3250 50  0000 C CNN
F 2 "TO_SOT_Packages_THT:TO-92_Horizontal1_Inline_Narrow_Oval" H 5850 3100 60  0001 C CNN
F 3 "" H 5850 3100 60  0000 C CNN
	1    5850 3100
	1    0    0    1   
$EndComp
Wire Wire Line
	5150 2800 5150 2900
Wire Wire Line
	5950 2800 5950 2900
Wire Wire Line
	4800 2850 5950 2850
Connection ~ 5150 2850
Wire Wire Line
	5150 3300 6350 3300
Wire Wire Line
	6350 3300 6350 2400
Connection ~ 5950 2850
Connection ~ 5150 2400
Wire Wire Line
	4800 2400 4800 2850
Wire Wire Line
	4150 2600 4900 2600
Wire Wire Line
	5700 2600 5500 2600
Wire Wire Line
	5500 2600 5500 2800
Wire Wire Line
	5500 2800 4850 2800
Wire Wire Line
	4850 2800 4850 2700
Wire Wire Line
	4850 2700 4150 2700
Wire Wire Line
	5700 3100 5500 3100
Wire Wire Line
	5500 3100 5500 2900
Wire Wire Line
	5500 2900 4750 2900
Wire Wire Line
	4750 2900 4750 2800
Wire Wire Line
	4750 2800 4150 2800
Wire Wire Line
	4900 3100 4900 2950
Wire Wire Line
	4900 2950 4700 2950
Wire Wire Line
	4700 2950 4700 2900
Wire Wire Line
	4700 2900 4150 2900
Wire Wire Line
	4150 2500 5000 2500
Wire Wire Line
	5000 2500 5000 2400
Wire Wire Line
	5000 2400 6350 2400
Wire Wire Line
	4150 2400 4800 2400
Connection ~ 5950 2400
Connection ~ 5950 3300
$Comp
L CONN_01X06 J1
U 1 1 592E8085
P 3950 2650
F 0 "J1" H 3950 3000 50  0000 C CNN
F 1 "CONN_01X06" V 4050 2650 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x06_Pitch2.54mm" H 3950 2650 50  0001 C CNN
F 3 "" H 3950 2650 50  0001 C CNN
	1    3950 2650
	-1   0    0    -1  
$EndComp
Text Notes 4100 2400 0    60   ~ 0
GND
Text Notes 4100 2500 0    60   ~ 0
VCC
Text Notes 4100 2600 0    60   ~ 0
S1
Text Notes 4100 2700 0    60   ~ 0
S2
Text Notes 4100 2800 0    60   ~ 0
S3
Text Notes 4100 2900 0    60   ~ 0
S4
$Comp
L Conn_01x01 J2
U 1 1 5B9CE186
P 3800 3250
F 0 "J2" H 3800 3350 50  0000 C CNN
F 1 "Conn_01x01" H 3800 3150 50  0000 C CNN
F 2 "Connectors:1pin" H 3800 3250 50  0001 C CNN
F 3 "" H 3800 3250 50  0001 C CNN
	1    3800 3250
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J3
U 1 1 5B9CE219
P 4200 3250
F 0 "J3" H 4200 3350 50  0000 C CNN
F 1 "Conn_01x01" H 4200 3150 50  0000 C CNN
F 2 "Connectors:1pin" H 4200 3250 50  0001 C CNN
F 3 "" H 4200 3250 50  0001 C CNN
	1    4200 3250
	1    0    0    -1  
$EndComp
$Comp
L Conn_01x01 J4
U 1 1 5B9CE25E
P 4200 3500
F 0 "J4" H 4200 3600 50  0000 C CNN
F 1 "Conn_01x01" H 4200 3400 50  0000 C CNN
F 2 "Connectors:1pin" H 4200 3500 50  0001 C CNN
F 3 "" H 4200 3500 50  0001 C CNN
	1    4200 3500
	1    0    0    -1  
$EndComp
$EndSCHEMATC
