//=============================================================================
//  omsp430_demo_tmct: Interrupt vectors
//-----------------------------------------------------------------------------
//  ivectors.h
//  Interrupt vectors part of omsp430_demo_tmct
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
#include <in430.h>


#define interrupt(x) void __attribute__((interrupt (x)))
#define wakeup  __attribute__((wakeup))
#define eint()  __eint()
#define dint()  __dint()

// Vector definition for RedHat/TI toolchain
#ifdef PFX_MSP430_ELF
    #define RESET_VECTOR    ("reset")   // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
    #define NMI_VECTOR      (15)        // Vector 14  (0xFFFC) - Non-maskable       -
    #define USER_13_VECTOR  (14)        // Vector 13  (0xFFFA) -                    -
    #define USER_12_VECTOR  (13)        // Vector 12  (0xFFF8) -                    -
    #define USER_11_VECTOR  (12)        // Vector 11  (0xFFF6) -                    -
    #define WDT_VECTOR      (11)        // Vector 10  (0xFFF4) - Watchdog Timer     -
    #define USER_09_VECTOR  (10)        // Vector  9  (0xFFF2) -                    -
    #define USER_08_VECTOR  (9)         // Vector  8  (0xFFF0) -                    -
    #define USER_07_VECTOR  (8)         // Vector  7  (0xFFEE) -                    -
    #define USER_06_VECTOR  (7)         // Vector  6  (0xFFEC) -                    -
    #define USER_05_VECTOR  (6)         // Vector  5  (0xFFEA) -                    -
    #define USER_04_VECTOR  (5)         // Vector  4  (0xFFE8) -                    -
    #define USER_03_VECTOR  (4)         // Vector  3  (0xFFE6) -                    -
    #define USER_02_VECTOR  (3)         // Vector  2  (0xFFE4) -                    -
    #define USER_01_VECTOR  (2)         // Vector  1  (0xFFE2) -                    -
    #define USER_00_VECTOR  (1)         // Vector  0  (0xFFE0) -                    -  [Lowest Priority]

// Vector definition for MSPGCC toolchain
#else
    #define RESET_VECTOR    (0x001E)    // Vector 15  (0xFFFE) - Reset              -  [Highest Priority]
    #define NMI_VECTOR      (0x001C)    // Vector 14  (0xFFFC) - Non-maskable       -
    #define USER_13_VECTOR  (0x001A)    // Vector 13  (0xFFFA) -                    -
    #define USER_12_VECTOR  (0x0018)    // Vector 12  (0xFFF8) -                    -
    #define USER_11_VECTOR  (0x0016)    // Vector 11  (0xFFF6) -                    -
    #define WDT_VECTOR      (0x0014)    // Vector 10  (0xFFF4) - Watchdog Timer     -
    #define USER_09_VECTOR  (0x0012)    // Vector  9  (0xFFF2) -                    -
    #define USER_08_VECTOR  (0x0010)    // Vector  8  (0xFFF0) -                    -
    #define USER_07_VECTOR  (0x000E)    // Vector  7  (0xFFEE) -                    -
    #define USER_06_VECTOR  (0x000C)    // Vector  6  (0xFFEC) -                    -
    #define USER_05_VECTOR  (0x000A)    // Vector  5  (0xFFEA) -                    -
    #define USER_04_VECTOR  (0x0008)    // Vector  4  (0xFFE8) -                    -
    #define USER_03_VECTOR  (0x0006)    // Vector  3  (0xFFE6) -                    -
    #define USER_02_VECTOR  (0x0004)    // Vector  2  (0xFFE4) -                    -
    #define USER_01_VECTOR  (0x0002)    // Vector  1  (0xFFE2) -                    -
    #define USER_00_VECTOR  (0x0000)    // Vector  0  (0xFFE0) -                    -  [Lowest Priority]
#endif
