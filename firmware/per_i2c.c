//=============================================================================
//  omsp430_demo_tmct: I2C driver
//-----------------------------------------------------------------------------
//  per_i2c.c
//  I2C driver part of omsp430_demo_tmct
//-----------------------------------------------------------------------------
//  © 2022 tmct-web  https://ss1.xrea.com/tmct.s1009.xrea.com/
//
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//
//  1.  Redistributions of source code must retain the above copyright notice, 
//      this list of conditions and the following disclaimer.
//
//  2.  Redistributions in binary form must reproduce the above copyright notice, 
//      this list of conditions and the following disclaimer in the documentation and/or 
//      other materials provided with the distribution.
//
//  3.  Neither the name of the copyright holder nor the names of 
//      its contributors may be used to endorse or promote products derived from 
//      this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR 
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//=============================================================================

//=============================================================================
//  Definitions
//=============================================================================
#define I2C_PRERL   (*(volatile unsigned char *)  0x00b0)
#define I2C_PRERH   (*(volatile unsigned char *)  0x00b1)
#define I2C_CTR     (*(volatile unsigned char *)  0x00b2)
#define I2C_RXD     (*(volatile unsigned char *)  0x00b3)
#define I2C_SR      (*(volatile unsigned char *)  0x00b4)
#define I2C_TXD     (*(volatile unsigned char *)  0x00b5)
#define I2C_CR      (*(volatile unsigned char *)  0x00b6)

#define I2C_CR_STA      0x80
#define I2C_CR_STO      0x40
#define I2C_CR_RD       0x20
#define I2C_CR_WR       0x10
#define I2C_CR_ACK      0x08
#define I2C_CR_IACK     0x01
#define I2C_SR_RXACK    0x80
#define I2C_SR_BUSY     0x40
#define I2C_SR_AL       0x20
#define I2C_SR_TIP      0x02
#define I2C_SR_IF       0x01

void i2cInitialize();
unsigned char i2cBeginTransmission(unsigned char slaveAddr);
unsigned char i2cWrite(unsigned char data);
void i2cEndTransmission();
unsigned char i2cBeginRequest(unsigned char slaveAddr);
unsigned char i2cRead(unsigned char ack);


//=============================================================================
//  I2C initialization
//-----------------------------------------------------------------------------
//  Arguments:
//      None
//  Return:
//      None
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void i2cInitialize()
{

    I2C_CTR = 0x00;     // I2C Core disable
    I2C_PRERH = 0x00;   // SCL Frequency = 100KHz
    I2C_PRERL = 0x32;   //  -> 25MHz / (5 * 100KHz) = 0x0032
    I2C_CTR = 0x80;     // I2C Core enable

}


//=============================================================================
//  Send device address in write mode after start condition
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char slaveAddr
//          Set the slave address to be accessed
//          (e.g.)
//              If the device address is 0x50, set 0xa0, which is the value 
//              shifted 1 bit to the left.
//              Valid values for addresses bits are [7:1].
//              The least significant bit is overwritten to 0.(Write)
//  Return:
//      Status register value
//      [7] I2C_SR_RXACK    ... Received acknowledge from slave
//                              1 = NoAck, 0 = Ack
//      [6] I2C_SR_BUSY     ... I2C Bus in use
//      [5] I2C_SR_AL       ... Arbitration lost
//      [1] I2C_SR_TIP      ... Transfer in progress
//      [0] I2C_SR_IF       ... Interrupt Flag
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char i2cBeginTransmission(unsigned char slaveAddr)
{

    slaveAddr &= 0xfe;
    I2C_TXD = slaveAddr;
    I2C_CR = I2C_CR_STA | I2C_CR_WR;
    while ((I2C_SR & I2C_SR_TIP) == I2C_SR_TIP);
    return I2C_SR;

}


//=============================================================================
//  Send data to i2c bus
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char data
//          Data to be written
//  Return:
//      Status register value
//      [7] I2C_SR_RXACK    ... Received acknowledge from slave
//                              1 = NoAck, 0 = Ack
//      [6] I2C_SR_BUSY     ... I2C Bus in use
//      [5] I2C_SR_AL       ... Arbitration lost
//      [1] I2C_SR_TIP      ... Transfer in progress
//      [0] I2C_SR_IF       ... Interrupt Flag
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char i2cWrite(unsigned char data)
{

    I2C_TXD = data;
    I2C_CR = I2C_CR_WR;
    while ((I2C_SR & I2C_SR_TIP) == I2C_SR_TIP);
    return I2C_SR;

}


//=============================================================================
//  Stop condition and release the i2c bus
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char data
//          Data to be written
//  Return:
//      Status register value
//      [7] I2C_SR_RXACK    ... Received acknowledge from slave
//                              1 = NoAck, 0 = Ack
//      [6] I2C_SR_BUSY     ... I2C Bus in use
//      [5] I2C_SR_AL       ... Arbitration lost
//      [1] I2C_SR_TIP      ... Transfer in progress
//      [0] I2C_SR_IF       ... Interrupt Flag
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void i2cEndTransmission()
{

    while ((I2C_SR & I2C_SR_BUSY) == I2C_SR_BUSY)
    {
        I2C_CR = I2C_CR_STO;
    }

}


//=============================================================================
//  Send device address in read mode after start condition
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char slaveAddr
//          Set the slave address to be accessed
//          (e.g.)
//              If the device address is 0x50, set 0xa0, which is the value 
//              shifted 1 bit to the left.
//              Valid values for addresses bits are [7:1].
//              The least significant bit is overwritten to 1.(Read)
//  Return:
//      Status register value
//      [7] I2C_SR_RXACK    ... Received acknowledge from slave
//                              1 = NoAck, 0 = Ack
//      [6] I2C_SR_BUSY     ... I2C Bus in use
//      [5] I2C_SR_AL       ... Arbitration lost
//      [1] I2C_SR_TIP      ... Transfer in progress
//      [0] I2C_SR_IF       ... Interrupt Flag
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char i2cBeginRequest(unsigned char slaveAddr)
{

    slaveAddr |= 0x01;
    I2C_TXD = slaveAddr;
    I2C_CR = I2C_CR_STA | I2C_CR_WR;
    while ((I2C_SR & I2C_SR_TIP) == I2C_SR_TIP);
    return I2C_SR;

}


//=============================================================================
//  Read data from I2c bus
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char ack
//          Sets whether the acknowledge is returned to the device 
//          after data is received.
//          1 = NoAck, 0 = Ack
//          For most EEPROMs, set Ack to continue Read access or NoAck to 
//          not continue.
//  Return:
//      Status register value
//      [7] I2C_SR_RXACK    ... Received acknowledge from slave
//                              1 = NoAck, 0 = Ack
//      [6] I2C_SR_BUSY     ... I2C Bus in use
//      [5] I2C_SR_AL       ... Arbitration lost
//      [1] I2C_SR_TIP      ... Transfer in progress
//      [0] I2C_SR_IF       ... Interrupt Flag
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char i2cRead(unsigned char ack)
{

    if (ack != 0) I2C_CR = I2C_CR_RD | I2C_CR_ACK; else I2C_CR = I2C_CR_RD;
    while ((I2C_SR & I2C_SR_TIP) == I2C_SR_TIP);
    return I2C_RXD;

}
