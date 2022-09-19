//=============================================================================
//  regs_uart: Register
//-----------------------------------------------------------------------------
//  regs_uart.v
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

//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
//----------------------------------------------------------------------------
//
// *File Name: template_periph_8b.v
// 
// *Module Description:
//                       8 bit peripheral template.
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 134 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2012-03-22 21:31:06 +0100 (Thu, 22 Mar 2012) $
//----------------------------------------------------------------------------
module regs_uart
(
    input   wire            i_mclk,     // Main system clock
    input   wire    [13:0]  i_per_addr, // Peripheral address
    input   wire    [15:0]  i_per_din,  // Peripheral data input
    input   wire            i_per_en,   // Peripheral enable (high active)
    input   wire    [1:0]   i_per_we,   // Peripheral write enable (high active)
    input   wire            i_puc_rst,  // Main system reset
    output  wire    [15:0]  o_per_dout, // Peripheral data output

    output  reg             o_rxclear,
    input   wire    [7:0]   i_rxdata,
    input   wire            i_rxerr,
    input   wire            i_rxdone,

    output  reg             o_txrun,
    output  reg     [7:0]   o_txdata,
    input   wire            i_txdone,

    output  reg     [15:0]  o_prer

);


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================
// Register base address (must be aligned to decoder bit width)
parameter   [14:0]          BASE_ADDR   =   15'h00a0;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter                   DEC_WD      =   3;

// Register addresses offset
parameter   [DEC_WD-1:0]    CNTRL       =   'h0,
                            PRERH       =   'h2,
                            PRERL       =   'h3,
                            RXDATA      =   'h4,
                            TXDATA      =   'h5;

// Register one-hot decoder utilities
parameter                   DEC_SZ      =   (1 << DEC_WD);
parameter   [DEC_SZ-1:0]    BASE_REG    =   {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter   [DEC_SZ-1:0]    CNTRL_D     =   (BASE_REG << CNTRL),
                            PRERH_D     =   (BASE_REG << PRERH), 
                            PRERL_D     =   (BASE_REG << PRERL), 
                            RXDATA_D    =   (BASE_REG << RXDATA), 
                            TXDATA_D    =   (BASE_REG << TXDATA);


//============================================================================
// 2)  REGISTER DECODER
//============================================================================
// Local register selection
wire reg_sel;
assign reg_sel = i_per_en & (i_per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr;
assign reg_addr = {1'b0, i_per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec;
assign reg_dec =    (CNTRL_D  & {DEC_SZ{(reg_addr==(CNTRL >>1))}}) |
                    (PRERH_D  & {DEC_SZ{(reg_addr==(PRERH >>1))}}) |
                    (PRERL_D  & {DEC_SZ{(reg_addr==(PRERL >>1))}}) |
                    (RXDATA_D & {DEC_SZ{(reg_addr==(RXDATA >>1))}}) |
                    (TXDATA_D & {DEC_SZ{(reg_addr==(TXDATA >>1))}});

// Read/Write probes
wire reg_lo_write;
assign reg_lo_write = i_per_we[0] & reg_sel;
wire reg_hi_write;
assign reg_hi_write = i_per_we[1] & reg_sel;
wire reg_read;
assign reg_read = ~|i_per_we   & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_hi_wr;
assign reg_hi_wr = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr;
assign reg_lo_wr = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd;
assign reg_rd = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// CNTRL Register
//-----------------
wire cntrl_wr;
assign cntrl_wr = CNTRL[0] ? reg_hi_wr[CNTRL] : reg_lo_wr[CNTRL];
wire [7:0] cntrl_nxt;
assign cntrl_nxt = CNTRL[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_txrun <= 1'b0;
        o_rxclear <= 1'b0;
    end
    else if (cntrl_wr)
    begin
        o_txrun <= cntrl_nxt[7];
        o_rxclear <= cntrl_nxt[3];
    end
end

   
// PRERH Register
//-----------------
wire prerh_wr;
assign prerh_wr = PRERH[0] ? reg_hi_wr[PRERH] : reg_lo_wr[PRERH];
wire [7:0] prerh_nxt;
assign prerh_nxt = PRERH[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_prer[15:8] <= 8'd0;
    end
    else if (prerh_wr)
    begin
        o_prer[15:8] <= prerh_nxt;
    end
end

   
// PRERL Register
//-----------------
wire prerl_wr;
assign prerl_wr = PRERL[0] ? reg_hi_wr[PRERL] : reg_lo_wr[PRERL];
wire [7:0] prerl_nxt;
assign prerl_nxt = PRERL[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_prer[7:0] <= 8'd0;
    end
    else if (prerl_wr)
    begin
        o_prer[7:0] <= prerl_nxt;
    end
end


// TXDATA Register
//-----------------
wire txdata_wr;
assign txdata_wr = TXDATA[0] ? reg_hi_wr[TXDATA] : reg_lo_wr[TXDATA];
wire [7:0] txdata_nxt;
assign txdata_nxt = TXDATA[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_txdata <= 8'd0;
    end
    else if (txdata_wr)
    begin
        o_txdata <= txdata_nxt;
    end
end


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] cntrl_rd;
assign cntrl_rd = {8'h00, ({o_txrun, 2'd0, i_txdone, o_rxclear, 1'd0, i_rxerr, i_rxdone}  & {8{reg_rd[CNTRL]}})}  << (8 & {4{CNTRL[0]}});
wire [15:0] prerh_rd;
assign prerh_rd = {8'h00, (o_prer[15:8] & {8{reg_rd[PRERH]}})}  << (8 & {4{PRERH[0]}});
wire [15:0] prerl_rd;
assign prerl_rd = {8'h00, (o_prer[7:0] & {8{reg_rd[PRERL]}})}  << (8 & {4{PRERL[0]}});
wire [15:0] rxdata_rd;
assign rxdata_rd = {8'h00, (i_rxdata & {8{reg_rd[RXDATA]}})}  << (8 & {4{RXDATA[0]}});
wire [15:0] txdata_rd;
assign txdata_rd = {8'h00, (o_txdata & {8{reg_rd[TXDATA]}})}  << (8 & {4{TXDATA[0]}});

assign o_per_dout = cntrl_rd  |
                    prerh_rd  |
                    prerl_rd  |
                    rxdata_rd  |
                    txdata_rd;

endmodule // template_periph_8b
