// Copyright (c) 2023, Microchip Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL MICROCHIP CORPORATIONM BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// APACHE LICENSE
// Copyright (c) 2023, Microchip Corporation 
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//
// SVN Revision Information:
// SVN $Revision: $
// SVN $Date: $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File: miv_rv32_subsys_pkg.sv
//
//   Purpose: subsys shared package
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none



package miv_rv32_subsys_pkg;

//------------------
// Global definitions
//------------------

  localparam l_subsys_cfg_cpu_addr_width                   = 32;
  localparam L_XLEN 									   = 32; 

  localparam l_subsys_cfg_udma_present                     = 0; // always = 0,   uDMA is not implemented in MIV_RV32
  localparam l_subsys_cfg_udma_ctrl_addr_width             = 32; //always = 32,  uDMA is not implemented in MIV_RV32  
  localparam l_subsys_cfg_subsys_cfg_addr_width            = 12;   
  localparam l_subsys_cfg_tcm0_addr_width                  = 32;
  localparam l_subsys_cfg_tcm0_udma_present                = 0;
  localparam l_subsys_cfg_tcm0_cpu_i_present               = 1;
  localparam l_subsys_cfg_tcm0_cpu_d_present               = 1;
  localparam l_subsys_cfg_tcm0_use_ram_parity_bits         = 0;
  localparam l_subsys_cfg_tcm1_present                     = 0;
  localparam l_subsys_cfg_tcm1_addr_width                  = 32;   
  localparam l_subsys_cfg_tcm1_udma_present                = 0;
  localparam l_subsys_cfg_tcm1_tas_present                 = 0;
  localparam l_subsys_cfg_tcm1_cpu_i_present               = 1;
  localparam l_subsys_cfg_tcm1_cpu_d_present               = 1;
  localparam l_subsys_cfg_tcm1_use_ram_parity_bits         = 0;
  localparam l_subsys_cfg_use_bus_parity                   = 1;
  localparam l_subsys_cfg_tcm_ram_sb_in_width              = 4;
  localparam l_subsys_cfg_tcm_ram_sb_out_width             = 4;  	  
  
  localparam l_subsys_icache_burst_size                    = 8;  
  localparam l_subsys_icache_ram_depth                     = 256; // Use when icache ram is configured       - valid values are 16, 32, 64, 128, 256 and 512
  localparam l_subsys_icache_reg_depth                     = 32;  // Use when icache registers is configured - valid values are 16, 32, 64, 128, 256 and 512


  localparam logic       l_cfg_fence_all_src               = 1'b0;
  localparam logic       l_subsys_cfg_raw_hzd_en           = 1'b1;  
  localparam logic       l_subsys_cfg_war_hzd_en           = 1'b1;   
  localparam logic [3:0] l_subsys_cfg_ar_cache             = 4'b0011; // Normal Non-cacheable Bufferable     
  localparam logic [3:0] l_subsys_cfg_aw_cache             = 4'b0011; // Normal Non-cacheable Bufferable              
  localparam logic [1:0] l_subsys_axi_rd_cfg_min_size      = 2'b10;  
  localparam logic [1:0] l_subsys_axi_wr_cfg_min_size      = 2'b10;         
  
  localparam logic [31:0] l_mtimecmp_addr_base             = 32'h0200_4000;
  localparam logic [31:0] l_mtime_prescaler_addr           = 32'h0200_5000;
  localparam logic [31:0] l_mtime_addr_base                = 32'h0200_BFF8; 

  localparam logic        l_cfg_hard_tcm0_en               = 1'b0; // when = 1'b1 instantiates PF Low Power RAM for TCM which can be initialized by the System Controller
                                                                   // when = 1'b0 uses inferred RAM for TCM which cannot be initialized by the System Controller
                                                                   // workaround for SAR#114807. 
                                                                   // Note that ECC enabled TCM cannot be initialized by the System Controller.

  localparam logic        l_cfg_ecc_err_inj_en             = 1'b0; // when = 1'b1 ecc error injection registers for TCM, GPR and ICache are enabled.
                                                                   // when = 1'b0 ecc error injection registers for TCM, GPR and ICache are disabled.
																   
  localparam logic        l_subsys_gpr_ded_reset_en         = 1'b1; // when = 1'b1 GPR DED Reset Enabled
                                                                    // when = 1'b0 GPR DED Reset Disabled
