import smbus
import time
import mcp23017
import tangible

bus = smbus.SMBus(1)

mcp = [0x20,0x21] #,0x22,0x23,0x24,0x25,0x26,0x27]

layout = [ [0x25, 0], [0x20,0], [0x20,1], [0x20,2], [0x20,3],
           [0x25, 1], [0x21,0], [0x21,1], [0x21,2], [0x21,3],
           [0x25, 2], [0x22,0], [0x22,1], [0x22,2], [0x22,3],
           [0x25, 3], [0x23,0], [0x23,1], [0x23,2], [0x23,3],
           [0x26, 0], [0x24,0], [0x24,1], [0x24,2], [0x24,3] ]

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

grid = tangible.sensor_grid(25,layout,tokens)

frequency=0.1

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    #print()    
    print(grid.state[4].token_current,
          grid.state[4].value_current)
    time.sleep(frequency)


#######################################################
          

def test():
    c = sensor_filter(tokens)
    c.observation(0.1,convert_4bit([1,0,0,0]))
    c.observation(0.1,convert_4bit([1,0,0,0]))
    c.observation(0.1,convert_4bit([1,0,0,0]))
    c.observation(0.1,convert_4bit([1,1,0,0]))
    c.observation(0.1,convert_4bit([1,1,0,0]))
    c.observation(0.1,convert_4bit([0,1,0,0]))
    c.observation(0.1,convert_4bit([0,1,0,0]))
    c.observation(0.1,convert_4bit([0,1,0,0]))
    c.observation(0.1,convert_4bit([0,1,0,0]))


