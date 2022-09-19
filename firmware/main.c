//=============================================================================
//  omsp430_demo_tmct: Main function
//-----------------------------------------------------------------------------
//  main.c
//  Main function part of omsp430_demo_tmct
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
#include "hardware.h"
#include "ivectors.h"


//=============================================================================
//  Function prototype declarations
//=============================================================================
//  main.c --------------------------------------------------------------------
#define GPIO0_PORT  (*(volatile unsigned char *)  0x0090)
#define GPIO0_DIR   (*(volatile unsigned char *)  0x0091)
#define GPIO1_PORT  (*(volatile unsigned char *)  0x0092)
#define GPIO1_DIR   (*(volatile unsigned char *)  0x0093)
#define console_ppt '>'
#define console_len 15
unsigned char hexByteStringToChar(char *str);
unsigned short hexByteStringToShort(char *str);

//  per_uart.c ----------------------------------------------------------------
void uartInitialize();
void uartClearReceive();
unsigned char uartGetReceiveChar();
void uartSendChar(unsigned char data);
void uartSendAsciiValue(unsigned char cc, unsigned short val);

//  per_i2c.c -----------------------------------------------------------------
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
//  Main function
//-----------------------------------------------------------------------------
//  Arguments:
//      None
//  Return:
//      int
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
int main(void)
{

    volatile unsigned char console_buf[console_len];
    volatile unsigned char console_byte;
    volatile unsigned char console_bufpos;
    volatile unsigned char i, j;
    volatile unsigned short addr;
    volatile unsigned char data;

    uartInitialize();
    i2cInitialize();
    GPIO0_DIR = 0x00;   // All input
    GPIO1_DIR = 0xff;   // All output

    while (1)
    {
        console_bufpos = 0;
        uartSendChar(console_ppt);
        eint();     // Interrupt enable

        //---------------------------------------------------------------------
        //  Receive loop
        //  Exits this loop when [LF] is received
        //--------------------------- https://ss1.xrea.com/tmct.s1009.xrea.com/
        for (i = 0; i < console_len; i++) console_buf[i] = 0;
        while (1)
        {

            // Waiting for receipt --------------------------------------------
            console_byte = 0xff;
            while (console_byte > 0x80)
            {
                console_byte = uartGetReceiveChar();
                if (console_byte == 0xfe) uartSendChar('!');
            }

            // Processes received data ----------------------------------------
            if ((console_byte == 0x0a) || (console_byte == 0x0d))
            {
                // When [CR] or [LF] is received
                uartSendChar(0x0d); // [CR]
                uartSendChar(0x0a); // [LF]
                break;
            }
            else if (console_byte == 0x08)
            {
                // When [BS] is received
                // Delete previous character
                if (console_bufpos > 0) {
                    uartSendChar(0x08); // [BS]
                    uartSendChar(' ');  // [SP]
                    uartSendChar(0x08); // [BS]
                    console_buf[console_bufpos] = 0;
                    console_bufpos--;
                }
                console_buf[console_bufpos] = 0;
            }
            else if (console_byte < ' ')
            {
                // For other control codes
                // Do nothing
            }
            else
            {
                // Other characters
                if (console_bufpos < console_len) {
                    console_buf[console_bufpos] = console_byte;
                    uartSendChar(console_byte);
                    console_bufpos++;
                }
            }
        }

        dint();     // Interrupt disable

        //---------------------------------------------------------------------
        //  Command processing
        //--------------------------- https://ss1.xrea.com/tmct.s1009.xrea.com/
        // SR / SW ------------------------------------------------------------
        //  Read/Write access to cpu bus space
        //  srxxxx
        //      Reads the value at address xxxx in cpu bus space and returns it 
        //      as a hex ascii value.
        //      xxxx    = Address to read(hex)
        //          Must be specified with 4 digits.
        //          Leading zeros cannot be omitted, so for example, 
        //          address a0 must be specified as 00a0.
        //  swxxxxyy
        //      Write value yy to address xxxx in cpu bus space.
        //      xxxx    = Address to write(hex)
        //          Must be specified with 4 digits.
        //      yy      = Value to write(hex)
        //          Must be specified with 2 digits.
        if ((console_buf[0] == 's') || (console_buf[0] == 'S'))
        {
            if ((console_buf[1] == 'r') || (console_buf[1] == 'R'))
            {
                addr = hexByteStringToShort((char *)&console_buf[2]);   // Address to read
                data = (*(volatile unsigned char *)addr);
                uartSendAsciiValue(2, data);
                uartSendChar(0x0d); // [CR]
                uartSendChar(0x0a); // [LF]
            }
            else if ((console_buf[1] == 'w') || (console_buf[1] == 'W'))
            {
                addr = hexByteStringToShort((char *)&console_buf[2]);   // Address to write
                data = hexByteStringToChar((char *)&console_buf[6]);    // Data to write
                (*(volatile unsigned char *)addr) = data;
                uartSendChar(0x0d); // [CR]
                uartSendChar(0x0a); // [LF]
            }
        }
        // PR / PW ------------------------------------------------------------
        //  Read/Write access to the specified GPIO port
        //  prxx
        //      Reads the state of GPIO port xx and returns it as a hex ascii value.
        //      xx  = Port number to read(hex)
        //          Must be specified with 2 digits.
        //          00: Port00
        //              In the demonstration configuration, this port is 
        //              connected to the breadboard slide switch 7-0.
        //          01: Port01
        //              In the demonstration configuration, this port is 
        //              connected to LED7-0 on the breadboard.
        //  pwxxyy
        //      Write yy to GPIO port xx.
        //      Writing a value to a port that is set as an input has no effect.
        //      xx  = Port number to write(hex)
        //          Must be specified with 2 digits.
        //      yy  = Value to write(hex)
        //          Must be specified with 2 digits.
        if ((console_buf[0] == 'p') || (console_buf[0] == 'P'))
        {
            if ((console_buf[1] == 'r') || (console_buf[1] == 'R'))
            {
                i = hexByteStringToChar((char *)&console_buf[2]);   // Port number to read
                if      (i == 0x00) data = GPIO0_PORT;
                else if (i == 0x01) data = GPIO1_PORT;
                else                data = 0xff;
                uartSendAsciiValue(2, data);
                uartSendChar(0x0d); // [CR]
                uartSendChar(0x0a); // [LF]
            }
            else if ((console_buf[1] == 'w') || (console_buf[1] == 'W'))
            {
                i = hexByteStringToChar((char *)&console_buf[2]);       // Port number to write
                data = hexByteStringToChar((char *)&console_buf[4]);    // Data to write
                if      (i == 0x00) GPIO0_PORT = data;
                else if (i == 0x01) GPIO1_PORT = data;
                uartSendChar(0x0d); // [CR]
                uartSendChar(0x0a); // [LF]
            }
        }
        // IR / IW ------------------------------------------------------------
        //  Read/Write access to I2C bus space
        //  irxxyy
        //      Reads the value at slave address xx; address yy in i2c bus space and 
        //      returns it as a hex ascii value.
        //      xx  = Slave address
        //          Must be specified with 2 digits.
        //      yy  = Address in device
        //          Must be specified with 2 digits.
        //  iwxxyyzz
        //      Write value zz to slave address xx; address yy in i2c bus space.
        //      xx  = Slave address
        //          Must be specified with 2 digits.
        //      yy  = Address in device
        //          Must be specified with 2 digits.
        //      zz  = Valut to write
        //          Must be specified with 2 digits.
        else if ((console_buf[0] == 'i') || (console_buf[0] == 'I'))
        {
            if ((console_buf[1] == 'r') || (console_buf[1] == 'R'))
            {
                j = 0;
                addr = (unsigned short)hexByteStringToChar((char *)&console_buf[2]);    // Slave address to read
                i = hexByteStringToChar((char *)&console_buf[4]);                       // Device address to read
                j |= i2cBeginTransmission((unsigned char)addr);
                j |= i2cWrite(i);
                j |= i2cBeginRequest((unsigned char)addr);
                if ((j & I2C_SR_RXACK) == 0x00)
                {
                    data = i2cRead(0);
                    uartSendAsciiValue(2, data);
                    uartSendChar(0x0d); // [CR]
                    uartSendChar(0x0a); // [LF]
                }
                else
                {
                    // Error
                    uartSendChar('E');
                    uartSendChar(0x0d); // [CR]
                    uartSendChar(0x0a); // [LF]
                }
                i2cEndTransmission();
            }
            else if ((console_buf[1] == 'w') || (console_buf[1] == 'W'))
            {
                j = 0;
                addr = (unsigned short)hexByteStringToChar((char *)&console_buf[2]);    // Slave address to write
                i = hexByteStringToChar((char *)&console_buf[4]);                       // Device address to write
                data = hexByteStringToChar((char *)&console_buf[6]);                    // Data to write
                j |= i2cBeginTransmission((unsigned char)addr);
                j |= i2cWrite(i);
                j |= i2cWrite(data);
                if ((j & I2C_SR_RXACK) == 0x00)
                {
                    uartSendChar(0x0d); // [CR]
                    uartSendChar(0x0a); // [LF]
                }
                else
                {
                    // Error
                    uartSendChar('E');
                    uartSendChar(0x0d); // [CR]
                    uartSendChar(0x0a); // [LF]
                }
                i2cEndTransmission();
            }
        }
    }

}


