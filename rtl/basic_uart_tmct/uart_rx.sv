//=============================================================================
//  basic_uart_tmct: UART Receiver
//-----------------------------------------------------------------------------
//  uart_rx.sv
//  UART Receiver part of basic uart
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
module uart_rx
(
    input   logic           i_clk,      // System clock input
    input   logic           i_reset,    // System reset input(high active)
    input   logic           i_rxclken,  // Receive timing signal input (one quarter of the baud rate interval)
    input   logic           i_rx,       // RX input
    input   logic           i_rxclear,  // Receive status reset input(high active)
    output  logic   [7:0]   o_rxdata,   // Receive data output
    output  logic           o_rxerr,    // Receive error output(high active)
    output  logic           o_rxdone    // Received data valid output(high active)
);
    
    logic   [3:0]   currentState;
    logic   [3:0]   nextState;
    logic   [1:0]   clockCount;
    logic   [2:0]   startBit;
    logic           i_rx_l;


    //-------------------------------------------------------------------------
    //  Shift register for start bit detection
    //-------------------------------------------------------------------------
    always_ff @(posedge i_clk, posedge i_reset, posedge i_rxclear)
    begin
        if (i_reset)
        begin
            startBit <= 3'b111;
            i_rx_l <= 1'b1;
        end
        else if (i_rxclear)
        begin
            startBit <= 3'b111;
            i_rx_l <= 1'b1;
        end
        else
        begin
            i_rx_l <= i_rx;
            if (i_rxclken) startBit[2:0] <= {startBit[1:0], i_rx_l};
        end
    end


    //-------------------------------------------------------------------------
    //  State machine: State transition synchronization
    //-------------------------------------------------------------------------
    always_ff @(posedge i_clk, posedge i_reset, posedge i_rxclear)
    begin
        if (i_reset)
        begin
            currentState <= 4'd0;
        end
        else if (i_rxclear)
        begin
            currentState <= 4'd0;
        end
        else
        begin
            if (i_rxclken) currentState <= nextState;
        end
    end


    //-------------------------------------------------------------------------
    //  State machine: State transition table
    //-------------------------------------------------------------------------
    always_comb
    begin
        if (currentState == 4'd0)
        begin
            // Start bit ------------------------------------------------------
            if (startBit == 3'b000)
            begin
                nextState = 4'd1;
            end
            else
            begin
                nextState = 4'd0;
            end
        end
        else if (currentState == 4'd1)
        begin
            // Bit0 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd2; else nextState = 4'd1;
        end
        else if (currentState == 4'd2)
        begin
            // Bit1 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd3; else nextState = 4'd2;
        end
        else if (currentState == 4'd3)
        begin
            // Bit2 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd4; else nextState = 4'd3;
        end
        else if (currentState == 4'd4)
        begin
            // Bit3 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd5; else nextState = 4'd4;
        end
        else if (currentState == 4'd5)
        begin
            // Bit4 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd6; else nextState = 4'd5;
        end
        else if (currentState == 4'd6)
        begin
            // Bit5 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd7; else nextState = 4'd6;
        end
        else if (currentState == 4'd7)
        begin
            // Bit6 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd8; else nextState = 4'd7;
        end
        else if (currentState == 4'd8)
        begin
            // Bit7 -----------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd9; else nextState = 4'd8;
        end
        else if (currentState == 4'd9)
        begin
            // Stop bit -------------------------------------------------------
            if (clockCount == 2'd3) nextState = 4'd10; else nextState = 4'd9;
        end
        else if (currentState == 4'd10)
        begin
            // Done -----------------------------------------------------------
            nextState = 4'd10;
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
    always_ff @(posedge i_clk, posedge i_reset, posedge i_rxclear)
    begin
        if (i_reset)
        begin
            //-----------------------------------------------------------------
            //  Asynchronous reset
            //-----------------------------------------------------------------
            clockCount <= 2'd0;
            o_rxdata <= 7'd0;
            o_rxdone <= 1'b0;
            o_rxerr <= 1'b0;
        end
        else if (i_rxclear)
        begin
            //-----------------------------------------------------------------
            //  Receiver clear
            //-----------------------------------------------------------------
            clockCount <= 2'd0;
            o_rxdata <= 7'd0;
            o_rxdone <= 1'b0;
            o_rxerr <= 1'b0;
        end
        else
        begin
            //-----------------------------------------------------------------
            //  Operational state
            //-----------------------------------------------------------------
            if (i_rxclken)
            begin
                if (currentState == 4'd0)
                begin
                    // Start bit ----------------------------------------------
                    clockCount <= 2'd0;
                    o_rxdata <= 7'd0;
                    o_rxdone <= 1'b0;
                    o_rxerr <= 1'b0;
                end
                else if (currentState <= 4'd8)
                begin
                    // Data bits ----------------------------------------------
                    if (clockCount == 2'd3)
                    begin
                        o_rxdata[currentState - 1] <= i_rx_l;
                        clockCount <= 2'd0;
                    end
                    else
                    begin
                        clockCount <= clockCount + 2'd1;
                    end
                end
                else if (currentState == 4'd9)
                begin
                    // Stop bit -----------------------------------------------
                    if (clockCount == 2'd3)
                    begin
                        if (i_rx_l == 1'b1) o_rxerr <= 1'b0; else o_rxerr <= 1'b1;
                        o_rxdone <= 1'b1;
                        clockCount <= 2'd0;
                    end
                    else
                    begin
                        o_rxdone <= 1'b0;
                        clockCount <= clockCount + 2'd1;
                    end
                end
                else if (currentState == 4'd10)
                begin
                    // Done ---------------------------------------------------
                end
                else
                begin
                    // Unknown ------------------------------------------------
                    clockCount <= 2'd0;
                    o_rxdata <= 7'd0;
                    o_rxdone <= 1'b0;
                    o_rxerr <= 1'b0;
                end
            end
        end
    end

endmodule