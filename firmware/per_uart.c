//=============================================================================
//  omsp430_demo_tmct: Basic uart driver
//-----------------------------------------------------------------------------
//  per_uart.c
//  Basic uart driver part of omsp430_demo_tmct
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
#define UART_CNTRL  (*(volatile unsigned char *)  0x00a0)
#define UART_PRERH  (*(volatile unsigned char *)  0x00a2)
#define UART_PRERL  (*(volatile unsigned char *)  0x00a3)
#define UART_RXDATA (*(volatile unsigned char *)  0x00a4)
#define UART_TXDATA (*(volatile unsigned char *)  0x00a5)

#define CNTRL_TXRUN         0x80
#define CNTRL_TXRUN_MASK    0x7f
#define CNTRL_TXDONE        0x10
#define CNTRL_RXCLEAR       0x08
#define CNTRL_RXCLEAR_MASK  0xf7
#define CNTRL_RXRUN         0x00
#define CNTRL_RXERR         0x02
#define CNTRL_RXDONE        0x01

void uartInitialize();
void uartClearReceive();
unsigned char uartGetReceiveChar();
void uartSendChar(unsigned char data);
unsigned char binaryToAscii(unsigned char c);
void uartSendAsciiValue(unsigned char cc, unsigned short val);


//=============================================================================
//  UART initialization
//-----------------------------------------------------------------------------
//  Arguments:
//      None
//  Return:
//      None
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void uartInitialize()
{

    UART_CNTRL = CNTRL_RXCLEAR; // TXRUN = 0, RXCLEAR = 1
    //UART_PRERH = 0x0a;          // 25MHz / 9600bps = 0x0a2c
    //UART_PRERL = 0x2c;
    //UART_PRERH = 0x00;          // 25MHz / 115200bps = 0x00d9
    //UART_PRERL = 0xd9;
    UART_PRERH = 0x02;          // 25MHz / 38400bps = 0x028b
    UART_PRERL = 0x8b;
    UART_CNTRL = CNTRL_RXRUN;   // TXRUN = 0, RXCLEAR = 0

}


//=============================================================================
//  UART receive status clear
//-----------------------------------------------------------------------------
//  Arguments:
//      None
//  Return:
//      None
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void uartClearReceive()
{

    UART_CNTRL |= CNTRL_RXCLEAR;
    UART_CNTRL &= CNTRL_RXCLEAR_MASK;

}


//=============================================================================
//  Obtain 1 byte of data from the receiver
//-----------------------------------------------------------------------------
//  Arguments:
//      None
//  Return:
//      unsigned char
//          Received data
//          However, the following values indicate reception errors:
//              0xfe ... Data was received but the stop bit data is abnormal.
//              0xff ... No data in receive buffer (data not received)
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char uartGetReceiveChar()
{

    volatile unsigned char returnValue;

    if ((UART_CNTRL & CNTRL_RXDONE) == CNTRL_RXDONE)
    {
        if ((UART_CNTRL & CNTRL_RXERR) == CNTRL_RXERR)
        {
            returnValue = 0xfe;
            UART_CNTRL |= CNTRL_RXCLEAR;
            UART_CNTRL &= CNTRL_RXCLEAR_MASK;
        }
        else
        {
            returnValue = UART_RXDATA;
            UART_CNTRL |= CNTRL_RXCLEAR;
            UART_CNTRL &= CNTRL_RXCLEAR_MASK;
        }
    }
    else
    {
        returnValue = 0xff;
    }

    return returnValue;

}


//=============================================================================
//  Send 1 byte of data from the transmitter.
//-----------------------------------------------------------------------------
//  Arguments:
//      unsigned char data
//          Data to be sent
//  Return:
//      None
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void uartSendChar(unsigned char data)
{

    volatile unsigned char work;

    work = UART_CNTRL & CNTRL_TXRUN_MASK;
    UART_CNTRL = work;  // Tx Stop
    UART_TXDATA = data;
    UART_CNTRL = work | CNTRL_TXRUN;    // Tx Run
    UART_CNTRL = work | CNTRL_TXRUN;    // One wait cycle required
    while ((UART_CNTRL & CNTRL_TXDONE) != CNTRL_TXDONE);

}


//=============================================================================
//  Converts 4-bit binary numbers to ASCII characters
//-----------------------------------------------------------------------------
//  Arguments:
//      c : Value to convert
//  Return:
//      unsigned char : ASCII character code
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
unsigned char binaryToAscii(unsigned char c)
{

    if (c <= 9) c = c + '0';
    if ((0xa <= c)&&(c <= 0xf)) c = (c + 'a' - 0xa);
    return c;

}


//=============================================================================
//  Convert binary numeric values to ASCII characters and send from UART
//-----------------------------------------------------------------------------
//  Arguments:
//      cc : Number of characters after conversion to ASCII (see table below)
//          Value of conversion source is ...    8bit = 2
//                                              16bit = 4
//                                              32bit = 8
//      val : Value to send
//  Return:
//      None
//=================================== https://ss1.xrea.com/tmct.s1009.xrea.com/
void uartSendAsciiValue(unsigned char cc, unsigned short val)
{
    unsigned char c;
    if( cc == 4 )
    {
        c = (unsigned char)(0xf & (val >> 12 ));
        uartSendChar( binaryToAscii(c) );
        
        c = (unsigned char)(0xf & (val >> 8  ));
        uartSendChar( binaryToAscii(c) );
    }
    
    if( cc == 4 || cc == 2 )
    {
        c = (unsigned char)(0xf & (val >> 4  ));
        uartSendChar( binaryToAscii(c) );
        
        c = (unsigned char)(0xf & val );
        uartSendChar( binaryToAscii(c) );
    }
}