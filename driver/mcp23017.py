import smbus

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


def read_inputs_a(bus,device):
    d = bus.read_byte_data(device,MCP_GPIOA)
    return [(d>>7)&1,
            (d>>6)&1,
            (d>>5)&1,
            (d>>4)&1,
            (d>>3)&1,
            (d>>2)&1,
            (d>>1)&1,
            (d)&1]

def read_inputs_b(bus,device):
    d = bus.read_byte_data(device,MCP_GPIOB)
    return [(d)&1,
            (d>>1)&1,
            (d>>2)&1,
            (d>>3)&1,
            (d>>4)&1,
            (d>>5)&1,
            (d>>6)&1,
            (d>>7)&1]

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

