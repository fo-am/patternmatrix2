import smbus
import mcp23017

##########################
#    a
#  f   b
#    g
#  e   c
#    d
#        h

def init(bus,mcp):
    try:
        print("setting up LED")
        bus.write_byte_data(mcp,mcp23017.MCP_IODIRA,0x03)
        bus.write_byte_data(mcp,mcp23017.MCP_IODIRB,0x03)
        bus.write_byte_data(mcp,mcp23017.MCP_GPPUA,0x03)
        bus.write_byte_data(mcp,mcp23017.MCP_GPPUB,0x03)
    except:
        print("IO problem "+format(mcp,"02x"))


# got a common anode so 0=led on
def write(bus,address,s):
    a_dat=0xff
    b_dat=0xff

    if s[0]==1: a_dat^=0x10
    if s[1]==1: b_dat^=0x08
    if s[2]==1: b_dat^=0x10
    if s[3]==1: a_dat^=0x04
    if s[4]==1: b_dat^=0x20
    if s[5]==1: b_dat^=0x04
    if s[6]==1: a_dat^=0x20
    if s[7]==1: a_dat^=0x08
     
    try:
        bus.write_byte_data(address,mcp23017.MCP_OLATA,a_dat)
        bus.write_byte_data(address,mcp23017.MCP_OLATB,b_dat)
    except:
        print("IO problem "+format(address,"02x"))
