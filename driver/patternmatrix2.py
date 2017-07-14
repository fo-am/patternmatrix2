import smbus
import time

bus = smbus.SMBus(1)

MCP_IODIRA = 0x00
MCP_IODIRB = 0x01
MCP_GPPUA = 0x0c
MCP_GPPUB = 0x0d
MCP_GPIOA = 0x12
MCP_GPIOB = 0x13

def read_sensor(bus,device,gpio,sensor):
    d = bus.read_byte_data(device,gpio)
    return [(d>>sensor)&1,
            (d>>1+sensor)&1,
            (d>>2+sensor)&1,
            (d>>3+sensor)&1]

def init_mcp(bus,mcp):
    bus.write_byte_data(mcp,MCP_IODIRA,0xff)
    bus.write_byte_data(mcp,MCP_IODIRB,0xff)
    bus.write_byte_data(mcp,MCP_GPPUA,0xff)
    bus.write_byte_data(mcp,MCP_GPPUB,0xff)

def print_raw(bus,mcp):
    print(read_sensor(bus,mcp,MCP_GPIOA,0))
    print(read_sensor(bus,mcp,MCP_GPIOA,4))
    print(read_sensor(bus,mcp,MCP_GPIOB,0))
    print(read_sensor(bus,mcp,MCP_GPIOB,4))


mcp = [0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27]

init_mcp(bus,mcp[0])
init_mcp(bus,mcp[1])

while True:
    print("--")
    print_raw(bus,mcp[0])
    print_raw(bus,mcp[1])
    time.sleep(0.1)
