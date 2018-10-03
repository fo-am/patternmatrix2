import smbus
import time
import mcp23017
import tangible
import nrf

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23]

# sensor orientation
dn = 0
up = 1
lr = 2
rl = 3

layout44_old = [[0x20,0,rl], [0x20,1,rl], [0x20,2,rl], [0x20,3,rl], 
          [0x21,0,dn], [0x21,1,dn], [0x21,2,dn], [0x21,3,dn],
          [0x22,0,rl], [0x22,1,rl], [0x22,2,rl], [0x22,3,rl],
          [0x23,0,dn], [0x23,1,dn], [0x23,2,dn], [0x23,3,dn]]

layout44 = [[0x22,0,up], [0x22,1,up], [0x22,2,up], [0x22,3,up],
          [0x23,0,lr], [0x23,1,lr], [0x23,2,lr], [0x23,3,lr],
          [0x20,0,up], [0x20,1,up], [0x20,2,up], [0x20,3,up],
          [0x21,0,lr], [0x21,1,lr], [0x21,2,lr], [0x21,3,lr],
          ]


layout55 = [[0x26,3,rl], [0x20,0,up], [0x20,1,up], [0x20,2,up], [0x20,3,up], 
          [0x26,2,rl], [0x21,3,dn], [0x21,2,dn], [0x21,1,dn], [0x21,0,dn],
          [0x26,1,rl], [0x22,0,up], [0x22,1,up], [0x22,2,up], [0x22,3,up],
          [0x26,0,dn], [0x23,3,dn], [0x23,2,dn], [0x23,1,dn], [0x23,0,dn],
          [0x24,3,lr], [0x24,2,lr], [0x24,1,lr], [0x24,0,lr], [0x25,0,lr]]



tokens = {"circle":    [[0,0,0,0],[1,1,1,1]],

          "rectangle": [[0,1,
                         1,0],
                        [1,0,
                         0,1]],

          "triangle":  [[1,1,
                         0,0],
                        [0,1,
                         0,1],
                        [0,0,
                         1,1],
                        [1,0,
                         1,0]],
          
          "square":    [[0,0,0,1],[0,0,1,0],[0,1,0,0],[1,0,0,0],
                        [1,1,1,0],[1,1,0,1],[1,0,1,1],[0,1,1,1]]}

for address in mcp:
    mcp23017.init_mcp(bus,address)

grid = tangible.sensor_grid(16,layout44,tokens)

frequency=0.1

#######################################################
def convert_symbols(s):
    return {tangible.convert_4bit_twist(v):k for k, v in s}

symbols = [["b",[1,1,1,1]],["B",[0,0,0,0]],
           ["0",[1,0,1,0]],["0",[0,1,0,1]],
           ["0",[1,1,0,0]],["0",[0,1,1,0]],["0",[0,0,1,1]],["0",[1,0,0,1]],
           ["0",[1,0,0,0]],["0",[0,1,0,0]],["0",[0,0,1,0]],["0",[0,0,0,1]],
           ["0",[0,1,1,1]],["0",[1,0,1,1]],["0",[1,1,0,1]],["0",[1,1,1,0]]]

symbols = convert_symbols(symbols)

def build_pattern(data,symbols):
    pat=[]
    for i in range(0,4):
        s=""
        for v in data[i][:4]:
            s+=symbols[v]
        pat.append(s)
    return pat

glob_speed = 15

def send_pattern(radio,a,b,c,d):
    nrf.write_pattern(radio,glob_speed,4,0.3,a+b+c+"0000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,glob_speed,4,0.3,a+b+c+"0000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,glob_speed,4,0.3,a+b+c+"0000000000000")

def send_stop(radio):
    nrf.write_pattern(radio,glob_speed,4,0.3,"0000000000000000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,glob_speed,4,0.3,"0000000000000000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,glob_speed,4,0.3,"0000000000000000000000000")
    
def send_sync(radio):
    nrf.write_sync(radio)
    
#######################################################

last=""
last_col=0

radio = nrf.start_radio()
sync_count = 0

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    pat = build_pattern(grid.data(4),symbols)
    cc = pat[0]+pat[1]+pat[2]+pat[3]
    if cc!=last:
        last=cc    
        print("   "+pat[0]+" "+pat[1]+" "+pat[2]+"\n")
        send_pattern(radio,pat[0],pat[1],pat[2],pat[3])

    special=grid.state[12].value_current
    if special==1:
        send_stop(radio)
    if special==2:
        if sync_count==10*4:
            send_sync(radio)
        
    if sync_count==10*4:
        sync_count=0;
    sync_count+=1
    
    time.sleep(frequency)






