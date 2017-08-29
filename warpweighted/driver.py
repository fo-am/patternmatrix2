import smbus
import time
import mcp23017
import tangible
import osc
import sev_seg

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23,0x24,0x25,0x26]

debug_mcp = 0x25

# sensor orientation
dn = 0
up = 1
lr = 2
rl = 3

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
    if address==debug_mcp:
        sev_seg.init(bus,address)
    else:
        mcp23017.init_mcp(bus,address)

grid = tangible.sensor_grid(25,layout,tokens)

frequency=0.1

#######################################################
def convert_symbols(s):
    return {tangible.convert_4bit_twist(v):k for k, v in s}

symbols = [["1",[1,1,1,1]],["0",[0,0,0,0]],
           ["1",[1,0,1,0]],["0",[0,1,0,1]],
           ["1",[1,1,0,0]],["0",[0,1,1,0]],["1",[0,0,1,1]],["0",[1,0,0,1]],
           ["1",[1,0,0,0]],["1",[0,1,0,0]],["1",[0,0,1,0]],["1",[0,0,0,1]],
           ["0",[0,1,1,1]],["0",[1,0,1,1]],["0",[1,1,0,1]],["0",[1,1,1,0]]]

symbols = convert_symbols(symbols)

def build_pattern(data,symbols):
    pat=[]
    for i in range(0,4):
        s=""
        c = 0
        for v in data[i][:4]:
            s+=symbols[v]+" "
            c+=1
            if c%4==0: s+="0\n"
        pat.append(s)
    return pat+["0 0 0 0 0\n"]
                
def send_pattern(pat):
    osc.Message("/eval",["(loom-update! loom (list \n"+pat+"))"]).sendlocal(8000)

def send_col(col):
    print("colour shift: "+col)
    osc.Message("/eval",["(play-now (mul (adsr 0 0.1 1 0.1)"+
                         "(sine (mul (sine 30) 800))) 0)"+
                         "(set-warp-yarn! loom warp-yarn-"+col+")"+
                         "(set-weft-yarn! loom weft-yarn-"+col+")"]).sendlocal(8000)

flip = 1

def update_debug(pat):
    #print(pat)
    global flip
    if flip==1: flip=0
    else: flip=1

    sev_seg.write(bus,debug_mcp,[pat[0],pat[1],0,0,0,pat[3],pat[2],flip])

    
osc.Message("/eval",["(set-scale pentatonic-minor)"]).sendlocal(8000)

#######################################################

last=""
last_col=0

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    pat = build_pattern(grid.data(5),symbols)
    cc = pat[0]+pat[1]+pat[2]+pat[3]+pat[4]
    if cc!=last:
        last=cc    
        print(cc)
        send_pattern(cc)

    col=grid.state[24].value_current
    if col!=last_col:
        last_col=col
        if col==1: send_col("a")
        if col==2: send_col("b")
        if col==4: send_col("c")
        if col==8: send_col("d")
        if col==7: send_col("e")
        if col==11: send_col("f")
        if col==13: send_col("g")
        if col==14: send_col("h")

        #grid.pprint(5)
    time.sleep(frequency)

    update_debug(grid.last_debug)





