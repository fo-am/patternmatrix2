EESchema Schematic File Version 2
LIBS:location-rescue
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
LIBS:patternmatrix
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
	4900 2600 4300 2600
Wire Wire Line
	5700 2600 5500 2600
Wire Wire Line
	5500 2600 5500 2800
Wire Wire Line
	5500 2800 4850 2800
Wire Wire Line
	4850 2800 4850 2700
Wire Wire Line
	4850 2700 4300 2700
Wire Wire Line
	5700 3100 5500 3100
Wire Wire Line
	5500 3100 5500 2900
Wire Wire Line
	5500 2900 4750 2900
Wire Wire Line
	4750 2900 4750 2800
Wire Wire Line
	4750 2800 4300 2800
Wire Wire Line
	4900 3100 4900 2950
Wire Wire Line
	4900 2950 4700 2950
Wire Wire Line
	4700 2950 4700 2900
Wire Wire Line
	4700 2900 4300 2900
$Comp
L C-RESCUE-location C1
U 1 1 5922FA46
P 4550 2300
F 0 "C1" H 4550 2400 40  0000 L CNN
F 1 "C 0.1uf" H 4556 2215 40  0000 L CNN
F 2 "Capacitors_THT:C_Disc_D3.8mm_W2.6mm_P2.50mm" V 4400 2250 30  0000 C CNN
F 3 "~" H 4550 2300 60  0000 C CNN
	1    4550 2300
	0    1    1    0   
$EndComp
Wire Wire Line
	4300 2500 5000 2500
Wire Wire Line
	5000 2500 5000 2400
Wire Wire Line
	5000 2400 6350 2400
Wire Wire Line
	4300 2400 4800 2400
Connection ~ 5950 2400
Connection ~ 5950 3300
Wire Wire Line
	4750 2300 4750 2400
Connection ~ 4750 2400
Wire Wire Line
	4350 2300 4350 2500
Connection ~ 4350 2500
$Comp
L CONN_01X06 J1
U 1 1 592E8085
P 4100 2650
F 0 "J1" H 4100 3000 50  0000 C CNN
F 1 "CONN_01X06" V 4200 2650 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x06_Pitch2.54mm" H 4100 2650 50  0001 C CNN
F 3 "" H 4100 2650 50  0001 C CNN
	1    4100 2650
	-1   0    0    -1  
$EndComp
$EndSCHEMATC