//=============================================================================
//  Converts a sequence of up to two hexadecimal ASCII bytes to 
//  a numeric value and returns it as a value of type unsigned char
//-----------------------------------------------------------------------------
//  Arguments:
//      *str : Pointer to byte sequence to be converted
//  Return:
//      unsigned char : Converted value
//  Note:
//      If the ASCII byte string to be converted contains characters that 
//      cannot be converted to hexadecimal an abnormal value is returned.
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char hexByteStringToChar(char *str)
{
    unsigned char r = 0;
    if(*str > 0x39) r = *str - 0x07; else r = *str;
    str++;
    if (*str != 0)
    {
        r <<= 4;
        if(*str > 0x39) r |= (*str - 0x07) & 0x0f; else r |= (*str & 0x0f);
    }
    return r;
}


//=============================================================================
//  Converts a sequence of up to 4 hexadecimal ASCII bytes to 
//  a numeric value and returns it as a value of type unsigned short
//-----------------------------------------------------------------------------
//  Arguments:
//      *str : Pointer to byte sequence to be converted
//  Return:
//      unsigned short : Converted value
//  Note:
//      If the ASCII byte string to be converted contains characters that 
//      cannot be converted to hexadecimal an abnormal value is returned.
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned short hexByteStringToShort(char *str)
{
    unsigned short r = 0;
    unsigned char i;
    if(*str > 0x39) r = *str - 0x07; else r = *str;
    for (i = 0; i < 3; i++)
    {
        str++;
        if (*str != 0) 
        {
            r <<= 4;
            if(*str > 0x39) r |= (*str - 0x07) & 0x0f; else r |= (*str & 0x0f);
        }
        else break;
    }
    return r;
}

