//=============================================================================
//  basic_uart_tmct: Baud-rate generator
//-----------------------------------------------------------------------------
//  uart_brgene.sv
//  Baud-rate generator part of basic uart
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
module uart_brgene
(
    input   logic           i_clk,      // System clock input
    input   logic           i_reset,    // System reset input(high active)
    input   logic   [15:0]  i_prer,     // Baud-rate generator frequency divider parameter
    output  logic           o_txclken,  // Transmit timing signal output (same as baud rate interval)
    output  logic           o_rxclken   // Receive timing signal output (one quarter of the baud rate interval)
);

    logic   [1:0]   txcnt;
    logic   [15:0]  rxprer;
    logic   [15:0]  counter;


    //-------------------------------------------------------------------------
    //  Combinational logic
    //-------------------------------------------------------------------------
    // Generates 4 times the baud rate timing
    always_comb rxprer = ({2'd0, i_prer[15:2]} - {9'd0, i_prer[15:9]} - 16'd1);


    //-------------------------------------------------------------------------
    //  Main counter
    //-------------------------------------------------------------------------
    always_ff @(posedge i_clk, posedge i_reset)
    begin
        if (i_reset)
        begin
            //-----------------------------------------------------------------
            //  Asynchronous reset
            //-----------------------------------------------------------------
            counter <= 15'd0;
            txcnt <= 2'd0;
            o_txclken <= 1'b0;
            o_rxclken <= 1'b0;
        end
        else
        begin
            //-----------------------------------------------------------------
            //  Operational state
            //-----------------------------------------------------------------
            if (counter < rxprer)
            begin
                counter <= counter + 15'd1;
                o_txclken <= 1'b0;
                o_rxclken <= 1'b0;
            end
            else
            begin
                counter <= 15'd0;
                o_rxclken <= 1'b1;
                txcnt <= txcnt + 2'd1;
                if (txcnt == 2'd0) o_txclken <= 1'b1; else o_txclken <= 1'b0;
            end
        end
    end
    
endmodule