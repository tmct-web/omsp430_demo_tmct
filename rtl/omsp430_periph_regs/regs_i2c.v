//=============================================================================
//  regs_i2c: Register
//-----------------------------------------------------------------------------
//  regs_i2c.v
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
module regs_i2c
(
    input   wire            i_mclk,     // Main system clock
    input   wire    [13:0]  i_per_addr, // Peripheral address
    input   wire    [15:0]  i_per_din,  // Peripheral data input
    input   wire            i_per_en,   // Peripheral enable (high active)
    input   wire    [1:0]   i_per_we,   // Peripheral write enable (high active)
    input   wire            i_puc_rst,  // Main system reset
    output  wire    [15:0]  o_per_dout, // Peripheral data output

    output  reg     [15:0]  o_prer,
    output  reg             o_core_en,
    output  reg     [7:0]   o_txd,
    output  reg             o_sta,
    output  reg             o_sto,
    output  reg             o_rd,
    output  reg             o_wr,
    output  reg             o_ack,
    input   wire    [7:0]   i_rxd,
    input   wire            i_busy,
    input   wire            i_al,
    input   wire            i_irxack,
    input   wire            i_done

);


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================
// Register base address (must be aligned to decoder bit width)
parameter   [14:0]          BASE_ADDR   =   15'h00b0;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter                   DEC_WD      =   3;

// Register addresses offset
parameter   [DEC_WD-1:0]    PRERL       =   'h0,
                            PRERH       =   'h1,
                            CTR         =   'h2,
                            RXD         =   'h3,
                            SR          =   'h4,
                            TXD         =   'h5,
                            CR          =   'h6;

