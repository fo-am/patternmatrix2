import smbus
import time
import mcp23017
import tangible
import osc

bus = smbus.SMBus(1)

mcp = [0x20,0x21,0x22,0x23]

# sensor orientation
dn = 0
up = 1
lr = 2
rl = 3

layout = [[0x20,0,dn], [0x20,1,dn], [0x20,2,dn], [0x20,3,dn], 
          [0x21,0,dn], [0x21,1,dn], [0x21,2,dn], [0x21,3,dn],
          [0x22,0,dn], [0x22,1,dn], [0x22,2,dn], [0x22,3,dn],
          [0x23,0,dn], [0x23,1,dn], [0x23,2,dn], [0x23,3,dn]]

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
    return {tangible.convert_4bit_twist(v):k for k, v in s}

symbols = [["ccw",[1,1,1,1]],["cw",[0,0,0,0]],
           ["cw",[1,0,1,0]],["cw",[0,1,0,1]],
           ["flip-all",[1,1,0,0]],["flip-odd",[0,1,1,0]],["flip-even",[0,0,1,1]],["flip-fhalf",[1,0,0,1]],
           ["cw",[1,0,0,0]],["cw",[0,1,0,0]],["cw",[0,0,1,0]],["cw",[0,0,0,1]],
           ["cw",[0,1,1,1]],["cw",[1,0,1,1]],["cw",[1,1,0,1]],["cw",[1,1,1,0]]]

symbols = convert_symbols(symbols)

def build_pattern(data,symbols):
    pat=[]
    for i in range(0,4):
        s=""
        for v in data[i][:4]:
            s+=symbols[v]+" "
        pat.append(s)
    return pat
                
def send_pattern(pat):
    osc.Message("/eval",["(weave-instructions '(\n"+pat+"))"]).sendlocal(8000)

def send_col(col):
    print("colour shift: "+col)
    osc.Message("/eval",["(play-now (mul (adsr 0 0.1 1 0.1)"+
                         "(sine (mul (sine 30) 800))) 0)"+
                         "(set-warp-yarn! loom warp-yarn-"+col+")"+
                         "(set-weft-yarn! loom weft-yarn-"+col+")"]).sendlocal(8000)

#######################################################

last=""
last_col=0

while True:
    for address in mcp:
        grid.update(frequency,address,
                    mcp23017.read_inputs_a(bus,address),
                    mcp23017.read_inputs_b(bus,address))
    pat = build_pattern(grid.data(4),symbols)
    cc = pat[0]+pat[1]+pat[2]+pat[3]
    if cc!=last:
        last=cc    
        print("   "+pat[0]+pat[1]+pat[2]+pat[3]+"\n")
        send_pattern(cc)
        
    col=grid.state[15].value_current
    if False: #col!=last_col:
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






