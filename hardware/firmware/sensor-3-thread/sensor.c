#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include <util/delay_basic.h>
#include "usiTwiSlave.h"

#define LED PB1
uint8_t EEMEM i2c_addr = 0x26;

// Somewhere to store the values the master writes to i2c register 2 and 3.
static volatile uint8_t i2cReg2 = 0;
static volatile uint8_t i2cReg3 = 0;

// A callback triggered when the i2c master attempts to read from a register.
uint8_t i2cReadFromRegister(uint8_t reg) {
  switch (reg) {
  case 0: 
    return eeprom_read_byte(&i2c_addr);
  case 1:
    return 99;
  default:
    return 0xff;
  }
}

// A callback triggered when the i2c master attempts to write to a register.
void i2cWriteToRegister(uint8_t reg, uint8_t value) {
  switch (reg) {
  case 0:
    eeprom_update_byte(&i2c_addr,value);
    break;
  case 2: 
    i2cReg2 = value;
    break;
  case 3:
    i2cReg3 = value;
    break;
  }
}

int main() {
  // Set the LED pin as output.
  DDRB |= (1 << LED);  
  usiTwiSlaveInit(eeprom_read_byte(&i2c_addr), i2cReadFromRegister, i2cWriteToRegister);
  sei();
  
  while (1) {
    // This is a pretty pointless example which allows me to test writing to two i2c registers: the
    // LED is only lit if both registers have the same value.
    if (i2cReg2 == i2cReg3)
      PORTB |= 1 << LED;
    else
      PORTB &= ~(1 << LED);
  }
}

