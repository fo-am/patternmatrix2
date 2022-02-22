// reads a 5x5 pattern matrix and outputs it over serial

#include <Wire.h>

#define MCP_IODIRA 0x00
#define MCP_IODIRB 0x01
#define MCP_IPOLA 0x02
#define MCP_IPOLB 0x03
#define MCP_GPPUA 0x0c
#define MCP_GPPUB 0x0d
#define MCP_GPIOA 0x12
#define MCP_GPIOB 0x13
#define MCP_OLATA 0x14
#define MCP_OLATB 0x15

void read_inputs(unsigned char device, unsigned char gpio, unsigned char offs, unsigned char *ret) {
  Wire.beginTransmission(device); // transmit to device #8
  Wire.write(gpio);
  if (Wire.endTransmission()) {
    Serial.print("Error reading: ");
    Serial.println(device);
  }  
  Wire.requestFrom(device, 1);
  unsigned char d = Wire.read();

  // reverse GPIOA to make things a bit easier 
  // (due to the way the pcb is wired)
  if (gpio==MCP_GPIOA) {
    ret[offs+7]=d&0x01;
    ret[offs+6]=(d>>1)&1;
    ret[offs+5]=(d>>2)&1;
    ret[offs+4]=(d>>3)&1;
    ret[offs+3]=(d>>4)&1;
    ret[offs+2]=(d>>5)&1;
    ret[offs+1]=(d>>6)&1;
    ret[offs]=(d>>7)&1;  
  } else {  
    ret[offs]=d&0x01;
    ret[offs+1]=(d>>1)&1;
    ret[offs+2]=(d>>2)&1;
    ret[offs+3]=(d>>3)&1;
    ret[offs+4]=(d>>4)&1;
    ret[offs+5]=(d>>5)&1;
    ret[offs+6]=(d>>6)&1;
    ret[offs+7]=(d>>7)&1;
  }
}

// ret = 16 char array
void read_raw(unsigned char device, unsigned char *ret) {
  read_inputs(device,MCP_GPIOA,0,ret);
  read_inputs(device,MCP_GPIOB,8,ret);
}

void write_reg(unsigned char device, unsigned char address, unsigned char value) {
  Wire.beginTransmission(device); // transmit to device #8
  Wire.write(address);
  Wire.write(value);
  if (Wire.endTransmission()) {
    Serial.print("Error writing: ");
    Serial.println(device);
  }
  delay(50);
}

void init_mcp(unsigned char device) {
  write_reg(device,MCP_IODIRA,0xff);
  write_reg(device,MCP_IODIRB,0xff);
  write_reg(device,MCP_IPOLA,0x00);
  write_reg(device,MCP_IPOLB,0x00);
  write_reg(device,MCP_GPPUA,0xff);
  write_reg(device,MCP_GPPUB,0xff);
}

void check_mcp(unsigned char device) {
  Wire.beginTransmission(device);
  if (Wire.endTransmission()) {
    Serial.print("Error reading device: ");
    Serial.println(device);
  } 
}

void setup() {
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
  init_mcp(0x20);
  init_mcp(0x21);
  init_mcp(0x22);
  init_mcp(0x23);
  init_mcp(0x24);
  init_mcp(0x25);
  init_mcp(0x26);
} 

void display(unsigned char *dat) {
  unsigned int pos=0;
  for (unsigned int r=0; r<14; r++) {
    for (unsigned int i=0; i<8; i++) {
      Serial.print((int)dat[pos++]);
      Serial.print(" ");
    }
    Serial.println();
  }
  Serial.println();
}

unsigned char state[16*7];

unsigned char sensor_state_lookup [100]={
  1,  9,  0,  8, // 0 clockwise: first bit matches token 0 corner
  3, 11,  2, 10, // 1
  5, 13,  4, 12, // 2
  7, 15,  6, 14, // 3
110,102,111,103, // 4
  
 16, 24, 17, 25, // 5
 18, 26, 19, 27, // 6
 20, 28, 21, 29, // 7
 22, 30, 23, 31, // 8
108,100,109,101, // 9

 33, 41, 32, 40, // 10
 35, 43, 34, 42, // 11
 37, 45, 36, 44, // 12
 39, 47, 38, 48, // 13
 106,98,107, 99, // 14

 48, 56, 49, 57, // 15
 50, 58, 51, 59, // 16
 52, 60, 53, 61, // 17
 54, 62, 55, 63, // 18
 105,97,104, 96, // 19 (this one is upside down)

  95, 87, 94, 86, // 20 (special addition)
  73, 65, 72, 64, // 21
  75, 67, 74, 66, // 22
  77, 69, 76, 68, // 23
  79, 71, 78, 70  // 24
};

void lookup_sensor_bits(unsigned char *state, unsigned char sensor, unsigned char *out) {
    out[0]=state[sensor_state_lookup[sensor*4]];
    out[1]=state[sensor_state_lookup[sensor*4+1]];
    out[2]=state[sensor_state_lookup[sensor*4+2]];
    out[3]=state[sensor_state_lookup[sensor*4+3]];
}

unsigned char lookup_sensor_code(unsigned char *state, unsigned char sensor) {
    return state[sensor_state_lookup[sensor*4]] |
           state[sensor_state_lookup[sensor*4+1]]<<1 |
           state[sensor_state_lookup[sensor*4+2]]<<2 |
           state[sensor_state_lookup[sensor*4+3]]<<3;
}


void loop() {
  // read from all the sensors into our state block
  // shuffle the device read to order the state a bit
  // more sensibly
  read_raw(0x21,state);  
  read_raw(0x20,state+(16*1));  
  read_raw(0x23,state+(16*2));  
  read_raw(0x22,state+(16*3));  
  read_raw(0x24,state+(16*4));  
  read_raw(0x25,state+(16*5));  
  read_raw(0x26,state+(16*6));  

 // display(state);

  unsigned char sensor_bits[4];

  int pos=0;
  for (unsigned int y=0; y<5; y++) {
    for (unsigned int x=0; x<5; x++) {
      Serial.print(lookup_sensor_code(state,pos++));
      Serial.print(" ");
    }
    Serial.println();
  }
  Serial.println();
  delay(500);
}