// Functions 
//-----------------------

   //***************************************************************************
   // Constant function for Ceiling Log Base 2: ceiling(log2(n))
   // Unlike $clog2(1) = 0, this function returns func_clog2(1) = 1
   //***************************************************************************
   function integer func_clog2 (input integer value);
      integer val;
      begin
         val = (value == 1) ?  value : value - 1;
         for (func_clog2 = 0; val > 0; func_clog2 = func_clog2 + 1) begin
            val = val >> 1;
         end
      end
   endfunction																  
																  
																  
   
   localparam        ABSTRACT_ERR_BUSY                = 1'b1;
   localparam [1:0]  ABSTRACT_ERR_CMD                 = 2'b10;
   localparam [2:0]  ABSTRACT_ERR_EXCEPTION           = 3'b011;
   localparam [2:0]  ABSTRACT_ERR_NOHALT              = 3'b100;
   localparam        ADDR_WIDTH                       = 32;
   localparam        DATA_WIDTH                       = 32;
   localparam        IR_REG_WIDTH                     = 5;
   localparam        DR_REG_WIDTH                     = 32;
   localparam        DMI_REG_WIDTH                    = 41;
   localparam        ACTIVE_HIGH_RESET                = 0;

	// Debug Registers Addresses

   localparam [6:0]  ABS_DATA_0_ADDR                   = 7'h04; //
   localparam [6:0]  ABS_DATA_1_ADDR                   = 7'h05; //
   localparam [6:0]  ABS_DATA_2_ADDR                   = 7'h06; //
   localparam [6:0]  ABS_DATA_3_ADDR                   = 7'h07; //
   localparam [6:0]  ABS_DATA_4_ADDR                   = 7'h08; //
   localparam [6:0]  ABS_DATA_5_ADDR                   = 7'h09; //
   localparam [6:0]  ABS_DATA_6_ADDR                   = 7'h0a; //
   localparam [6:0]  ABS_DATA_7_ADDR                   = 7'h0b; //
   localparam [6:0]  ABS_DATA_8_ADDR                   = 7'h0c; //
   localparam [6:0]  ABS_DATA_9_ADDR                   = 7'h0d; //
   localparam [6:0]  ABS_DATA_10_ADDR                  = 7'h0e; //
   localparam [6:0]  ABS_DATA_11_ADDR                  = 7'h0f; //
   localparam [6:0]  DMCONTROL_ADDR                    = 7'h10; //
   localparam [6:0]  DMSTATUS_ADDR                     = 7'h11; //
   localparam [6:0]  HART_INFO_ADDR                    = 7'h12; //
   localparam [6:0]  HALT_SUM_0_ADDR                   = 7'h40;
   localparam [6:0]  HALT_SUM_1_ADDR                   = 7'h13; //
   localparam [6:0]  HART_ARRAY_WINDOW_SEL_ADDR        = 7'h14; // Hart Array Window Select.
   localparam [6:0]  HART_ARRAY_WINDOW_ADDR            = 7'h15; // HArt Array Window.
   localparam [6:0]  ABST_CONTROL_AND_STATUS_ADDR      = 7'h16; // Abstract Control and Status.
   localparam [6:0]  ABST_COMMAND_ADDR                 = 7'h17; // Abstract Command.
   localparam [6:0]  ABST_COMMAND_AUTOEXEC_ADDR        = 7'h18; // Abstract Command Autoexec.
   localparam [6:0]  CONF_STR_PTR_0_ADDR               = 7'h19; // Config String Pointer Address 0.
   localparam [6:0]  CONF_STR_PTR_1_ADDR               = 7'h1a; // Config String Pointer Address 1.
   localparam [6:0]  CONF_STR_PTR_2_ADDR               = 7'h1b; // Config String Pointer Address 2.
   localparam [6:0]  CONF_STR_PTR_3_ADDR               = 7'h1c; // Config String Pointer Address 3.
   localparam [6:0]  PROG_BUFF_0_ADDR                  = 7'h20; // Program Buffer 0.
   localparam [6:0]  PROG_BUFF_1_ADDR                  = 7'h21; // Program Buffer 1.
   localparam [6:0]  PROG_BUFF_2_ADDR                  = 7'h22; // Program Buffer 2.
   localparam [6:0]  PROG_BUFF_3_ADDR                  = 7'h23; // Program Buffer 3.
   localparam [6:0]  PROG_BUFF_4_ADDR                  = 7'h24; // Program Buffer 4.
   localparam [6:0]  PROG_BUFF_5_ADDR                  = 7'h25; // Program Buffer 5.
   localparam [6:0]  PROG_BUFF_6_ADDR                  = 7'h26; // Program Buffer 6.
   localparam [6:0]  PROG_BUFF_7_ADDR                  = 7'h27; // Program Buffer 7.
   localparam [6:0]  PROG_BUFF_8_ADDR                  = 7'h28; // Program Buffer 8.
   localparam [6:0]  PROG_BUFF_9_ADDR                  = 7'h29; // Program Buffer 9.
   localparam [6:0]  PROG_BUFF_10_ADDR                 = 7'h2a; // Program Buffer 10.
   localparam [6:0]  PROG_BUFF_11_ADDR                 = 7'h2b; // Program Buffer 11.
   localparam [6:0]  PROG_BUFF_12_ADDR                 = 7'h2c; // Program Buffer 12.
   localparam [6:0]  PROG_BUFF_13_ADDR                 = 7'h2d; // Program Buffer 13.
   localparam [6:0]  PROG_BUFF_14_ADDR                 = 7'h2e; // Program Buffer 14.
   localparam [6:0]  PROG_BUFF_15_ADDR                 = 7'h2f; // Program Buffer 15.
   localparam [6:0]  AUTH_DATA_ADDR                    = 7'h30; // Authentication Data.
   localparam [6:0]  SBA_CONTROL_AND_STATUS_ADDR       = 7'h38; // System Bus Access Control and Status.
   localparam [6:0]  SYS_BUS_ADDR_0_ADDR               = 7'h39; // System Bus Address 31:0.
   localparam [6:0]  SYS_BUS_ADDR_1_ADDR               = 7'h3a; // System Bus Address 63:32.
   localparam [6:0]  SYS_BUS_ADDR_2_ADDR               = 7'h3b; // System Bus Address 95:64.
   localparam [6:0]  SYS_BUS_DATA_0_ADDR               = 7'h3c; // System Bus Data 31:0.
   localparam [6:0]  SYS_BUS_DATA_1_ADDR               = 7'h3d; // System Bus Data 63:32.
   localparam [6:0]  SYS_BUS_DATA_2_ADDR               = 7'h3e; // System Bus Data 96:64.
   localparam [6:0]  SYS_BUS_DATA_3_ADDR               = 7'h3f; // System Bus Data 127:96. 8 bit
													  
   // Machine Information Registers (read-only)       
   localparam [11:0] CSR_ADDR_MVENDORID                = 12'hF11;
   localparam [11:0] CSR_ADDR_MARCHID                  = 12'hF12;
   localparam [11:0] CSR_ADDR_MIMPID                   = 12'hF13;
   localparam [11:0] CSR_ADDR_MHARTID                  = 12'hF14;
   localparam [11:0] CSR_ADDR_MISA                     = 12'h301;
   localparam [11:0] DBGCSR_ADDR_DPC                   = 12'h7b0;
               
   // ABSTRACTCS
   localparam        ABSTRACTCS_RESERVEDD             = 1'b0;
   localparam [4:0]  ABSTRACTCS_PROGBUFSIZE           = 5'b0;
   localparam        ABSTRACTCS_RESERVEDC             = 1'b0;
   localparam        ABSTRACTCS_RESERVEDB             = 1'b0;
   localparam        ABSTRACTCS_RESERVEDA             = 1'b0;
   localparam [3:0]  ABSTRACTCS_DATACOUNT             = 4'b0001;
               
   // DMCONTROL   
   localparam        DMCONTROL_HARTRESET              = 1'b0;
   localparam        DMCONTROL_RESERVEDB              = 1'b0;
   localparam        DMCONTROL_HASEL                  = 1'b0;
   localparam [9:0]  DMCONTROL_HARTSELLO              = 10'b0;
   localparam [9:0]  DMCONTROL_HARTSELHI              = 10'b0;
   localparam [3:0]  DMCONTROL_RESERVEDA              = 4'b0;
               
   // DMSTATUS 
   localparam [8:0]  DMSTATUS_RESERVEDC               = 9'b0;
   localparam        DMSTATUS_IMPEBREAK               = 1'b0;
   localparam [1:0]  DMSTATUS_RESERVEDB               = 2'b0;
   localparam        DMSTATUS_ALLUNAVAIL              = 1'b0;
   localparam        DMSTATUS_ANYUNAVAIL              = 1'b0;
   localparam        DMSTATUS_ALLANYUNAVAIL           = 1'b0;
   localparam        DMSTATUS_ALLANYNONEXIST          = 1'b0;
   localparam        DMSTATUS_AUTHENTICATED           = 1'b1;
   localparam        DMSTATUS_AUTHBUSY                = 1'b0;
   localparam        DMSTATUS_HASRESETHALTREQ         = 1'b0;//disabled
   localparam        DMSTATUS_CONFSTRPTRVALID         = 1'b0;
   localparam  [3:0] DMSTATUS_VERSION                 = 4'b0010;
               
   // SBA      
   localparam  [2:0] SBCS_VER                         = 3'b1; // post 2018 spec implemented
   localparam  [6:0] SBCS_SIZE                        = 7'h20; //tied to 32
   localparam  [4:0] SBCS_ACCESSES                    = 5'h7; // 32/16/8 bit bus accesses supported
   localparam  [3:0] TIMEOUT_VAL                      = 4'h8; // 8 bit base counter used, increments prescale counter on overflow. 
                                                              //   Timeout occurs when prescale counter reaches or exceeds TIMOUT_VAL
               
               
   // DMI      
   localparam        DBG_DMI_OP_WIDTH                 = 2;
   localparam        DBG_DMI_DATA_WIDTH               = 32;
   localparam        DBG_DMI_ADDR_WIDTH               = 7;
               
   localparam        DMI_REQ_DATA_WIDTH               = 41; //DBG_DMI_ADDR_WIDTH + DBG_DMI_DATA_WIDTH + DBG_DMI_OP_WIDTH;
   localparam        DMI_RESP_DATA_WIDTH              = 34; //DBG_DMI_DATA_WIDTH + DBG_DMI_OP_WIDTH;
               
   localparam        DBG_CDC_FIFO_DEPTH               = 2;
               
   // DTMS     
 
 
 // DTMCS      
               
   localparam [13:0] DTMCS_RESERVEDB                  = 14'b0;
   localparam        DTMCS_RESERVEDA                  = 1'b0;
   localparam [2:0]  DTMCS_IDLE                       = 3'b0; // 0 xtra clocks if busy
   localparam [5:0]  DTMCS_ABITS                      = 6'b000111; // 7 bit address
   localparam [3:0]  DTMCS_VERSION                    = 4'b0001; // v0.13
               
               
               
               
   // JTAG TAP 
               
