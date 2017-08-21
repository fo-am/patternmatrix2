import smbus
import time
import mcp23017
import tangible
import osc

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23,0x24,0x25,0x26]

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

layout = [[0x26,3,rl], [0x20,0,up], [0x20,1,up], [0x20,2,up], [0x20,3,up], 
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

grid = tangible.sensor_grid(25,layout,tokens)

frequency=0.1

#######################################################
def convert_symbols(s):
    return {tangible.convert_4bit_twist(v):k for k, v in s.items()}

symbols = {" ":[1,1,1,1],".":[0,0,0,0],
           "+":[1,0,1,0],"-":[0,1,0,1],
           "a":[1,1,0,0],"b":[0,1,1,0],"c":[0,0,1,1],"d":[1,0,0,1],
           "C":[1,0,0,0],"D":[0,1,0,0],"A":[0,0,1,0],"B":[0,0,0,1],
           "<":[0,1,1,1],"[":[1,0,1,1],">":[1,1,0,1],"]":[1,1,1,0]}

symbols = convert_symbols(symbols)

def build_pattern(data,symbols):
    pat=[]
    for i in range(0,4):
        s=""
        for v in data[i]:
            s+=symbols[v]
        pat.append(s)
    return pat
                
def send_pattern(pat):
    osc.Message("/eval",["(lz-prog l 0 \""+pat[0]+"\")\n "+\
                         "(lz-prog l 1 \""+pat[1]+"\")\n "+\
                         "(lz-prog l 2 \""+pat[2]+"\")\n "+\
                         "(lz-prog l 3 \""+pat[3]+"\")\n "]).sendlocal(8000)


def send_grp(grp):
    osc.Message("/eval",["(set-nz-vx! z 0)"]).sendlocal(8000)
    osc.Message("/eval",["(set-nz-grp! z "+str(grp)+")"]).sendlocal(8000)

send_grp(4)    
osc.Message("/eval",["(set-scale pentatonic-minor)"]).sendlocal(8000)

#######################################################

last=""
last_grp=0

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    pat = build_pattern(grid.data(5),symbols)
    cc = pat[0]+pat[1]+pat[2]+pat[3]
    if cc!=last:
        last=cc    
        print(pat)
        send_pattern(pat)
    grp=grid.state[20].value_current
    if grp!=last_grp:
        last_grp=grp
        if grp==1: send_grp(0)
        if grp==2: send_grp(1)
        if grp==4: send_grp(2)
        if grp==8: send_grp(3)
        if grp==7: send_grp(4)
        if grp==11: send_grp(5)
        if grp==13: send_grp(6)
        if grp==14: send_grp(7)
    #grid.pprint(5)
    time.sleep(frequency)




