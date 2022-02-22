#include <avr/io.h>
#include <avr/interrupt.h>
//#include <avr/eeprom.h>
#include <util/delay_basic.h>
#include <util/delay.h>
#include "usiTwiSlave.h"

#define SENSOR_A PB4
#define SENSOR_B PB1
#define SENSOR_C PB5 // reset
#define SENSOR_D PB3

// tried all sorts of nonsense to make i2c addresses writable so
// we can build different configurations of pattern matrix, but they
// are just to susceptable to noise - so hardcoding em for now...
#define I2C_ADDR 0x0a

uint8_t counter=0;

uint8_t i2c_read(uint8_t reg) {
  switch (reg) {
  case 0: return (PINB&_BV(SENSOR_A))!=0;
  case 1: return (PINB&_BV(SENSOR_B))!=0;
  case 2: return (PINB&_BV(SENSOR_C))!=0;
  case 3: return (PINB&_BV(SENSOR_D))!=0; 
  case 4: return counter++; 
  case 5: return I2C_ADDR; 
  default:
    return 0xff;
  }
}

void i2c_write(uint8_t reg, uint8_t value) {}

int main() {
  DDRB = 0x00; // all inputs
  usiTwiSlaveInit(I2C_ADDR, i2c_read, i2c_write);
  sei();
  
  while (1) {
    _delay_ms(1000);    
  }
}

