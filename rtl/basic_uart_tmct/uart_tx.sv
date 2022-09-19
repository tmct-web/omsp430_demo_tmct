//=============================================================================
//  basic_uart_tmct: UART Transmitter
//-----------------------------------------------------------------------------
//  uart_tx.sv
//  UART Transmitter part of basic uart
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
module uart_tx
(
    input   logic           i_clk,      // System clock input
    input   logic           i_reset,    // System reset input(high active)
    input   logic           i_txclken,  // Transmit timing signal input (same as baud rate interval)
    input   logic           i_txrun,    // Transmission trigger input(high active)
    input   logic   [7:0]   i_txdata,   // Transmission data input
    output  logic           o_tx,       // TX output
    output  logic           o_txdone    // Transmission completion output(high active)
);
    
    logic   [3:0]   currentState;
    logic   [3:0]   nextState;


    //-------------------------------------------------------------------------
    //  State machine: State transition synchronization
    //-------------------------------------------------------------------------
    always_ff @(posedge i_clk, posedge i_reset, negedge i_txrun)
    begin
        if (i_reset)
        begin
            currentState <= 4'd0;
        end
        else if (!i_txrun)
        begin
            currentState <= 4'd0;
        end
        else
        begin
            if (i_txclken) currentState <= nextState;
        end
    end


    //-------------------------------------------------------------------------
    //  State machine: State transition table
    //-------------------------------------------------------------------------
    always_comb
    begin
        if (currentState == 4'd0)
        begin
            // Idle -----------------------------------------------------------
            if (i_txrun) nextState = 4'd1; else nextState = 4'd0; 
        end
        else if (currentState == 4'd1)
        begin
            // Start bit ------------------------------------------------------
            nextState = 4'd2;
        end
        else if (currentState == 4'd2)
        begin
            // Bit0 -----------------------------------------------------------
            nextState = 4'd3;
        end
        else if (currentState == 4'd3)
        begin
            // Bit1 -----------------------------------------------------------
            nextState = 4'd4;
        end
        else if (currentState == 4'd4)
        begin
            // Bit2 -----------------------------------------------------------
            nextState = 4'd5;
        end
        else if (currentState == 4'd5)
        begin
            // Bit3 -----------------------------------------------------------
            nextState = 4'd6;
        end
        else if (currentState == 4'd6)
        begin
            // Bit4 -----------------------------------------------------------
            nextState = 4'd7;
        end
        else if (currentState == 4'd7)
        begin
            // Bit5 -----------------------------------------------------------
            nextState = 4'd8;
        end
        else if (currentState == 4'd8)
        begin
            // Bit6 -----------------------------------------------------------
            nextState = 4'd9;
        end
        else if (currentState == 4'd9)
        begin
            // Bit7 -----------------------------------------------------------
            nextState = 4'd10;
        end
        else if (currentState == 4'd10)
        begin
            // Stop bit -------------------------------------------------------
            nextState = 4'd11;
        end
        else if (currentState == 4'd11)
        begin
            // Done -----------------------------------------------------------
            nextState = 4'd11;
        end
        else
        begin
            // Unknown state --------------------------------------------------
            nextState = 4'd0;
        end
    end


    //-------------------------------------------------------------------------
    //  State machine: Output signal table
    //-------------------------------------------------------------------------
    always_ff @ (posedge i_clk, posedge i_reset, negedge i_txrun)
    begin
        if (i_reset)
        begin
            //-----------------------------------------------------------------
            //  Asynchronous reset
            //-----------------------------------------------------------------
            o_tx <= 1'b1;
            o_txdone <= 1'b0;
        end
        else if (!i_txrun)
        begin
            //-----------------------------------------------------------------
            //  Transmitter clear
            //-----------------------------------------------------------------
            o_tx <= 1'b1;
            o_txdone <= 1'b0;
        end
        else
        begin
            //-----------------------------------------------------------------
            //  Operational state
            //-----------------------------------------------------------------
            if (i_txclken)
            begin
                if (currentState == 4'd0)
                begin
                    o_tx <= 1'b1;
                    o_txdone <= 1'b0;
                end
                else if (currentState == 4'd1) o_tx <= 1'b0;
                else if (currentState == 4'd2) o_tx <= i_txdata[0];
                else if (currentState == 4'd3) o_tx <= i_txdata[1];
                else if (currentState == 4'd4) o_tx <= i_txdata[2];
                else if (currentState == 4'd5) o_tx <= i_txdata[3];
                else if (currentState == 4'd6) o_tx <= i_txdata[4];
                else if (currentState == 4'd7) o_tx <= i_txdata[5];
                else if (currentState == 4'd8) o_tx <= i_txdata[6];
                else if (currentState == 4'd9) o_tx <= i_txdata[7];
                else if (currentState == 4'd10) o_tx <= 1'b1;
                else if (currentState == 4'd11)
                begin
                    o_tx <= 1'b1;
                    o_txdone <= 1'b1;
                end
            end
        end
    end

endmodule


