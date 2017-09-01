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
    if address==debug_mcp:
        sev_seg.init(bus,address)
    else:
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
#    osc.Message("/eval",["(set-nz-vx! z 0)"]).sendlocal(8000)
    osc.Message("/eval",["(set-nz-grp! z "+str(grp)+")"]).sendlocal(8000)

def send_bar(bar):
    print("bar: "+str(bar))
    osc.Message("/eval",["(set-nz-bar-reset! z "+str(bar)+")"]).sendlocal(8000)

def send_sch(sch):
    print("sch: "+sch)
    osc.Message("/eval",["(set-scale "+sch+")"]).sendlocal(8000)

def send_mul(mul):
    print("mul: "+str(mul))
    osc.Message("/eval",["(set-nz-bpm-mult! z "+str(mul)+")"]).sendlocal(8000)

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
last_grp=0
last_bar=0
last_sch=0
last_mul=0

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

    bar=grid.state[21].value_current
    if bar!=last_bar:
        last_bar=bar
        if bar==1: send_bar(0)
        if bar==2: send_bar(4)
        if bar==4: send_bar(8)
        if bar==8: send_bar(6)
        if bar==7: send_bar(12)
        if bar==11: send_bar(16)
        if bar==13: send_bar(24)
        if bar==14: send_bar(32)

    sch=grid.state[22].value_current
    if sch!=last_sch:
        last_sch=sch
        if sch==1: send_sch("major")
        if sch==2: send_sch("harmonic-minor")
        if sch==4: send_sch("pentatonic-major")
        if sch==8: send_sch("pentatonic-minor")
        if sch==7: send_sch("aeolian")
        if sch==11: send_sch("ethiopian")
        if sch==13: send_sch("hindu")
        if sch==14: send_sch("persian")

    mul=grid.state[23].value_current
    if mul!=last_mul:
        last_mul=mul
        if mul==1: send_mul(1)
        if mul==2: send_mul(2)
        if mul==4: send_mul(3)
        if mul==8: send_mul(4)
        if mul==7: send_mul(0.5)
        if mul==11: send_mul(0.25)
        if mul==13: send_mul(0.125)
        if mul==14: send_mul(1)
        
        #grid.pprint(5)
    time.sleep(frequency)

    update_debug(grid.last_debug)





