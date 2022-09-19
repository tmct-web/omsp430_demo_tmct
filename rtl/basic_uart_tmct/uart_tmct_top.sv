//=============================================================================
//  basic_uart_tmct: Top-level entry
//-----------------------------------------------------------------------------
//  uart_tmct_top.sv
//  Basic uart top-level entry
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
module uart_tmct_top
(
    input   logic           i_clk,      // System clock input
    input   logic           i_reset,    // System reset input(high active)

    input   logic           i_rxclear,  // Receive status reset input(high active)
    output  logic   [7:0]   o_rxdata,   // Receive data output
    output  logic           o_rxerr,    // Receive error output(high active)
    output  logic           o_rxdone,   // Received data valid output(high active)

    input   logic           i_txrun,    // Transmission trigger input(high active)
    input   logic   [7:0]   i_txdata,   // Transmission data input
    output  logic           o_txdone,   // Transmission completion output(high active)

    input   logic   [15:0]  i_prer,     // Baud-rate generator frequency divider parameter
                                        //  (System clock frequency[Hz]) ÷ (Baud rate[bps])
                                        // e.g.
                                        //  System clock frequency = 50MHz
                                        //  Baud rate = 9600 bps
                                        //      i_prer = 50,000,000 ÷ 9600 = 5208(dec)

    input   logic           i_rx,       // RX input
    output  logic           o_tx,       // TX output

    output  logic           o_debug_rxclken,
    output  logic           o_debug_txclken

);
    
    logic rxclken;
    logic txclken;

    always_comb o_debug_rxclken = rxclken;
    always_comb o_debug_txclken = txclken;


    //-------------------------------------------------------------------------
    //  Baud-rate generator
    //-------------------------------------------------------------------------
    uart_brgene uart_brgene0
    (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_prer     (i_prer),
        .o_txclken  (txclken),
        .o_rxclken  (rxclken)
    );


    //-------------------------------------------------------------------------
    //  UART Receiver
    //-------------------------------------------------------------------------
    uart_rx uart_rx0
    (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_rxclken  (rxclken),
        .i_rx       (i_rx),
        .i_rxclear  (i_rxclear),
        .o_rxdata   (o_rxdata),
        .o_rxerr    (o_rxerr),
        .o_rxdone   (o_rxdone)
    );


    //-------------------------------------------------------------------------
    //  UART Transmitter
    //-------------------------------------------------------------------------
    uart_tx uart_tx0
    (
        .i_clk      (i_clk),
        .i_reset    (i_reset),
        .i_txclken  (txclken),
        .i_txrun    (i_txrun),
        .i_txdata   (i_txdata),
        .o_tx       (o_tx),
        .o_txdone   (o_txdone)
    );

endmodule
