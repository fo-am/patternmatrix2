import smbus
import time
import mcp23017
import tangible
import osc
import sev_seg

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23]

# sensor orientation
dn = 0
up = 1
lr = 2
rl = 3

layout_rot = [[0x25,0,lr], [0x24,0,lr], [0x24,1,lr], [0x24,2,lr], [0x24,3,lr],
          [0x23,0,dn], [0x23,1,dn], [0x23,2,dn], [0x23,3,dn], [0x26,0,dn],
          [0x22,3,up], [0x22,2,up], [0x22,1,up], [0x22,0,up], [0x26,1,rl],
          [0x21,0,dn], [0x21,1,dn], [0x21,2,dn], [0x21,3,dn], [0x26,2,rl],
          [0x20,3,up], [0x20,2,up], [0x20,1,up], [0x20,0,up], [0x26,3,rl] ]

layout55 = [[0x26,3,rl], [0x20,0,up], [0x20,1,up], [0x20,2,up], [0x20,3,up], 
          [0x26,2,rl], [0x21,3,dn], [0x21,2,dn], [0x21,1,dn], [0x21,0,dn],
          [0x26,1,rl], [0x22,0,up], [0x22,1,up], [0x22,2,up], [0x22,3,up],
          [0x26,0,dn], [0x23,3,dn], [0x23,2,dn], [0x23,1,dn], [0x23,0,dn],
          [0x24,3,lr], [0x24,2,lr], [0x24,1,lr], [0x24,0,lr], [0x25,0,lr]]

layout = [[0x22,0,up], [0x22,1,up], [0x22,2,up], [0x22,3,up],
          [0x23,0,lr], [0x23,1,lr], [0x23,2,lr], [0x23,3,lr],
          [0x20,0,up], [0x20,1,up], [0x20,2,up], [0x20,3,up],
          [0x21,0,lr], [0x21,1,lr], [0x21,2,lr], [0x21,3,lr],
          ]
          


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

grid = tangible.sensor_grid(16,layout,tokens)

frequency=0.1

#######################################################
def convert_symbols(s):
    return {tangible.convert_4bit_twist(v):k for k, v in s.items()}

symbols = {" ":[1,1,1,1],".":[0,0,0,0],
           "+":[1,0,1,0],"-":[0,1,0,1],
           "A":[1,1,0,0],"B":[0,1,1,0],"C":[0,0,1,1],"D":[1,0,0,1],
#'           "C":[1,0,0,0],"D":[0,1,0,0],"A":[0,0,1,0],"B":[0,0,0,1],"<":[0,1,1,1],"[":[1,0,1,1],">":[1,1,0,1],"]":[1,1,1,0]}
           "c":[1,0,0,0],"d":[0,1,0,0],"a":[0,0,1,0],"b":[0,0,0,1],"g":[0,1,1,1],"h":[1,0,1,1],"e":[1,1,0,1],"f":[1,1,1,0]}

symbols = convert_symbols(symbols)

flip = 1


#######################################################


while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))

        #print(mcp23017.read_inputs_a(bus,address))
        #print(mcp23017.read_inputs_b(bus,address))

    grid.pprint(4)
    #print(grid.last_debug)
    time.sleep(frequency)







