//=============================================================================
//  regs_gpio
//-----------------------------------------------------------------------------
//  regs_gpio.v
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
module regs_gpio (

// OUTPUTs
    output  wire  [15:0]  o_per_dout, // Peripheral data output
    output  reg   [7:0]   o_dir0,     // GPIO0 direction (0=input, 1=output)
    output  reg   [7:0]   o_dout0,    // GPIO0 output data
    output  reg   [7:0]   o_dir1,     // GPIO1 direction (0=input, 1=output)
    output  reg   [7:0]   o_dout1,    // GPIO1 output data

// INPUTs
    input   wire          i_mclk,     // Main system clock
    input   wire  [13:0]  i_per_addr, // Peripheral address
    input   wire  [15:0]  i_per_din,  // Peripheral data input
    input   wire          i_per_en,   // Peripheral enable (high active)
    input   wire  [1:0]   i_per_we,   // Peripheral write enable (high active)
    input   wire          i_puc_rst,  // Main system reset
    input   wire  [7:0]   i_din0,     // GPIO0 input data
    input   wire  [7:0]   i_din1      // GPIO1 input data
);


//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR  = 15'h0090;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD     = 2;

// Register addresses offset
parameter [DEC_WD-1:0] PORT0      = 'h0,
                       PORT0_DIR  = 'h1,
                       PORT1      = 'h2,
                       PORT1_DIR  = 'h3;

   
// Register one-hot decoder utilities
parameter              DEC_SZ     = (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG   = {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] PORT0_D      = (BASE_REG << PORT0),
                       PORT0_DIR_D  = (BASE_REG << PORT0_DIR), 
                       PORT1_D      = (BASE_REG << PORT1), 
                       PORT1_DIR_D  = (BASE_REG << PORT1_DIR); 


//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel       = i_per_en & (i_per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr      = {1'b0, i_per_addr[DEC_WD-2:0]};

// Register address decode
wire [DEC_SZ-1:0] reg_dec       = (PORT0_D  &  {DEC_SZ{(reg_addr==(PORT0 >>1))}}) |
                                  (PORT0_DIR_D  &  {DEC_SZ{(reg_addr==(PORT0_DIR >>1))}}) |
                                  (PORT1_D  &  {DEC_SZ{(reg_addr==(PORT1 >>1))}}) |
                                  (PORT1_DIR_D  &  {DEC_SZ{(reg_addr==(PORT1_DIR >>1))}});

// Read/Write probes
wire              reg_lo_write  = i_per_we[0] & reg_sel;
wire              reg_hi_write  = i_per_we[1] & reg_sel;
wire              reg_read      = ~|i_per_we  & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_hi_wr     = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr     = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd        = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// PORT0 Register
//-----------------
wire       port0_wr  = PORT0[0] ? reg_hi_wr[PORT0] : reg_lo_wr[PORT0];
wire [7:0] port0_nxt = PORT0[0] ? i_per_din[15:8]  : i_per_din[7:0];

always @ (posedge i_mclk or posedge i_puc_rst)
  if      (i_puc_rst) o_dout0 <= 8'h00;
  else if (port0_wr)  o_dout0 <= port0_nxt;

   
// PORT0_DIR Register
//-----------------
wire       dir0_wr  = PORT0_DIR[0] ? reg_hi_wr[PORT0_DIR] : reg_lo_wr[PORT0_DIR];
wire [7:0] dir0_nxt = PORT0_DIR[0] ? i_per_din[15:8]      : i_per_din[7:0];

always @ (posedge i_mclk or posedge i_puc_rst)
  if      (i_puc_rst) o_dir0 <= 8'h00;
  else if (dir0_wr)   o_dir0 <= dir0_nxt;

   
// PORT1 Register
//-----------------
wire       port1_wr  = PORT1[0] ? reg_hi_wr[PORT1] : reg_lo_wr[PORT1];
wire [7:0] port1_nxt = PORT1[0] ? i_per_din[15:8]  : i_per_din[7:0];

always @ (posedge i_mclk or posedge i_puc_rst)
  if      (i_puc_rst) o_dout1 <= 8'h00;
  else if (port1_wr)  o_dout1 <= port1_nxt;

   
// PORT1_DIR Register
//-----------------
wire       dir1_wr  = PORT1_DIR[0] ? reg_hi_wr[PORT1_DIR] : reg_lo_wr[PORT1_DIR];
wire [7:0] dir1_nxt = PORT1_DIR[0] ? i_per_din[15:8]      : i_per_din[7:0];

always @ (posedge i_mclk or posedge i_puc_rst)
  if      (i_puc_rst) o_dir1 <= 8'h00;
  else if (dir1_wr)   o_dir1 <= dir1_nxt;


//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================

// Data output mux
wire [15:0] port0_rd  = {8'h00, (i_din0 & {8{reg_rd[PORT0]}})}  << (8 & {4{PORT0[0]}});
wire [15:0] dir0_rd   = {8'h00, (o_dir0 & {8{reg_rd[PORT0_DIR]}})}  << (8 & {4{PORT0_DIR[0]}});
wire [15:0] port1_rd  = {8'h00, (i_din1 & {8{reg_rd[PORT1]}})}  << (8 & {4{PORT1[0]}});
wire [15:0] dir1_rd   = {8'h00, (o_dir1 & {8{reg_rd[PORT1_DIR]}})}  << (8 & {4{PORT1_DIR[0]}});

assign o_per_dout = port0_rd  |
                    dir0_rd  |
                    port1_rd  |
                    dir1_rd;
   
endmodule // template_periph_8b
