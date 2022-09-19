//=============================================================================
//  omsp430_demo_tmct: Interrupt handler
//-----------------------------------------------------------------------------
//  ihandler.c
//  Interrupt handler part of omsp430_demo_tmct
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
#include "ivectors.h"
#include "hardware.h"

//  As a sample of interrupt processing, the output port state is changed when 
//  an interrupt is received.
//  The output port is set to 0x55 for IRQ0 and 0xaa for IRQ1.
#define GPIO1_PORT  (*(volatile unsigned char *)  0x0092)

wakeup interrupt (NMI_VECTOR) INT_NMI(void){ }

wakeup interrupt (USER_13_VECTOR) INT_User_13(void){ }

wakeup interrupt (USER_12_VECTOR) INT_User_12(void){ }

wakeup interrupt (USER_11_VECTOR) INT_User_11(void){ }

wakeup interrupt (WDT_VECTOR) INT_Watchdog(void){ }

wakeup interrupt (USER_09_VECTOR) INT_User_09(void){ }

wakeup interrupt (USER_08_VECTOR) INT_User_08(void){ }

wakeup interrupt (USER_07_VECTOR) INT_User_07(void){ }

wakeup interrupt (USER_06_VECTOR) INT_User_06(void){ }

wakeup interrupt (USER_05_VECTOR) INT_User_05(void){ }

wakeup interrupt (USER_04_VECTOR) INT_User_04(void){ }

wakeup interrupt (USER_03_VECTOR) INT_User_03(void){ }

wakeup interrupt (USER_02_VECTOR) INT_User_02(void){ }

wakeup interrupt (USER_01_VECTOR) INT_User_01(void){ GPIO1_PORT = 0xaa; }

wakeup interrupt (USER_00_VECTOR) INT_User_00(void){ GPIO1_PORT = 0x55; }