//------------------------------------------------------------------------------
// Constants   
//------------------------------------------------------------------------------
               
 // JTAG State Machine
   localparam [3:0]  TEST_LOGIC_RESET                 = 4'h0;
   localparam [3:0]  RUN_TEST_IDLE                    = 4'h1;
   localparam [3:0]  SELECT_DR                        = 4'h2;
   localparam [3:0]  CAPTURE_DR                       = 4'h3;
   localparam [3:0]  SHIFT_DR                         = 4'h4;
   localparam [3:0]  EXIT1_DR                         = 4'h5;
   localparam [3:0]  PAUSE_DR                         = 4'h6;
   localparam [3:0]  EXIT2_DR                         = 4'h7;
   localparam [3:0]  UPDATE_DR                        = 4'h8;
   localparam [3:0]  SELECT_IR                        = 4'h9;
   localparam [3:0]  CAPTURE_IR                       = 4'hA;
   localparam [3:0]  SHIFT_IR                         = 4'hB;
   localparam [3:0]  EXIT1_IR                         = 4'hC;
   localparam [3:0]  PAUSE_IR                         = 4'hD;
   localparam [3:0]  EXIT2_IR                         = 4'hE;
   localparam [3:0]  UPDATE_IR                        = 4'hF;
               
   //RISCV DTM Registers (see RISC-V Debug Specification)
   // All others are treated as 'BYPASS'.
   localparam [4:0]	 REG_BYPASS                       = 5'b11111;
   localparam [4:0]	 REG_IDCODE                       = 5'b00001;
   localparam [4:0]	 REG_DMI_ACCESS                   = 5'b10001;
   localparam [4:0]	 REG_DTMCS                        = 5'b10000;
               
               
   // TAP ID code
   localparam [31:0] ID_CODE                          = 32'h4E50105F; // Ver[31:28] 0x3 (MIV_RV32 v3.1.100), Part No.[27:12] E501, ManufID[11:1] 0x02F (Actel), Hardwired[0] = 1'b1 
   
               
   // SBA      
   localparam [2:0]  BYTE_ACCESS                      = 3'b000;
   localparam [2:0]  HWORD_ACCESS                     = 3'b001;
   localparam [2:0]  WORD_ACCESS                      = 3'b010;
   localparam [2:0]  DWORD_ACCESS                     = 3'b011;
   localparam [2:0]  QWORD_ACCESS                     = 3'b100;
               
   //3 (64-bit) and 4 (128-bit) unsupported.
               
               
endpackage     
               
               
`default_nettype wire
               