import smbus
import time
import mcp23017
import tangible
import nrf

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23,0x24,0x25,0x26]

# sensor orientation
dn = 0
up = 1
lr = 2
rl = 3

layout44 = [[0x20,0,rl], [0x20,1,rl], [0x20,2,rl], [0x20,3,rl], 
          [0x21,0,dn], [0x21,1,dn], [0x21,2,dn], [0x21,3,dn],
          [0x22,0,rl], [0x22,1,rl], [0x22,2,rl], [0x22,3,rl],
          [0x23,0,dn], [0x23,1,dn], [0x23,2,dn], [0x23,3,dn]]

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

grid = tangible.sensor_grid(25,layout55,tokens)

frequency=0.1

#######################################################
def convert_symbols(s):
    return {tangible.convert_4bit_twist(v):k for k, v in s}

symbols = [["0",[1,1,1,1]],["0",[0,0,0,0]],
           ["A",[1,0,1,0]],["a",[0,1,0,1]],
           ["0",[1,1,0,0]],["0",[0,1,1,0]],["0",[0,0,1,1]],["0",[1,0,0,1]],
           ["0",[1,0,0,0]],["0",[0,1,0,0]],["0",[0,0,1,0]],["0",[0,0,0,1]],
           ["0",[0,1,1,1]],["0",[1,0,1,1]],["0",[1,1,0,1]],["0",[1,1,1,0]]]

symbols = convert_symbols(symbols)

def build_pattern(data,symbols):
    pat=[]
    for i in range(0,4):
        s=""
        for v in data[i][:5]:
            s+=symbols[v]
        pat.append(s)
    return pat
                
def send_pattern(radio,a,b,c,d):
    nrf.write_pattern(radio,0,50,4,a+"000000000000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,0,50,4,b+"000000000000000000000")
    time.sleep(0.1)
    nrf.write_pattern(radio,0,50,4,c+"000000000000000000000")


#######################################################

last=""
last_col=0

radio = nrf.start_radio()

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    pat = build_pattern(grid.data(5),symbols)
    cc = pat[0]+pat[1]+pat[2]+pat[3]
    if cc!=last:
        last=cc    
        print("   "+pat[0]+pat[1]+pat[2]+pat[3]+"\n")
        send_pattern(radio,pat[0],pat[1],pat[2],pat[3])
        
    time.sleep(frequency)