// Register one-hot decoder utilities
parameter                   DEC_SZ      =   (1 << DEC_WD);
parameter   [DEC_SZ-1:0]    BASE_REG    =   {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter   [DEC_SZ-1:0]    PRERL_D     =   (BASE_REG << PRERL),
                            PRERH_D     =   (BASE_REG << PRERH), 
                            CTR_D       =   (BASE_REG << CTR), 
                            RXD_D       =   (BASE_REG << RXD), 
                            SR_D        =   (BASE_REG << SR), 
                            TXD_D       =   (BASE_REG << TXD), 
                            CR_D        =   (BASE_REG << CR); 


reg al;
reg rxack;
reg tip;
reg irq_flag;
reg ien;
reg iack;

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        al <= 1'b0;
        rxack <= 1'b0;
        tip <= 1'b0;
        irq_flag <= 1'b0;
    end
    else
    begin
	      al        <= i_al | (al & ~o_sta);
	      rxack     <= i_irxack;
	      tip       <= (o_rd | o_wr);
	      irq_flag  <= (i_done | i_al | irq_flag) & ~iack;
    end
end


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
assign reg_dec =    (PRERL_D  &  {DEC_SZ{(reg_addr==(PRERL >>1))}}) |
                    (PRERH_D  &  {DEC_SZ{(reg_addr==(PRERH >>1))}}) |
                    (CTR_D  &  {DEC_SZ{(reg_addr==(CTR >>1))}}) |
                    (RXD_D  &  {DEC_SZ{(reg_addr==(RXD >>1))}}) |
                    (SR_D  &  {DEC_SZ{(reg_addr==(SR >>1))}}) |
                    (TXD_D  &  {DEC_SZ{(reg_addr==(TXD >>1))}}) |
                    (CR_D  &  {DEC_SZ{(reg_addr==(CR >>1))}});

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

// PRERL Register
//-----------------
wire prerl_wr;
assign prerl_wr = PRERL[0] ? reg_hi_wr[PRERL] : reg_lo_wr[PRERL];
wire [7:0] prerl_nxt;
assign prerl_nxt = PRERL[0] ? i_per_din[15:8]     : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_prer[7:0] <=  8'hff;
    end
    else if (prerl_wr)
    begin
        o_prer[7:0] <=  prerl_nxt;
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
        o_prer[15:8] <=  8'hff;
    end
    else if (prerh_wr)
    begin
        o_prer[15:8] <=  prerh_nxt;
    end  
end

   
// CTR Register
//-----------------
wire ctr_wr;
assign ctr_wr = CTR[0] ? reg_hi_wr[CTR] : reg_lo_wr[CTR];
wire [7:0] ctr_nxt;
assign ctr_nxt = CTR[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_core_en <= 1'b0;
        ien <= 1'b0;
    end
    else if (ctr_wr)
    begin
        o_core_en <= ctr_nxt[7];
        ien <= ctr_nxt[6];
    end
end

   
// TXD Register
//-----------------
wire txd_wr;
assign txd_wr = TXD[0] ? reg_hi_wr[TXD] : reg_lo_wr[TXD];
wire [7:0] txd_nxt;
assign txd_nxt = TXD[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_txd <=  8'h00;
    end
    else if (txd_wr)
    begin
        o_txd <=  txd_nxt;
    end
end

   
// CR Register
//-----------------
wire cr_wr;
assign cr_wr = CR[0] ? reg_hi_wr[CR] : reg_lo_wr[CR];
wire [7:0] cr_nxt;
assign cr_nxt = CR[0] ? i_per_din[15:8] : i_per_din[7:0];

always @(posedge i_mclk, posedge i_puc_rst)
begin
    if (i_puc_rst)
    begin
        o_sta <= 1'b0;
        o_sto <= 1'b0;
        o_rd <= 1'b0;
        o_wr <= 1'b0;
        o_ack <= 1'b0;
        iack <= 1'b0;
    end
    else if (cr_wr)
    begin
        o_sta <= cr_nxt[7];
        o_sto <= cr_nxt[6];
        o_rd <= cr_nxt[5];
        o_wr <= cr_nxt[4];
        o_ack <= cr_nxt[3];
        iack <= cr_nxt[0];
    end
    else
    begin
        if (i_done | i_al)
        begin
            o_sta <= 1'b0;
            o_sto <= 1'b0;
            o_rd <= 1'b0;
            o_wr <= 1'b0;
        end
        iack <= 1'b0;
    end
end



//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] prerl_rd;
assign prerl_rd = {8'h00, (o_prer[7:0] & {8{reg_rd[PRERL]}})}  << (8 & {4{PRERL[0]}});
wire [15:0] prerh_rd;
assign prerh_rd = {8'h00, (o_prer[15:8] & {8{reg_rd[PRERH]}})}  << (8 & {4{PRERH[0]}});
wire [15:0] ctr_rd;
assign ctr_rd = {8'h00, ({o_core_en, ien, 6'd0} & {8{reg_rd[CTR]}})}  << (8 & {4{CTR[0]}});
wire [15:0] rxd_rd;
assign rxd_rd = {8'h00, (i_rxd  & {8{reg_rd[RXD]}})}  << (8 & {4{RXD[0]}});
wire [15:0] sr_rd;
assign sr_rd = {8'h00, ({rxack, i_busy, al, 3'd0, tip, irq_flag}  & {8{reg_rd[SR]}})}  << (8 & {4{SR[0]}});
wire [15:0] txd_rd;
assign txd_rd = {8'h00, (o_txd  & {8{reg_rd[TXD]}})}  << (8 & {4{TXD[0]}});
wire [15:0] cr_rd;
assign cr_rd = {8'h00, ({o_sta, o_sto, o_rd, o_wr, o_ack, 2'd0, iack}  & {8{reg_rd[CR]}})}  << (8 & {4{CR[0]}});

assign o_per_dout = prerl_rd  |
                    prerh_rd  |
                    ctr_rd  |
                    rxd_rd  |
                    sr_rd  |
                    txd_rd  |
                    cr_rd;

   
endmodule // template_periph_8b
