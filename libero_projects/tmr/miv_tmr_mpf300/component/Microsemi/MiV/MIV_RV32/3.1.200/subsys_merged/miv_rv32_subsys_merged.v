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
// DAP changed to TAS
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_ipcore.sv
//
//   Purpose:
//    subsys top-level
//   
//
//
//   Author: Microchip FPGA ESIP
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

//import miv_rv32_pkg::*;
//import miv_rv32_hart_cfg_pkg::*;
import miv_rv32_subsys_pkg::*;

module  miv_rv32_ipcore
//********************************************************************************
// Parameter description

   #(   
    parameter FAMILY                          = 26,  
    parameter CPU_ADDR_WIDTH                  = 32,
    parameter AXI_ADDR_WIDTH             = 32,
    parameter APB_ADDR_WIDTH             = 32,
    parameter APB_REGISTER_IO            = 1,
    parameter AHB_ADDR_WIDTH             = 32,
    parameter UDMA_PRESENT                    = 0,
    parameter UDMA_CTRL_ADDR_WIDTH            = 32,    
    parameter SUBSYS_CFG_ADDR_WIDTH            = 32,    
    parameter TCM0_ADDR_WIDTH                 = 32,
    parameter TCM0_UDMA_PRESENT               = 0,
    parameter TCM0_CPU_I_PRESENT              = 1,
    parameter TCM0_CPU_D_PRESENT              = 1,
    parameter TCM0_USE_RAM_PARITY_BITS        = 0, 
    parameter TCM_TAS_ADDR_WIDTH             = 32,
    parameter USE_BUS_PARITY                  = 0,
    parameter TCM1_ADDR_WIDTH                 = 32,
    parameter TCM1_CPU_I_PRESENT              = 1, 
    parameter TCM1_CPU_D_PRESENT              = 1, 
    parameter TCM1_USE_RAM_PARITY_BITS        = 0, 
	//
    parameter l_axi_start_addr           = 32'h6000_0000,
    parameter l_axi_end_addr             = 32'h6000_FFFF,
    parameter l_apb_start_addr           = 32'h7000_0000,
    parameter l_apb_end_addr             = 32'h7000_FFFF,
    parameter l_ahb_start_addr           = 32'h6000_0000,
    parameter l_ahb_end_addr             = 32'h6000_FFFF,
    parameter l_udma_ctrl_start_addr          = 32'h0000_0000,
    parameter l_udma_ctrl_end_addr            = 32'h0000_0FFF,
    parameter l_subsys_cfg_start_addr          = 32'h0000_1000,
    parameter l_subsys_cfg_end_addr            = 32'h0000_1FFF,
    parameter l_tcm0_start_addr               = 32'h8000_0000,
    parameter l_tcm0_end_addr                 = 32'h8000_0FFF,
    parameter l_tcm1_start_addr               = 32'h8001_0000,
    parameter l_tcm1_end_addr                 = 32'h8001_0FFF,
    parameter l_tcm_tas_udma_ctrl_start_addr = 32'h0000_0000,
    parameter l_tcm_tas_udma_ctrl_end_addr   = 32'h0000_0FFF,
    parameter l_tcm_tas_tcm0_start_addr      = 32'h8000_0000,
    parameter l_tcm_tas_tcm0_end_addr        = 32'h8000_0FFF,
    parameter l_tcm_tas_tcm1_start_addr      = 32'h8001_0000,
    parameter l_tcm_tas_tcm1_end_addr        = 32'h8001_0FFF,
	parameter l_subsys_cfg_tcm_tas_present    = 0,
	parameter l_subsys_cfg_tcm0_tas_present    = 0,
    parameter l_subsys_cfg_tcm0_present        = 1,
    parameter l_subsys_cfg_tcm1_present        = 1, 
    parameter l_subsys_cfg_axi_present    = 1,
    parameter l_subsys_cfg_ahb_present    = 0,
	parameter l_subsys_cfg_apb_present    = 0,
    parameter l_subsys_cfg_hart_debug          = 1,
	parameter l_hart_cfg_hw_debug             = 1,
    parameter l_hart_cfg_num_triggers         = 2,
    //
	parameter l_hart_cfg_hw_multiply_divide = 0,
	parameter l_hart_cfg_hw_compressed      = 0,
	parameter l_hart_cfg_hw_sp_float        = 0,
	parameter l_hart_reset_vector           = 32'h6000_0000,
	parameter l_hart_static_mtvec_base      = 32'h6000_0034,
    parameter l_hart_cfg_static_mtvec_base  = 0,
    parameter l_hart_cfg_static_mtvec_mode  = 0,
    parameter l_hart_static_mtvec_mode      = 0,
	parameter l_hart_num_sys_ext_irqs       = 9,
	parameter l_hart_cfg_hw_macc_multiplier = 0,
	parameter l_hart_cfg_time_count_width   = 64,	
    parameter RAM_SB_IN_WIDTH               = l_subsys_cfg_tcm_ram_sb_in_width,
    parameter RAM_SB_OUT_WIDTH              = l_subsys_cfg_tcm_ram_sb_out_width,
    parameter l_hart_cfg_lsu_fwd            = 1'b0,
    parameter l_hart_cfg_csr_fwd            = 1'b1,
    parameter l_hart_cfg_exu_fwd            = 1'b1,
	parameter l_hart_cfg_gpr_type           = 0,
	parameter ECC_ENABLE                    = 0,
	parameter NO_MACC_BLK                   = 0,
    parameter INTERNAL_MTIME                = 0,
    parameter INTERNAL_MTIME_IRQ            = 0,
    parameter MTIME_PRESCALER               = 16'h63,
    parameter BOOTROM_SRC_START_ADDR        = 0,
    parameter BOOTROM_SRC_END_ADDR          = 0,
    parameter BOOTROM_DEST_ADDR             = 0,
	parameter RECONFIG_BOOTROM              = 0,
	parameter ICACHE_EN                     = 0,
	parameter MI_I_MEM                      = 0,
	parameter TCM_REGS						= 0,
	parameter I_REGS                        = 0,
	parameter l_miv_rv32_version            = 32'h03010064
   )

//********************************************************************************
// Port description

  (    
    
    input wire logic                              clk,
    input wire logic                              resetn,
    
    output     logic     						  trace_valid, 
	output     logic [31:0]                       trace_iaddr,
	output     logic [31:0]                       trace_insn,
    output     logic [2:0]						  trace_priv, 
	output     logic							  trace_exception,
    output     logic							  trace_interrupt,
	output     logic [5:0]						  trace_cause,
    output     logic [31:0]                       trace_tval,

    
    // CPU controls
    input wire  logic [63:0]                      mtime_count,   
    input  wire logic [31:0]                      hart_id, 
    input wire  logic                             sys_parity_disable, 
    input wire  logic                             m_timer_irq,
    input wire  logic                             m_external_irq,
    input wire  logic [7:0]                       m_sys_ext_irq,
    output      logic                             debug_sys_reset, 
	output      logic [63:0]                      mtime_count_out,
    output      logic                             tcm0_uncorrectable_ecc_error,
    output      logic                             tcm1_uncorrectable_ecc_error,
    output      logic                             gpr_uncorrectable_ecc_error,
                               
    
    input wire  logic                             jtag_trst,
    input wire  logic                             jtag_tck,
    input wire  logic                             jtag_tdi,
    input wire  logic                             jtag_tms,
    output      logic                             jtag_tdo,
    output      logic                             jtag_tdo_dr,
      
    // APB Initiator interface
    output      logic [APB_ADDR_WIDTH-1:0]   apb_paddr, 
    output      logic                             apb_paddr_p,
    output      logic [2:0]                       apb_pprot,
    output      logic                             apb_psel,
    output      logic                             apb_penable, 
    output      logic                             apb_pwrite, 
    output      logic [31:0]                      apb_pwdata,
    output      logic [3:0]                       apb_pwdata_p,
    output      logic [3:0]                       apb_pstrb, 
    input wire  logic                             apb_pready, 
    input wire  logic [31:0]                      apb_prdata,
    input wire  logic [3:0]                       apb_prdata_p, 
    input wire  logic                             apb_pslverr,
    
    // APB Target interface (TCM access support)
    input wire logic                              tcm0_cpu_access_disable,  
    input wire logic                              tcm0_dma_access_disable, 
    input wire logic                              tcm0_tas_access_disable, 
    input wire logic                              tcm1_cpu_access_disable,  
    input wire logic                              tcm1_dma_access_disable, 
    input wire logic                              tcm1_tas_access_disable,
    input wire  logic [TCM_TAS_ADDR_WIDTH-1:0]    tcm_tas_paddr, 
    input wire  logic                             tcm_tas_paddr_p,
    input wire  logic [2:0]                       tcm_tas_pprot,
    input wire  logic                             tcm_tas_psel,
    input wire  logic                             tcm_tas_penable, 
    input wire  logic                             tcm_tas_pwrite, 
    input wire  logic [31:0]                      tcm_tas_pwdata,
    input wire  logic [3:0]                       tcm_tas_pwdata_p, 
    output      logic                             tcm_tas_pready, 
    output      logic [31:0]                      tcm_tas_prdata,
    output      logic [3:0]                       tcm_tas_prdata_p, 
    output      logic                             tcm_tas_pslverr,
    output      logic                             tcm_tas_udma_ctrl_irq,
    
    // TCM Sideband signals
    output      logic [RAM_SB_OUT_WIDTH-1:0]      tcm0_ram_sb_out,
    input  wire logic [RAM_SB_IN_WIDTH-1:0]       tcm0_ram_sb_in,
    output      logic [RAM_SB_OUT_WIDTH-1:0]      tcm1_ram_sb_out,
    input  wire logic [RAM_SB_IN_WIDTH-1:0]       tcm1_ram_sb_in,
    
    
    // AXI Initiator interface
    input wire logic                              axi_aclk_en,
    output logic                                  axi_arid,
    output logic [AXI_ADDR_WIDTH-1:0]        axi_araddr,
    output logic [3:0]                            axi_arlen,
    output logic [2:0]                            axi_arsize,
    output logic [1:0]                            axi_arburst,
    output logic                                  axi_arlock,
    output logic [3:0]                            axi_arcache,
    output logic [2:0]                            axi_arprot,
    input wire logic                              axi_arready,
    output logic                                  axi_arvalid,
    output logic                                  axi_ar_addr_p,
    input wire logic [1:0]                        axi_rresp,
    input wire logic [31:0]                       axi_rdata,
    input wire logic                              axi_rlast,
    input wire logic                              axi_rid,
    output logic                                  axi_rready,
    input wire logic                              axi_rvalid,
    input wire logic [3:0]                        axi_r_data_p,
    output logic                                  axi_awid,
    output logic [AXI_ADDR_WIDTH-1:0]        axi_awaddr,
    output logic [3:0]                            axi_awlen,
    output logic [2:0]                            axi_awsize,
    output logic [1:0]                            axi_awburst,
    output logic                                  axi_awlock,
    output logic [3:0]                            axi_awcache,
    output logic [2:0]                            axi_awprot,
    output logic                                  axi_aw_addr_p,
    input wire logic                              axi_awready,
    output logic                                  axi_awvalid,
    output logic [31:0]                           axi_wdata,
    output logic [3:0]                            axi_wstrb,
    output logic                                  axi_wlast,
    output logic                                  axi_wid,
    input wire logic                              axi_wready,
    output logic                                  axi_wvalid,
    output logic [3:0]                            axi_w_data_p, 
    input wire logic  [1:0]                       axi_bresp,
    input wire logic                              axi_bid,
    output logic                                  axi_bready,
    input wire logic                              axi_bvalid,
    
    // AHB Initiator interface
    output      logic [AHB_ADDR_WIDTH-1:0]   ahb_haddr,     
    output      logic                             ahb_haddr_p,   
    output      logic [2:0]                       ahb_hburst,    
    output      logic                             ahb_hmastlock, 
    output      logic [3:0]                       ahb_hprot,     
    output      logic [2:0]                       ahb_hsize,     
    output      logic [1:0]                       ahb_htrans,    
    output      logic [31:0]                      ahb_hwdata,    
    output      logic [3:0]                       ahb_hwdata_p,  
    output      logic                             ahb_hwrite,    
    input wire  logic [31:0]                      ahb_hrdata,    
    input wire  logic [3:0]                       ahb_hrdata_p,  
    input wire  logic                             ahb_hready,    
    input wire  logic                             ahb_hresp       
    
    
  );

//********************************************************************************
// Declarations

// localparams                 
  localparam ICACHE_DEPTH      = (I_REGS) ? l_subsys_icache_reg_depth : l_subsys_icache_ram_depth;  
  
  localparam TCM0_DEPTH        = (l_tcm0_end_addr - l_tcm0_start_addr) + 1; 
  localparam TCM0_WIDTH        = $clog2(TCM0_DEPTH);
  localparam TCM1_DEPTH        = ((l_tcm1_end_addr - l_tcm1_start_addr) + 4) / 4; 
  localparam l_hart_total_sys_ext_irqs = l_hart_num_sys_ext_irqs + 2; // MSYS +  2 SSYS interrupts																								  

// nets

  logic [1:0]                                  axi_rd_cfg_min_size_net; 
  logic [1:0]                                  axi_wr_cfg_min_size_net; 
  logic                                        subsys_parity_en_net;     
  logic                                        cfg_fence_all_src_net;   
  logic [3:0]                                  cfg_ar_cache_net;        
  logic [3:0]                                  cfg_aw_cache_net;        
  logic                                        cfg_raw_hzd_check_net;
  logic                                        cfg_war_hzd_check_net; 
  logic                                        cpu_i_req_valid_net;                 
  logic                                        cpu_i_req_ready_net;                 
  logic [3:0]                                  cpu_i_req_rd_byte_en_net;            
  logic [l_subsys_cfg_cpu_addr_width-1:0]       cpu_i_req_addr_net;                  
  logic                                        cpu_i_req_addr_p_net;              
  logic                                        cpu_i_resp_valid_net;              
  logic                                        cpu_i_resp_ready_net;              
  logic                                        cpu_i_resp_error_net;   
  logic [31:0]                                 cpu_i_resp_rd_data_net;            
  logic [3:0]                                  cpu_i_resp_rd_data_p_net;        
  logic                                        cpu_i_req_valid_sel;                 
  logic                                        cpu_i_req_ready_sel;                 
  logic [3:0]                                  cpu_i_req_rd_byte_en_sel;            
  logic [l_subsys_cfg_cpu_addr_width-1:0]       cpu_i_req_addr_sel;                  
  logic                                        cpu_i_req_addr_p_sel;              
  logic                                        cpu_i_resp_valid_sel;              
  logic                                        cpu_i_resp_ready_sel;     
  logic [31:0]                                 cpu_i_resp_rd_data_sel;            
  logic [3:0]                                  cpu_i_resp_rd_data_p_sel;            
  logic                                        cpu_i_resp_error_sel;       
  logic                                        icache_flush;              
  logic                                        cpu_d_req_valid_net;               
  logic                                        cpu_d_req_ready_net;               
  logic [3:0]                                  cpu_d_req_rd_byte_en_net;          
  logic [3:0]                                  cpu_d_req_wr_byte_en_net;          
  logic [l_subsys_cfg_cpu_addr_width-1:0]       cpu_d_req_addr_net;                  
  logic                                        cpu_d_req_addr_p_net;            
  logic                                        cpu_d_req_fence_net;  
  logic                                        cpu_d_req_read_net;
  logic                                        cpu_d_req_write_net;             
  logic [31:0]                                 cpu_d_req_wr_data_net;           
  logic [3:0]                                  cpu_d_req_wr_data_p_net;         
  logic                                        cpu_d_resp_valid_net;            
  logic                                        cpu_d_resp_ready_net;            
  logic                                        cpu_d_resp_error_net;            
  logic [31:0]                                 cpu_d_resp_rd_data_net;          
  logic [3:0]                                  cpu_d_resp_rd_data_p_net; 
  
  logic                                        cpu_debug_reset_net;
  logic                                        cpu_debug_hart_reset_net;
  logic                                        cpu_debug_active_net;
  logic [31:0]                                 cpu_debug_op_wr_data_net;    
  logic [31:0]                                 cpu_debug_csr_op_rd_data_net; 
  logic                                        cpu_debug_csr_op_rd_data_valid_net; 
  logic                                        cpu_debug_csr_op_rd_data_ready_net;    
  logic                                        cpu_debug_csr_op_ready_net;    
  logic                                        cpu_debug_csr_op_valid_net; 
  logic                                        cpu_debug_csr_wr_en_net; 
  logic                                        cpu_debug_csr_rd_en_net; 
  logic [11:0]                                 cpu_debug_csr_op_addr_net;  
  logic [31:0]                                 cpu_debug_gpr_op_rd_data_net; 
  logic                                        cpu_debug_gpr_op_rd_data_valid_net; 
  logic                                        cpu_debug_gpr_op_rd_data_ready_net;  
  logic                                        cpu_debug_gpr_op_valid_net; 
  logic                                        cpu_debug_gpr_op_ready_net;
  logic                                        cpu_debug_gpr_wr_en_net; 
  logic                                        cpu_debug_gpr_rd_en_net; 
  logic [5:0]                                  cpu_debug_gpr_op_addr_net; 
  logic                                        cpu_debug_halt_req_net;   
  logic                                        cpu_debug_halt_ack_net;
  logic                                        cpu_debug_resethalt_req_net;   
  logic                                        cpu_debug_resethalt_ack_net;    
  logic                                        cpu_debug_resume_req_net;   
  logic                                        cpu_debug_resume_ack_net;
  logic                                        cpu_debug_mode_net;
  
  logic [9:0]                                  sys_ext_irq_src_net;
  
  logic                                        debug_trx_os_net;       
  logic                                        debug_sysbus_req_valid_net;                 
  logic                                        debug_sysbus_req_ready_net;                 
  logic [3:0]                                  debug_sysbus_req_rd_byte_en_net;            
  logic [3:0]                                  debug_sysbus_req_wr_byte_en_net;            
  logic [l_subsys_cfg_cpu_addr_width-1:0]      debug_sysbus_req_addr_net;                  
  logic [31:0]                                 debug_sysbus_req_wr_data_net;               
  logic                                        debug_sysbus_resp_valid_net;                
  logic                                        debug_sysbus_resp_ready_net;                
  logic                                        debug_sysbus_resp_error_net;             
  logic [31:0]                                 debug_sysbus_resp_rd_data_net;    
       
  logic                                        apb_i_req_valid_net;             
  logic                                        apb_i_req_ready_net;             
  logic [3:0]                                  apb_i_req_rd_byte_en_net;        
  logic [APB_ADDR_WIDTH-1:0]              apb_i_req_addr_net;              
  logic                                        apb_i_req_addr_p_net;            
  logic                                        apb_i_resp_valid_net;            
  logic                                        apb_i_resp_ready_net;            
  logic                                        apb_i_resp_error_net;            
  logic [31:0]                                 apb_i_resp_rd_data_net;          
  logic [3:0]                                  apb_i_resp_rd_data_p_net;    
  logic                                        apb_d_req_valid_net;             
  logic                                        apb_d_req_ready_net;             
  logic [3:0]                                  apb_d_req_rd_byte_en_net;        
  logic [3:0]                                  apb_d_req_wr_byte_en_net; 
 // logic                                        apb_d_req_read_net; 
 // logic                                        apb_d_req_write_net;       
  logic [APB_ADDR_WIDTH-1:0]              apb_d_req_addr_net;              
  logic                                        apb_d_req_addr_p_net;            
  logic [31:0]                                 apb_d_req_wr_data_net;           
  logic [3:0]                                  apb_d_req_wr_data_p_net;         
  logic                                        apb_d_resp_valid_net;            
  logic                                        apb_d_resp_ready_net;            
  logic                                        apb_d_resp_error_net;         
  logic [31:0]                                 apb_d_resp_rd_data_net;          
  logic [3:0]                                  apb_d_resp_rd_data_p_net;  
  logic                                        apb_trx_os_d_rd_net;
  logic                                        apb_trx_os_d_wr_net;    
  logic                                        apb_psel_int;
  logic                                        apb_penable_int; 
  logic                                        apb_pslverr_int;
  logic                                        apb_pready_int;
  logic [31:0]                                 apb_prdata_int;
  logic                                        apb_psel_net;
  logic                                        apb_penable_net; 
  logic                                        apb_pready_net;
  logic [31:0]                                 apb_prdata_net;
  logic                                        apb_pslverr_net;
  logic                                        apb_int_sel;
  logic                                        tcm0_i_req_valid_net;                
  logic                                        tcm0_i_req_ready_net;                
  logic [3:0]                                  tcm0_i_req_rd_byte_en_net;           
  logic [l_subsys_cfg_tcm0_addr_width-1:0]     tcm0_i_req_addr_net;                 
  logic                                        tcm0_i_req_addr_p_net;               
  logic                                        tcm0_i_resp_valid_net;               
  logic                                        tcm0_i_resp_ready_net;               
  logic                                        tcm0_i_resp_error_net;               
  logic [31:0]                                 tcm0_i_resp_rd_data_net;             
  logic [3:0]                                  tcm0_i_resp_rd_data_p_net;           
  logic                                        tcm0_d_req_valid_net;                
  logic                                        tcm0_d_req_ready_net;                
  logic [3:0]                                  tcm0_d_req_rd_byte_en_net;           
  logic [3:0]                                  tcm0_d_req_wr_byte_en_net;  
  logic                                        tcm0_d_req_read_net; 
  logic                                        tcm0_d_req_write_net;         
  logic [l_subsys_cfg_tcm0_addr_width-1:0]     tcm0_d_req_addr_net;                 
  logic                                        tcm0_d_req_addr_p_net;               
  logic [31:0]                                 tcm0_d_req_wr_data_net;              
  logic [3:0]                                  tcm0_d_req_wr_data_p_net;            
  logic                                        tcm0_d_resp_valid_net;               
  logic                                        tcm0_d_resp_ready_net;               
  logic                                        tcm0_d_resp_error_net;            
  logic [31:0]                                 tcm0_d_resp_rd_data_net;             
  logic [3:0]                                  tcm0_d_resp_rd_data_p_net;   
  logic                                        tcm0_trx_os_d_rd_net;
  logic                                        tcm0_trx_os_d_wr_net;  
  logic                                        tcm0_ecc_err_correctable_net;  
  logic                                        tcm0_ecc_err_uncorrectable_net;            
  logic                                        tcm1_i_req_valid_net;                
  logic                                        tcm1_i_req_ready_net;                
  logic [3:0]                                  tcm1_i_req_rd_byte_en_net;           
  logic [l_subsys_cfg_tcm1_addr_width-1:0]     tcm1_i_req_addr_net;                         
  logic                                        tcm1_i_req_addr_p_net;               
  logic                                        tcm1_i_resp_valid_net;               
  logic                                        tcm1_i_resp_ready_net;               
  logic                                        tcm1_i_resp_error_net;               
  logic [31:0]                                 tcm1_i_resp_rd_data_net;             
  logic [3:0]                                  tcm1_i_resp_rd_data_p_net;           
  logic                                        tcm1_d_req_valid_net;                
  logic                                        tcm1_d_req_ready_net;                
  logic [3:0]                                  tcm1_d_req_rd_byte_en_net;           
  logic [3:0]                                  tcm1_d_req_wr_byte_en_net;   
  logic                                        tcm1_d_req_read_net; 
  logic                                        tcm1_d_req_write_net;            
  logic [l_subsys_cfg_tcm1_addr_width-1:0]     tcm1_d_req_addr_net;                 
  logic                                        tcm1_d_req_addr_p_net;               
  logic [31:0]                                 tcm1_d_req_wr_data_net;              
  logic [3:0]                                  tcm1_d_req_wr_data_p_net;            
  logic                                        tcm1_d_resp_valid_net;               
  logic                                        tcm1_d_resp_ready_net;               
  logic                                        tcm1_d_resp_error_net;            
  logic [31:0]                                 tcm1_d_resp_rd_data_net;             
  logic [3:0]                                  tcm1_d_resp_rd_data_p_net;   
  logic                                        tcm1_trx_os_d_rd_net;
  logic                                        tcm1_trx_os_d_wr_net;   
  logic                                        tcm1_ecc_err_correctable_net;  
  logic                                        tcm1_ecc_err_uncorrectable_net;                                
  logic                                        axi_i_req_valid_net;             
  logic                                        axi_i_req_ready_net;             
  logic [3:0]                                  axi_i_req_rd_byte_en_net;        
  logic [AXI_ADDR_WIDTH-1:0]              axi_i_req_addr_net;              
  logic                                        axi_i_req_addr_p_net;            
  logic                                        axi_i_resp_valid_net;   
  logic                                        axi_i_resp_last_net;          
  logic                                        axi_i_resp_ready_net;            
  logic                                        axi_i_resp_error_net;            
  logic [31:0]                                 axi_i_resp_rd_data_net;          
  logic [3:0]                                  axi_i_resp_rd_data_p_net;        
  logic                                        axi_d_req_valid_net;             
  logic                                        axi_d_req_ready_net;             
  logic [3:0]                                  axi_d_req_rd_byte_en_net;        
  logic [3:0]                                  axi_d_req_wr_byte_en_net;  
  logic                                        axi_d_req_read_net; 
  logic                                        axi_d_req_write_net;          
  logic [AXI_ADDR_WIDTH-1:0]              axi_d_req_addr_net;              
  logic                                        axi_d_req_addr_p_net;            
  logic [31:0]                                 axi_d_req_wr_data_net;           
  logic [3:0]                                  axi_d_req_wr_data_p_net;         
  logic                                        axi_d_resp_valid_net;            
  logic                                        axi_d_resp_ready_net;            
  logic                                        axi_d_resp_rd_error_net;         
  logic [31:0]                                 axi_d_resp_rd_data_net;          
  logic [3:0]                                  axi_d_resp_rd_data_p_net; 
  logic                                        axi_d_wr_resp_err_net;
  logic                                        axi_trx_os_d_rd_net;
  logic                                        axi_trx_os_d_wr_net;       
  logic                                        ahb_i_req_valid_net;             
  logic                                        ahb_i_req_ready_net;             
  logic [3:0]                                  ahb_i_req_rd_byte_en_net;        
  logic [AHB_ADDR_WIDTH-1:0]              ahb_i_req_addr_net;              
  logic                                        ahb_i_req_addr_p_net;            
  logic                                        ahb_i_resp_valid_net;   
  logic                                        ahb_i_resp_last_net;                   
  logic                                        ahb_i_resp_ready_net;            
  logic                                        ahb_i_resp_error_net;            
  logic [31:0]                                 ahb_i_resp_rd_data_net;          
  logic [3:0]                                  ahb_i_resp_rd_data_p_net;        
  logic                                        ahb_d_req_valid_net;             
  logic                                        ahb_d_req_ready_net;             
  logic [3:0]                                  ahb_d_req_rd_byte_en_net;        
  logic [3:0]                                  ahb_d_req_wr_byte_en_net;  
  logic                                        ahb_d_req_read_net; 
  logic                                        ahb_d_req_write_net;        
  logic [AHB_ADDR_WIDTH-1:0]              ahb_d_req_addr_net;              
  logic                                        ahb_d_req_addr_p_net;            
  logic [31:0]                                 ahb_d_req_wr_data_net;           
  logic [3:0]                                  ahb_d_req_wr_data_p_net;         
  logic                                        ahb_d_resp_valid_net;            
  logic                                        ahb_d_resp_ready_net;            
  logic                                        ahb_d_resp_rd_error_net;         
  logic [31:0]                                 ahb_d_resp_rd_data_net;          
  logic [3:0]                                  ahb_d_resp_rd_data_p_net;  
  logic                                        ahb_trx_os_d_rd_net;
  logic                                        ahb_trx_os_d_wr_net;        
  logic                                        cpu_udma_ctrl_req_valid_net;            
  logic                                        cpu_udma_ctrl_req_ready_net;            
  logic [3:0]                                  cpu_udma_ctrl_req_rd_byte_en_net;       
  logic [3:0]                                  cpu_udma_ctrl_req_wr_byte_en_net;  
  logic                                        cpu_udma_ctrl_req_read_net; 
  logic                                        cpu_udma_ctrl_req_write_net;       
  logic [l_subsys_cfg_udma_ctrl_addr_width-1:0] cpu_udma_ctrl_req_addr_net;             
  logic                                        cpu_udma_ctrl_req_addr_p_net;           
  logic [31:0]                                 cpu_udma_ctrl_req_wr_data_net;          
  logic [3:0]                                  cpu_udma_ctrl_req_wr_data_p_net;        
  logic                                        cpu_udma_ctrl_resp_valid_net;           
  logic                                        cpu_udma_ctrl_resp_ready_net;           
  logic                                        cpu_udma_ctrl_resp_error_net;        
  logic [31:0]                                 cpu_udma_ctrl_resp_rd_data_net; 
  logic                                        cpu_udma_ctrl_irq_net;        
  logic [3:0]                                  cpu_udma_ctrl_resp_rd_data_p_net;   
  logic                                        udma_trx_os_d_rd_net;
  logic                                        udma_trx_os_d_wr_net;    
  
  logic                                        tcm0_tas_req_valid_net;              
  logic                                        tcm0_tas_req_ready_net;              
  logic [3:0]                                  tcm0_tas_req_rd_byte_en_net;         
  logic [3:0]                                  tcm0_tas_req_wr_byte_en_net;         
  logic [l_subsys_cfg_tcm0_addr_width-1:0]     tcm0_tas_req_addr_net;          
  logic                                        tcm0_tas_req_addr_p_net;     
  logic [31:0]                                 tcm0_tas_req_wr_data_net;            
  logic [3:0]                                  tcm0_tas_req_wr_data_p_net;          
  logic                                        tcm0_tas_resp_valid_net;             
  logic                                        tcm0_tas_resp_ready_net;             
  logic                                        tcm0_tas_resp_rd_error_net;          
  logic [31:0]                                 tcm0_tas_resp_rd_data_net;           
  logic [3:0]                                  tcm0_tas_resp_rd_data_p_net;       
  logic                                        tcm1_tas_req_valid_net;              
  logic                                        tcm1_tas_req_ready_net;              
  logic [3:0]                                  tcm1_tas_req_rd_byte_en_net;         
  logic [3:0]                                  tcm1_tas_req_wr_byte_en_net;         
  logic [l_subsys_cfg_tcm1_addr_width-1:0]     tcm1_tas_req_addr_net;      
  logic                                        tcm1_tas_req_addr_p_net;         
  logic [31:0]                                 tcm1_tas_req_wr_data_net;            
  logic [3:0]                                  tcm1_tas_req_wr_data_p_net;          
  logic                                        tcm1_tas_resp_valid_net;             
  logic                                        tcm1_tas_resp_ready_net;             
  logic                                        tcm1_tas_resp_rd_error_net;          
  logic [31:0]                                 tcm1_tas_resp_rd_data_net;           
  logic [3:0]                                  tcm1_tas_resp_rd_data_p_net;         
  logic                                        tcm_tas_udma_ctrl_req_valid_net;     
  logic                                        tcm_tas_udma_ctrl_req_ready_net;     
  logic [3:0]                                  tcm_tas_udma_ctrl_req_rd_byte_en_net;
  logic [3:0]                                  tcm_tas_udma_ctrl_req_wr_byte_en_net;
  logic [l_subsys_cfg_udma_ctrl_addr_width-1:0] tcm_tas_udma_ctrl_req_addr_net;      
  logic                                        tcm_tas_udma_ctrl_req_addr_p_net;    
  logic [31:0]                                 tcm_tas_udma_ctrl_req_wr_data_net;   
  logic [3:0]                                  tcm_tas_udma_ctrl_req_wr_data_p_net; 
  logic                                        tcm_tas_udma_ctrl_resp_valid_net;    
  logic                                        tcm_tas_udma_ctrl_resp_ready_net;    
  logic                                        tcm_tas_udma_ctrl_resp_rd_error_net; 
  logic [31:0]                                 tcm_tas_udma_ctrl_resp_rd_data_net;  
  logic [3:0]                                  tcm_tas_udma_ctrl_resp_rd_data_p_net;    
  
  logic                                        udma_tcm0_req_valid_net;       
  logic                                        udma_tcm0_req_ready_net;       
  logic [3:0]                                  udma_tcm0_req_rd_byte_en_net;  
  logic [3:0]                                  udma_tcm0_req_wr_byte_en_net;  
  logic [l_subsys_cfg_tcm0_addr_width-1:0]     udma_tcm0_req_addr_net;        
  logic                                        udma_tcm0_req_addr_p_net;      
  logic [3:0]                                  udma_tcm0_req_len_net;         
  logic [31:0]                                 udma_tcm0_req_wr_data_net;     
  logic [3:0]                                  udma_tcm0_req_wr_data_p_net;  
  logic                                        udma_tcm0_req_read_net; 
  logic                                        udma_tcm0_req_write_net;   
  logic                                        udma_tcm0_resp_valid_net;      
  logic                                        udma_tcm0_resp_ready_net;      
  logic                                        udma_tcm0_resp_rd_error_net;   
  logic [31:0]                                 udma_tcm0_resp_rd_data_net;    
  logic [3:0]                                  udma_tcm0_resp_rd_data_p_net;  
  
  logic                                        udma_tcm1_req_valid_net;       
  logic                                        udma_tcm1_req_ready_net;       
  logic [3:0]                                  udma_tcm1_req_rd_byte_en_net;  
  logic [3:0]                                  udma_tcm1_req_wr_byte_en_net;  
  logic                                        udma_tcm1_req_read_net; 
  logic                                        udma_tcm1_req_write_net;
  logic [l_subsys_cfg_tcm1_addr_width-1:0]     udma_tcm1_req_addr_net;        
  logic                                        udma_tcm1_req_addr_p_net;      
  logic [3:0]                                  udma_tcm1_req_len_net;         
  logic [31:0]                                 udma_tcm1_req_wr_data_net;     
  logic [3:0]                                  udma_tcm1_req_wr_data_p_net;   
  logic                                        udma_tcm1_resp_valid_net;       
  logic                                        udma_tcm1_resp_ready_net;      
  logic                                        udma_tcm1_resp_rd_error_net;   
  logic [31:0]                                 udma_tcm1_resp_rd_data_net;    
  logic [3:0]                                  udma_tcm1_resp_rd_data_p_net;  
  
  logic                                        udma_axi_req_valid_net;       
  logic                                        udma_axi_req_ready_net;       
  logic [3:0]                                  udma_axi_req_rd_byte_en_net;  
  logic [3:0]                                  udma_axi_req_wr_byte_en_net;  
  logic                                        udma_axi_req_read_net;
  logic                                        udma_axi_req_write_net;
  logic [AXI_ADDR_WIDTH-1:0]              udma_axi_req_addr_net;        
  logic                                        udma_axi_req_addr_p_net;      
  logic [3:0]                                  udma_axi_req_len_net;         
  logic [31:0]                                 udma_axi_req_wr_data_net;     
  logic [3:0]                                  udma_axi_req_wr_data_p_net;   
  logic                                        udma_axi_req_wr_data_last_net;
  logic                                        udma_axi_resp_valid_net;      
  logic                                        udma_axi_resp_last_net;       
  logic                                        udma_axi_resp_ready_net;      
  logic                                        udma_axi_resp_rd_error_net;   
  logic [31:0]                                 udma_axi_resp_rd_data_net;    
  logic [3:0]                                  udma_axi_resp_rd_data_p_net;    
  logic                                        udma_axi_wr_resp_err_net;
  
  logic                                        udma_ahb_req_valid_net;       
  logic                                        udma_ahb_req_ready_net;       
  logic [3:0]                                  udma_ahb_req_rd_byte_en_net;  
  logic [3:0]                                  udma_ahb_req_wr_byte_en_net; 
  logic                                        udma_ahb_req_read_net; 
  logic                                        udma_ahb_req_write_net; 
  logic [AHB_ADDR_WIDTH-1:0]              udma_ahb_req_addr_net;        
  logic                                        udma_ahb_req_addr_p_net;      
  logic [3:0]                                  udma_ahb_req_len_net;         
  logic [31:0]                                 udma_ahb_req_wr_data_net;     
  logic [3:0]                                  udma_ahb_req_wr_data_p_net;   
  logic                                        udma_ahb_req_wr_data_last_net;
  logic                                        udma_ahb_resp_valid_net;      
  logic                                        udma_ahb_resp_last_net;       
  logic                                        udma_ahb_resp_ready_net;      
  logic                                        udma_ahb_resp_rd_error_net;   
  logic [31:0]                                 udma_ahb_resp_rd_data_net;    
  logic [3:0]                                  udma_ahb_resp_rd_data_p_net; 
  logic [1:0]                                  subsys_irq;    
  logic [63:0]                                 mtime_count_sel;
  logic                                        m_timer_irq_sel;
  logic [63:0]                                 mtime_count_int;
  logic                                        m_timer_irq_int;
     
  logic                                        hart_soft_reset_net; //net for connecting the hart_soft_reset output of the interconnect to the hart_soft_reset input to the miv_rv32_core
  logic                                        hart_soft_irq_net;   //net for conecting the hart_soft_irq output of the interconnecto to the m_sw_irq input to the ACT_UNIQUE_core
  
  logic                                        icache_ecc_err_correctable; 
  logic                                        icache_ecc_err_uncorrectable;
  logic                                        icache_ram_init_done;
  logic                                        gpr_ram_init_done;
  logic                                        ram_init_soft_debug_reset;
  
  logic [1:0]                                  icache_ecc_error_injection;
  logic [1:0]                                  gpr_ecc_error_injection;
  logic [1:0]                                  tcm_ecc_error_injection;
  
  logic                                        ifu_emi_req_valid_c;    
  logic                                        ifu_emi_req_ready_c;     
  logic[3:0]                                   ifu_emi_req_rd_byte_en_c;
  logic[31:0]                                  ifu_emi_req_addr_c;      
  logic[31:0]                                  ifu_emi_req_addr_c_reg;      
  logic[31:0]                                  ifu_emi_req_addr_c_sel;     
  logic                                        ifu_emi_req_addr_p_c;    
  logic                                        ifu_emi_resp_valid_c;    
  logic                                        ifu_emi_resp_ready_c;    
  logic [31:0]                                 ifu_emi_resp_rd_data_c;     
  logic [3:0]                                  ifu_emi_resp_rd_data_p_c;   
  logic                                        ifu_emi_resp_error_c;   
  
  logic                                        ifu_emi_req_valid_i;   
  logic                                        ifu_emi_req_ready_i;    
  logic[3:0]                                   ifu_emi_req_rd_byte_en_i;
  logic[31:0]                                  ifu_emi_req_addr_i;     
  logic                                        ifu_emi_req_addr_p_i;   
  logic                                        ifu_emi_resp_valid_i;   
  logic                                        ifu_emi_resp_ready_i;   
  logic [31:0]                                 ifu_emi_resp_rd_data_i;    
  logic [3:0]                                  ifu_emi_resp_rd_data_p_i;  
  logic                                        ifu_emi_resp_error_i;  
  
  logic                                        cpu_i_req_is_ahb;   
  logic                                        cpu_i_req_is_axi;

  logic											subsys_resetn;

//********************************************************************************
// Main code
//********************************************************************************

// CPU Core and debug
//--------------------------------------------

assign sys_ext_irq_src_net = {m_sys_ext_irq, subsys_irq}; //1_hart_total_sys_ext_irqs =10

assign subsys_resetn = (resetn && !debug_sys_reset); // revisit

// core instance

  miv_rv32_hart
  #(    
    .I_ADDR_WIDTH                  (l_subsys_cfg_cpu_addr_width       ),
    .D_ADDR_WIDTH                  (l_subsys_cfg_cpu_addr_width       ),
    .I_DATA_BYTES                  (L_XLEN/8                          ),
    .D_DATA_BYTES                  (L_XLEN/8                          ),
	.l_core_cfg_hw_debug           (l_hart_cfg_hw_debug               ),
    .l_core_cfg_num_triggers       (l_hart_cfg_num_triggers           ),
    .l_core_cfg_hw_multiply_divide (l_hart_cfg_hw_multiply_divide     ),
    .l_core_cfg_hw_compressed      (l_hart_cfg_hw_compressed          ),
    .l_core_cfg_hw_sp_float        (l_hart_cfg_hw_sp_float            ),
	
    .l_core_reset_vector           (l_hart_reset_vector          	  ),
    .l_core_static_mtvec_base      (l_hart_static_mtvec_base     	  ),
    .l_core_cfg_static_mtvec_base  (l_hart_cfg_static_mtvec_base 	  ),
    .l_core_cfg_static_mtvec_mode  (l_hart_cfg_static_mtvec_mode	  ),
    .l_core_static_mtvec_mode      (l_hart_static_mtvec_mode    	  ),
	.l_core_num_sys_ext_irqs       (l_hart_total_sys_ext_irqs      	  ),
	.l_core_cfg_hw_macc_multiplier (l_hart_cfg_hw_macc_multiplier	  ),
	.l_core_cfg_time_count_width   (l_hart_cfg_time_count_width  	  ),
    .l_core_cfg_lsu_fwd            (l_hart_cfg_lsu_fwd           	  ),
    .l_core_cfg_csr_fwd            (l_hart_cfg_csr_fwd           	  ),
    .l_core_cfg_exu_fwd            (l_hart_cfg_exu_fwd           	  ),
	.l_core_cfg_gpr_type           (l_hart_cfg_gpr_type         	  ),
	.ECC_ENABLE                    (ECC_ENABLE                  	  ),
	.NO_MACC_BLK                   (NO_MACC_BLK                 	  ),
	.MI_I_MEM                      (MI_I_MEM                     	  ),
    .l_subsys_cfg_axi_present      (l_subsys_cfg_axi_present          ),
    .l_subsys_cfg_ahb_present      (l_subsys_cfg_ahb_present          ),
    .l_subsys_cfg_tcm0_present     (l_subsys_cfg_tcm0_present         ),
    .l_axi_start_addr              (l_axi_start_addr                  ),
    .l_axi_end_addr                (l_axi_end_addr                    ),
    .l_ahb_start_addr              (l_ahb_start_addr                  ),
    .l_ahb_end_addr                (l_ahb_end_addr                    ),
    .l_tcm0_start_addr             (l_tcm0_start_addr                 ),
    .l_tcm0_end_addr               (l_tcm0_end_addr                   )
	
  )
  u_hart_0
  (
  .clk                                  (clk                            ),
  .resetn                               (resetn                         ),
  .core_soft_reset                      (hart_soft_reset_net            ), //hart_soft_reset output from interconnect connected to core core here
  .parity_en                            (subsys_parity_en_net           ),
  .gpr_uncorrectable_ecc_error          (gpr_uncorrectable_ecc_error    ),
  .time_count                           (mtime_count_sel                ),
  .hart_id                              (hart_id                        ),
  .ifu_emi_req_valid                    (ifu_emi_req_valid_c          	),
  .ifu_emi_req_ready                    (ifu_emi_req_ready_c         	),
  .ifu_emi_req_rd_byte_en               (ifu_emi_req_rd_byte_en_c       ),
  .ifu_emi_req_addr                     (ifu_emi_req_addr_c           	),
  .ifu_emi_req_addr_p                   (ifu_emi_req_addr_p_c         	),
  .ifu_emi_resp_valid                   (ifu_emi_resp_valid_c         	),
  .ifu_emi_resp_ready                   (ifu_emi_resp_ready_c         	),
  .ifu_emi_resp_data                    (ifu_emi_resp_rd_data_c       	),
  .ifu_emi_resp_data_p                  (ifu_emi_resp_rd_data_p_c     	),
  .ifu_emi_resp_error                   (ifu_emi_resp_error_c         ),
  .icache_flush                         (icache_flush                   ),
  .lsu_emi_req_valid                    (cpu_d_req_valid_net            ),
  .lsu_emi_req_ready                    (cpu_d_req_ready_net            ),
  .lsu_emi_req_rd_byte_en               (cpu_d_req_rd_byte_en_net       ),
  .lsu_emi_req_wr_byte_en               (cpu_d_req_wr_byte_en_net       ),
  .lsu_emi_req_addr                     (cpu_d_req_addr_net             ),
  .lsu_emi_req_addr_p                   (cpu_d_req_addr_p_net           ),
  .lsu_emi_req_fence                    (cpu_d_req_fence_net            ),
  .lsu_emi_req_read                     (cpu_d_req_read_net             ),
  .lsu_emi_req_write                    (cpu_d_req_write_net            ),
  .lsu_emi_req_wr_data                  (cpu_d_req_wr_data_net          ),
  .lsu_emi_req_wr_data_p                (cpu_d_req_wr_data_p_net        ),
  .lsu_emi_resp_valid                   (cpu_d_resp_valid_net           ),
  .lsu_emi_resp_ready                   (cpu_d_resp_ready_net           ),
  .lsu_emi_resp_error                   (cpu_d_resp_error_net           ),
  .lsu_emi_resp_rd_data                 (cpu_d_resp_rd_data_net         ),
  .lsu_emi_resp_rd_data_p               (cpu_d_resp_rd_data_p_net       ),
  .debug_reset                          (cpu_debug_reset_net            ), 
  .debug_core_reset                     (cpu_debug_hart_reset_net       ),
  .debug_active                         (cpu_debug_active_net           ),
  
   
  .debug_csr_gpr_req_wr_data            (cpu_debug_op_wr_data_net          ),  
  .debug_csr_req_valid                  (cpu_debug_csr_op_valid_net        ), 
  .debug_csr_req_ready                  (cpu_debug_csr_op_ready_net        ), 
  .debug_csr_req_wr_en                  (cpu_debug_csr_wr_en_net           ),  
  .debug_csr_req_rd_en                  (cpu_debug_csr_rd_en_net           ),  
  .debug_csr_req_addr                   (cpu_debug_csr_op_addr_net         ),
  .debug_csr_resp_rd_data               (cpu_debug_csr_op_rd_data_net      ),
  .debug_csr_resp_valid                 (cpu_debug_csr_op_rd_data_valid_net),
  .debug_csr_resp_ready                 (cpu_debug_csr_op_rd_data_ready_net),
  .debug_gpr_req_valid                  (cpu_debug_gpr_op_valid_net        ), 
  .debug_gpr_req_ready                  (cpu_debug_gpr_op_ready_net        ),   
  .debug_gpr_req_wr_en                  (cpu_debug_gpr_wr_en_net           ),
  .debug_gpr_req_rd_en                  (cpu_debug_gpr_rd_en_net           ), 
  .debug_gpr_req_addr                   (cpu_debug_gpr_op_addr_net         ),    
  .debug_gpr_resp_rd_data               (cpu_debug_gpr_op_rd_data_net      ), 
  .debug_gpr_resp_valid                 (cpu_debug_gpr_op_rd_data_valid_net), 
  .debug_gpr_resp_ready                 (cpu_debug_gpr_op_rd_data_ready_net),   
  
  
  .debug_halt_req                       (cpu_debug_halt_req_net          ),
  .debug_halt_ack                       (cpu_debug_halt_ack_net          ),
  .debug_resethalt_req                  (cpu_debug_resethalt_req_net     ),
  .debug_resethalt_ack                  (cpu_debug_resethalt_ack_net     ),
  .debug_resume_req                     (cpu_debug_resume_req_net        ),
  .debug_resume_ack                     (cpu_debug_resume_ack_net        ),
  .debug_mode                           (cpu_debug_mode_net              ),
  .m_sw_irq                             (hart_soft_irq_net               ),
  .m_timer_irq                          (m_timer_irq_sel                 ),
  .m_external_irq                       (m_external_irq                  ),
  .sys_ext_irq_src                      (sys_ext_irq_src_net             ),
  .trace_valid							(trace_valid					 ),
  .trace_iaddr                 		    (trace_iaddr                     ),
  .trace_insn                 		    (trace_insn                      ),
  .trace_priv					        (trace_priv						 ),
  .trace_exception   			        (trace_exception                 ),
  .trace_interrupt       		        (trace_interrupt                 ),
  .trace_cause                          (trace_cause                     ),
  .trace_tval                           (trace_tval                      ),
  // Formal Trace signals left disconnected at this level.
  // Used by the formal test bench only when the parameter
  // l_core_cfg_formal_dbg_if is set to 1.
  .formal_trace_instr (),
  .formal_trace_pc(),
  .formal_trace_reset_taken(),
  .formal_trace_instr_retire(),
  
  .icache_ram_init_done                 ( icache_ram_init_done           ),
  .ram_init_soft_debug_reset            ( ram_init_soft_debug_reset      ),
  .gpr_ram_init_done                    ( gpr_ram_init_done              ),
  .gpr_ecc_error_injection              ( gpr_ecc_error_injection        )
  
  
  );
  
 
  
 generate if(l_subsys_cfg_hart_debug)
 begin : gen_subsys_debug
 
  miv_rv32_subsys_debug #( .l_subsys_cfg_hart_debug(l_subsys_cfg_hart_debug))

  u_subsys_debug_unit_0
  (
  .clk                            (clk                               ),
  .resetn                         (resetn                            ),                                                                       
  .jtag_trst                      (jtag_trst                        ),  
  .jtag_tck                       (jtag_tck                          ),  
  .jtag_tdi                       (jtag_tdi                          ),  
  .jtag_tms                       (jtag_tms                          ),  
  .jtag_tdo                       (jtag_tdo                          ),  
  .jtag_tdo_dr                    (jtag_tdo_dr                       ),
  .debug_reset                    (cpu_debug_reset_net               ), 
  .debug_hart_reset               (cpu_debug_hart_reset_net          ), 
  .debug_sys_reset                (debug_sys_reset                   ),
  .debug_active                   (cpu_debug_active_net              ),
  
  .debug_op_wr_data               (cpu_debug_op_wr_data_net          ),
  
  .debug_csr_valid                (cpu_debug_csr_op_valid_net        ),
  .debug_csr_ready                (cpu_debug_csr_op_ready_net        ),
  .debug_csr_wr_en                (cpu_debug_csr_wr_en_net           ),
  .debug_csr_rd_en                (cpu_debug_csr_rd_en_net           ),
  .debug_csr_addr                 (cpu_debug_csr_op_addr_net         ),
  .debug_csr_rd_data              (cpu_debug_csr_op_rd_data_net      ),
  .debug_csr_rd_data_valid        (cpu_debug_csr_op_rd_data_valid_net),
  .debug_csr_rd_data_ready        (cpu_debug_csr_op_rd_data_ready_net),
  
  .debug_gpr_valid                (cpu_debug_gpr_op_valid_net        ),
  .debug_gpr_ready                (cpu_debug_gpr_op_ready_net        ),
  .debug_gpr_wr_en                (cpu_debug_gpr_wr_en_net           ),
  .debug_gpr_rd_en                (cpu_debug_gpr_rd_en_net           ),
  .debug_gpr_addr                 (cpu_debug_gpr_op_addr_net         ),
  .debug_gpr_rd_data              (cpu_debug_gpr_op_rd_data_net      ),
  .debug_gpr_rd_data_valid        (cpu_debug_gpr_op_rd_data_valid_net),
  .debug_gpr_rd_data_ready        (cpu_debug_gpr_op_rd_data_ready_net),
  
  .debug_halt_req                 (cpu_debug_halt_req_net            ),   
  .debug_halt_ack                 (cpu_debug_halt_ack_net            ),    
  .debug_resethalt_req            (cpu_debug_resethalt_req_net       ),
  //.debug_resethalt_ack            (cpu_debug_resethalt_ack_net       ), 
  .debug_resume_req               (cpu_debug_resume_req_net          ),   
  .debug_resume_ack               (cpu_debug_resume_ack_net          ),   
  .debug_mode                     (cpu_debug_mode_net                ),   
  .debug_trx_os                   (debug_trx_os_net                  ),   
  .debug_sysbus_req_valid         (debug_sysbus_req_valid_net        ),   
  .debug_sysbus_req_ready         (debug_sysbus_req_ready_net        ),   
  .debug_sysbus_req_rd_byte_en    (debug_sysbus_req_rd_byte_en_net   ),   
  .debug_sysbus_req_wr_byte_en    (debug_sysbus_req_wr_byte_en_net   ),   
  .debug_sysbus_req_addr          (debug_sysbus_req_addr_net         ),   
  .debug_sysbus_req_wr_data       (debug_sysbus_req_wr_data_net      ),   
  .debug_sysbus_resp_valid        (debug_sysbus_resp_valid_net       ),   
  .debug_sysbus_resp_ready        (debug_sysbus_resp_ready_net       ),   
  .debug_sysbus_resp_error        (debug_sysbus_resp_error_net       ),   
  .debug_sysbus_resp_rd_data      (debug_sysbus_resp_rd_data_net     )                                                                                                                                          
  );
  
  end
  else begin :ngen_subsys_debug

    assign jtag_tdo                           = 1'b0;             
    assign jtag_tdo_dr                        = 1'b0;             
    assign cpu_debug_reset_net                = 1'b0;             
    assign cpu_debug_hart_reset_net           = 1'b0;             
    assign debug_sys_reset                    = 1'b0;             
    assign cpu_debug_active_net               = 1'b0;             
    assign cpu_debug_op_wr_data_net           = {L_XLEN{1'b0}};
    assign cpu_debug_csr_op_valid_net         = 1'b0;   
    assign cpu_debug_csr_wr_en_net            = 1'b0;             
    assign cpu_debug_csr_rd_en_net            = 1'b0;             
    assign cpu_debug_csr_op_addr_net          = {12{1'b0}}; 
    assign cpu_debug_csr_op_rd_data_ready_net = 1'b0;  
    assign cpu_debug_gpr_op_valid_net         = 1'b0;    
    assign cpu_debug_gpr_wr_en_net            = 1'b0;             
    assign cpu_debug_gpr_rd_en_net            = 1'b0;             
    assign cpu_debug_gpr_op_addr_net          = {6{1'b0}}; 
    assign cpu_debug_gpr_op_rd_data_ready_net = 1'b0;       
    assign cpu_debug_halt_req_net             = 1'b0;     
    assign cpu_debug_resume_req_net           = 1'b0;        
    assign debug_sysbus_req_valid_net         = 1'b0;             
    assign debug_sysbus_req_rd_byte_en_net    = {4{1'b0}};        
    assign debug_sysbus_req_wr_byte_en_net    = {4{1'b0}};        
    assign debug_sysbus_req_addr_net          = 1'b0;             
    assign debug_sysbus_req_wr_data_net       = {L_XLEN{1'b0}};   
    assign debug_sysbus_resp_ready_net        = {L_XLEN{1'b0}};   
    

    
  end
  endgenerate

// SUBSYS Interconnect
//--------------------------------------------

  miv_rv32_subsys_interconnect
  #(    
    .CPU_ADDR_WIDTH                   (l_subsys_cfg_cpu_addr_width      ),
    .AXI_ADDR_WIDTH                   (AXI_ADDR_WIDTH                   ),
    .APB_ADDR_WIDTH                   (APB_ADDR_WIDTH                   ),
    .AHB_ADDR_WIDTH                   (AHB_ADDR_WIDTH                   ),
	.ECC_ENABLE                       (ECC_ENABLE                       ),
    .UDMA_CTRL_ADDR_WIDTH             (l_subsys_cfg_udma_ctrl_addr_width),
    .TCM0_ADDR_WIDTH                  (l_subsys_cfg_tcm0_addr_width     ),
    .TCM1_ADDR_WIDTH                  (l_subsys_cfg_tcm1_addr_width     ),
    .l_subsys_cfg_tcm0_present        (l_subsys_cfg_tcm0_present        ),
    .l_subsys_cfg_tcm1_present        (l_subsys_cfg_tcm1_present        ),
    .l_subsys_cfg_axi_present         (l_subsys_cfg_axi_present         ),
    .l_subsys_cfg_ahb_present         (l_subsys_cfg_ahb_present         ),
	.ICACHE_EN                        (ICACHE_EN                        ),
	.MI_I_MEM                         (MI_I_MEM                         ),
	.l_miv_rv32_version               (l_miv_rv32_version               )
  )
  u_subsys_interconnect_0
  (
    .clk                                   (clk                            ),
    .resetn                                (subsys_resetn                  ),
    .axi_rd_cfg_min_size                   (axi_rd_cfg_min_size_net        ),
    .axi_wr_cfg_min_size                   (axi_wr_cfg_min_size_net        ),
    .subsys_parity_en                      (subsys_parity_en_net           ),
    .sys_parity_disable                    (sys_parity_disable             ),
    .cfg_fence_all_src                     (cfg_fence_all_src_net          ),
    .cfg_ar_cache                          (cfg_ar_cache_net               ),
    .cfg_aw_cache                          (cfg_aw_cache_net               ),
    .cfg_raw_hzd_check                     (cfg_raw_hzd_check_net          ),
    .cfg_war_hzd_check                     (cfg_war_hzd_check_net          ),
    .tcm0_uncorrectable_ecc_error          (tcm0_uncorrectable_ecc_error   ),
    .tcm1_uncorrectable_ecc_error          (tcm1_uncorrectable_ecc_error   ),
    .subsys_irq                            (subsys_irq                     ),
    .cfg_axi_start_addr               	   (l_axi_start_addr          	   ),
    .cfg_axi_end_addr                      (l_axi_end_addr                 ),
    .cfg_apb_start_addr                    (l_apb_start_addr               ),
    .cfg_apb_end_addr                      (l_apb_end_addr                 ),
    .cfg_ahb_start_addr                    (l_ahb_start_addr               ),
    .cfg_ahb_end_addr                      (l_ahb_end_addr                 ),
    .cfg_udma_ctrl_start_addr              (l_udma_ctrl_start_addr         ),
    .cfg_udma_ctrl_end_addr                (l_udma_ctrl_end_addr           ),
    .cfg_subsys_cfg_start_addr             (l_subsys_cfg_start_addr        ),
    .cfg_subsys_cfg_end_addr               (l_subsys_cfg_end_addr          ),
    .cfg_tcm0_start_addr                   (l_tcm0_start_addr              ),
    .cfg_tcm0_end_addr                     (l_tcm0_end_addr                ),
    .cfg_tcm1_start_addr                   (l_tcm1_start_addr              ),
    .cfg_tcm1_end_addr                     (l_tcm1_end_addr                ), 
    .cpu_i_req_valid                       (cpu_i_req_valid_sel            ),
    .cpu_i_req_ready                       (cpu_i_req_ready_sel            ),
    .cpu_i_req_rd_byte_en                  (cpu_i_req_rd_byte_en_sel       ),
    .cpu_i_req_addr                        (cpu_i_req_addr_sel             ),
    .cpu_i_req_addr_p                      (cpu_i_req_addr_p_sel           ),
    .cpu_i_resp_valid                      (cpu_i_resp_valid_sel           ),
    .cpu_i_resp_ready                      (cpu_i_resp_ready_sel           ),
    .cpu_i_resp_error                      (cpu_i_resp_error_sel           ),
    .cpu_i_resp_rd_data                    (cpu_i_resp_rd_data_sel         ),
    .cpu_i_resp_rd_data_p                  (cpu_i_resp_rd_data_p_sel       ),
    .cpu_d_req_valid                       (cpu_d_req_valid_net            ),
    .cpu_d_req_ready                       (cpu_d_req_ready_net            ),
    .cpu_d_req_rd_byte_en                  (cpu_d_req_rd_byte_en_net       ),
    .cpu_d_req_wr_byte_en                  (cpu_d_req_wr_byte_en_net       ),
    .cpu_d_req_addr                        (cpu_d_req_addr_net             ),
    .cpu_d_req_addr_p                      (cpu_d_req_addr_p_net           ),
    .cpu_d_req_fence                       (cpu_d_req_fence_net            ),
    .cpu_d_req_read                        (cpu_d_req_read_net             ),
    .cpu_d_req_write                       (cpu_d_req_write_net            ),
    .cpu_d_req_wr_data                     (cpu_d_req_wr_data_net          ),
    .cpu_d_req_wr_data_p                   (cpu_d_req_wr_data_p_net        ),
    .cpu_d_resp_valid                      (cpu_d_resp_valid_net           ),
    .cpu_d_resp_ready                      (cpu_d_resp_ready_net           ),
    .cpu_d_resp_error                      (cpu_d_resp_error_net           ),
    .cpu_d_resp_rd_data                    (cpu_d_resp_rd_data_net         ),
    .cpu_d_resp_rd_data_p                  (cpu_d_resp_rd_data_p_net       ),
    .debug_mode                            (cpu_debug_mode_net             ),
    .debug_trx_os                          (debug_trx_os_net               ),  
    .debug_sysbus_req_valid                (debug_sysbus_req_valid_net     ),
    .debug_sysbus_req_ready                (debug_sysbus_req_ready_net     ),
    .debug_sysbus_req_rd_byte_en           (debug_sysbus_req_rd_byte_en_net),
    .debug_sysbus_req_wr_byte_en           (debug_sysbus_req_wr_byte_en_net),
    .debug_sysbus_req_addr                 (debug_sysbus_req_addr_net      ),
    .debug_sysbus_req_wr_data              (debug_sysbus_req_wr_data_net   ),
    .debug_sysbus_resp_valid               (debug_sysbus_resp_valid_net    ),
    .debug_sysbus_resp_ready               (debug_sysbus_resp_ready_net    ),
    .debug_sysbus_resp_error               (debug_sysbus_resp_error_net    ),
    .debug_sysbus_resp_rd_data             (debug_sysbus_resp_rd_data_net  ),
    .apb_i_req_valid                       (apb_i_req_valid_net            ),
    .apb_i_req_ready                       (apb_i_req_ready_net            ),
    .apb_i_req_rd_byte_en                  (apb_i_req_rd_byte_en_net       ),
    .apb_i_req_addr                        (apb_i_req_addr_net             ),
    .apb_i_req_addr_p                      (apb_i_req_addr_p_net           ),
    .apb_i_resp_valid                      (apb_i_resp_valid_net           ),
    .apb_i_resp_ready                      (apb_i_resp_ready_net           ),
    .apb_i_resp_error                      (apb_i_resp_error_net           ),
    .apb_i_resp_rd_data                    (apb_i_resp_rd_data_net         ),
    .apb_i_resp_rd_data_p                  (apb_i_resp_rd_data_p_net       ),
    .apb_d_req_valid                       (apb_d_req_valid_net            ),
    .apb_d_req_ready                       (apb_d_req_ready_net            ),
    .apb_d_req_rd_byte_en                  (apb_d_req_rd_byte_en_net       ),
    .apb_d_req_wr_byte_en                  (apb_d_req_wr_byte_en_net       ),
    //.apb_d_req_read                        (apb_d_req_read_net             ),
    //.apb_d_req_write                       (apb_d_req_write_net            ),
    .apb_d_req_addr                        (apb_d_req_addr_net             ),
    .apb_d_req_addr_p                      (apb_d_req_addr_p_net           ),
    .apb_d_req_wr_data                     (apb_d_req_wr_data_net          ),
    .apb_d_req_wr_data_p                   (apb_d_req_wr_data_p_net        ),
    .apb_d_resp_valid                      (apb_d_resp_valid_net           ),
    .apb_d_resp_ready                      (apb_d_resp_ready_net           ),
    .apb_d_resp_error                      (apb_d_resp_error_net           ),
    .apb_d_resp_rd_data                    (apb_d_resp_rd_data_net         ),
    .apb_d_resp_rd_data_p                  (apb_d_resp_rd_data_p_net       ),
    .apb_trx_os_d_rd                       (apb_trx_os_d_rd_net            ),
    .apb_trx_os_d_wr                       (apb_trx_os_d_wr_net            ),
    .tcm0_i_req_valid                      (tcm0_i_req_valid_net           ),
    .tcm0_i_req_ready                      (tcm0_i_req_ready_net           ),
    .tcm0_i_req_rd_byte_en                 (tcm0_i_req_rd_byte_en_net      ),
    .tcm0_i_req_addr                       (tcm0_i_req_addr_net            ),
    .tcm0_i_req_addr_p                     (tcm0_i_req_addr_p_net          ),
    .tcm0_i_resp_valid                     (tcm0_i_resp_valid_net          ),
    .tcm0_i_resp_ready                     (tcm0_i_resp_ready_net          ),
    .tcm0_i_resp_error                     (tcm0_i_resp_error_net          ),
    .tcm0_i_resp_rd_data                   (tcm0_i_resp_rd_data_net        ),
    .tcm0_i_resp_rd_data_p                 (tcm0_i_resp_rd_data_p_net      ),
    .tcm0_d_req_valid                      (tcm0_d_req_valid_net           ),
    .tcm0_d_req_ready                      (tcm0_d_req_ready_net           ),
    .tcm0_d_req_rd_byte_en                 (tcm0_d_req_rd_byte_en_net      ),
    .tcm0_d_req_wr_byte_en                 (tcm0_d_req_wr_byte_en_net      ),
    .tcm0_d_req_read                       (tcm0_d_req_read_net            ),
    .tcm0_d_req_write                      (tcm0_d_req_write_net           ),
    .tcm0_d_req_addr                       (tcm0_d_req_addr_net            ),
    .tcm0_d_req_addr_p                     (tcm0_d_req_addr_p_net          ),
    .tcm0_d_req_wr_data                    (tcm0_d_req_wr_data_net         ),
    .tcm0_d_req_wr_data_p                  (tcm0_d_req_wr_data_p_net       ),
    .tcm0_d_resp_valid                     (tcm0_d_resp_valid_net          ),
    .tcm0_d_resp_ready                     (tcm0_d_resp_ready_net          ),
    .tcm0_d_resp_error                     (tcm0_d_resp_error_net          ),
    .tcm0_d_resp_rd_data                   (tcm0_d_resp_rd_data_net        ),
    .tcm0_d_resp_rd_data_p                 (tcm0_d_resp_rd_data_p_net      ),     
    .tcm0_trx_os_d_rd                      (tcm0_trx_os_d_rd_net           ),
    .tcm0_trx_os_d_wr                      (tcm0_trx_os_d_wr_net           ), 
    .tcm0_ecc_err_correctable              (tcm0_ecc_err_correctable_net   ),
    .tcm0_ecc_err_uncorrectable            (tcm0_ecc_err_uncorrectable_net ),    
    .tcm1_i_req_valid                      (tcm1_i_req_valid_net           ),
    .tcm1_i_req_ready                      (tcm1_i_req_ready_net           ),
    .tcm1_i_req_rd_byte_en                 (tcm1_i_req_rd_byte_en_net      ),
    .tcm1_i_req_addr                       (tcm1_i_req_addr_net            ),
    .tcm1_i_req_addr_p                     (tcm1_i_req_addr_p_net          ),
    .tcm1_i_resp_valid                     (tcm1_i_resp_valid_net          ),
    .tcm1_i_resp_ready                     (tcm1_i_resp_ready_net          ),
    .tcm1_i_resp_error                     (tcm1_i_resp_error_net          ),
    .tcm1_i_resp_rd_data                   (tcm1_i_resp_rd_data_net        ),
    .tcm1_i_resp_rd_data_p                 (tcm1_i_resp_rd_data_p_net      ),
    .tcm1_d_req_valid                      (tcm1_d_req_valid_net           ),
    .tcm1_d_req_ready                      (tcm1_d_req_ready_net           ),
    .tcm1_d_req_rd_byte_en                 (tcm1_d_req_rd_byte_en_net      ),
    .tcm1_d_req_wr_byte_en                 (tcm1_d_req_wr_byte_en_net      ),
    .tcm1_d_req_read                       (tcm1_d_req_read_net            ),
    .tcm1_d_req_write                      (tcm1_d_req_write_net           ),
    .tcm1_d_req_addr                       (tcm1_d_req_addr_net            ),
    .tcm1_d_req_addr_p                     (tcm1_d_req_addr_p_net          ),
    .tcm1_d_req_wr_data                    (tcm1_d_req_wr_data_net         ),
    .tcm1_d_req_wr_data_p                  (tcm1_d_req_wr_data_p_net       ),
    .tcm1_d_resp_valid                     (tcm1_d_resp_valid_net          ),
    .tcm1_d_resp_ready                     (tcm1_d_resp_ready_net          ),
    .tcm1_d_resp_error                     (tcm1_d_resp_error_net          ),
    .tcm1_d_resp_rd_data                   (tcm1_d_resp_rd_data_net        ),
    .tcm1_d_resp_rd_data_p                 (tcm1_d_resp_rd_data_p_net      ),     
    .tcm1_trx_os_d_rd                      (tcm1_trx_os_d_rd_net           ),
    .tcm1_trx_os_d_wr                      (tcm1_trx_os_d_wr_net           ),  
    .tcm1_ecc_err_correctable              (tcm1_ecc_err_correctable_net   ),
    .tcm1_ecc_err_uncorrectable            (tcm1_ecc_err_uncorrectable_net ), 
    .axi_i_req_valid                       (axi_i_req_valid_net            ),
    .axi_i_req_ready                       (axi_i_req_ready_net            ),
    .axi_i_req_rd_byte_en                  (axi_i_req_rd_byte_en_net       ),
    .axi_i_req_addr                        (axi_i_req_addr_net             ),
    .axi_i_req_addr_p                      (axi_i_req_addr_p_net           ),
    .axi_i_resp_valid                      (axi_i_resp_valid_net           ),
    .axi_i_resp_last                       (axi_i_resp_last_net            ),
    .axi_i_resp_ready                      (axi_i_resp_ready_net           ),
    .axi_i_resp_error                      (axi_i_resp_error_net           ),
    .axi_i_resp_rd_data                    (axi_i_resp_rd_data_net         ),
    .axi_i_resp_rd_data_p                  (axi_i_resp_rd_data_p_net       ),
    .axi_d_req_valid                       (axi_d_req_valid_net            ),
    .axi_d_req_ready                       (axi_d_req_ready_net            ),
    .axi_d_req_rd_byte_en                  (axi_d_req_rd_byte_en_net       ),
    .axi_d_req_wr_byte_en                  (axi_d_req_wr_byte_en_net       ),
    .axi_d_req_read                        (axi_d_req_read_net             ),
    .axi_d_req_write                       (axi_d_req_write_net            ),
    .axi_d_req_addr                        (axi_d_req_addr_net             ),
    .axi_d_req_addr_p                      (axi_d_req_addr_p_net           ),
    .axi_d_req_wr_data                     (axi_d_req_wr_data_net          ),
    .axi_d_req_wr_data_p                   (axi_d_req_wr_data_p_net        ),
    .axi_d_resp_valid                      (axi_d_resp_valid_net           ),
    .axi_d_resp_ready                      (axi_d_resp_ready_net           ),
    .axi_d_resp_rd_error                   (axi_d_resp_rd_error_net        ),
    .axi_d_resp_rd_data                    (axi_d_resp_rd_data_net         ),
    .axi_d_resp_rd_data_p                  (axi_d_resp_rd_data_p_net       ),
    .axi_d_wr_resp_err                     (axi_d_wr_resp_err_net          ),
    .axi_trx_os_d_rd                       (axi_trx_os_d_rd_net            ),
    .axi_trx_os_d_wr                       (axi_trx_os_d_wr_net            ),
    .ahb_i_req_valid                       (ahb_i_req_valid_net            ),
    .ahb_i_req_ready                       (ahb_i_req_ready_net            ),
    .ahb_i_req_rd_byte_en                  (ahb_i_req_rd_byte_en_net       ),
    .ahb_i_req_addr                        (ahb_i_req_addr_net             ),
    .ahb_i_req_addr_p                      (ahb_i_req_addr_p_net           ),
    .ahb_i_resp_valid                      (ahb_i_resp_valid_net           ),
    .ahb_i_resp_last                       (ahb_i_resp_last_net            ),
    .ahb_i_resp_ready                      (ahb_i_resp_ready_net           ),
    .ahb_i_resp_error                      (ahb_i_resp_error_net           ),
    .ahb_i_resp_rd_data                    (ahb_i_resp_rd_data_net         ),
    .ahb_i_resp_rd_data_p                  (ahb_i_resp_rd_data_p_net       ),
    .ahb_d_req_valid                       (ahb_d_req_valid_net            ),
    .ahb_d_req_ready                       (ahb_d_req_ready_net            ),
    .ahb_d_req_rd_byte_en                  (ahb_d_req_rd_byte_en_net       ),
    .ahb_d_req_wr_byte_en                  (ahb_d_req_wr_byte_en_net       ),
    .ahb_d_req_read                        (ahb_d_req_read_net             ),
    .ahb_d_req_write                       (ahb_d_req_write_net            ),
    .ahb_d_req_addr                        (ahb_d_req_addr_net             ),
    .ahb_d_req_addr_p                      (ahb_d_req_addr_p_net           ),
    .ahb_d_req_wr_data                     (ahb_d_req_wr_data_net          ),
    .ahb_d_req_wr_data_p                   (ahb_d_req_wr_data_p_net        ),
    .ahb_d_resp_valid                      (ahb_d_resp_valid_net           ),
    .ahb_d_resp_ready                      (ahb_d_resp_ready_net           ),
    .ahb_d_resp_rd_error                   (ahb_d_resp_rd_error_net        ),
    .ahb_d_resp_rd_data                    (ahb_d_resp_rd_data_net         ),
    .ahb_d_resp_rd_data_p                  (ahb_d_resp_rd_data_p_net       ),    
    .ahb_trx_os_d_rd                       (ahb_trx_os_d_rd_net            ),
    .ahb_trx_os_d_wr                       (ahb_trx_os_d_wr_net            ),   
    .udma_ctrl_d_req_valid                 (cpu_udma_ctrl_req_valid_net    ),
    .udma_ctrl_d_req_ready                 (cpu_udma_ctrl_req_ready_net    ),
    .udma_ctrl_d_req_rd_byte_en            (cpu_udma_ctrl_req_rd_byte_en_net),
    .udma_ctrl_d_req_wr_byte_en            (cpu_udma_ctrl_req_wr_byte_en_net),
    .udma_ctrl_d_req_read                  (cpu_udma_ctrl_req_read_net      ),
    .udma_ctrl_d_req_write                 (cpu_udma_ctrl_req_write_net     ),
    .udma_ctrl_d_req_addr                  (cpu_udma_ctrl_req_addr_net      ),
    .udma_ctrl_d_req_addr_p                (cpu_udma_ctrl_req_addr_p_net    ),
    .udma_ctrl_d_req_wr_data               (cpu_udma_ctrl_req_wr_data_net   ),
    .udma_ctrl_d_req_wr_data_p             (cpu_udma_ctrl_req_wr_data_p_net ),
    .udma_ctrl_d_resp_valid                (cpu_udma_ctrl_resp_valid_net    ),
    .udma_ctrl_d_resp_ready                (cpu_udma_ctrl_resp_ready_net    ),
    .udma_ctrl_d_resp_error                (cpu_udma_ctrl_resp_error_net    ),
    .udma_ctrl_d_resp_rd_data              (cpu_udma_ctrl_resp_rd_data_net  ),
    .udma_ctrl_d_resp_rd_data_p            (cpu_udma_ctrl_resp_rd_data_p_net),
    .udma_ctrl_irq                         (cpu_udma_ctrl_irq_net           ),
    .udma_trx_os_d_rd                      (udma_trx_os_d_rd_net            ),
    .udma_trx_os_d_wr                      (udma_trx_os_d_wr_net            ),
    .hart_soft_reset                       (hart_soft_reset_net             ),       //hart_soft_reset output from interconnect
    .hart_soft_irq                         (hart_soft_irq_net               ),       //hart_soft_irq output from interconnect
    .gpr_ded_soft_reset                    (gpr_uncorrectable_ecc_error     ),
	.cpu_i_req_is_ahb_in                   (cpu_i_req_is_ahb                ),
	.cpu_i_req_is_axi_in                   (cpu_i_req_is_axi                ),
    .icache_ecc_err_correctable            (icache_ecc_err_correctable      ),
    .icache_ecc_err_uncorrectable          (icache_ecc_err_uncorrectable    ),
	.gpr_ecc_error_injection               (gpr_ecc_error_injection         ),  
    .tcm_ecc_error_injection               (tcm_ecc_error_injection         ),
    .icache_ecc_error_injection            (icache_ecc_error_injection      )
	
  );

// APB Initiator
//--------------------------------------------
// APB Initiator always present

  generate
  if(l_subsys_cfg_apb_present | INTERNAL_MTIME | INTERNAL_MTIME_IRQ) begin: gen_apb
    miv_rv32_subsys_apb_initiator
    #(    
      .APB_ADDR_WIDTH                  (APB_ADDR_WIDTH            )
    )
    u_apb_initiator_0
    (
      .clk                                  (clk                       ),
      .presetn                              (subsys_resetn             ),                                            
      .subsys_parity_en                     (subsys_parity_en_net      ),
      .trx_os_d_rd                          (apb_trx_os_d_rd_net       ),
      .trx_os_d_wr                          (apb_trx_os_d_wr_net       ),
      .cpu_i_req_valid                      (apb_i_req_valid_net       ),  
      .cpu_i_req_ready                      (apb_i_req_ready_net       ),  
      .cpu_i_req_rd_byte_en                 (apb_i_req_rd_byte_en_net  ),  
      .cpu_i_req_addr                       (apb_i_req_addr_net        ),  
      .cpu_i_req_addr_p                     (apb_i_req_addr_p_net      ),  
      .cpu_i_resp_valid                     (apb_i_resp_valid_net      ),  
      .cpu_i_resp_ready                     (apb_i_resp_ready_net      ),  
      .cpu_i_resp_error                     (apb_i_resp_error_net      ),  
      .cpu_i_resp_rd_data                   (apb_i_resp_rd_data_net    ),  
      .cpu_i_resp_rd_data_p                 (apb_i_resp_rd_data_p_net  ),
      .cpu_d_req_valid                      (apb_d_req_valid_net       ),  
      .cpu_d_req_ready                      (apb_d_req_ready_net       ),  
      .cpu_d_req_rd_byte_en                 (apb_d_req_rd_byte_en_net  ),  
      .cpu_d_req_wr_byte_en                 (apb_d_req_wr_byte_en_net  ),  
      .cpu_d_req_addr                       (apb_d_req_addr_net        ),  
      .cpu_d_req_addr_p                     (apb_d_req_addr_p_net      ),     
      .cpu_d_req_wr_data                    (apb_d_req_wr_data_net     ),  
      .cpu_d_req_wr_data_p                  (apb_d_req_wr_data_p_net   ),  
      .cpu_d_resp_valid                     (apb_d_resp_valid_net      ),  
      .cpu_d_resp_ready                     (apb_d_resp_ready_net      ),  
      .cpu_d_resp_error                     (apb_d_resp_error_net      ),  
      .cpu_d_resp_rd_data                   (apb_d_resp_rd_data_net    ),
      .cpu_d_resp_rd_data_p                 (apb_d_resp_rd_data_p_net  ),
      .paddr                                (apb_paddr                 ),
      .paddr_p                              (apb_paddr_p               ),
      .pprot                                (apb_pprot                 ),
      .psel                                 (apb_psel_net              ),
      .penable                              (apb_penable_net           ),
      .pwrite                               (apb_pwrite                ),
      .pwdata                               (apb_pwdata                ),
      .pwdata_p                             (apb_pwdata_p              ),
      .pstrb                                (apb_pstrb                 ),
      .pready                               (apb_pready_net            ),
      .prdata                               (apb_prdata_net            ),
      .prdata_p                             (apb_prdata_p              ),
      .pslverr                              (apb_pslverr_net           )
    );  
  end else begin : ngen_apb
	assign apb_trx_os_d_rd_net = 1'b0;
	assign apb_trx_os_d_wr_net = 1'b0;
	assign apb_i_req_ready_net = 1'b0; 
	assign apb_i_resp_valid_net = 1'b0;
	assign apb_i_resp_error_net = 1'b0;
	assign apb_i_resp_rd_data_net = 32'b0; 
	assign apb_i_resp_rd_data_p_net = 4'b0; 
	assign apb_d_req_ready_net = 1'b0; 
	assign apb_d_resp_valid_net = 1'b0;
	assign apb_d_resp_error_net = 1'b0;
	assign apb_d_resp_rd_data_net = 32'b0;  
	assign apb_d_resp_rd_data_p_net = 4'b0;   
	assign apb_paddr = {APB_ADDR_WIDTH{1'b0}}; 
	assign apb_paddr_p = 1'b0;
	assign apb_pprot = 3'b0;
	assign apb_psel_net = 1'b0;
	assign apb_penable_net = 1'b0; 
	assign apb_pwrite = 1'b0; 
	assign apb_pwdata = 32'b0;
	assign apb_pwdata_p = 4'b0;
	assign apb_pstrb = 4'b0; 
  end
  endgenerate


// APB Target (TCM access support)
//--------------------------------------------

  generate
  if(l_subsys_cfg_tcm_tas_present) begin: gen_apb_tcm_tas
    miv_rv32_subsys_tcm_tas_apb_target
    #(    
      .CPU_ADDR_WIDTH                       (l_subsys_cfg_cpu_addr_width          ),
      .TCM_TAS_ADDR_WIDTH                   (TCM_TAS_ADDR_WIDTH                 ),
      .TCM0_ADDR_WIDTH                      (l_subsys_cfg_tcm0_addr_width        ),
      .TCM1_ADDR_WIDTH                      (l_subsys_cfg_tcm1_addr_width        ),
      .UDMA_CTRL_ADDR_WIDTH                 (l_subsys_cfg_udma_ctrl_addr_width    )
    )
    u_tcm_tas_0
    (
      .clk                                  (clk                                  ),
      .resetn                               (subsys_resetn                        ),                                      
      .subsys_parity_en                     (subsys_parity_en_net                  ),
      .cfg_tcm_tas_udma_ctrl_start_addr     (l_tcm_tas_udma_ctrl_start_addr      ),
      .cfg_tcm_tas_udma_ctrl_end_addr       (l_tcm_tas_udma_ctrl_end_addr        ),
      .cfg_tcm_tas_tcm0_start_addr          (l_tcm_tas_tcm0_start_addr          ),
      .cfg_tcm_tas_tcm0_end_addr            (l_tcm_tas_tcm0_end_addr            ),
      .cfg_tcm_tas_tcm1_start_addr          (l_tcm_tas_tcm1_start_addr          ),
      .cfg_tcm_tas_tcm1_end_addr            (l_tcm_tas_tcm1_end_addr            ),
      .paddr                                (tcm_tas_paddr               ),
      .paddr_p                              (tcm_tas_paddr_p             ),
      .pprot                                (tcm_tas_pprot               ),
      .psel                                 (tcm_tas_psel                ),
      .penable                              (tcm_tas_penable             ),
      .pwrite                               (tcm_tas_pwrite              ),
      .pwdata                               (tcm_tas_pwdata              ),
      .pwdata_p                             (tcm_tas_pwdata_p            ),
      .pready                               (tcm_tas_pready              ),
      .prdata                               (tcm_tas_prdata              ),
      .prdata_p                             (tcm_tas_prdata_p            ),
      .pslverr                              (tcm_tas_pslverr             ),
      .tcm0_tas_req_valid                  (tcm0_tas_req_valid_net              ),
      .tcm0_tas_req_ready                  (tcm0_tas_req_ready_net              ),
      .tcm0_tas_req_rd_byte_en             (tcm0_tas_req_rd_byte_en_net         ),
      .tcm0_tas_req_wr_byte_en             (tcm0_tas_req_wr_byte_en_net         ),
      .tcm0_tas_req_addr                   (tcm0_tas_req_addr_net               ),
      .tcm0_tas_req_addr_p                 (tcm0_tas_req_addr_p_net             ),
      .tcm0_tas_req_wr_data                (tcm0_tas_req_wr_data_net            ),
      .tcm0_tas_req_wr_data_p              (tcm0_tas_req_wr_data_p_net          ),
      .tcm0_tas_resp_valid                 (tcm0_tas_resp_valid_net             ),
      .tcm0_tas_resp_ready                 (tcm0_tas_resp_ready_net             ),
      .tcm0_tas_resp_rd_error              (tcm0_tas_resp_rd_error_net          ),
      .tcm0_tas_resp_rd_data               (tcm0_tas_resp_rd_data_net           ),
      .tcm0_tas_resp_rd_data_p             (tcm0_tas_resp_rd_data_p_net         ),
      .tcm1_tas_req_valid                  (tcm1_tas_req_valid_net              ),
      .tcm1_tas_req_ready                  (tcm1_tas_req_ready_net              ),
      .tcm1_tas_req_rd_byte_en             (tcm1_tas_req_rd_byte_en_net         ),
      .tcm1_tas_req_wr_byte_en             (tcm1_tas_req_wr_byte_en_net         ),
      .tcm1_tas_req_addr                   (tcm1_tas_req_addr_net               ),
      .tcm1_tas_req_addr_p                 (tcm1_tas_req_addr_p_net             ),
      .tcm1_tas_req_wr_data                (tcm1_tas_req_wr_data_net            ),
      .tcm1_tas_req_wr_data_p              (tcm1_tas_req_wr_data_p_net          ),
      .tcm1_tas_resp_valid                 (tcm1_tas_resp_valid_net             ),
      .tcm1_tas_resp_ready                 (tcm1_tas_resp_ready_net             ),
      .tcm1_tas_resp_rd_error              (tcm1_tas_resp_rd_error_net          ),
      .tcm1_tas_resp_rd_data               (tcm1_tas_resp_rd_data_net           ),
      .tcm1_tas_resp_rd_data_p             (tcm1_tas_resp_rd_data_p_net         ),
      .udma_ctrl_req_valid                  (tcm_tas_udma_ctrl_req_valid_net     ),
      .udma_ctrl_req_ready                  (tcm_tas_udma_ctrl_req_ready_net     ),
      .udma_ctrl_req_rd_byte_en             (tcm_tas_udma_ctrl_req_rd_byte_en_net),
      .udma_ctrl_req_wr_byte_en             (tcm_tas_udma_ctrl_req_wr_byte_en_net),
      .udma_ctrl_req_addr                   (tcm_tas_udma_ctrl_req_addr_net      ),      
      .udma_ctrl_req_addr_p                 (tcm_tas_udma_ctrl_req_addr_p_net    ),
      .udma_ctrl_req_wr_data                (tcm_tas_udma_ctrl_req_wr_data_net   ),
      .udma_ctrl_req_wr_data_p              (tcm_tas_udma_ctrl_req_wr_data_p_net ),
      .udma_ctrl_resp_valid                 (tcm_tas_udma_ctrl_resp_valid_net    ),
      .udma_ctrl_resp_ready                 (tcm_tas_udma_ctrl_resp_ready_net    ),
      .udma_ctrl_resp_rd_error              (tcm_tas_udma_ctrl_resp_rd_error_net ),
      .udma_ctrl_resp_rd_data               (tcm_tas_udma_ctrl_resp_rd_data_net  ),
      .udma_ctrl_resp_rd_data_p             (tcm_tas_udma_ctrl_resp_rd_data_p_net) 
    );
  end
  else begin : ngen_apb_tcm_tas
  
    assign tcm_tas_pready                 = 1'b0;  
    assign tcm_tas_prdata                 = {32{1'b0}}; 
    assign tcm_tas_prdata_p               = {4{1'b0}};
    assign tcm_tas_pslverr                = 1'b0;    
    assign tcm0_tas_req_valid_net                 = 1'b0; 
    assign tcm0_tas_req_rd_byte_en_net            = {4{1'b0}};
    assign tcm0_tas_req_wr_byte_en_net            = {4{1'b0}};
    assign tcm0_tas_req_addr_net                  = {l_subsys_cfg_tcm0_addr_width{1'b0}};
    assign tcm0_tas_req_addr_p_net                = 1'b0;
    assign tcm0_tas_req_wr_data_net               = {32{1'b0}};
    assign tcm0_tas_req_wr_data_p_net             = {4{1'b0}};
    assign tcm0_tas_resp_ready_net                = 1'b0; 
    assign tcm1_tas_req_valid_net                 = 1'b0; 
    assign tcm1_tas_req_rd_byte_en_net            = {4{1'b0}};
    assign tcm1_tas_req_wr_byte_en_net            = {4{1'b0}};
    assign tcm1_tas_req_addr_net                  = {l_subsys_cfg_tcm1_addr_width{1'b0}};
    assign tcm1_tas_req_addr_p_net                = 1'b0;
    assign tcm1_tas_req_wr_data_net               = {32{1'b0}};
    assign tcm1_tas_req_wr_data_p_net             = {4{1'b0}};
    assign tcm1_tas_resp_ready_net                = 1'b0;    
    assign tcm_tas_udma_ctrl_req_valid_net        = 1'b0;
    assign tcm_tas_udma_ctrl_req_rd_byte_en_net   = {4{1'b0}}; 
    assign tcm_tas_udma_ctrl_req_wr_byte_en_net   = {4{1'b0}};
    assign tcm_tas_udma_ctrl_req_addr_net         = {l_subsys_cfg_udma_ctrl_addr_width{1'b0}};
    assign tcm_tas_udma_ctrl_req_addr_p_net       = 1'b0;
    assign tcm_tas_udma_ctrl_req_wr_data_net      = {32{1'b0}};
    assign tcm_tas_udma_ctrl_req_wr_data_p_net    = {4{1'b0}};
    assign tcm_tas_udma_ctrl_resp_ready_net       = 1'b0;   
    
  end   
  endgenerate
  
  
  
  

// Local Memory 0
//--------------------------------------------


  generate
  if(l_subsys_cfg_tcm0_present) begin: gen_tcm0
    miv_rv32_subsys_tcm
    #(    
	  .FAMILY                               (FAMILY                               ),
      .UDMA_PRESENT                         (l_subsys_cfg_tcm0_udma_present       ),
      .TCM_TAS_PRESENT                      (l_subsys_cfg_tcm0_tas_present        ),
      .DEBUG_PRESENT                        (l_subsys_cfg_hart_debug              ),
      .CPU_I_PRESENT                        (l_subsys_cfg_tcm0_cpu_i_present      ),
      .CPU_D_PRESENT                        (l_subsys_cfg_tcm0_cpu_d_present      ),
      .USE_RAM_PARITY_BITS                  (l_subsys_cfg_tcm0_use_ram_parity_bits),
      .RAM_SB_IN_WIDTH                      (RAM_SB_IN_WIDTH),
      .RAM_SB_OUT_WIDTH                     (RAM_SB_OUT_WIDTH),
	  .RAM_DEPTH                            (TCM0_DEPTH/4),   // 32bit = 4 bytes
      .TCM_ADDR_WIDTH                       (TCM0_WIDTH),
	  .ECC_ENABLE                           (ECC_ENABLE),
      .ROM                                  (0),
	  .TCM_REGS								(TCM_REGS)
      
    )
    u_subsys_TCM_0
    (
      .clk                                  (clk                                 ),
      .resetn                               (subsys_resetn                       ),                                      
      .subsys_parity_en                      (subsys_parity_en_net               ),
      .trx_os_d_rd                          (tcm0_trx_os_d_rd_net                ),
      .trx_os_d_wr                          (tcm0_trx_os_d_wr_net                ),
      .ecc_err_correctable                  (tcm0_ecc_err_correctable_net        ),
      .ecc_err_uncorrectable                (tcm0_ecc_err_uncorrectable_net      ),
      .cpu_i_req_valid                      (tcm0_i_req_valid_net                ),
      .cpu_i_req_ready                      (tcm0_i_req_ready_net                ),
      .cpu_i_req_rd_byte_en                 (tcm0_i_req_rd_byte_en_net           ),
      .cpu_i_req_addr                       (tcm0_i_req_addr_net                 ),
      .cpu_i_req_addr_p                     (tcm0_i_req_addr_p_net               ),
      .cpu_i_resp_valid                     (tcm0_i_resp_valid_net               ),
      .cpu_i_resp_ready                     (tcm0_i_resp_ready_net               ),
      .cpu_i_resp_error                     (tcm0_i_resp_error_net               ),
      .cpu_i_resp_rd_data                   (tcm0_i_resp_rd_data_net             ),
      .cpu_i_resp_rd_data_p                 (tcm0_i_resp_rd_data_p_net           ),
      .cpu_d_req_valid                      (tcm0_d_req_valid_net                ),
      .cpu_d_req_ready                      (tcm0_d_req_ready_net                ),
      .cpu_d_req_rd_byte_en                 (tcm0_d_req_rd_byte_en_net           ),
      .cpu_d_req_wr_byte_en                 (tcm0_d_req_wr_byte_en_net           ),
      .cpu_d_req_read                       (tcm0_d_req_read_net                 ),
      .cpu_d_req_write                      (tcm0_d_req_write_net                ),
      .cpu_d_req_addr                       (tcm0_d_req_addr_net                 ),
      .cpu_d_req_addr_p                     (tcm0_d_req_addr_p_net               ),
      .cpu_d_req_wr_data                    (tcm0_d_req_wr_data_net              ),
      .cpu_d_req_wr_data_p                  (tcm0_d_req_wr_data_p_net            ),
      .cpu_d_resp_valid                     (tcm0_d_resp_valid_net               ),
      .cpu_d_resp_ready                     (tcm0_d_resp_ready_net               ),
      .cpu_d_resp_error                     (tcm0_d_resp_error_net               ),
      .cpu_d_resp_rd_data                   (tcm0_d_resp_rd_data_net             ),
      .cpu_d_resp_rd_data_p                 (tcm0_d_resp_rd_data_p_net           ),    
      .udma_req_valid                       (udma_tcm0_req_valid_net             ),
      .udma_req_ready                       (udma_tcm0_req_ready_net             ),
      .udma_req_rd_byte_en                  (udma_tcm0_req_rd_byte_en_net        ),
      .udma_req_wr_byte_en                  (udma_tcm0_req_wr_byte_en_net        ),
      .udma_req_read                        (udma_tcm0_req_read_net              ),
      .udma_req_write                       (udma_tcm0_req_write_net             ),
      .udma_req_addr                        (udma_tcm0_req_addr_net              ),
      .udma_req_addr_p                      (udma_tcm0_req_addr_p_net            ),
      .udma_req_len                         (udma_tcm0_req_len_net               ),
      .udma_req_wr_data                     (udma_tcm0_req_wr_data_net           ),
      .udma_req_wr_data_p                   (udma_tcm0_req_wr_data_p_net         ),
      .udma_resp_valid                      (udma_tcm0_resp_valid_net            ),
      .udma_resp_ready                      (udma_tcm0_resp_ready_net            ),
      .udma_resp_rd_error                   (udma_tcm0_resp_rd_error_net         ),
      .udma_resp_rd_data                    (udma_tcm0_resp_rd_data_net          ),
      .udma_resp_rd_data_p                  (udma_tcm0_resp_rd_data_p_net        ), 
      .tcm_tas_access_disable              (tcm0_tas_access_disable             ),
      .tcm_cpu_access_disable              (tcm0_cpu_access_disable             ),
      .tcm_dma_access_disable              (tcm0_dma_access_disable             ),
      .tcm_tas_req_valid                   (tcm0_tas_req_valid_net              ),
      .tcm_tas_req_ready                   (tcm0_tas_req_ready_net              ),
      .tcm_tas_req_rd_byte_en              (tcm0_tas_req_rd_byte_en_net         ),
      .tcm_tas_req_wr_byte_en              (tcm0_tas_req_wr_byte_en_net         ),
      .tcm_tas_req_addr                    (tcm0_tas_req_addr_net               ),
      .tcm_tas_req_addr_p                  (tcm0_tas_req_addr_p_net             ),
      .tcm_tas_req_wr_data                 (tcm0_tas_req_wr_data_net            ),
      .tcm_tas_req_wr_data_p               (tcm0_tas_req_wr_data_p_net          ),
      .tcm_tas_resp_valid                  (tcm0_tas_resp_valid_net             ),
      .tcm_tas_resp_ready                  (tcm0_tas_resp_ready_net             ),
      .tcm_tas_resp_rd_error               (tcm0_tas_resp_rd_error_net          ),
      .tcm_tas_resp_rd_data                (tcm0_tas_resp_rd_data_net           ),
      .tcm_tas_resp_rd_data_p              (tcm0_tas_resp_rd_data_p_net         ),
      .tcm_ram_sb_out                      (tcm0_ram_sb_out                     ), 
      .tcm_ram_sb_in                       (tcm0_ram_sb_in                      ),
      .tcm_ecc_error_injection             (tcm_ecc_error_injection             )	  
    );
  end
  else begin : ngen_tcm0 
    assign tcm0_i_req_ready_net           = 1'b0;  
    assign tcm0_i_resp_valid_net          = 1'b0;  
    assign tcm0_i_resp_error_net          = 1'b0;  
    assign tcm0_i_resp_rd_data_net        = {32{1'b0}}; 
    assign tcm0_i_resp_rd_data_p_net      = {4{1'b0}};
    assign tcm0_d_req_ready_net           = 1'b0;  
    assign tcm0_d_resp_valid_net          = 1'b0;  
    assign tcm0_d_resp_error_net          = 1'b0;  
    assign tcm0_d_resp_rd_data_net        = {32{1'b0}}; 
    assign tcm0_d_resp_rd_data_p_net      = {4{1'b0}};
    assign udma_tcm0_req_ready_net        = 1'b0;              
    assign udma_tcm0_resp_valid_net       = 1'b0;               
    assign udma_tcm0_resp_rd_error_net    = 1'b0;              
    assign udma_tcm0_resp_rd_data_net     = {32{1'b0}};        
    assign udma_tcm0_resp_rd_data_p_net   = {4{1'b0}};                  
    assign tcm0_tas_req_ready_net         = 1'b0;                      
    assign tcm0_tas_resp_valid_net        = 1'b0;                      
    assign tcm0_tas_resp_rd_error_net     = 1'b0;                      
    assign tcm0_tas_resp_rd_data_net      = {32{1'b0}};                
    assign tcm0_tas_resp_rd_data_p_net    = {4{1'b0}};    
    assign tcm0_trx_os_d_rd_net           = 1'b0;
    assign tcm0_trx_os_d_wr_net           = 1'b0;
    assign tcm0_ecc_err_correctable_net   = 1'b0;
    assign tcm0_ecc_err_uncorrectable_net = 1'b0;
    assign tcm0_ram_sb_out                = {RAM_SB_OUT_WIDTH{1'b0}};
    
  end   
  endgenerate

// Local Memory 1
//--------------------------------------------

  generate
  if(l_subsys_cfg_tcm1_present) begin: gen_bootrom 
    miv_rv32_subsys_tcm
    #(    
	  .FAMILY                               (FAMILY                            ),
      .TCM_ADDR_WIDTH                       (l_subsys_cfg_tcm1_addr_width       ),
      .UDMA_PRESENT                         (l_subsys_cfg_tcm1_udma_present     ),
      .TCM_TAS_PRESENT                      (l_subsys_cfg_tcm1_tas_present      ),
      .DEBUG_PRESENT                        (l_subsys_cfg_hart_debug            ),
      .CPU_I_PRESENT                        (l_subsys_cfg_tcm1_cpu_i_present    ),
      .CPU_D_PRESENT                        (l_subsys_cfg_tcm1_cpu_d_present    ),
      .USE_RAM_PARITY_BITS                  (l_subsys_cfg_tcm1_use_ram_parity_bits),
      .RAM_SB_IN_WIDTH                      (RAM_SB_IN_WIDTH  ),
      .RAM_SB_OUT_WIDTH                     (RAM_SB_OUT_WIDTH ),
	  .RAM_DEPTH                            (TCM1_DEPTH),
	  .ECC_ENABLE                           (ECC_ENABLE),
      .ROM                                  (1),
      .BOOTROM_SRC_START_ADDR               (BOOTROM_SRC_START_ADDR),
      .BOOTROM_SRC_END_ADDR                 (BOOTROM_SRC_END_ADDR),
      .BOOTROM_DEST_ADDR                    (BOOTROM_DEST_ADDR),
	  .RECONFIG_BOOTROM                     (RECONFIG_BOOTROM),
	  .TCM_REGS								(TCM_REGS)
      
    )
    u_bootrom
    (
      .clk                                  (clk                                 ),
      .resetn                               (subsys_resetn                       ),                                      
      .subsys_parity_en                     (subsys_parity_en_net                ),
      .trx_os_d_rd                          (tcm1_trx_os_d_rd_net                ),
      .trx_os_d_wr                          (tcm1_trx_os_d_wr_net                ),
      .ecc_err_correctable                  (tcm1_ecc_err_correctable_net        ),
      .ecc_err_uncorrectable                (tcm1_ecc_err_uncorrectable_net      ),
      .cpu_i_req_valid                      (tcm1_i_req_valid_net                ),
      .cpu_i_req_ready                      (tcm1_i_req_ready_net                ),
      .cpu_i_req_rd_byte_en                 (tcm1_i_req_rd_byte_en_net           ),
      .cpu_i_req_addr                       (tcm1_i_req_addr_net                 ),
      .cpu_i_req_addr_p                     (tcm1_i_req_addr_p_net               ),
      .cpu_i_resp_valid                     (tcm1_i_resp_valid_net               ),
      .cpu_i_resp_ready                     (tcm1_i_resp_ready_net               ),
      .cpu_i_resp_error                     (tcm1_i_resp_error_net               ),
      .cpu_i_resp_rd_data                   (tcm1_i_resp_rd_data_net             ),
      .cpu_i_resp_rd_data_p                 (tcm1_i_resp_rd_data_p_net           ),
      .cpu_d_req_valid                      (tcm1_d_req_valid_net                ),
      .cpu_d_req_ready                      (tcm1_d_req_ready_net                ),
      .cpu_d_req_rd_byte_en                 (tcm1_d_req_rd_byte_en_net           ),
      .cpu_d_req_wr_byte_en                 (tcm1_d_req_wr_byte_en_net           ),
      .cpu_d_req_read                       (tcm1_d_req_read_net                 ),
      .cpu_d_req_write                      (tcm1_d_req_write_net                ),
      .cpu_d_req_addr                       (tcm1_d_req_addr_net                 ),
      .cpu_d_req_addr_p                     (tcm1_d_req_addr_p_net               ),
      .cpu_d_req_wr_data                    (tcm1_d_req_wr_data_net              ),
      .cpu_d_req_wr_data_p                  (tcm1_d_req_wr_data_p_net            ),
      .cpu_d_resp_valid                     (tcm1_d_resp_valid_net               ),
      .cpu_d_resp_ready                     (tcm1_d_resp_ready_net               ),
      .cpu_d_resp_error                     (tcm1_d_resp_error_net               ),
      .cpu_d_resp_rd_data                   (tcm1_d_resp_rd_data_net             ),
      .cpu_d_resp_rd_data_p                 (tcm1_d_resp_rd_data_p_net           ),    
      .udma_req_valid                       (udma_tcm1_req_valid_net             ),
      .udma_req_ready                       (udma_tcm1_req_ready_net             ),
      .udma_req_rd_byte_en                  (udma_tcm1_req_rd_byte_en_net        ),
      .udma_req_wr_byte_en                  (udma_tcm1_req_wr_byte_en_net        ),
      .udma_req_read                        (udma_tcm1_req_read_net              ),
      .udma_req_write                       (udma_tcm1_req_write_net             ),
      .udma_req_addr                        (udma_tcm1_req_addr_net              ),
      .udma_req_addr_p                      (udma_tcm1_req_addr_p_net            ),
      .udma_req_len                         (udma_tcm1_req_len_net               ),
      .udma_req_wr_data                     (udma_tcm1_req_wr_data_net           ),
      .udma_req_wr_data_p                   (udma_tcm1_req_wr_data_p_net         ),
      .udma_resp_valid                      (udma_tcm1_resp_valid_net            ),
      .udma_resp_ready                      (udma_tcm1_resp_ready_net            ),
      .udma_resp_rd_error                   (udma_tcm1_resp_rd_error_net         ),
      .udma_resp_rd_data                    (udma_tcm1_resp_rd_data_net          ),
      .udma_resp_rd_data_p                  (udma_tcm1_resp_rd_data_p_net        ), 
      .tcm_tas_access_disable              (tcm1_tas_access_disable             ),
      .tcm_cpu_access_disable              (tcm1_cpu_access_disable             ),
      .tcm_dma_access_disable              (tcm1_dma_access_disable             ),
      .tcm_tas_req_valid                   (tcm1_tas_req_valid_net              ),
      .tcm_tas_req_ready                   (tcm1_tas_req_ready_net              ),
      .tcm_tas_req_rd_byte_en              (tcm1_tas_req_rd_byte_en_net         ),
      .tcm_tas_req_wr_byte_en              (tcm1_tas_req_wr_byte_en_net         ),
      .tcm_tas_req_addr                    (tcm1_tas_req_addr_net               ),
      .tcm_tas_req_addr_p                  (tcm1_tas_req_addr_p_net             ),
      .tcm_tas_req_wr_data                 (tcm1_tas_req_wr_data_net            ),
      .tcm_tas_req_wr_data_p               (tcm1_tas_req_wr_data_p_net          ),
      .tcm_tas_resp_valid                  (tcm1_tas_resp_valid_net             ),
      .tcm_tas_resp_ready                  (tcm1_tas_resp_ready_net             ),
      .tcm_tas_resp_rd_error               (tcm1_tas_resp_rd_error_net          ),
      .tcm_tas_resp_rd_data                (tcm1_tas_resp_rd_data_net           ),
      .tcm_tas_resp_rd_data_p              (tcm1_tas_resp_rd_data_p_net         ),
      .tcm_ram_sb_out                      (tcm1_ram_sb_out                     ), 
      .tcm_ram_sb_in                       (tcm1_ram_sb_in                      ) 
      
    );
  end
  else begin : ngen_tcm1 
    assign tcm1_i_req_ready_net           = 1'b0;  
    assign tcm1_i_resp_valid_net          = 1'b0;  
    assign tcm1_i_resp_error_net          = 1'b0;  
    assign tcm1_i_resp_rd_data_net        = {32{1'b0}}; 
    assign tcm1_i_resp_rd_data_p_net      = {4{1'b0}};
    assign tcm1_d_req_ready_net           = 1'b0;  
    assign tcm1_d_resp_valid_net          = 1'b0;  
    assign tcm1_d_resp_error_net          = 1'b0;  
    assign tcm1_d_resp_rd_data_net        = {32{1'b0}}; 
    assign tcm1_d_resp_rd_data_p_net      = {4{1'b0}};
    assign udma_tcm1_req_ready_net        = 1'b0;              
    assign udma_tcm1_resp_valid_net       = 1'b0;              
    assign udma_tcm1_resp_rd_error_net    = 1'b0;              
    assign udma_tcm1_resp_rd_data_net     = {32{1'b0}};        
    assign udma_tcm1_resp_rd_data_p_net   = {4{1'b0}};
    assign tcm1_tas_req_ready_net         = 1'b0;       
    assign tcm1_tas_resp_valid_net        = 1'b0;       
    assign tcm1_tas_resp_rd_error_net     = 1'b0;       
    assign tcm1_tas_resp_rd_data_net      = {32{1'b0}}; 
    assign tcm1_tas_resp_rd_data_p_net    = {4{1'b0}};      
    assign tcm1_trx_os_d_rd_net           = 1'b0;
    assign tcm1_trx_os_d_wr_net           = 1'b0;
    assign tcm1_ecc_err_correctable_net   = 1'b0;
    assign tcm1_ecc_err_uncorrectable_net = 1'b0;    
    assign tcm1_ram_sb_out                = {RAM_SB_OUT_WIDTH{1'b0}};
  end   
  endgenerate

// AXI Initiator
//--------------------------------------------

  generate
  if(l_subsys_cfg_axi_present) begin: gen_axi
    miv_rv32_subsys_axi_initiator
    #( 
      .AXI_ADDR_WIDTH                  (AXI_ADDR_WIDTH                  ),
	  .ICACHE_EN                            (ICACHE_EN                            ),
	  .ICACHE_BURST_SIZE                    (l_subsys_icache_burst_size           )
    )
    u_subsys_axi_0
    (
      .clk                              (clk                                  ),
      .resetn                           (subsys_resetn                        ), 
      .axi_rd_cfg_min_size              (axi_rd_cfg_min_size_net              ),
      .axi_wr_cfg_min_size              (axi_wr_cfg_min_size_net              ),
      .subsys_parity_en                 (subsys_parity_en_net                 ),
      .cfg_fence_all_src                (cfg_fence_all_src_net                ),
      .cfg_ar_cache                     (cfg_ar_cache_net                     ),
      .cfg_aw_cache                     (cfg_aw_cache_net                     ),
      .cfg_raw_hzd_check                (cfg_raw_hzd_check_net                ),
      .cfg_war_hzd_check                (cfg_war_hzd_check_net                ),
      .trx_os_d_rd                      (axi_trx_os_d_rd_net             ),
      .trx_os_d_wr                      (axi_trx_os_d_wr_net             ),
      .cpu_i_req_valid                  (axi_i_req_valid_net             ),
      .cpu_i_req_ready                  (axi_i_req_ready_net             ),
      .cpu_i_req_rd_byte_en             (axi_i_req_rd_byte_en_net        ),
      .cpu_i_req_addr                   (axi_i_req_addr_net              ),
      .cpu_i_req_addr_p                 (axi_i_req_addr_p_net            ),
      .cpu_i_resp_valid                 (axi_i_resp_valid_net            ),
	  .cpu_i_resp_last                  (axi_i_resp_last_net             ),
      .cpu_i_resp_ready                 (axi_i_resp_ready_net            ),
      .cpu_i_resp_error                 (axi_i_resp_error_net            ),
      .cpu_i_resp_rd_data               (axi_i_resp_rd_data_net          ),
      .cpu_i_resp_rd_data_p             (axi_i_resp_rd_data_p_net        ),
      .cpu_d_req_valid                  (axi_d_req_valid_net             ),
      .cpu_d_req_ready                  (axi_d_req_ready_net             ),
      .cpu_d_req_rd_byte_en             (axi_d_req_rd_byte_en_net        ),
      .cpu_d_req_wr_byte_en             (axi_d_req_wr_byte_en_net        ),
      .cpu_d_req_read                   (axi_d_req_read_net              ),
      .cpu_d_req_write                  (axi_d_req_write_net             ),
      .cpu_d_req_addr                   (axi_d_req_addr_net              ),
      .cpu_d_req_addr_p                 (axi_d_req_addr_p_net            ),
      .cpu_d_req_wr_data                (axi_d_req_wr_data_net           ),
      .cpu_d_req_wr_data_p              (axi_d_req_wr_data_p_net         ),
      .cpu_d_resp_valid                 (axi_d_resp_valid_net            ),
      .cpu_d_resp_ready                 (axi_d_resp_ready_net            ),
      .cpu_d_resp_rd_error              (axi_d_resp_rd_error_net         ),
      .cpu_d_resp_rd_data               (axi_d_resp_rd_data_net          ),
      .cpu_d_resp_rd_data_p             (axi_d_resp_rd_data_p_net        ),
      .cpu_d_wr_resp_err                (axi_d_wr_resp_err_net           ),
      .udma_req_valid                   (udma_axi_req_valid_net               ),
      .udma_req_ready                   (udma_axi_req_ready_net               ),
      .udma_req_rd_byte_en              (udma_axi_req_rd_byte_en_net          ),
      .udma_req_wr_byte_en              (udma_axi_req_wr_byte_en_net          ),
      .udma_req_read                    (udma_axi_req_read_net                ),
      .udma_req_write                   (udma_axi_req_write_net               ),
      .udma_req_addr                    (udma_axi_req_addr_net                ),
      .udma_req_addr_p                  (udma_axi_req_addr_p_net              ),
      .udma_req_len                     (udma_axi_req_len_net                 ),
      .udma_req_wr_data                 (udma_axi_req_wr_data_net             ),
      .udma_req_wr_data_p               (udma_axi_req_wr_data_p_net           ),
      .udma_req_wr_data_last            (udma_axi_req_wr_data_last_net        ),
      .udma_resp_valid                  (udma_axi_resp_valid_net              ),
      .udma_resp_last                   (udma_axi_resp_last_net               ),
      .udma_resp_ready                  (udma_axi_resp_ready_net              ),
      .udma_resp_rd_error               (udma_axi_resp_rd_error_net           ),
      .udma_resp_rd_data                (udma_axi_resp_rd_data_net            ),
      .udma_resp_rd_data_p              (udma_axi_resp_rd_data_p_net          ),
      .udma_wr_resp_err                 (udma_axi_wr_resp_err_net             ),
      .aclk_en                          (1'b1                                 ),
      .axi_arid                         (axi_arid                        ),
      .axi_araddr                       (axi_araddr                      ),
      .axi_arlen                        (axi_arlen                       ),
      .axi_arsize                       (axi_arsize                      ),
      .axi_arburst                      (axi_arburst                     ),
      .axi_arlock                       (axi_arlock                      ),
      .axi_arcache                      (axi_arcache                     ),
      .axi_arprot                       (axi_arprot                      ),
      .axi_arready                      (axi_arready                     ),
      .axi_arvalid                      (axi_arvalid                     ),
      .axi_ar_addr_p                    (axi_ar_addr_p                   ),
      .axi_rresp                        (axi_rresp                       ),
      .axi_rdata                        (axi_rdata                       ),
      .axi_rlast                        (axi_rlast                       ),
      .axi_rid                          (axi_rid                         ),
      .axi_rready                       (axi_rready                      ),
      .axi_rvalid                       (axi_rvalid                      ),
      .axi_r_data_p                     (axi_r_data_p                    ),
      .axi_awid                         (axi_awid                        ),
      .axi_awaddr                       (axi_awaddr                      ),
      .axi_awlen                        (axi_awlen                       ),
      .axi_awsize                       (axi_awsize                      ),
      .axi_awburst                      (axi_awburst                     ),
      .axi_awlock                       (axi_awlock                      ),
      .axi_awcache                      (axi_awcache                     ),
      .axi_awprot                       (axi_awprot                      ),
      .axi_aw_addr_p                    (axi_aw_addr_p                   ),
      .axi_awready                      (axi_awready                     ),
      .axi_awvalid                      (axi_awvalid                     ),
      .axi_wdata                        (axi_wdata                       ),
      .axi_wstrb                        (axi_wstrb                       ),
      .axi_wlast                        (axi_wlast                       ),
      .axi_wid                          (axi_wid                         ),
      .axi_wready                       (axi_wready                      ),
      .axi_wvalid                       (axi_wvalid                      ),
      .axi_w_data_p                     (axi_w_data_p                    ),
      .axi_bresp                        (axi_bresp                       ),
      .axi_bid                          (axi_bid                         ),
      .axi_bready                       (axi_bready                      ),
      .axi_bvalid                       (axi_bvalid                      )
    );
  end
  else begin : ngen_axi 
               
    assign axi_i_req_ready_net          = 1'b0;
    assign axi_i_resp_valid_net         = 1'b0;
    assign axi_i_resp_last_net          = 1'b0;
    assign axi_i_resp_error_net         = 1'b0;
    assign axi_i_resp_rd_data_net       = {32{1'b0}};
    assign axi_i_resp_rd_data_p_net     = {4{1'b0}};
    assign axi_d_req_ready_net          = 1'b0;
    assign axi_d_resp_valid_net         = 1'b0; 
    assign axi_d_resp_rd_error_net      = 1'b0;
    assign axi_d_resp_rd_data_net       = {32{1'b0}};
    assign axi_d_resp_rd_data_p_net     = {4{1'b0}};   
    assign axi_d_wr_resp_err_net        = 1'b0; 
    assign udma_axi_req_ready_net            = 1'b0;
    assign udma_axi_resp_valid_net           = 1'b0; 
    assign udma_axi_resp_last_net            = 1'b0;
    assign udma_axi_resp_rd_error_net        = 1'b0;
    assign udma_axi_resp_rd_data_net         = {32{1'b0}};
    assign udma_axi_resp_rd_data_p_net       = {4{1'b0}};    
    assign udma_axi_wr_resp_err_net          = 1'b0;  
    assign axi_arid                     = 1'b0;
    assign axi_araddr                   = {AXI_ADDR_WIDTH{1'b0}};
    assign axi_arlen                    = {4{1'b0}};
    assign axi_arsize                   = {3{1'b0}};
    assign axi_arburst                  = {2{1'b0}};
    assign axi_arlock                   = 1'b0;
    assign axi_arcache                  = {4{1'b0}};
    assign axi_arprot                   = {3{1'b0}};
    assign axi_arvalid                  = 1'b0;
    assign axi_ar_addr_p                = 1'b0;
    assign axi_rready                   = 1'b0;
    assign axi_awid                     = 1'b0;
    assign axi_awaddr                   = {AXI_ADDR_WIDTH{1'b0}};
    assign axi_awlen                    = {4{1'b0}};
    assign axi_awsize                   = {3{1'b0}};
    assign axi_awburst                  = {2{1'b0}};
    assign axi_awlock                   = 1'b0;
    assign axi_awcache                  = {4{1'b0}};
    assign axi_awprot                   = {3{1'b0}};
    assign axi_aw_addr_p                = 1'b0;
    assign axi_awvalid                  = 1'b0;
    assign axi_wdata                    = {32{1'b0}};
    assign axi_wstrb                    = {4{1'b0}};
    assign axi_wlast                    = 1'b0;
    assign axi_wid                      = 1'b0;
    assign axi_wvalid                   = 1'b0;
    assign axi_w_data_p                 = {4{1'b0}};
    assign axi_bready                   = 1'b0;
    assign axi_trx_os_d_rd_net          = 1'b0;
    assign axi_trx_os_d_wr_net          = 1'b0;
    
  end   
  endgenerate

// AHB Initiator
//--------------------------------------------

  generate
  if(l_subsys_cfg_ahb_present) begin: gen_ahb
    miv_rv32_subsys_ahb_initiator
    #( 
      .AHB_ADDR_WIDTH                  (AHB_ADDR_WIDTH                  ),
	  .ICACHE_EN                            (ICACHE_EN                            ),
	  .ICACHE_BURST_SIZE                    (l_subsys_icache_burst_size            )
    )
    u_subsys_ahb_0
    (
      .clk                                  (clk                             ),
      .resetn                               (subsys_resetn                   ),                                      
      .subsys_parity_en                     (subsys_parity_en_net            ),
      .trx_os_d_rd                          (ahb_trx_os_d_rd_net             ),
      .trx_os_d_wr                          (ahb_trx_os_d_wr_net             ),
      .cpu_i_req_valid                      (ahb_i_req_valid_net             ),
      .cpu_i_req_ready                      (ahb_i_req_ready_net             ),
      .cpu_i_req_rd_byte_en                 (ahb_i_req_rd_byte_en_net        ),
      .cpu_i_req_addr                       (ahb_i_req_addr_net              ),
      .cpu_i_req_addr_p                     (ahb_i_req_addr_p_net            ),
      .cpu_i_resp_valid                     (ahb_i_resp_valid_net            ),
      .cpu_i_resp_last                      (ahb_i_resp_last_net             ),
      .cpu_i_resp_ready                     (ahb_i_resp_ready_net            ),
      .cpu_i_resp_error                     (ahb_i_resp_error_net            ),
      .cpu_i_resp_rd_data                   (ahb_i_resp_rd_data_net          ),
      .cpu_i_resp_rd_data_p                 (ahb_i_resp_rd_data_p_net        ),
      .cpu_d_req_valid                      (ahb_d_req_valid_net             ),
      .cpu_d_req_ready                      (ahb_d_req_ready_net             ),
      .cpu_d_req_rd_byte_en                 (ahb_d_req_rd_byte_en_net        ),
      .cpu_d_req_wr_byte_en                 (ahb_d_req_wr_byte_en_net        ),
      .cpu_d_req_read                       (ahb_d_req_read_net              ),
      .cpu_d_req_write                      (ahb_d_req_write_net             ),
      .cpu_d_req_addr                       (ahb_d_req_addr_net              ),
      .cpu_d_req_addr_p                     (ahb_d_req_addr_p_net            ),
      .cpu_d_req_wr_data                    (ahb_d_req_wr_data_net           ),
      .cpu_d_req_wr_data_p                  (ahb_d_req_wr_data_p_net         ),
      .cpu_d_resp_valid                     (ahb_d_resp_valid_net            ),
      .cpu_d_resp_ready                     (ahb_d_resp_ready_net            ),
      .cpu_d_resp_rd_error                  (ahb_d_resp_rd_error_net         ),
      .cpu_d_resp_rd_data                   (ahb_d_resp_rd_data_net          ),
      .cpu_d_resp_rd_data_p                 (ahb_d_resp_rd_data_p_net        ),
      .udma_req_valid                       (udma_ahb_req_valid_net               ),
      .udma_req_ready                       (udma_ahb_req_ready_net               ),
      .udma_req_rd_byte_en                  (udma_ahb_req_rd_byte_en_net          ),
      .udma_req_wr_byte_en                  (udma_ahb_req_wr_byte_en_net          ),
      .udma_req_read                        (udma_ahb_req_read_net                ),
      .udma_req_write                       (udma_ahb_req_write_net               ),
      .udma_req_addr                        (udma_ahb_req_addr_net                ),
      .udma_req_addr_p                      (udma_ahb_req_addr_p_net              ),
      .udma_req_len                         (udma_ahb_req_len_net                 ),
      .udma_req_wr_data                     (udma_ahb_req_wr_data_net             ),
      .udma_req_wr_data_p                   (udma_ahb_req_wr_data_p_net           ),
      .udma_req_wr_data_last                (udma_ahb_req_wr_data_last_net        ),
      .udma_resp_valid                      (udma_ahb_resp_valid_net              ),
      .udma_resp_last                       (udma_ahb_resp_last_net               ),
      .udma_resp_ready                      (udma_ahb_resp_ready_net              ),
      .udma_resp_rd_error                   (udma_ahb_resp_rd_error_net           ),
      .udma_resp_rd_data                    (udma_ahb_resp_rd_data_net            ),
      .udma_resp_rd_data_p                  (udma_ahb_resp_rd_data_p_net          ),
      .haddr                                (ahb_haddr                       ),
      .haddr_p                              (ahb_haddr_p                     ),
      .hburst                               (ahb_hburst                      ),
      .hmastlock                            (ahb_hmastlock                   ),
      .hprot                                (ahb_hprot                       ),
      .hsize                                (ahb_hsize                       ),
      .htrans                               (ahb_htrans                      ),
      .hwdata                               (ahb_hwdata                      ),
      .hwdata_p                             (ahb_hwdata_p                    ),
      .hwrite                               (ahb_hwrite                      ),
      .hrdata                               (ahb_hrdata                      ),
      .hrdata_p                             (ahb_hrdata_p                    ),
      .hready                               (ahb_hready                      ),
      .hresp                                (ahb_hresp                       )
    );
  end
  else begin : ngen_ahb 
  
    assign ahb_i_req_ready_net          = 1'b0;
    assign ahb_i_resp_valid_net         = 1'b0;
    assign ahb_i_resp_error_net         = 1'b0;
    assign ahb_i_resp_rd_data_net       = {32{1'b0}};
    assign ahb_i_resp_rd_data_p_net     = {4{1'b0}};
    assign ahb_d_req_ready_net          = 1'b0;
    assign ahb_d_resp_valid_net         = 1'b0; 
    assign ahb_d_resp_rd_error_net      = 1'b0;
    assign ahb_d_resp_rd_data_net       = {32{1'b0}};
    assign ahb_d_resp_rd_data_p_net     = {4{1'b0}};    
    assign udma_ahb_req_ready_net            = 1'b0;
    assign udma_ahb_resp_valid_net           = 1'b0; 
    assign udma_ahb_resp_last_net            = 1'b0;
    assign udma_ahb_resp_rd_error_net        = 1'b0;
    assign udma_ahb_resp_rd_data_net         = {32{1'b0}};
    assign udma_ahb_resp_rd_data_p_net       = {4{1'b0}};      
    assign ahb_haddr                    = {AHB_ADDR_WIDTH{1'b0}}; 
    assign ahb_haddr_p                  = 1'b0;
    assign ahb_hburst                   = {3{1'b0}}; 
    assign ahb_hmastlock                = 1'b0;
    assign ahb_hprot                    = {4{1'b0}}; 
    assign ahb_hsize                    = {3{1'b0}}; 
    assign ahb_htrans                   = {2{1'b0}}; 
    assign ahb_hwdata                   = {32{1'b0}}; 
    assign ahb_hwdata_p                 = {4{1'b0}}; 
    assign ahb_hwrite                   = 1'b0;
    assign ahb_trx_os_d_rd_net          = 1'b0;
    assign ahb_trx_os_d_wr_net          = 1'b0;
    
  end   
  endgenerate                   

// uDMA
//--------------------------------------------

generate
  if(l_subsys_cfg_udma_present) begin: gen_udma
    miv_rv32_subsys_udma
    #( 
      .AXI_ADDR_WIDTH                      (AXI_ADDR_WIDTH                       ),
      .AHB_ADDR_WIDTH                      (AHB_ADDR_WIDTH                       ),
      .UDMA_CTRL_ADDR_WIDTH                (l_subsys_cfg_udma_ctrl_addr_width    ),
      .TCM0_ADDR_WIDTH                     (l_subsys_cfg_tcm0_addr_width         ),
      .TCM1_ADDR_WIDTH                     (l_subsys_cfg_tcm1_addr_width         )
    )
    u_subsys_udma_0
    (
      .clk                                  (clk                                  ),
      .resetn                               (subsys_resetn                        ), 
      .subsys_parity_en                     (subsys_parity_en_net                 ),
      .trx_os_d_rd                          (udma_trx_os_d_rd_net                 ),
      .trx_os_d_wr                          (udma_trx_os_d_wr_net                 ),
      .cpu_udma_ctrl_req_valid              (cpu_udma_ctrl_req_valid_net          ),
      .cpu_udma_ctrl_req_ready              (cpu_udma_ctrl_req_ready_net          ),
      .cpu_udma_ctrl_req_rd_byte_en         (cpu_udma_ctrl_req_rd_byte_en_net     ),
      .cpu_udma_ctrl_req_wr_byte_en         (cpu_udma_ctrl_req_wr_byte_en_net     ),
      .cpu_udma_ctrl_req_read               (cpu_udma_ctrl_req_read_net           ),
      .cpu_udma_ctrl_req_write              (cpu_udma_ctrl_req_write_net          ),
      .cpu_udma_ctrl_req_addr               (cpu_udma_ctrl_req_addr_net           ),
      .cpu_udma_ctrl_req_addr_p             (cpu_udma_ctrl_req_addr_p_net         ),
      .cpu_udma_ctrl_req_wr_data            (cpu_udma_ctrl_req_wr_data_net        ),
      .cpu_udma_ctrl_req_wr_data_p          (cpu_udma_ctrl_req_wr_data_p_net      ),
      .cpu_udma_ctrl_resp_valid             (cpu_udma_ctrl_resp_valid_net         ),
      .cpu_udma_ctrl_resp_ready             (cpu_udma_ctrl_resp_ready_net         ),
      .cpu_udma_ctrl_resp_error             (cpu_udma_ctrl_resp_error_net         ),
      .cpu_udma_ctrl_resp_rd_data           (cpu_udma_ctrl_resp_rd_data_net       ),
      .cpu_udma_ctrl_resp_rd_data_p         (cpu_udma_ctrl_resp_rd_data_p_net     ),
      .cpu_udma_ctrl_irq                    (cpu_udma_ctrl_irq_net                ),
      .udma_tcm0_req_valid                 (udma_tcm0_req_valid_net             ),
      .udma_tcm0_req_ready                 (udma_tcm0_req_ready_net             ),
      .udma_tcm0_req_rd_byte_en            (udma_tcm0_req_rd_byte_en_net        ),
      .udma_tcm0_req_wr_byte_en            (udma_tcm0_req_wr_byte_en_net        ),
      .udma_tcm0_req_read                  (udma_tcm0_req_read_net              ),
      .udma_tcm0_req_write                  (udma_tcm0_req_write_net             ),
      .udma_tcm0_req_addr                  (udma_tcm0_req_addr_net              ),
      .udma_tcm0_req_addr_p                (udma_tcm0_req_addr_p_net            ),
      .udma_tcm0_req_len                   (udma_tcm0_req_len_net               ),
      .udma_tcm0_req_wr_data               (udma_tcm0_req_wr_data_net           ),
      .udma_tcm0_req_wr_data_p             (udma_tcm0_req_wr_data_p_net         ),
      .udma_tcm0_resp_valid                (udma_tcm0_resp_valid_net            ),
      .udma_tcm0_resp_ready                (udma_tcm0_resp_ready_net            ),
      .udma_tcm0_resp_rd_error             (udma_tcm0_resp_rd_error_net         ),
      .udma_tcm0_resp_rd_data              (udma_tcm0_resp_rd_data_net          ),
      .udma_tcm0_resp_rd_data_p            (udma_tcm0_resp_rd_data_p_net        ),
      .udma_tcm1_req_valid                 (udma_tcm1_req_valid_net             ),
      .udma_tcm1_req_ready                 (udma_tcm1_req_ready_net             ),
      .udma_tcm1_req_rd_byte_en            (udma_tcm1_req_rd_byte_en_net        ),
      .udma_tcm1_req_wr_byte_en            (udma_tcm1_req_wr_byte_en_net        ),
      .udma_tcm1_req_read                  (udma_tcm1_req_read_net              ),
      .udma_tcm1_req_write                 (udma_tcm1_req_write_net             ),
      .udma_tcm1_req_addr                  (udma_tcm1_req_addr_net              ),
      .udma_tcm1_req_addr_p                (udma_tcm1_req_addr_p_net            ),
      .udma_tcm1_req_len                   (udma_tcm1_req_len_net               ),
      .udma_tcm1_req_wr_data               (udma_tcm1_req_wr_data_net           ),
      .udma_tcm1_req_wr_data_p             (udma_tcm1_req_wr_data_p_net         ),
      .udma_tcm1_resp_valid                (udma_tcm1_resp_valid_net            ),
      .udma_tcm1_resp_ready                (udma_tcm1_resp_ready_net            ),
      .udma_tcm1_resp_rd_error             (udma_tcm1_resp_rd_error_net         ),
      .udma_tcm1_resp_rd_data              (udma_tcm1_resp_rd_data_net          ),
      .udma_tcm1_resp_rd_data_p            (udma_tcm1_resp_rd_data_p_net        ),
      .udma_axi_req_valid                   (udma_axi_req_valid_net               ),
      .udma_axi_req_ready                   (udma_axi_req_ready_net               ),
      .udma_axi_req_rd_byte_en              (udma_axi_req_rd_byte_en_net          ),
      .udma_axi_req_wr_byte_en              (udma_axi_req_wr_byte_en_net          ),
      .udma_axi_req_read                    (udma_axi_req_read_net                ),
      .udma_axi_req_write                   (udma_axi_req_write_net               ),
      .udma_axi_req_addr                    (udma_axi_req_addr_net                ),
      .udma_axi_req_addr_p                  (udma_axi_req_addr_p_net              ),
      .udma_axi_req_len                     (udma_axi_req_len_net                 ),
      .udma_axi_req_wr_data                 (udma_axi_req_wr_data_net             ),
      .udma_axi_req_wr_data_p               (udma_axi_req_wr_data_p_net           ),
      .udma_axi_req_wr_data_last            (udma_axi_req_wr_data_last_net        ),
      .udma_axi_resp_valid                  (udma_axi_resp_valid_net              ),
      .udma_axi_resp_last                   (udma_axi_resp_last_net               ),
      .udma_axi_resp_ready                  (udma_axi_resp_ready_net              ),
      .udma_axi_resp_rd_error               (udma_axi_resp_rd_error_net           ),
      .udma_axi_resp_rd_data                (udma_axi_resp_rd_data_net            ),
      .udma_axi_resp_rd_data_p              (udma_axi_resp_rd_data_p_net          ),     
      .udma_axi_wr_resp_err                 (udma_axi_wr_resp_err_net             ),
      .udma_ahb_req_valid                   (udma_ahb_req_valid_net               ),
      .udma_ahb_req_ready                   (udma_ahb_req_ready_net               ),
      .udma_ahb_req_rd_byte_en              (udma_ahb_req_rd_byte_en_net          ),
      .udma_ahb_req_wr_byte_en              (udma_ahb_req_wr_byte_en_net          ),
      .udma_ahb_req_read                    (udma_ahb_req_read_net                ),
      .udma_ahb_req_write                   (udma_ahb_req_write_net               ),
      .udma_ahb_req_addr                    (udma_ahb_req_addr_net                ),
      .udma_ahb_req_addr_p                  (udma_ahb_req_addr_p_net              ),
      .udma_ahb_req_len                     (udma_ahb_req_len_net                 ),
      .udma_ahb_req_wr_data                 (udma_ahb_req_wr_data_net             ),
      .udma_ahb_req_wr_data_p               (udma_ahb_req_wr_data_p_net           ),
      .udma_ahb_req_wr_data_last            (udma_ahb_req_wr_data_last_net        ),
      .udma_ahb_resp_valid                  (udma_ahb_resp_valid_net              ),
      .udma_ahb_resp_last                   (udma_ahb_resp_last_net               ),
      .udma_ahb_resp_ready                  (udma_ahb_resp_ready_net              ),
      .udma_ahb_resp_rd_error               (udma_ahb_resp_rd_error_net           ),
      .udma_ahb_resp_rd_data                (udma_ahb_resp_rd_data_net            ),
      .udma_ahb_resp_rd_data_p              (udma_ahb_resp_rd_data_p_net          ),
      .apb_tas_udma_ctrl_req_valid          (tcm_tas_udma_ctrl_req_valid_net     ),
      .apb_tas_udma_ctrl_req_ready          (tcm_tas_udma_ctrl_req_ready_net     ),
      .apb_tas_udma_ctrl_req_rd_byte_en     (tcm_tas_udma_ctrl_req_rd_byte_en_net),
      .apb_tas_udma_ctrl_req_wr_byte_en     (tcm_tas_udma_ctrl_req_wr_byte_en_net),
      .apb_tas_udma_ctrl_req_addr           (tcm_tas_udma_ctrl_req_addr_net      ),
      .apb_tas_udma_ctrl_req_addr_p         (tcm_tas_udma_ctrl_req_addr_p_net    ),
      .apb_tas_udma_ctrl_req_wr_data        (tcm_tas_udma_ctrl_req_wr_data_net   ),
      .apb_tas_udma_ctrl_req_wr_data_p      (tcm_tas_udma_ctrl_req_wr_data_p_net ),
      .apb_tas_udma_ctrl_resp_valid         (tcm_tas_udma_ctrl_resp_valid_net    ),
      .apb_tas_udma_ctrl_resp_ready         (tcm_tas_udma_ctrl_resp_ready_net    ),
      .apb_tas_udma_ctrl_resp_rd_error      (tcm_tas_udma_ctrl_resp_rd_error_net ),
      .apb_tas_udma_ctrl_resp_rd_data       (tcm_tas_udma_ctrl_resp_rd_data_net  ),
      .apb_tas_udma_ctrl_resp_rd_data_p     (tcm_tas_udma_ctrl_resp_rd_data_p_net),
      .apb_tas_udma_ctrl_irq                (tcm_tas_udma_ctrl_irq               )
    );
  end
  else begin : ngen_udma 
  
    assign cpu_udma_ctrl_req_ready_net              = 1'b0;  
    assign cpu_udma_ctrl_resp_valid_net             = 1'b0;  
    assign cpu_udma_ctrl_resp_error_net             = 1'b0;  
    assign cpu_udma_ctrl_resp_rd_data_net           = {32{1'b0}};
    assign cpu_udma_ctrl_resp_rd_data_p_net         = {4{1'b0}};
    assign cpu_udma_ctrl_irq_net                    = 1'b0;
    assign udma_tcm0_req_valid_net                 = 1'b0;  
    assign udma_tcm0_req_rd_byte_en_net            = {4{1'b0}};
    assign udma_tcm0_req_wr_byte_en_net            = {4{1'b0}};
    assign udma_tcm0_req_read_net                  = 1'b0; 
    assign udma_tcm0_req_write_net                 = 1'b0;  
    assign udma_tcm0_req_addr_net                  = {l_subsys_cfg_tcm0_addr_width{1'b0}};
    assign udma_tcm0_req_addr_p_net                = 1'b0;  
    assign udma_tcm0_req_len_net                   = {4{1'b0}};
    assign udma_tcm0_req_wr_data_net               = {32{1'b0}};
    assign udma_tcm0_req_wr_data_p_net             = {4{1'b0}}; 
    assign udma_tcm0_resp_ready_net                = 1'b0;  
    assign udma_tcm1_req_valid_net                 = 1'b0;  
    assign udma_tcm1_req_rd_byte_en_net            = {4{1'b0}};
    assign udma_tcm1_req_wr_byte_en_net            = {4{1'b0}};
    assign udma_tcm1_req_read_net                  = 1'b0; 
    assign udma_tcm1_req_write_net                 = 1'b0;  
    assign udma_tcm1_req_addr_net                  = {l_subsys_cfg_tcm1_addr_width{1'b0}};
    assign udma_tcm1_req_addr_p_net                = 1'b0;  
    assign udma_tcm1_req_len_net                   = {4{1'b0}};
    assign udma_tcm1_req_wr_data_net               = {32{1'b0}};
    assign udma_tcm1_req_wr_data_p_net             = {4{1'b0}}; 
    assign udma_tcm1_resp_ready_net                = 1'b0;  
    assign udma_axi_req_valid_net                   = 1'b0;  
    assign udma_axi_req_rd_byte_en_net              = {4{1'b0}};
    assign udma_axi_req_wr_byte_en_net              = {4{1'b0}};
    assign udma_axi_req_read_net                    = 1'b0;
    assign udma_axi_req_write_net                   = 1'b0;
    assign udma_axi_req_addr_net                    = {AXI_ADDR_WIDTH{1'b0}};
    assign udma_axi_req_addr_p_net                  = 1'b0;  
    assign udma_axi_req_len_net                     = {4{1'b0}};
    assign udma_axi_req_wr_data_net                 = {32{1'b0}};
    assign udma_axi_req_wr_data_p_net               = {4{1'b0}};
    assign udma_axi_req_wr_data_last_net            = 1'b0;  
    assign udma_axi_resp_ready_net                  = 1'b0;  
    assign udma_ahb_req_valid_net                   = 1'b0;  
    assign udma_ahb_req_rd_byte_en_net              = {4{1'b0}};
    assign udma_ahb_req_wr_byte_en_net              = {4{1'b0}};
    assign udma_ahb_req_read_net                    = 1'b0; 
    assign udma_ahb_req_write_net                   = 1'b0;
    assign udma_ahb_req_addr_net                    = {AHB_ADDR_WIDTH{1'b0}};
    assign udma_ahb_req_addr_p_net                  = 1'b0;  
    assign udma_ahb_req_len_net                     = {4{1'b0}};
    assign udma_ahb_req_wr_data_net                 = {32{1'b0}};
    assign udma_ahb_req_wr_data_p_net               = {4{1'b0}};
    assign udma_ahb_req_wr_data_last_net            = 1'b0;  
    assign udma_ahb_resp_ready_net                  = 1'b0;  
    assign tcm_tas_udma_ctrl_req_ready_net          = 1'b0;  
    assign tcm_tas_udma_ctrl_resp_valid_net         = 1'b0;  
    assign tcm_tas_udma_ctrl_resp_rd_error_net      = 1'b0;  
    assign tcm_tas_udma_ctrl_resp_rd_data_net       = {32{1'b0}};
    assign tcm_tas_udma_ctrl_resp_rd_data_p_net     = {4{1'b0}};
    assign udma_trx_os_d_rd_net                      = 1'b0;
    assign udma_trx_os_d_wr_net                      = 1'b0;
    assign tcm_tas_udma_ctrl_irq                    = 1'b0;
  
  end   
  endgenerate                   


// MTIME
//--------------------------------------------
  
generate
if(INTERNAL_MTIME | INTERNAL_MTIME_IRQ)
  begin : gen_mtime
    assign apb_int_sel     = (apb_paddr[APB_ADDR_WIDTH-1:3] == l_mtime_addr_base[APB_ADDR_WIDTH-1:3]) | 
                                  (apb_paddr[APB_ADDR_WIDTH-1:3] == l_mtimecmp_addr_base[APB_ADDR_WIDTH-1:3]) | 
                                  (apb_paddr[APB_ADDR_WIDTH-1:3] == l_mtime_prescaler_addr[APB_ADDR_WIDTH-1:3]) ? 1'b1 : 1'b0;
  								 
    assign apb_psel        = (apb_int_sel)   ? 1'b0                 : apb_psel_net;
    assign apb_penable     = (apb_int_sel)   ? 1'b0                 : apb_penable_net; 
    assign apb_psel_int    = (apb_int_sel)   ? apb_psel_net    : 1'b0;
    assign apb_penable_int = (apb_int_sel)   ? apb_penable_net : 1'b0; 
    assign apb_pslverr_net = (apb_int_sel)   ? apb_pslverr_int : apb_pslverr;
    assign apb_pready_net  = (apb_int_sel)   ? apb_pready_int  : apb_pready ;
    assign apb_prdata_net  = (apb_int_sel)   ? apb_prdata_int  : apb_prdata ;   
    assign mtime_count_sel      = (INTERNAL_MTIME)     ? mtime_count_int      : mtime_count ;
    assign m_timer_irq_sel      = (INTERNAL_MTIME_IRQ) ? m_timer_irq_int      : m_timer_irq ;
	assign mtime_count_out      = mtime_count_int;
  	
    miv_rv32_subsys_mtime_irq 
      #(
       .INTERNAL_MTIME(INTERNAL_MTIME),
       .INTERNAL_MTIME_IRQ(INTERNAL_MTIME_IRQ),
       .MTIME_PRESCALER(MTIME_PRESCALER)
       ) 
       u_mtime_irq 
       ( 
       .pclk           (clk),     
       .presetn        (subsys_resetn),   
       .penable        (apb_penable_int), 
       .psel           (apb_psel_int),   
       .paddr          (apb_paddr),     
       .pwrite         (apb_pwrite),   
       .pwdata         (apb_pwdata),   
       .prdata         (apb_prdata_int),     
       .pready         (apb_pready_int),     
       .pslverr        (apb_pslverr_int),    
       					  
       .m_timer_stall  (cpu_debug_mode_net),
	   .m_timer_irq    (m_timer_irq_int),   
       .mtime_count_in (mtime_count),
       .mtime_count_out(mtime_count_int)
       );     
    end else begin  : ngen_mtime
	  assign m_timer_irq_int      = 1'b0;
      assign apb_penable_int = 1'b0; 
      assign apb_psel_int    = 1'b0;   
      assign apb_prdata_int  = 32'b0;     
      assign apb_pready_int  = 1'b0;     
      assign apb_pslverr_int = 1'b0; 
      assign apb_int_sel     = 1'b0; 							 
      assign apb_psel        = apb_psel_net;
      assign apb_penable     = apb_penable_net; 
      assign apb_pslverr_net = apb_pslverr;
      assign apb_pready_net  = apb_pready ;
      assign apb_prdata_net  = apb_prdata ;   
      assign mtime_count_sel      = mtime_count ;
      assign m_timer_irq_sel      = m_timer_irq ;
	  assign mtime_count_int      = 64'b0;
	  assign mtime_count_out      = 64'b0;
	end
endgenerate	


	
//////////////////////////////////////////////////////////////////////////////////////////////
  //--------------------------------------------------------
  // uInstruction Cache Unit
  //--------------------------------------------------------

  generate
  if (ICACHE_EN) begin : gen_icache
      assign ifu_emi_req_addr_c_sel   = ((ifu_emi_req_valid_c & ifu_emi_resp_ready_c)) ? ifu_emi_req_addr_c: ifu_emi_req_addr_c_reg;
      assign cpu_i_req_is_ahb    = l_subsys_cfg_ahb_present ? (ifu_emi_req_addr_c_sel[CPU_ADDR_WIDTH-1:12] >= l_ahb_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                                                       (ifu_emi_req_addr_c_sel[CPU_ADDR_WIDTH-1:12] <= l_ahb_end_addr[CPU_ADDR_WIDTH-1:12]) : 1'b0;  
      assign cpu_i_req_is_axi    = l_subsys_cfg_axi_present ? (ifu_emi_req_addr_c_sel[CPU_ADDR_WIDTH-1:12] >= l_axi_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                                                       (ifu_emi_req_addr_c_sel[CPU_ADDR_WIDTH-1:12] <= l_axi_end_addr[CPU_ADDR_WIDTH-1:12]) : 1'b0;  

      assign cpu_i_req_ready_net      = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_req_ready_sel      : 1'b0;   
      assign cpu_i_resp_valid_net     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_resp_valid_sel     : 1'b0;    
      assign cpu_i_resp_error_net     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_resp_error_sel     : 1'b0;
      assign cpu_i_resp_rd_data_net   = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_resp_rd_data_sel   : 32'b0;
      assign cpu_i_resp_rd_data_p_net = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_resp_rd_data_p_sel : 4'b0;
      
      assign cpu_i_req_valid_sel      = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_req_valid_net      : ifu_emi_req_valid_c;       
      assign cpu_i_req_rd_byte_en_sel = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_req_rd_byte_en_net : ifu_emi_req_rd_byte_en_c;
      assign cpu_i_req_addr_sel       = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_req_addr_net       : ifu_emi_req_addr_c;
      assign cpu_i_req_addr_p_sel     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_req_addr_p_net     : ifu_emi_req_addr_p_c;    
      assign cpu_i_resp_ready_sel     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? cpu_i_resp_ready_net     : ifu_emi_resp_ready_c;    
             
      assign ifu_emi_req_ready_c      = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_req_ready_i      : cpu_i_req_ready_sel;            
      assign ifu_emi_resp_valid_c     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_resp_valid_i     : cpu_i_resp_valid_sel;         
      assign ifu_emi_resp_rd_data_c   = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_resp_rd_data_i   : cpu_i_resp_rd_data_sel;
      assign ifu_emi_resp_rd_data_p_c = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_resp_rd_data_p_i : cpu_i_resp_rd_data_p_sel;  
      assign ifu_emi_resp_error_c     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_resp_error_i     : cpu_i_resp_error_sel;
      
      assign ifu_emi_req_valid_i      = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_req_valid_c      : 1'b0;
      assign ifu_emi_req_rd_byte_en_i = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_req_rd_byte_en_c : 4'b0;
      assign ifu_emi_req_addr_i       = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_req_addr_c       : 32'b0;      
      assign ifu_emi_req_addr_p_i     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_req_addr_p_c     : 1'b0; 
      assign ifu_emi_resp_ready_i     = (cpu_i_req_is_ahb | cpu_i_req_is_axi) ? ifu_emi_resp_ready_c     : 1'b0; 

      always @(posedge clk or negedge resetn)  // Required for JALR instruction
      begin
        if(!resetn) begin
            ifu_emi_req_addr_c_reg <= 32'b0;
    	end else begin
            ifu_emi_req_addr_c_reg <= ifu_emi_req_addr_c;
        end
      end

      miv_rv32_subsys_icache 
      #(
      .SYNC_RESET         (0), 
      .ICACHE_DEPTH       (ICACHE_DEPTH),   
      .ICACHE_ADDR_WIDTH  (32),
      .ICACHE_DATA_WIDTH  (32),
      .ICACHE_BURST_SIZE  (l_subsys_icache_burst_size),
	  .ECC_ENABLE         (ECC_ENABLE),
	  .I_REGS             (I_REGS)
      )
      u_uicache_0
      (         				
        .clk                              (clk                             ),
        .resetn                           (subsys_resetn                   ), 
        .parity_en                        (subsys_parity_en_net            ),
        .icache_flush                     (icache_flush                    ),
        .ifu_emi_req_valid                (ifu_emi_req_valid_i & !icache_flush), 
        .ifu_emi_req_ready                (ifu_emi_req_ready_i             ), 
        .ifu_emi_req_rd_byte_en           (ifu_emi_req_rd_byte_en_i        ), 
        .ifu_emi_req_addr                 (ifu_emi_req_addr_i              ), 
        .ifu_emi_req_addr_p               (ifu_emi_req_addr_p_i            ), 
        .ifu_emi_resp_valid               (ifu_emi_resp_valid_i            ), 
        .ifu_emi_resp_ready               (ifu_emi_resp_ready_i            ), 
        .ifu_emi_resp_data                (ifu_emi_resp_rd_data_i          ), 
        .ifu_emi_resp_data_p              (ifu_emi_resp_rd_data_p_i        ), 
        .ifu_emi_resp_error               (ifu_emi_resp_error_i            ), 
									  	   								      		
        .cpu_i_req_valid                  (cpu_i_req_valid_net             ), 
        .cpu_i_req_ready                  (cpu_i_req_ready_net             ), 
        .cpu_i_req_rd_byte_en             (cpu_i_req_rd_byte_en_net        ), 
        .cpu_i_req_addr                   (cpu_i_req_addr_net              ), 
        .cpu_i_req_addr_p                 (cpu_i_req_addr_p_net            ), 
        .cpu_i_resp_valid                 (cpu_i_resp_valid_net            ), 
        .cpu_i_resp_ready                 (cpu_i_resp_ready_net            ), 
        .cpu_i_resp_rd_data               (cpu_i_resp_rd_data_net          ), 
        .cpu_i_resp_rd_data_p             (cpu_i_resp_rd_data_p_net        ), 
        .cpu_i_resp_error                 (cpu_i_resp_error_net            ),
		.icache_ecc_error_injection       (icache_ecc_error_injection      ),
		.icache_ecc_err_correctable       (icache_ecc_err_correctable      ), 
		.icache_ecc_err_uncorrectable     (icache_ecc_err_uncorrectable    ),
		.icache_ram_init_soft_debug_reset (ram_init_soft_debug_reset       ),
		.icache_ram_init_done             (icache_ram_init_done            ),
		.gpr_ram_init_done                (gpr_ram_init_done               )
      );       

  end else begin  : ngen_icache
      assign cpu_i_req_is_ahb    = 1'b0;
      assign cpu_i_req_is_axi    = 1'b0;
	  
      assign cpu_i_req_ready_net      = 1'b0;   
      assign cpu_i_resp_valid_net     = 1'b0;    
      assign cpu_i_resp_error_net     = 1'b0;
      assign cpu_i_resp_rd_data_net   = 32'b0;
      assign cpu_i_resp_rd_data_p_net = 4'b0;
      
      assign cpu_i_req_valid_sel      = ifu_emi_req_valid_c;       
      assign cpu_i_req_rd_byte_en_sel = ifu_emi_req_rd_byte_en_c;
      assign cpu_i_req_addr_sel       = ifu_emi_req_addr_c;
      assign cpu_i_req_addr_p_sel     = ifu_emi_req_addr_p_c;    
      assign cpu_i_resp_ready_sel     = ifu_emi_resp_ready_c;    
             
      assign ifu_emi_req_ready_c      = cpu_i_req_ready_sel;            
      assign ifu_emi_resp_valid_c     = cpu_i_resp_valid_sel;         
      assign ifu_emi_resp_rd_data_c   = cpu_i_resp_rd_data_sel;
      assign ifu_emi_resp_rd_data_p_c = cpu_i_resp_rd_data_p_sel;  
      assign ifu_emi_resp_error_c     = cpu_i_resp_error_sel;
      
      assign ifu_emi_req_valid_i      = 1'b0;  
      assign ifu_emi_req_ready_i      = 1'b0;  
      assign ifu_emi_req_rd_byte_en_i = 4'b0;
      assign ifu_emi_req_addr_i       = 32'b0;      
      assign ifu_emi_req_addr_p_i     = 1'b0; 
      assign ifu_emi_resp_valid_i     = 1'b0; 
      assign ifu_emi_resp_ready_i     = 1'b0;       
      assign ifu_emi_resp_rd_data_i    = 32'b0;      
      assign ifu_emi_resp_rd_data_p_i = 4'b0;      
      assign ifu_emi_resp_error_i     = 1'b0;      
	  
      assign ifu_emi_req_addr_c_reg = 1'b0;
      assign ifu_emi_req_addr_c_sel = 1'b0;
	  
	  assign icache_ram_init_done         = 1'b1;
	  assign icache_ecc_err_correctable   = 1'b0;
	  assign icache_ecc_err_uncorrectable = 1'b0;
  end
  endgenerate


endmodule


`default_nettype wire
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
// SVN $Revision: 43976 $
// SVN $Date: 2023-08-31 14:29:57 +0100 (Thu, 31 Aug 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_interconnect.sv
//
//   Purpose:
//    MIV_RV32 subsystem memory interconnect
//    Connects all memories, initiator interfaces and the CPU hart
//    Also manages ordering/fences, contains SUBSYS configuration, and the dummy target
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_interconnect
//********************************************************************************
// Parameter description

  #(   
    parameter CPU_ADDR_WIDTH            = 32,
    parameter AXI_ADDR_WIDTH            = 32,
    parameter APB_ADDR_WIDTH            = 32,
    parameter AHB_ADDR_WIDTH            = 32,
    parameter UDMA_CTRL_ADDR_WIDTH      = 32, 
    parameter TCM0_ADDR_WIDTH           = 32,
    parameter TCM1_ADDR_WIDTH           = 32,
	parameter ECC_ENABLE                = 0,
	parameter l_subsys_cfg_tcm0_present = 1,
    parameter l_subsys_cfg_tcm1_present = 1, // HB
	parameter l_subsys_cfg_axi_present  = 1,
	parameter l_subsys_cfg_ahb_present  = 1,
	parameter ICACHE_EN                 = 0,
	parameter MI_I_MEM                  = 0,
	parameter l_miv_rv32_version        = 32'h03010064
   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,
    
    // config/control
    output logic [1:0]                           axi_rd_cfg_min_size,
    output logic [1:0]                           axi_wr_cfg_min_size,
    output logic                                 subsys_parity_en,
    input wire  logic                            sys_parity_disable, 
    output logic                                 cfg_fence_all_src,
    output logic [3:0]                           cfg_ar_cache,
    output logic [3:0]                           cfg_aw_cache,  
    output logic                                 cfg_raw_hzd_check,
    output logic                                 cfg_war_hzd_check,
     
    output logic                                 tcm0_uncorrectable_ecc_error,
    output logic                                 tcm1_uncorrectable_ecc_error,
    output logic [1:0]                           subsys_irq,
    
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_axi_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_axi_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_apb_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_apb_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_ahb_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_ahb_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_udma_ctrl_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_udma_ctrl_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_subsys_cfg_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_subsys_cfg_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm0_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm0_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm1_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm1_end_addr,            
    
    // CPU interface    
    input wire  logic                            cpu_i_req_valid,
    output      logic                            cpu_i_req_ready, 
    input wire  logic [3:0]                      cpu_i_req_rd_byte_en,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cpu_i_req_addr,
    input wire  logic                            cpu_i_req_addr_p,
    output      logic                            cpu_i_resp_valid,
    input wire  logic                            cpu_i_resp_ready,
    output      logic                            cpu_i_resp_error,
    output      logic [31:0]                     cpu_i_resp_rd_data, 
    output      logic [3:0]                      cpu_i_resp_rd_data_p,
    input wire  logic                            cpu_d_req_valid,
    output      logic                            cpu_d_req_ready, 
    input wire  logic [3:0]                      cpu_d_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_d_req_wr_byte_en,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cpu_d_req_addr,    
    input wire  logic                            cpu_d_req_addr_p,    
    input wire  logic                            cpu_d_req_fence,
    input wire  logic                            cpu_d_req_read,
    input wire  logic                            cpu_d_req_write,
    input wire  logic [31:0]                     cpu_d_req_wr_data,   
    input wire  logic [3:0]                      cpu_d_req_wr_data_p,
    output      logic                            cpu_d_resp_valid,
    input wire  logic                            cpu_d_resp_ready,
    output      logic                            cpu_d_resp_error,
    output      logic [31:0]                     cpu_d_resp_rd_data,  
    output      logic [3:0]                      cpu_d_resp_rd_data_p,
    
    // Debug unit interface
    input wire  logic                            debug_mode,
    output      logic                            debug_trx_os,
    input wire  logic                            debug_sysbus_req_valid,
    output      logic                            debug_sysbus_req_ready, 
    input wire  logic [3:0]                      debug_sysbus_req_rd_byte_en,  
    input wire  logic [3:0]                      debug_sysbus_req_wr_byte_en,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       debug_sysbus_req_addr,  
    input wire  logic [31:0]                     debug_sysbus_req_wr_data,  
    output      logic                            debug_sysbus_resp_valid,
    input wire  logic                            debug_sysbus_resp_ready,
    output      logic                            debug_sysbus_resp_error,
    output      logic [31:0]                     debug_sysbus_resp_rd_data,  
    
    // APB Initiator interface 
    output      logic                            apb_i_req_valid,
    input wire  logic                            apb_i_req_ready, 
    output      logic [3:0]                      apb_i_req_rd_byte_en,
    output      logic [APB_ADDR_WIDTH-1:0]  apb_i_req_addr,
    output      logic                            apb_i_req_addr_p,
    input wire  logic                            apb_i_resp_valid,
    output      logic                            apb_i_resp_ready,
    input wire  logic                            apb_i_resp_error,
    input wire  logic [31:0]                     apb_i_resp_rd_data, 
    input wire  logic [3:0]                      apb_i_resp_rd_data_p,
    output      logic                            apb_d_req_valid,
    input wire  logic                            apb_d_req_ready, 
    output      logic [3:0]                      apb_d_req_rd_byte_en,  
    output      logic [3:0]                      apb_d_req_wr_byte_en,
    //output      logic                            apb_d_req_read,
    //output      logic                            apb_d_req_write,
    output      logic [APB_ADDR_WIDTH-1:0]  apb_d_req_addr,
    output      logic                            apb_d_req_addr_p,
    output      logic [31:0]                     apb_d_req_wr_data,
    output      logic [3:0]                      apb_d_req_wr_data_p,
    input wire  logic                            apb_d_resp_valid,
    output      logic                            apb_d_resp_ready,
    input wire  logic                            apb_d_resp_error,
    input wire  logic [31:0]                     apb_d_resp_rd_data,   
    input wire  logic [3:0]                      apb_d_resp_rd_data_p,     
    input wire  logic                            apb_trx_os_d_rd,
    input wire  logic                            apb_trx_os_d_wr, 
    
    // Local memory 0 interface
    output      logic                            tcm0_i_req_valid,
    input wire  logic                            tcm0_i_req_ready, 
    output      logic [3:0]                      tcm0_i_req_rd_byte_en, 
    output      logic [TCM0_ADDR_WIDTH-1:0]     tcm0_i_req_addr,
    output      logic                            tcm0_i_req_addr_p,
    input wire  logic                            tcm0_i_resp_valid,
    output      logic                            tcm0_i_resp_ready,
    input wire  logic                            tcm0_i_resp_error,
    input wire  logic [31:0]                     tcm0_i_resp_rd_data, 
    input wire  logic [3:0]                      tcm0_i_resp_rd_data_p, 
    output      logic                            tcm0_d_req_valid,
    input wire  logic                            tcm0_d_req_ready, 
    output      logic [3:0]                      tcm0_d_req_rd_byte_en,   
    output      logic [3:0]                      tcm0_d_req_wr_byte_en,
    output      logic                            tcm0_d_req_read,
    output      logic                            tcm0_d_req_write,
    output      logic [TCM0_ADDR_WIDTH-1:0]     tcm0_d_req_addr,
    output      logic                            tcm0_d_req_addr_p,
    output      logic [31:0]                     tcm0_d_req_wr_data,
    output      logic [3:0]                      tcm0_d_req_wr_data_p,
    input wire  logic                            tcm0_d_resp_valid,
    output      logic                            tcm0_d_resp_ready,
    input wire  logic                            tcm0_d_resp_error,
    input wire  logic [31:0]                     tcm0_d_resp_rd_data, 
    input wire  logic [3:0]                      tcm0_d_resp_rd_data_p,    
    input wire  logic                            tcm0_trx_os_d_rd,
    input wire  logic                            tcm0_trx_os_d_wr, 
    input wire  logic                            tcm0_ecc_err_correctable,  
    input wire  logic                            tcm0_ecc_err_uncorrectable,
    
    // Local memory 1 interface
    output      logic                            tcm1_i_req_valid,
    input wire  logic                            tcm1_i_req_ready, 
    output      logic [3:0]                      tcm1_i_req_rd_byte_en, 
    output      logic [TCM1_ADDR_WIDTH-1:0]     tcm1_i_req_addr,
    output      logic                            tcm1_i_req_addr_p,
    input wire  logic                            tcm1_i_resp_valid,
    output      logic                            tcm1_i_resp_ready,
    input wire  logic                            tcm1_i_resp_error,
    input wire  logic [31:0]                     tcm1_i_resp_rd_data, 
    input wire  logic [3:0]                      tcm1_i_resp_rd_data_p, 
    output      logic                            tcm1_d_req_valid,
    input wire  logic                            tcm1_d_req_ready, 
    output      logic [3:0]                      tcm1_d_req_rd_byte_en,   
    output      logic [3:0]                      tcm1_d_req_wr_byte_en,
    output      logic                            tcm1_d_req_read,
    output      logic                            tcm1_d_req_write,
    output      logic [TCM1_ADDR_WIDTH-1:0]     tcm1_d_req_addr,
    output      logic                            tcm1_d_req_addr_p,
    output      logic [31:0]                     tcm1_d_req_wr_data,
    output      logic [3:0]                      tcm1_d_req_wr_data_p,
    input wire  logic                            tcm1_d_resp_valid,
    output      logic                            tcm1_d_resp_ready,
    input wire  logic                            tcm1_d_resp_error,
    input wire  logic [31:0]                     tcm1_d_resp_rd_data, 
    input wire  logic [3:0]                      tcm1_d_resp_rd_data_p,     
    input wire  logic                            tcm1_trx_os_d_rd,
    input wire  logic                            tcm1_trx_os_d_wr,
    input wire  logic                            tcm1_ecc_err_correctable,  
    input wire  logic                            tcm1_ecc_err_uncorrectable,
    
    // AXI Initiator interface 
    output      logic                            axi_i_req_valid,
    input wire  logic                            axi_i_req_ready, 
    output      logic [3:0]                      axi_i_req_rd_byte_en,  
    output      logic [AXI_ADDR_WIDTH-1:0]  axi_i_req_addr,
    output      logic                            axi_i_req_addr_p,
    input wire  logic                            axi_i_resp_valid,
    input wire  logic                            axi_i_resp_last,
    output      logic                            axi_i_resp_ready,
    input wire  logic                            axi_i_resp_error,
    input wire  logic [31:0]                     axi_i_resp_rd_data, 
    input wire  logic [3:0]                      axi_i_resp_rd_data_p, 
    output      logic                            axi_d_req_valid,
    input wire  logic                            axi_d_req_ready, 
    output      logic [3:0]                      axi_d_req_rd_byte_en,  
    output      logic [3:0]                      axi_d_req_wr_byte_en,
    output      logic                            axi_d_req_read,
    output      logic                            axi_d_req_write,
    output      logic [AXI_ADDR_WIDTH-1:0]  axi_d_req_addr,
    output      logic                            axi_d_req_addr_p,
    output      logic [31:0]                     axi_d_req_wr_data,
    output      logic [3:0]                      axi_d_req_wr_data_p,
    input wire  logic                            axi_d_resp_valid,
    output      logic                            axi_d_resp_ready,
    input wire  logic                            axi_d_resp_rd_error,
    input wire  logic [31:0]                     axi_d_resp_rd_data,  
    input wire  logic [3:0]                      axi_d_resp_rd_data_p,
    input wire  logic                            axi_d_wr_resp_err,   
    input wire  logic                            axi_trx_os_d_rd,
    input wire  logic                            axi_trx_os_d_wr, 
    
    // AHB-Lite Initiator interface 
    output      logic                            ahb_i_req_valid,
    input wire  logic                            ahb_i_req_ready, 
    output      logic [3:0]                      ahb_i_req_rd_byte_en,  
    output      logic [AHB_ADDR_WIDTH-1:0]  ahb_i_req_addr,
    output      logic                            ahb_i_req_addr_p,
    input wire  logic                            ahb_i_resp_valid,
    input wire  logic                            ahb_i_resp_last,
    output      logic                            ahb_i_resp_ready,
    input wire  logic                            ahb_i_resp_error,
    input wire  logic [31:0]                     ahb_i_resp_rd_data, 
    input wire  logic [3:0]                      ahb_i_resp_rd_data_p, 
    output      logic                            ahb_d_req_valid,
    input wire  logic                            ahb_d_req_ready, 
    output      logic [3:0]                      ahb_d_req_rd_byte_en,  
    output      logic [3:0]                      ahb_d_req_wr_byte_en,
    output      logic                            ahb_d_req_read,
    output      logic                            ahb_d_req_write,
    output      logic [AHB_ADDR_WIDTH-1:0]  ahb_d_req_addr,
    output      logic                            ahb_d_req_addr_p,
    output      logic [31:0]                     ahb_d_req_wr_data,
    output      logic [3:0]                      ahb_d_req_wr_data_p,
    input wire  logic                            ahb_d_resp_valid,
    output      logic                            ahb_d_resp_ready,
    input wire  logic                            ahb_d_resp_rd_error,
    input wire  logic [31:0]                     ahb_d_resp_rd_data,  
    input wire  logic [3:0]                      ahb_d_resp_rd_data_p,   
    input wire  logic                            ahb_trx_os_d_rd,
    input wire  logic                            ahb_trx_os_d_wr,  
       
    // uDMA control interface 
    output      logic                            udma_ctrl_d_req_valid,
    input wire  logic                            udma_ctrl_d_req_ready, 
    output      logic [3:0]                      udma_ctrl_d_req_rd_byte_en,  
    output      logic [3:0]                      udma_ctrl_d_req_wr_byte_en,
    output      logic                            udma_ctrl_d_req_read,
    output      logic                            udma_ctrl_d_req_write,
    output      logic [UDMA_CTRL_ADDR_WIDTH-1:0] udma_ctrl_d_req_addr,
    output      logic                            udma_ctrl_d_req_addr_p,
    output      logic [31:0]                     udma_ctrl_d_req_wr_data,
    output      logic [3:0]                      udma_ctrl_d_req_wr_data_p,
    input wire  logic                            udma_ctrl_d_resp_valid,
    output      logic                            udma_ctrl_d_resp_ready,
    input wire  logic                            udma_ctrl_d_resp_error,
    input wire  logic [31:0]                     udma_ctrl_d_resp_rd_data,
    input wire  logic [3:0]                      udma_ctrl_d_resp_rd_data_p,     
    input wire  logic                            udma_ctrl_irq,
    input wire  logic                            udma_trx_os_d_rd,
    input wire  logic                            udma_trx_os_d_wr,
    
    output wire logic                            hart_soft_reset, //hart_soft_reset module output
    output wire logic                            hart_soft_irq,    //hart_soft_irq module output
    
    input wire logic                             gpr_ded_soft_reset, //input to connect gpr ded signal from sumbicron to the interconnect
    input wire logic                             cpu_i_req_is_ahb_in,
    input wire logic                             cpu_i_req_is_axi_in,
	   
    input wire  logic                            icache_ecc_err_correctable,       
    input wire  logic                            icache_ecc_err_uncorrectable,
	
    output      logic [1:0]                      gpr_ecc_error_injection,
    output      logic [1:0]                      tcm_ecc_error_injection,
    output      logic [1:0]                      icache_ecc_error_injection

  );

//********************************************************************************
// Declarations

  typedef enum logic [1:0] {subsys_mem_req_rd,
                            subsys_mem_req_wr,
                            subsys_mem_req_fence,
                            subsys_mem_req_invalid} t_subsys_mem_req;

// localparams
  
  localparam MAX_OS_I_TRX = (MI_I_MEM) ? 1 : 2;
  localparam LOG2_MAX_OS_I_TRX = 1;
  localparam MAX_OS_D_TRX = 2;
  localparam LOG2_MAX_OS_D_TRX = 1;


// Internal nets

  logic                                        cpu_i_req_accepted; 
  logic                                        cpu_i_resp_accepted;
  logic                                        cpu_i_resp_last;

  logic                                        cpu_i_req_is_apb;
  logic                                        cpu_i_req_is_ahb;
  logic                                        cpu_i_req_is_axi;
  logic                                        cpu_i_req_is_tcm0;
  logic                                        cpu_i_req_is_tcm1;
  logic                                        cpu_i_req_is_dummy_target;
  
  logic                                        cpu_i_resp_is_apb;
  logic                                        cpu_i_resp_is_ahb;
  logic                                        cpu_i_resp_is_axi;
  logic                                        cpu_i_resp_is_tcm0;
  logic                                        cpu_i_resp_is_tcm1;
  logic                                        cpu_i_resp_is_dummy_target;
  
  logic                                        cpu_i_req_addr_parity_error;
  logic                                        cpu_d_req_valid_mux;
  logic [3:0]                                  cpu_d_req_rd_byte_en_mux;  
  logic [3:0]                                  cpu_d_req_wr_byte_en_mux;
  logic                                        cpu_d_req_read_mux;  
  logic                                        cpu_d_req_write_mux;
  logic [CPU_ADDR_WIDTH-1:0]                   cpu_d_req_addr_mux;    
  logic                                        cpu_d_req_addr_p_mux;    
  logic                                        cpu_d_req_fence_mux;
  logic [31:0]                                 cpu_d_req_wr_data_mux;   
  logic [3:0]                                  cpu_d_req_wr_data_p_mux;
  logic                                        cpu_d_resp_ready_mux;  
  
  logic                                        cpu_d_req_ready_sig;
  logic                                        cpu_d_resp_valid_sig;
  logic                                        cpu_d_resp_error_sig;
  logic [31:0]                                 cpu_d_resp_rd_data_sig;  
  logic [3:0]                                  cpu_d_resp_rd_data_p_sig;
  logic                                        cpu_d_req_accepted; 
  logic                                        cpu_d_resp_accepted;
   
  logic                                        cpu_d_req_is_apb;
  logic                                        cpu_d_req_is_ahb;
  logic                                        cpu_d_req_is_axi;
  logic                                        cpu_d_req_is_tcm0;
  logic                                        cpu_d_req_is_tcm1;
  logic                                        cpu_d_req_is_udma_ctrl;
  logic                                        cpu_d_req_is_subsys_cfg;
  logic                                        cpu_d_req_is_dummy_target;
  logic                                        cpu_d_req_is_fence;
  
  logic                                        cpu_d_req_addr_parity_error;
  
  logic                                        cpu_d_resp_is_apb;
  logic                                        cpu_d_resp_is_ahb;
  logic                                        cpu_d_resp_is_axi;
  logic                                        cpu_d_resp_is_tcm0;
  logic                                        cpu_d_resp_is_tcm1;
  logic                                        cpu_d_resp_is_udma_ctrl;
  logic                                        cpu_d_resp_is_subsys_cfg;
  logic                                        cpu_d_resp_is_dummy_target;
  logic                                        cpu_d_resp_is_fence;

  logic                                        dummy_target_i_req_valid;
  logic                                        dummy_target_i_req_ready; 
  logic [3:0]                                  dummy_target_i_req_rd_byte_en;
  logic [CPU_ADDR_WIDTH-1:0]                   dummy_target_i_req_addr;
  logic                                        dummy_target_i_req_addr_p;
  logic                                        dummy_target_i_resp_valid;
  logic                                        dummy_target_i_resp_ready;
  logic                                        dummy_target_i_resp_error;
  logic [31:0]                                 dummy_target_i_resp_rd_data;
  logic [3:0]                                  dummy_target_i_resp_rd_data_p;
   
  logic                                        dummy_target_d_req_valid;
  logic                                        dummy_target_d_req_ready; 
  logic [3:0]                                  dummy_target_d_req_rd_byte_en;  
  logic [3:0]                                  dummy_target_d_req_wr_byte_en;
  logic [CPU_ADDR_WIDTH-1:0]                   dummy_target_d_req_addr;
  logic                                        dummy_target_d_req_addr_p;
  logic [31:0]                                 dummy_target_d_req_wr_data;
  logic [3:0]                                  dummy_target_d_req_wr_data_p;
  logic                                        dummy_target_d_resp_valid;
  logic                                        dummy_target_d_resp_ready;
  logic                                        dummy_target_d_resp_error;
  logic [31:0]                                 dummy_target_d_resp_rd_data;
  logic [3:0]                                  dummy_target_d_resp_rd_data_p;
  
  logic                                        fence_d_req_valid;
  logic                                        fence_d_req_ready; 
  logic [3:0]                                  fence_d_req_rd_byte_en;  
  logic [3:0]                                  fence_d_req_wr_byte_en;
  logic [CPU_ADDR_WIDTH-1:0]                   fence_d_req_addr;
  logic                                        fence_d_req_addr_p;
  logic [31:0]                                 fence_d_req_wr_data;
  logic [3:0]                                  fence_d_req_wr_data_p;
  logic                                        fence_d_resp_ready;
  logic [31:0]                                 fence_d_resp_rd_data;
  logic [3:0]                                  fence_d_resp_rd_data_p;
  
  logic                                        d_trx_os;
  logic                                        write_op_d_resp_valid;
  logic                                        fence_op_d_resp_valid;
  logic                                        fence_op_d_resp_error;  

  logic                                        subsys_cfg_d_resp_valid;
  logic                                        subsys_cfg_d_resp_ready;
  logic                                        subsys_cfg_d_resp_error;
  logic [31:0]                                 subsys_cfg_d_resp_rd_data; 
  logic [3:0]                                  subsys_cfg_d_resp_rd_data_p;
  logic                                        subsys_cfg_d_req_valid;
  logic                                        subsys_cfg_d_req_ready; 
  logic [3:0]                                  subsys_cfg_d_req_rd_byte_en;  
  logic [3:0]                                  subsys_cfg_d_req_wr_byte_en;
  logic                                        subsys_cfg_d_req_read;
  logic                                        subsys_cfg_d_req_write;
  logic [31:0]                                 subsys_cfg_d_req_wr_data;
  logic [3:0]                                  subsys_cfg_d_req_wr_data_p;
  logic [l_subsys_cfg_subsys_cfg_addr_width-1:0] subsys_cfg_d_req_addr;
  logic                                        subsys_cfg_d_req_addr_p;
                                              
  logic                                        apb_i_os_other;
  logic                                        tcm0_i_os_other;
  logic                                        tcm1_i_os_other;
  logic                                        dummy_target_i_os_other;
  logic                                        i_trx_os_buff_ready;
  logic [5:0]                                  i_trx_req;
  logic [5:0]                                  i_trx_resp;
  logic                                        i_trx_resp_valid;
  logic [5:0]                                  req_os_i_src;
  logic [(MAX_OS_I_TRX*6)-1:0]                 i_trx_resp_pkd;
  logic [MAX_OS_I_TRX-1:0]                     i_trx_resp_valid_pkd;
  logic                                        req_os_i_apb;
  logic                                        req_os_i_ahb;
  logic                                        req_os_i_axi;
  logic                                        req_os_i_tcm0;
  logic                                        req_os_i_tcm1;
  logic                                        req_os_i_dummy_target;
                                              
  logic                                        apb_d_os_other;
  logic                                        subsys_cfg_d_os_other;
  logic                                        tcm0_d_os_other;
  logic                                        tcm1_d_os_other;
  logic                                        udma_ctrl_d_os_other;
  logic                                        dummy_target_d_os_other;
  logic                                        fence_d_os_other;
  logic                                        d_trx_os_buff_ready;
  logic [10:0]                                 d_trx_req;
  logic [10:0]                                 d_trx_resp;
  logic                                        d_trx_resp_valid;
  logic [8:0]                                  req_os_d_src;
  logic [(MAX_OS_D_TRX*11)-1:0]                d_trx_resp_pkd;
  logic [MAX_OS_D_TRX-1:0]                     d_trx_resp_valid_pkd;
  logic                                        req_os_d_apb;
  logic                                        req_os_d_ahb;
  logic                                        req_os_d_axi;
  logic                                        req_os_d_tcm0;
  logic                                        req_os_d_tcm1;
  logic                                        req_os_d_dummy_target;
  logic                                        req_os_d_fence;
  logic                                        req_os_d_subsys_cfg;
  logic                                        req_os_d_udma_ctrl;
  t_subsys_mem_req                              cpu_d_req_type; 
  t_subsys_mem_req                              cpu_d_resp_type;  
                                              
  logic                                        cpu_d_resp_valid_rd;  
  logic                                        cpu_d_resp_valid_wr; 
  logic                                        cpu_d_resp_valid_fence;         
  logic                                        cpu_d_resp_error_rd;  
  logic                                        cpu_d_resp_error_wr; 
  logic                                        cpu_d_resp_error_fence;
                                              
  logic                                        subsys_parity_en_reg;
                                              


//********************************************************************************
// Main code
//********************************************************************************

  // address decoder
  // Minimum region size is 4K, this allows less bits to be used in the address compare and therfore be faster/smaller at expense of address space for 
  // small regions (eg config regs)
  

  
  // All responses to the CPU must be returned at least one cycle after the request
  // Keep a list of the request destination to route the response appropriately (in order)
  // REVISIT Could encode the response destination to save bits rather than being onehot
  
  // CPU I-side
  // Read only  
  
  // Need to regenerate parity for all address buses as width varies. if it is already incorrect make generated parity incorrect  
  assign cpu_i_req_addr_parity_error = (cpu_i_req_addr_p != ^cpu_i_req_addr) & subsys_parity_en_reg;
  
  assign i_trx_req  = {cpu_i_req_is_apb,
                       cpu_i_req_is_ahb,
                       cpu_i_req_is_axi,
                       cpu_i_req_is_tcm0,
                       cpu_i_req_is_tcm1,
                       cpu_i_req_is_dummy_target};
  
  
  miv_rv32_buffer
  #(
    .BUFF_WIDTH         (6), 
    .BUFF_SIZE          (MAX_OS_I_TRX),
    .PTR_SIZE           (LOG2_MAX_OS_I_TRX)
  )
  u_i_trx_os_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (cpu_i_req_accepted),
    .ready_in           (i_trx_os_buff_ready),
    .data_in            (i_trx_req),
    .data_out           (i_trx_resp),     
    .valid_out          (i_trx_resp_valid),     
    .ready_out          (cpu_i_resp_accepted),
    .data_out_pkd       (i_trx_resp_pkd), 
    .valid_out_pkd      (i_trx_resp_valid_pkd),
    .nearly_full        ()
  );
  
  assign {cpu_i_resp_is_apb,
          cpu_i_resp_is_ahb,
          cpu_i_resp_is_axi,
          cpu_i_resp_is_tcm0,
          cpu_i_resp_is_tcm1,
          cpu_i_resp_is_dummy_target} = i_trx_resp;
          
  // because the RAM and AHB initiator do not buffer responses, need to prevent the request unless it can be guaranteed the response will be
  // returned directly. This may not be the case if there is anything else ahead outstanding that is not coming from the same source.
  
  always @*
  begin :extract_os_i_loop
    integer i;
    
    req_os_i_src = {6{1'b0}};
    for(i=0; i<MAX_OS_I_TRX; i=i+1)
    begin
      req_os_i_src = req_os_i_src | ({6{i_trx_resp_valid_pkd[i]}} & i_trx_resp_pkd[(i*6)+:6]);
    end
  end
  
  assign {req_os_i_apb,
          req_os_i_ahb,
          req_os_i_axi,
          req_os_i_tcm0,
          req_os_i_tcm1,
          req_os_i_dummy_target} = req_os_i_src;
  
  assign cpu_i_req_accepted  = cpu_i_req_valid & cpu_i_req_ready;
  assign cpu_i_resp_accepted = cpu_i_resp_last & cpu_i_resp_ready; 
  
  
  assign cpu_i_req_is_apb      = ((cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] >= cfg_apb_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                       (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] <= cfg_apb_end_addr[CPU_ADDR_WIDTH-1:12])) |
                                       (cpu_i_req_addr[CPU_ADDR_WIDTH-1:3] == l_mtime_addr_base[CPU_ADDR_WIDTH-1:3]) |  
                                       (cpu_i_req_addr[CPU_ADDR_WIDTH-1:3] == l_mtimecmp_addr_base[CPU_ADDR_WIDTH-1:3]) |
                                       (cpu_i_req_addr[CPU_ADDR_WIDTH-1:3] == l_mtime_prescaler_addr[CPU_ADDR_WIDTH-1:3]) ;   
  assign apb_i_os_other        = req_os_i_ahb | 
                                      req_os_i_axi |
                                      req_os_i_tcm0 |
                                      req_os_i_tcm1 |
                                      req_os_i_dummy_target;                                                           
  assign apb_i_req_valid       = cpu_i_req_is_apb & cpu_i_req_valid & i_trx_os_buff_ready & ~apb_i_os_other;
  assign apb_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
  assign apb_i_req_addr        = cpu_i_req_addr[APB_ADDR_WIDTH-1:0];
  assign apb_i_req_addr_p      = ((^cpu_i_req_addr[APB_ADDR_WIDTH-1:0]) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;
  assign apb_i_resp_ready      = cpu_i_resp_is_apb & cpu_i_resp_ready;
  
                                                            
  
  generate
  if(l_subsys_cfg_ahb_present) begin: gen_ahb_i_decode
    assign cpu_i_req_is_ahb    = (ICACHE_EN) ? cpu_i_req_is_ahb_in : 
	                                              (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] >= cfg_ahb_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                                  (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] <= cfg_ahb_end_addr[CPU_ADDR_WIDTH-1:12]);  
    // ahb buffers responses, so no need to block for others outstanding                                                      
    assign ahb_i_req_valid       = cpu_i_req_is_ahb & cpu_i_req_valid & i_trx_os_buff_ready;
    assign ahb_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
    assign ahb_i_req_addr        = cpu_i_req_addr[AHB_ADDR_WIDTH-1:0];
    assign ahb_i_req_addr_p      = ((^cpu_i_req_addr[AHB_ADDR_WIDTH-1:0]) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;
    assign ahb_i_resp_ready      = cpu_i_resp_is_ahb & cpu_i_resp_ready;                                  
                                    
  end
  else begin : ngen_ahb_i_decode
    assign cpu_i_req_is_ahb      = 1'b0;    
    assign ahb_i_req_valid       = 1'b0;
    assign ahb_i_req_rd_byte_en  = {4{1'b0}};
    assign ahb_i_req_addr        = {AHB_ADDR_WIDTH{1'b0}};
    assign ahb_i_req_addr_p      = 1'b0;
    assign ahb_i_resp_ready      = 1'b0;
  end   
  endgenerate
  
  generate
  if(l_subsys_cfg_axi_present) begin: gen_axi_i_decode
    assign cpu_i_req_is_axi     = (ICACHE_EN) ? cpu_i_req_is_axi_in : 
                                                	(cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] >= cfg_axi_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                                    (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] <= cfg_axi_end_addr[CPU_ADDR_WIDTH-1:12]); 
    // axi buffers responses, so no need to block for others outstanding                                                                                                            
    assign axi_i_req_valid       = cpu_i_req_is_axi & cpu_i_req_valid & i_trx_os_buff_ready;
    assign axi_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
    assign axi_i_req_addr        = cpu_i_req_addr[AXI_ADDR_WIDTH-1:0];
    assign axi_i_req_addr_p      = ((^cpu_i_req_addr[AXI_ADDR_WIDTH-1:0]) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;
    assign axi_i_resp_ready      = cpu_i_resp_is_axi & cpu_i_resp_ready;                                        
  end
  else begin : ngen_axi_i_decode
    assign cpu_i_req_is_axi    = 1'b0;  
    assign axi_i_req_valid       = 1'b0;
    assign axi_i_req_rd_byte_en  = {4{1'b0}};
    assign axi_i_req_addr        = {AXI_ADDR_WIDTH{1'b0}};
    assign axi_i_req_addr_p      = 1'b0;
    assign axi_i_resp_ready      = 1'b0;
  end   
  endgenerate
  
  generate
  if(l_subsys_cfg_tcm0_present) begin: gen_tcm0_i_decode
    assign cpu_i_req_is_tcm0      = (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] >= cfg_tcm0_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                    (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] <= cfg_tcm0_end_addr[CPU_ADDR_WIDTH-1:12]);  
    assign tcm0_i_os_other        = req_os_i_apb | 
                                      req_os_i_ahb |
                                      req_os_i_axi |
                                      req_os_i_tcm1 |
                                      req_os_i_dummy_target;                                                                                                         
    assign tcm0_i_req_valid       = cpu_i_req_is_tcm0 & cpu_i_req_valid & i_trx_os_buff_ready & ~tcm0_i_os_other;
    assign tcm0_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
    assign tcm0_i_req_addr        = cpu_i_req_addr[TCM0_ADDR_WIDTH-1:0];
    assign tcm0_i_req_addr_p      = ((^cpu_i_req_addr[TCM0_ADDR_WIDTH-1:0]) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;
    assign tcm0_i_resp_ready      = cpu_i_resp_is_tcm0 & cpu_i_resp_ready;                                    
  end
  else begin : ngen_tcm0_i_decode
    assign cpu_i_req_is_tcm0      = 1'b0; 
    assign tcm0_i_os_other        = 1'b0;
    assign tcm0_i_req_valid       = 1'b0;
    assign tcm0_i_req_rd_byte_en  = {4{1'b0}};
    assign tcm0_i_req_addr        = {TCM0_ADDR_WIDTH{1'b0}};
    assign tcm0_i_req_addr_p      = 1'b0;
    assign tcm0_i_resp_ready      = 1'b0;
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_tcm1_present) begin: gen_tcm1_i_decode
    assign cpu_i_req_is_tcm1      = (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] >= cfg_tcm1_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                    (cpu_i_req_addr[CPU_ADDR_WIDTH-1:12] <= cfg_tcm1_end_addr[CPU_ADDR_WIDTH-1:12]);    
    assign tcm1_i_os_other        = req_os_i_apb | 
                                      req_os_i_ahb |
                                      req_os_i_axi |
                                      req_os_i_tcm0 |
                                      req_os_i_dummy_target;                                                                                                           
    assign tcm1_i_req_valid       = cpu_i_req_is_tcm1 & cpu_i_req_valid & i_trx_os_buff_ready & ~tcm1_i_os_other;
    assign tcm1_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
    assign tcm1_i_req_addr        = cpu_i_req_addr[TCM1_ADDR_WIDTH-1:0];
    assign tcm1_i_req_addr_p      = ((^cpu_i_req_addr[TCM1_ADDR_WIDTH-1:0]) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;    
    assign tcm1_i_resp_ready      = cpu_i_resp_is_tcm1 & cpu_i_resp_ready;                                
  end
  else begin : ngen_tcm1_id_ecode
    assign cpu_i_req_is_tcm1      = 1'b0; 
    assign tcm1_i_os_other        = 1'b0;
    assign tcm1_i_req_valid       = 1'b0;
    assign tcm1_i_req_rd_byte_en  = {4{1'b0}};
    assign tcm1_i_req_addr        = {TCM1_ADDR_WIDTH{1'b0}};
    assign tcm1_i_req_addr_p      = 1'b0;
    assign tcm1_i_resp_ready      = 1'b0;
  end   
  endgenerate  
  
  
  // dummy target cleans up any read request to undefined address space and returns an error to the cpu
  
  assign cpu_i_req_is_dummy_target      = !cpu_i_req_is_apb  &
                                         !cpu_i_req_is_ahb  &
                                         !cpu_i_req_is_axi  &
                                         !cpu_i_req_is_tcm0     &
                                         !cpu_i_req_is_tcm1;                                 
  assign dummy_target_i_os_other        = req_os_i_apb | 
                                         req_os_i_ahb |
                                         req_os_i_axi |
                                         req_os_i_tcm0 | 
                                         req_os_i_tcm1;                                
  assign dummy_target_i_req_valid       = cpu_i_req_is_dummy_target & cpu_i_req_valid & i_trx_os_buff_ready & ~dummy_target_i_os_other;
  assign dummy_target_i_req_rd_byte_en  = cpu_i_req_rd_byte_en;
  assign dummy_target_i_req_addr        = cpu_i_req_addr;
  assign dummy_target_i_req_addr_p      = ((^cpu_i_req_addr) ^ cpu_i_req_addr_parity_error) & subsys_parity_en_reg;
  assign dummy_target_i_resp_ready      = cpu_i_resp_is_dummy_target & cpu_i_resp_ready;                                       

  
    // response mux
  assign cpu_i_req_ready      = ((cpu_i_req_is_apb    & apb_i_req_ready) |
                                 (cpu_i_req_is_ahb    & ahb_i_req_ready) |
                                 (cpu_i_req_is_axi    & axi_i_req_ready) |
                                 (cpu_i_req_is_tcm0       & tcm0_i_req_ready) |
                                 (cpu_i_req_is_tcm1       & tcm1_i_req_ready) |
                                 (cpu_i_req_is_dummy_target & dummy_target_i_req_ready)) & i_trx_os_buff_ready;
  assign cpu_i_resp_last     = (ICACHE_EN) ? (cpu_i_resp_is_apb    & apb_i_resp_valid) |
                                            (cpu_i_resp_is_ahb    & ahb_i_resp_valid & ahb_i_resp_last) |
                                            (cpu_i_resp_is_axi    & axi_i_resp_valid & axi_i_resp_last) |
                                            (cpu_i_resp_is_tcm0        & tcm0_i_resp_valid) |
                                            (cpu_i_resp_is_tcm1        & tcm1_i_resp_valid) |
                                            (cpu_i_resp_is_dummy_target & dummy_target_i_resp_valid) : cpu_i_resp_valid;
  assign cpu_i_resp_valid     = (cpu_i_resp_is_apb    & apb_i_resp_valid) |
                                (cpu_i_resp_is_ahb    & ahb_i_resp_valid) |
                                (cpu_i_resp_is_axi    & axi_i_resp_valid) |
                                (cpu_i_resp_is_tcm0        & tcm0_i_resp_valid) |
                                (cpu_i_resp_is_tcm1        & tcm1_i_resp_valid) |
                                (cpu_i_resp_is_dummy_target & dummy_target_i_resp_valid);
  
  assign cpu_i_resp_error     = (cpu_i_resp_is_apb    & apb_i_resp_error) |
                                (cpu_i_resp_is_ahb    & ahb_i_resp_error) |
                                (cpu_i_resp_is_axi    & axi_i_resp_error) |
                                (cpu_i_resp_is_tcm0       & tcm0_i_resp_error) |
                                (cpu_i_resp_is_tcm1       & tcm1_i_resp_error) |
                                (cpu_i_resp_is_dummy_target & dummy_target_i_resp_error);
  
  assign cpu_i_resp_rd_data   = ({32{cpu_i_resp_is_apb}}    & apb_i_resp_rd_data) |
                                ({32{cpu_i_resp_is_ahb}}    & ahb_i_resp_rd_data) |
                                ({32{cpu_i_resp_is_axi}}    & axi_i_resp_rd_data) |
                                ({32{cpu_i_resp_is_tcm0}}       & tcm0_i_resp_rd_data) |
                                ({32{cpu_i_resp_is_tcm1}}       & tcm1_i_resp_rd_data) |
                                ({32{cpu_i_resp_is_dummy_target}} & dummy_target_i_resp_rd_data);
                                

  assign cpu_i_resp_rd_data_p = (({4{cpu_i_resp_is_apb}}    & apb_i_resp_rd_data_p) |
                                 ({4{cpu_i_resp_is_ahb}}    & ahb_i_resp_rd_data_p) |
                                 ({4{cpu_i_resp_is_axi}}    & axi_i_resp_rd_data_p) |
                                 ({4{cpu_i_resp_is_tcm0}}       & tcm0_i_resp_rd_data_p) |
                                 ({4{cpu_i_resp_is_tcm1}}       & tcm1_i_resp_rd_data_p) |
                                 ({4{cpu_i_resp_is_dummy_target}} & dummy_target_i_resp_rd_data_p) & {4{subsys_parity_en_reg}});                               
  
  // CPU D-side
  // Read/write     
  
  // Mux in debug read/write paths to d-side.
  // Do not need to track source and destination, since debug unit and cpu requests are mutually exclusive 
  // CPU requests cannot be made in debug mode, and debug requests cannot be made when not in debug mode. No 
  // outstanding requests should be in flight when debug mode changes.
  // Limit number of outstanding debug requests to 1 to ensure no re-ordering issues until debug spec can support abstract fence commands

  
  assign cpu_d_req_valid_mux       =  debug_mode ? (debug_sysbus_req_valid & ~(|d_trx_resp_valid_pkd)) : cpu_d_req_valid;
  assign cpu_d_req_rd_byte_en_mux  =  debug_mode ? debug_sysbus_req_rd_byte_en                         : cpu_d_req_rd_byte_en;  
  assign cpu_d_req_wr_byte_en_mux  =  debug_mode ? debug_sysbus_req_wr_byte_en                         : cpu_d_req_wr_byte_en;
  assign cpu_d_req_read_mux        =  debug_mode ? |debug_sysbus_req_rd_byte_en                        : cpu_d_req_read;
  assign cpu_d_req_write_mux       =  debug_mode ? |debug_sysbus_req_wr_byte_en                        : cpu_d_req_write;
  assign cpu_d_req_addr_mux        =  debug_mode ? debug_sysbus_req_addr                               : cpu_d_req_addr;    
  assign cpu_d_req_addr_p_mux      =  debug_mode ? ^debug_sysbus_req_addr                              : cpu_d_req_addr_p;    
  assign cpu_d_req_fence_mux       =  debug_mode ? 1'b0                                                : cpu_d_req_fence;
  assign cpu_d_req_wr_data_mux     =  debug_mode ? debug_sysbus_req_wr_data                            : cpu_d_req_wr_data;   
  assign cpu_d_req_wr_data_p_mux   =  debug_mode ? {(^debug_sysbus_req_wr_data[31:24]),                           
                                                    (^debug_sysbus_req_wr_data[23:16]),
                                                    (^debug_sysbus_req_wr_data[15:8]),
                                                    (^debug_sysbus_req_wr_data[7:0])}                  : cpu_d_req_wr_data_p;
  assign cpu_d_resp_ready_mux      =  debug_mode ? debug_sysbus_resp_ready                             : cpu_d_resp_ready;
  
  
  
    // Need to regenerate parity for all address buses as width varies. if it is already incorrect make generated parity incorrect  
  assign cpu_d_req_addr_parity_error = (cpu_d_req_addr_p_mux != ^cpu_d_req_addr_mux) & subsys_parity_en_reg;   
  
  assign cpu_d_req_type = cpu_d_req_read_mux  ? subsys_mem_req_rd :
                          cpu_d_req_write_mux ? subsys_mem_req_wr :
                          cpu_d_req_fence_mux ? subsys_mem_req_fence : subsys_mem_req_invalid;
  
  assign d_trx_req  = {cpu_d_req_is_apb,
                       cpu_d_req_is_subsys_cfg,
                       cpu_d_req_is_ahb,
                       cpu_d_req_is_axi,
                       cpu_d_req_is_tcm0,
                       cpu_d_req_is_tcm1,
                       cpu_d_req_is_udma_ctrl,
                       cpu_d_req_is_dummy_target,
                       cpu_d_req_is_fence,
                       cpu_d_req_type};
  
  
  miv_rv32_buffer
  #(
    .BUFF_WIDTH         (11), 
    .BUFF_SIZE          (MAX_OS_D_TRX),
    .PTR_SIZE           (LOG2_MAX_OS_D_TRX)
  )
  u_d_trx_os_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (cpu_d_req_accepted),
    .ready_in           (d_trx_os_buff_ready),
    .data_in            (d_trx_req),
    .data_out           (d_trx_resp),     
    .valid_out          (d_trx_resp_valid),     
    .ready_out          (cpu_d_resp_accepted),
    .data_out_pkd       (d_trx_resp_pkd), 
    .valid_out_pkd      (d_trx_resp_valid_pkd),
    .nearly_full        ()
  );
  
  assign {cpu_d_resp_is_apb,
          cpu_d_resp_is_subsys_cfg,
          cpu_d_resp_is_ahb,
          cpu_d_resp_is_axi,
          cpu_d_resp_is_tcm0,
          cpu_d_resp_is_tcm1,
          cpu_d_resp_is_udma_ctrl,
          cpu_d_resp_is_dummy_target,
          cpu_d_resp_is_fence,
          cpu_d_resp_type} = d_trx_resp_valid ? d_trx_resp : {{9{1'b0}},subsys_mem_req_invalid};
          
  // because the RAM and AHB initiator do not buffer responses, need to prevent the request unless it can be guaranteed the response will be
  // returned directly. This may not be the case if there is anything else ahead outstanding that is not coming from the same source.
  
  always @*
  begin :extract_os_d_loop
    integer i;
    logic [10:0] tmp_curr_trx_entry;
    req_os_d_src = {9{1'b0}};
    for(i=0; i<MAX_OS_D_TRX; i=i+1)
    begin
      tmp_curr_trx_entry  = d_trx_resp_pkd[(i*11)+:11];
      req_os_d_src        = req_os_d_src | ({9{d_trx_resp_valid_pkd[i]}} & tmp_curr_trx_entry[10:2]);
    end
  end
  
  
  assign {req_os_d_apb,
          req_os_d_subsys_cfg,
          req_os_d_ahb,
          req_os_d_axi,
          req_os_d_tcm0,
          req_os_d_tcm1,
          req_os_d_udma_ctrl,
          req_os_d_dummy_target,
          req_os_d_fence} = req_os_d_src;

        
                                      
  assign cpu_d_req_accepted  = cpu_d_req_valid_mux & cpu_d_req_ready_sig & ((|cpu_d_req_rd_byte_en_mux) | 
                                                                            (|cpu_d_req_wr_byte_en_mux) | 
                                                                            cpu_d_req_fence_mux);
  assign cpu_d_resp_accepted = cpu_d_resp_valid_sig & cpu_d_resp_ready_mux;                       
  
  
  assign cpu_d_req_is_apb      = ((cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_apb_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_apb_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                      (cpu_d_req_read_mux | cpu_d_req_write_mux)) |
								      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:3] == l_mtime_addr_base[CPU_ADDR_WIDTH-1:3]) |   
								      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:3] == l_mtimecmp_addr_base[CPU_ADDR_WIDTH-1:3])|
                                      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:3] == l_mtime_prescaler_addr[CPU_ADDR_WIDTH-1:3]) ;
                                        
  assign apb_d_os_other        = req_os_d_ahb | 
                                      req_os_d_subsys_cfg |
                                      req_os_d_axi |
                                      req_os_d_tcm0 |
                                      req_os_d_tcm1 |
                                      req_os_d_udma_ctrl |
                                      req_os_d_dummy_target;                                 
                                    
  assign apb_d_req_valid       = cpu_d_req_is_apb & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~apb_d_os_other & ~req_os_d_fence;
  assign apb_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
  assign apb_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
  //assign apb_d_req_read        = cpu_d_req_read_mux;
  //assign apb_d_req_write       = cpu_d_req_write_mux;
  assign apb_d_req_wr_data     = cpu_d_req_wr_data_mux;
  assign apb_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
  assign apb_d_req_addr        = cpu_d_req_addr_mux[APB_ADDR_WIDTH-1:0];
  assign apb_d_req_addr_p      = ((^cpu_d_req_addr_mux[APB_ADDR_WIDTH-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
  assign apb_d_resp_ready      = cpu_d_resp_is_apb & cpu_d_resp_ready_mux;
                                  
  
  assign cpu_d_req_is_subsys_cfg     = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_subsys_cfg_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                    (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_subsys_cfg_end_addr[CPU_ADDR_WIDTH-1:12]);   
                                    
  assign subsys_cfg_d_os_other       = req_os_d_apb |
                                      req_os_d_ahb | 
                                      req_os_d_axi |
                                      req_os_d_tcm0 |
                                      req_os_d_tcm1 |
                                      req_os_d_udma_ctrl |
                                      req_os_d_dummy_target;                                                                                                             
                                    
  assign subsys_cfg_d_req_valid       = cpu_d_req_is_subsys_cfg & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~subsys_cfg_d_os_other & ~req_os_d_fence;
  assign subsys_cfg_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
  assign subsys_cfg_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
  assign subsys_cfg_d_req_read        = cpu_d_req_read_mux;
  assign subsys_cfg_d_req_write       = cpu_d_req_write_mux;
  assign subsys_cfg_d_req_wr_data     = cpu_d_req_wr_data_mux;
  assign subsys_cfg_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
  assign subsys_cfg_d_req_addr        = cpu_d_req_addr_mux[l_subsys_cfg_subsys_cfg_addr_width-1:0];
  assign subsys_cfg_d_req_addr_p      = ((^cpu_d_req_addr_mux[l_subsys_cfg_subsys_cfg_addr_width-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
  assign subsys_cfg_d_resp_ready      = cpu_d_resp_is_subsys_cfg & cpu_d_resp_ready_mux;
    
  
  miv_rv32_subsys_regs
  #(
    .REGS_ADDR_WIDTH                         (l_subsys_cfg_subsys_cfg_addr_width),
	.ECC_ENABLE                              (ECC_ENABLE                        ),
    .l_subsys_cfg_tcm0_present               (l_subsys_cfg_tcm0_present         ),
	.l_subsys_cfg_axi_present                (l_subsys_cfg_axi_present          ),
	.l_subsys_gpr_ded_reset_en               (l_subsys_gpr_ded_reset_en         ),
	.ICACHE_EN                               (ICACHE_EN                         ),
	.l_miv_rv32_version                      (l_miv_rv32_version                )
  )
  u_subsys_regs
  (
    .clk                                     (clk                          ),
    .resetn                                  (resetn                       ),
    .sys_parity_disable                      (sys_parity_disable           ),
    .cpu_regs_req_valid                      (subsys_cfg_d_req_valid       ),
    .cpu_regs_req_ready                      (subsys_cfg_d_req_ready       ),
    .cpu_regs_req_rd_byte_en                 (subsys_cfg_d_req_rd_byte_en  ),
    .cpu_regs_req_wr_byte_en                 (subsys_cfg_d_req_wr_byte_en  ),
    .cpu_regs_req_read                       (subsys_cfg_d_req_read        ),
    .cpu_regs_req_write                      (subsys_cfg_d_req_write       ),
    .cpu_regs_req_addr                       (subsys_cfg_d_req_addr        ),
    .cpu_regs_req_addr_p                     (subsys_cfg_d_req_addr_p      ),
    .cpu_regs_req_wr_data                    (subsys_cfg_d_req_wr_data     ),
    .cpu_regs_req_wr_data_p                  (subsys_cfg_d_req_wr_data_p   ),
    .cpu_regs_resp_valid                     (subsys_cfg_d_resp_valid      ),
    .cpu_regs_resp_ready                     (subsys_cfg_d_resp_ready      ),
    .cpu_regs_resp_error                     (subsys_cfg_d_resp_error      ),
    .cpu_regs_resp_rd_data                   (subsys_cfg_d_resp_rd_data    ),
    .cpu_regs_resp_rd_data_p                 (subsys_cfg_d_resp_rd_data_p  ),
    
    .cpu_regs_icache_ecc_err_correctable     (icache_ecc_err_correctable  ),   
    .cpu_regs_icache_ecc_err_uncorrectable   (icache_ecc_err_uncorrectable), 
    .cpu_regs_tcm0_ecc_err_correctable       (tcm0_ecc_err_correctable    ),
    .cpu_regs_tcm0_ecc_err_uncorrectable     (tcm0_ecc_err_uncorrectable  ),
    .cpu_regs_tcm1_ecc_err_correctable       (tcm1_ecc_err_correctable    ),
    .cpu_regs_tcm1_ecc_err_uncorrectable     (tcm1_ecc_err_uncorrectable  ),
    .cpu_regs_axi_wr_resp_err                (axi_d_wr_resp_err           ),
    .cpu_regs_udma_ctrl_irq                  (udma_ctrl_irq               ),
    .cpu_regs_subsys_irq                      (subsys_irq                 ),
    .cpu_regs_axi_rd_cfg_min_size            (axi_rd_cfg_min_size         ),
    .cpu_regs_axi_wr_cfg_min_size            (axi_wr_cfg_min_size         ),
    .cpu_regs_subsys_parity_en                (subsys_parity_en_reg       ),
    .cpu_regs_cfg_fence_all_src              (cfg_fence_all_src           ),
    .cpu_regs_cfg_ar_cache                   (cfg_ar_cache                ),
    .cpu_regs_cfg_aw_cache                   (cfg_aw_cache                ),
    .cpu_regs_cfg_raw_hzd_check              (cfg_raw_hzd_check           ),
    .cpu_regs_cfg_war_hzd_check              (cfg_war_hzd_check           ),
    
    .cpu_regs_hart_soft_reset                (hart_soft_reset             ),  //connected the hart_soft_reset output from the subsys_regs to the interconnect
    .cpu_regs_hart_soft_irq                  (hart_soft_irq               ),     //connected the hart_soft_irq output from the subsys_regs to the interconnect  
    
    .gpr_ded_soft_reset                      (gpr_ded_soft_reset          ), //connected gpr ded soft reset from interconnect to regs file

    .gpr_ecc_error_injection                 (gpr_ecc_error_injection     ),  
    .tcm_ecc_error_injection                 (tcm_ecc_error_injection     ),
    .icache_ecc_error_injection              (icache_ecc_error_injection  )
                   
  );
  
  assign subsys_parity_en = subsys_parity_en_reg;

  
  assign tcm0_uncorrectable_ecc_error = tcm0_ecc_err_uncorrectable;
  assign tcm1_uncorrectable_ecc_error = tcm1_ecc_err_uncorrectable;
                                                                       
  
  generate
  if(l_subsys_cfg_ahb_present) begin: gen_ahb_d_decode
    assign cpu_d_req_is_ahb    = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_ahb_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_ahb_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                      (cpu_d_req_read_mux | cpu_d_req_write_mux);                           
    assign ahb_d_req_valid       = cpu_d_req_is_ahb & cpu_d_req_valid_mux & d_trx_os_buff_ready &  ~req_os_d_fence;
    assign ahb_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
    assign ahb_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
    assign ahb_d_req_read        = cpu_d_req_read_mux;
    assign ahb_d_req_write       = cpu_d_req_write_mux;
    assign ahb_d_req_wr_data     = cpu_d_req_wr_data_mux;
    assign ahb_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
    assign ahb_d_req_addr        = cpu_d_req_addr_mux[AHB_ADDR_WIDTH-1:0];
    assign ahb_d_req_addr_p      = ((^cpu_d_req_addr_mux[AHB_ADDR_WIDTH-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
    assign ahb_d_resp_ready      = cpu_d_resp_is_ahb & cpu_d_resp_ready_mux;                                  
                                    
  end
  else begin : ngen_ahb_d_decode
    assign cpu_d_req_is_ahb      = 1'b0;
    assign ahb_d_req_valid       = 1'b0;
    assign ahb_d_req_rd_byte_en  = {4{1'b0}};
    assign ahb_d_req_wr_byte_en  = {4{1'b0}};
    assign ahb_d_req_read        = 1'b0;
    assign ahb_d_req_write       = 1'b0;
    assign ahb_d_req_wr_data     = {32{1'b0}};
    assign ahb_d_req_wr_data_p   = {4{1'b0}};
    assign ahb_d_req_addr        = {AHB_ADDR_WIDTH{1'b0}};
    assign ahb_d_req_addr_p      = 1'b0;
    assign ahb_d_resp_ready      = 1'b0;
  end   
  endgenerate
  
  generate
  if(l_subsys_cfg_axi_present) begin: gen_axi_d_decode
    assign cpu_d_req_is_axi    = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_axi_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                      (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_axi_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                      (cpu_d_req_read_mux | cpu_d_req_write_mux);                                 
    assign axi_d_req_valid       = cpu_d_req_is_axi & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~req_os_d_fence;
    assign axi_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
    assign axi_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
    assign axi_d_req_read        = cpu_d_req_read_mux;
    assign axi_d_req_write       = cpu_d_req_write_mux;
    assign axi_d_req_wr_data     = cpu_d_req_wr_data_mux;
    assign axi_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
    assign axi_d_req_addr        = cpu_d_req_addr_mux[AXI_ADDR_WIDTH-1:0];
    assign axi_d_req_addr_p      = ((^cpu_d_req_addr_mux[AXI_ADDR_WIDTH-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
    assign axi_d_resp_ready      = cpu_d_resp_is_axi & cpu_d_resp_ready_mux;                                        
  end
  else begin : ngen_axi_d_decode
    assign cpu_d_req_is_axi      = 1'b0;  
    assign axi_d_req_valid       = 1'b0;
    assign axi_d_req_rd_byte_en  = {4{1'b0}};
    assign axi_d_req_wr_byte_en  = {4{1'b0}};
    assign axi_d_req_read        = 1'b0;
    assign axi_d_req_write       = 1'b0;
    assign axi_d_req_wr_data     = {32{1'b0}};
    assign axi_d_req_wr_data_p   = {4{1'b0}};
    assign axi_d_req_addr        = {AXI_ADDR_WIDTH{1'b0}};
    assign axi_d_req_addr_p      = 1'b0;
    assign axi_d_resp_ready      = 1'b0;
  end   
  endgenerate
  
  generate
  if(l_subsys_cfg_tcm0_present) begin: gen_tcm0_d_decode
    assign cpu_d_req_is_tcm0      = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_tcm0_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                     (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_tcm0_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                     (cpu_d_req_read_mux | cpu_d_req_write_mux);
                                         
    assign tcm0_d_os_other        = req_os_d_apb |
                                     req_os_d_subsys_cfg |
                                     req_os_d_ahb | 
                                     req_os_d_axi |
                                     req_os_d_tcm1 |
                                     req_os_d_udma_ctrl |
                                     req_os_d_dummy_target;                                     
                                      
    assign tcm0_d_req_valid       = cpu_d_req_is_tcm0 & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~tcm0_d_os_other & ~req_os_d_fence;
    assign tcm0_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
    assign tcm0_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
    assign tcm0_d_req_read        = cpu_d_req_read_mux;
    assign tcm0_d_req_write       = cpu_d_req_write_mux;
    assign tcm0_d_req_wr_data     = cpu_d_req_wr_data_mux;
    assign tcm0_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
    assign tcm0_d_req_addr        = cpu_d_req_addr_mux[TCM0_ADDR_WIDTH-1:0];
    assign tcm0_d_req_addr_p      = ((^cpu_d_req_addr_mux[TCM0_ADDR_WIDTH-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
    assign tcm0_d_resp_ready      = cpu_d_resp_is_tcm0 & cpu_d_resp_ready_mux;                                    
  end
  else begin : ngen_tcm0_d_decode
    assign cpu_d_req_is_tcm0      = 1'b0; 
    assign tcm0_d_req_valid       = 1'b0;
    assign tcm0_d_req_rd_byte_en  = {4{1'b0}};
    assign tcm0_d_req_wr_byte_en  = {4{1'b0}};
    assign tcm0_d_req_read        = 1'b0;
    assign tcm0_d_req_write       = 1'b0;
    assign tcm0_d_req_wr_data     = {32{1'b0}};
    assign tcm0_d_req_wr_data_p   = {4{1'b0}};
    assign tcm0_d_req_addr        = {TCM0_ADDR_WIDTH{1'b0}};
    assign tcm0_d_req_addr_p      = 1'b0;
    assign tcm0_d_resp_ready      = 1'b0;
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_tcm1_present) begin: gen_tcm1_d_decode
    assign cpu_d_req_is_tcm1      = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_tcm1_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                     (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_tcm1_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                     (cpu_d_req_read_mux | cpu_d_req_write_mux);
                                    
    assign tcm1_d_os_other        = req_os_d_apb |
                                     req_os_d_subsys_cfg |
                                     req_os_d_ahb | 
                                     req_os_d_axi |
                                     req_os_d_tcm0 |
                                     req_os_d_udma_ctrl |
                                     req_os_d_dummy_target;                                     
                                      
    assign tcm1_d_req_valid       = cpu_d_req_is_tcm1 & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~tcm1_d_os_other & ~req_os_d_fence; 
    assign tcm1_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
    assign tcm1_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
    assign tcm1_d_req_read        = cpu_d_req_read_mux;
    assign tcm1_d_req_write       = cpu_d_req_write_mux;
    assign tcm1_d_req_wr_data     = cpu_d_req_wr_data_mux;
    assign tcm1_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
    assign tcm1_d_req_addr        = cpu_d_req_addr_mux[TCM1_ADDR_WIDTH-1:0];
    assign tcm1_d_req_addr_p      = ((^cpu_d_req_addr_mux[TCM1_ADDR_WIDTH-1:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
    assign tcm1_d_resp_ready      = cpu_d_resp_is_tcm1 & cpu_d_resp_ready_mux;                                
  end
  else begin : ngen_tcm1_d_decode
    assign cpu_d_req_is_tcm1      = 1'b0;
    assign tcm1_d_req_valid       = 1'b0;
    assign tcm1_d_req_rd_byte_en  = {4{1'b0}};
    assign tcm1_d_req_wr_byte_en  = {4{1'b0}};
    assign tcm1_d_req_read        = 1'b0;
    assign tcm1_d_req_write       = 1'b0;
    assign tcm1_d_req_wr_data     = {32{1'b0}};
    assign tcm1_d_req_wr_data_p   = {4{1'b0}};
    assign tcm1_d_req_addr        = {TCM1_ADDR_WIDTH{1'b0}};
    assign tcm1_d_req_addr_p      = 1'b0;
    assign tcm1_d_resp_ready      = 1'b0;
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_udma_present) begin: gen_udma_decode
    assign cpu_d_req_is_udma_ctrl      = (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] >= cfg_udma_ctrl_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                         (cpu_d_req_addr_mux[CPU_ADDR_WIDTH-1:12] <= cfg_udma_ctrl_end_addr[CPU_ADDR_WIDTH-1:12]) &
                                         (cpu_d_req_read_mux | cpu_d_req_write_mux);    
    assign udma_ctrl_d_os_other        = req_os_d_apb |
                                         req_os_d_subsys_cfg |
                                         req_os_d_ahb | 
                                         req_os_d_axi |
                                         req_os_d_tcm0 |
                                         req_os_d_tcm1 |
                                         req_os_d_dummy_target;                                    
                                      
    assign udma_ctrl_d_req_valid       = cpu_d_req_is_udma_ctrl & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~udma_ctrl_d_os_other & ~req_os_d_fence;                                
    assign udma_ctrl_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
    assign udma_ctrl_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
    assign udma_ctrl_d_req_read        = cpu_d_req_read_mux;
    assign udma_ctrl_d_req_write       = cpu_d_req_write_mux;
    assign udma_ctrl_d_req_wr_data     = cpu_d_req_wr_data_mux;
    assign udma_ctrl_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
    assign udma_ctrl_d_req_addr        = cpu_d_req_addr_mux[UDMA_CTRL_ADDR_WIDTH-1:0];
    assign udma_ctrl_d_req_addr_p      = ((^cpu_d_req_addr_mux[UDMA_CTRL_ADDR_WIDTH:0]) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
    assign udma_ctrl_d_resp_ready      = cpu_d_resp_is_udma_ctrl & cpu_d_resp_ready_mux;                                
  end
  else begin : ngen_udma_ctrl_decode
    assign cpu_d_req_is_udma_ctrl      = 1'b0;  
    assign udma_ctrl_d_req_valid       = 1'b0;
    assign udma_ctrl_d_req_rd_byte_en  = {4{1'b0}};
    assign udma_ctrl_d_req_wr_byte_en  = {4{1'b0}};
    assign udma_ctrl_d_req_read        = 1'b0;
    assign udma_ctrl_d_req_write       = 1'b0;
    assign udma_ctrl_d_req_wr_data     = {32{1'b0}};
    assign udma_ctrl_d_req_wr_data_p   = {4{1'b0}};
    assign udma_ctrl_d_req_addr        = {UDMA_CTRL_ADDR_WIDTH{1'b0}};
    assign udma_ctrl_d_req_addr_p      = 1'b0;
    assign udma_ctrl_d_resp_ready      = 1'b0;
  end   
  endgenerate  
  
  // dummy target cleans up any read request to undefined address space and returns an error to the cpu
  
  assign cpu_d_req_is_dummy_target   = (!cpu_d_req_is_apb  &
                                       !cpu_d_req_is_ahb  &
                                       !cpu_d_req_is_axi  &
                                       !cpu_d_req_is_tcm0     &
                                       !cpu_d_req_is_tcm1     &
                                       !cpu_d_req_is_udma_ctrl &
                                       !cpu_d_req_is_subsys_cfg)  &
                                      (cpu_d_req_read_mux | cpu_d_req_write_mux);
                                      
  assign dummy_target_d_os_other        = req_os_d_apb |
                                         req_os_d_subsys_cfg |
                                         req_os_d_ahb | 
                                         req_os_d_axi |
                                         req_os_d_tcm0 |
                                         req_os_d_tcm1 |
                                         req_os_d_udma_ctrl;                                                                         
                                    
  assign dummy_target_d_req_valid       = cpu_d_req_is_dummy_target & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~dummy_target_d_os_other & ~req_os_d_fence;
  assign dummy_target_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
  assign dummy_target_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
  assign dummy_target_d_req_wr_data     = cpu_d_req_wr_data_mux;
  assign dummy_target_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
  assign dummy_target_d_req_addr        = cpu_d_req_addr_mux;
  assign dummy_target_d_req_addr_p      = ((^cpu_d_req_addr_mux) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
  assign dummy_target_d_resp_ready      = cpu_d_resp_is_dummy_target & cpu_d_resp_ready_mux;       
  
  // Fence
  // treat fence as an endpoint, attributes are not currently used, but may be in future revision of RISC-V ISA       
  
  
  assign cpu_d_req_is_fence   = cpu_d_req_fence_mux;
                                      
  assign fence_d_os_other        = req_os_d_apb |
                                   req_os_d_subsys_cfg |
                                   req_os_d_ahb | 
                                   req_os_d_axi |
                                   req_os_d_tcm0 |
                                   req_os_d_tcm1 |
                                   req_os_d_udma_ctrl |
                                   req_os_d_dummy_target;                                                                         
                                    
  assign fence_d_req_valid       = cpu_d_req_is_fence & cpu_d_req_valid_mux & d_trx_os_buff_ready & ~req_os_d_fence;
  assign fence_d_req_rd_byte_en  = cpu_d_req_rd_byte_en_mux;
  assign fence_d_req_wr_byte_en  = cpu_d_req_wr_byte_en_mux;
  assign fence_d_req_wr_data     = cpu_d_req_wr_data_mux;
  assign fence_d_req_wr_data_p   = cpu_d_req_wr_data_p_mux & {4{subsys_parity_en_reg}};
  assign fence_d_req_addr        = cpu_d_req_addr_mux;
  assign fence_d_req_addr_p      = ((^cpu_d_req_addr_mux) ^ cpu_d_req_addr_parity_error) & subsys_parity_en_reg;
  assign fence_d_resp_ready      = cpu_d_resp_is_fence & cpu_d_resp_ready_mux;                      
  
    // response mux
  
  assign cpu_d_req_ready_sig      = (cpu_d_req_is_apb    & apb_d_req_ready) |
                                    (cpu_d_req_is_ahb    & ahb_d_req_ready) |
                                    (cpu_d_req_is_axi    & axi_d_req_ready) |
                                    (cpu_d_req_is_tcm0       & tcm0_d_req_ready) |
                                    (cpu_d_req_is_tcm1       & tcm1_d_req_ready) |
                                    (cpu_d_req_is_udma_ctrl   & udma_ctrl_d_req_ready) |
                                    (cpu_d_req_is_subsys_cfg   & subsys_cfg_d_req_ready) |
                                    (cpu_d_req_is_dummy_target & dummy_target_d_req_ready) |
                                    (cpu_d_req_is_fence       & fence_d_req_ready);
  
  // Limit number of outstanding debug requests to 1 to ensure no re-ordering issues until debug spec can support abstract fence commands                              
  assign cpu_d_req_ready          = cpu_d_req_ready_sig & ~debug_mode;    
  assign debug_sysbus_req_ready   = cpu_d_req_ready_sig & debug_mode & ~(|d_trx_resp_valid_pkd) ;                      
                                

  assign cpu_d_resp_valid_rd     = (cpu_d_resp_is_apb    & apb_d_resp_valid) |
                                   (cpu_d_resp_is_ahb    & ahb_d_resp_valid) |
                                   (cpu_d_resp_is_axi    & axi_d_resp_valid) |
                                   (cpu_d_resp_is_tcm0       & tcm0_d_resp_valid) |
                                   (cpu_d_resp_is_tcm1       & tcm1_d_resp_valid) |
                                   (cpu_d_resp_is_udma_ctrl   & udma_ctrl_d_resp_valid) |
                                   (cpu_d_resp_is_subsys_cfg   & subsys_cfg_d_resp_valid) |
                                   (cpu_d_resp_is_dummy_target & dummy_target_d_resp_valid);
                                   
  assign cpu_d_resp_valid_wr     = write_op_d_resp_valid;
  
  assign cpu_d_resp_valid_fence  = fence_op_d_resp_valid;   
  
  assign cpu_d_resp_valid_sig    = ((cpu_d_resp_type == subsys_mem_req_rd) & cpu_d_resp_valid_rd) |  
                                   ((cpu_d_resp_type == subsys_mem_req_wr) & cpu_d_resp_valid_wr) |
                                   ((cpu_d_resp_type == subsys_mem_req_fence) & cpu_d_resp_valid_fence);     
                                   
  assign cpu_d_resp_valid        = cpu_d_resp_valid_sig & ~debug_mode; 
  assign debug_sysbus_resp_valid = cpu_d_resp_valid_sig & debug_mode;                                                    
  
  assign cpu_d_resp_error_rd     = (cpu_d_resp_is_apb    & apb_d_resp_error) |
                                   (cpu_d_resp_is_ahb    & ahb_d_resp_rd_error) |
                                   (cpu_d_resp_is_axi    & axi_d_resp_rd_error) |
                                   (cpu_d_resp_is_tcm0       & tcm0_d_resp_error) |
                                   (cpu_d_resp_is_tcm1       & tcm1_d_resp_error) |
                                   (cpu_d_resp_is_udma_ctrl   & udma_ctrl_d_resp_error) |
                                   (cpu_d_resp_is_subsys_cfg   & subsys_cfg_d_resp_error) |
                                   (cpu_d_resp_is_dummy_target & dummy_target_d_resp_error);
                                   
  assign cpu_d_resp_error_wr     = (cpu_d_resp_is_apb    & apb_d_resp_error) |
                                   (cpu_d_resp_is_ahb    & 1'b0) | // AXI and AHB errors are delayed and imprecise so cause interrupt
                                   (cpu_d_resp_is_axi    & 1'b0) |
                                   (cpu_d_resp_is_tcm0       & tcm0_d_resp_error) |
                                   (cpu_d_resp_is_tcm1       & tcm1_d_resp_error) |
                                   (cpu_d_resp_is_udma_ctrl   & udma_ctrl_d_resp_error) |
                                   (cpu_d_resp_is_subsys_cfg   & subsys_cfg_d_resp_error) |
                                   (cpu_d_resp_is_dummy_target & dummy_target_d_resp_error);
  
  assign cpu_d_resp_error_fence  = fence_op_d_resp_error;   
  
  assign cpu_d_resp_error_sig    = ((cpu_d_resp_type == subsys_mem_req_rd) & cpu_d_resp_error_rd) |  
                                   ((cpu_d_resp_type == subsys_mem_req_wr) & cpu_d_resp_error_wr) |
                                   ((cpu_d_resp_type == subsys_mem_req_fence) & cpu_d_resp_error_fence);     
                                       
  assign cpu_d_resp_error        = cpu_d_resp_error_sig & ~debug_mode;
  assign debug_sysbus_resp_error = cpu_d_resp_error_sig & debug_mode;
                                
  
  assign cpu_d_resp_rd_data_sig  = ({32{cpu_d_resp_is_apb}}    & apb_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_ahb}}    & ahb_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_axi}}    & axi_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_tcm0}}       & tcm0_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_tcm1}}       & tcm1_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_udma_ctrl}}   & udma_ctrl_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_subsys_cfg}}   & subsys_cfg_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_dummy_target}} & dummy_target_d_resp_rd_data) |
                                   ({32{cpu_d_resp_is_fence}}       & fence_d_resp_rd_data);                                                                      
  
  assign cpu_d_resp_rd_data         =  cpu_d_resp_rd_data_sig;        
  assign debug_sysbus_resp_rd_data  =  cpu_d_resp_rd_data_sig;                      
                                
  assign cpu_d_resp_rd_data_p_sig   = (({4{cpu_d_resp_is_apb}}    & apb_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_ahb}}    & ahb_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_axi}}    & axi_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_tcm0}}       & tcm0_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_tcm1}}       & tcm1_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_udma_ctrl}}   & udma_ctrl_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_subsys_cfg}}   & subsys_cfg_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_dummy_target}} & dummy_target_d_resp_rd_data_p) |
                                       ({4{cpu_d_resp_is_fence}}       & fence_d_resp_rd_data_p)) & {4{subsys_parity_en_reg}}; 
                                       
  assign cpu_d_resp_rd_data_p       = cpu_d_resp_rd_data_p_sig;                                                             
                                
  // Dummy target
  //-------------------------------
  // Dummy target returns an error response 1 cycle after a request
  // Deal with I and D seperately
  
  assign dummy_target_i_req_ready      = 1'b1; 
  assign dummy_target_i_resp_valid     = cpu_i_resp_is_dummy_target & i_trx_resp_valid;
  assign dummy_target_i_resp_error     = 1'b1;
  assign dummy_target_i_resp_rd_data   = {32{1'b0}};
  assign dummy_target_i_resp_rd_data_p = {4{1'b0}};
  
  assign dummy_target_d_req_ready      = 1'b1; 
  assign dummy_target_d_resp_valid     = cpu_d_resp_is_dummy_target & d_trx_resp_valid;
  assign dummy_target_d_resp_error     = 1'b1;
  assign dummy_target_d_resp_rd_data   = {32{1'b0}};
  assign dummy_target_d_resp_rd_data_p = {4{1'b0}};
  
  // Write response
  // SUBSYS returns write response immediately to the hart as no requests to the same location can be
  // reordered except by AXI which enforce RAW ordering in the initiator
  
  assign write_op_d_resp_valid     = d_trx_resp_valid;
  
  // Ordering/Fence control
  //-------------------------------
  // When a fence request is accepted all subsequent request will be blocked until the fence completes
  // The fence completes when all initiators indicate they have no outstanding requests
  
  assign d_trx_os = req_os_d_apb |
                    req_os_d_subsys_cfg |
                    req_os_d_ahb |
                    req_os_d_axi |
                    req_os_d_tcm0 |
                    req_os_d_tcm1 |
                    req_os_d_udma_ctrl;

// assign d_trx_os = (axi_trx_os_d_rd |
//                    axi_trx_os_d_wr |
//                    ahb_trx_os_d_rd |
//                    ahb_trx_os_d_wr |
//                    apb_trx_os_d_rd |
//                    apb_trx_os_d_wr |
//                    tcm0_trx_os_d_rd    |
//                    tcm0_trx_os_d_wr    |
//                    tcm1_trx_os_d_rd    |
//                    tcm1_trx_os_d_wr    |
//                    udma_trx_os_d_rd     |
//                    udma_trx_os_d_wr);         
  
  assign fence_op_d_resp_valid    = cpu_d_resp_is_fence & d_trx_resp_valid & ~d_trx_os;                                                                                                                         
  assign fence_op_d_resp_error    = 1'b0;
  
  assign fence_d_req_ready      = 1'b1; 
  assign fence_d_resp_rd_data   = {32{1'b0}};
  assign fence_d_resp_rd_data_p = {4{1'b0}};
  
  // Need to ensure a response has been received for all transactions made before allowing debug mode to be left,
  // therefore indicate to debug module when all transactions are complete (from the perspective of the SUBSYS)
  // only need to deal with d-side outstanding as all debug requests are made to the d-side.
  assign debug_trx_os = |d_trx_resp_valid_pkd;
  

                                                                                                       

//******************************************************************************
// properties
//********************************************************************************
`ifdef SUBSYS_RTL_PROPS

  assert_subsys_cpu_i_req_is_onehot: assert property (@(posedge clk) disable iff (~resetn)
                                                     cpu_i_req_valid |-> $onehot({cpu_i_req_is_apb,
                                                                                  cpu_i_req_is_ahb,
                                                                                  cpu_i_req_is_axi,
                                                                                  cpu_i_req_is_tcm0,
                                                                                  cpu_i_req_is_tcm1,
                                                                                  cpu_i_req_is_dummy_target}));

  assert_subsys_cpu_i_resp_is_onehot: assert property (@(posedge clk) disable iff (~resetn)
                                                     cpu_i_resp_valid |-> $onehot({cpu_i_resp_is_apb,
                                                                                   cpu_i_resp_is_ahb,
                                                                                   cpu_i_resp_is_axi,
                                                                                   cpu_i_resp_is_tcm0,
                                                                                   cpu_i_resp_is_tcm1,
                                                                                   cpu_i_resp_is_dummy_target}));
                                                                                   
                                                                                   
  assert_subsys_cpu_d_req_is_onehot: assert property (@(posedge clk) disable iff (~resetn)
                                                     cpu_d_req_valid_mux |-> $onehot({cpu_d_req_is_apb,
                                                                                  cpu_d_req_is_ahb,
                                                                                  cpu_d_req_is_axi,
                                                                                  cpu_d_req_is_tcm0,
                                                                                  cpu_d_req_is_tcm1,
                                                                                  cpu_d_req_is_udma_ctrl,
                                                                                  cpu_d_req_is_subsys_cfg,
                                                                                  cpu_d_req_is_dummy_target,
                                                                                  cpu_d_req_is_fence}));

  assert_subsys_cpu_d_resp_is_onehot: assert property (@(posedge clk) disable iff (~resetn)
                                                     cpu_d_resp_valid_sig |-> $onehot({cpu_d_resp_is_apb,
                                                                                   cpu_d_resp_is_ahb,
                                                                                   cpu_d_resp_is_axi,
                                                                                   cpu_d_resp_is_tcm0,
                                                                                   cpu_d_resp_is_tcm1,
                                                                                   cpu_d_resp_is_udma_ctrl,
                                                                                   cpu_d_resp_is_subsys_cfg,
                                                                                   cpu_d_resp_is_dummy_target,
                                                                                   cpu_d_resp_is_fence}));   
                                                                                   
   //-------------                                                              
   // covers
   //------------
   
   sequence seq_subsys_ic_cpu_i_any_req_consec(cycles);
      (cpu_i_req_accepted)[*cycles] ;
   endsequence 
   
   sequence seq_subsys_ic_cpu_i_any_resp_consec(cycles);
      (cpu_i_resp_accepted)[*cycles] ;
   endsequence 

   // cpu i apb initiator request and response   
   sequence seq_subsys_ic_cpu_i_apb_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_apb)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_apb_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_apb)[*cycles] ;
   endsequence       
   
   // cpu i ahb initiator request and response   
   sequence seq_subsys_ic_cpu_i_ahb_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_ahb)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_ahb_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_ahb)[*cycles] ;
   endsequence      
   
   // cpu i axi initiator request and response   
   sequence seq_subsys_ic_cpu_i_axi_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_axi)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_axi_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_axi)[*cycles] ;
   endsequence       
   
   // cpu i tcm0 request and response   
   sequence seq_subsys_ic_cpu_i_tcm0_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_tcm0)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_tcm0_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_tcm0)[*cycles] ;
   endsequence  
   
   // cpu i tcm1 request and response   
   sequence seq_subsys_ic_cpu_i_tcm1_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_tcm1)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_tcm1_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_tcm1)[*cycles] ;
   endsequence   
   
   // cpu i dummy_target (illegal address) request and response   
   sequence seq_subsys_ic_cpu_i_dummy_target_req_consec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_dummy_target)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_dummy_target_resp_consec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_dummy_target)[*cycles] ;
   endsequence            
   
   sequence seq_subsys_ic_cpu_d_any_req_consec(cycles);
      (cpu_d_req_accepted)[*cycles] ;
   endsequence 
   
   sequence seq_subsys_ic_cpu_d_any_resp_consec(cycles);
      (cpu_d_resp_accepted)[*cycles] ;
   endsequence 

   // cpu d apb initiator request and response   
   sequence seq_subsys_ic_cpu_d_apb_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_apb)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_apb_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_apb)[*cycles] ;
   endsequence       
   
   // cpu d ahb initiator request and response   
   sequence seq_subsys_ic_cpu_d_ahb_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_ahb)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_ahb_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_ahb)[*cycles] ;
   endsequence      
   
   // cpu d axi initiator request and response   
   sequence seq_subsys_ic_cpu_d_axi_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_axi)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_axi_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_axi)[*cycles] ;
   endsequence       
   
   // cpu d tcm0 request and response   
   sequence seq_subsys_ic_cpu_d_tcm0_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_tcm0)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_tcm0_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_tcm0)[*cycles] ;
   endsequence  
   
   // cpu d tcm1 request and response   
   sequence seq_subsys_ic_cpu_d_tcm1_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_tcm1)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_tcm1_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_tcm1)[*cycles] ;
   endsequence 
     
   // cpu d udma_ctrl (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_udma_ctrl_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_udma_ctrl)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_udma_ctrl_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_udma_ctrl)[*cycles] ;
   endsequence  
   
   // cpu d subsys_cfg request and response   
   sequence seq_subsys_ic_cpu_d_subsys_cfg_d_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_subsys_cfg)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_subsys_cfg_d_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_subsys_cfg)[*cycles] ;
   endsequence  
      
   // cpu d dummy_target (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_dummy_target_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_dummy_target)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_dummy_target_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_dummy_target)[*cycles] ;
   endsequence                                                              
      
   // cpu d fence (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_fence_req_consec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_fence)[*cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_fence_resp_consec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_fence)[*cycles] ;
   endsequence  
      
   sequence seq_subsys_ic_cpu_i_any_req_nonconsec(cycles);
      (cpu_i_req_accepted)[->cycles] ;
   endsequence 
   
   sequence seq_subsys_ic_cpu_i_any_resp_nonconsec(cycles);
      (cpu_i_resp_accepted)[->cycles] ;
   endsequence 

   // cpu i apb initiator request and response   
   sequence seq_subsys_ic_cpu_i_apb_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_apb)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_apb_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_apb)[->cycles] ;
   endsequence       
   
   // cpu i ahb initiator request and response   
   sequence seq_subsys_ic_cpu_i_ahb_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_ahb)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_ahb_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_ahb)[->cycles] ;
   endsequence      
   
   // cpu i axi initiator request and response   
   sequence seq_subsys_ic_cpu_i_axi_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_axi)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_axi_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_axi)[->cycles] ;
   endsequence       
   
   // cpu i tcm0 request and response   
   sequence seq_subsys_ic_cpu_i_tcm0_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_tcm0)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_tcm0_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_tcm0)[->cycles] ;
   endsequence  
   
   // cpu i tcm1 request and response   
   sequence seq_subsys_ic_cpu_i_tcm1_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_tcm1)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_tcm1_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_tcm1)[->cycles] ;
   endsequence   
   
   // cpu i dummy_target (illegal address) request and response   
   sequence seq_subsys_ic_cpu_i_dummy_target_req_nonconsec(cycles);
      (cpu_i_req_accepted & cpu_i_req_is_dummy_target)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_i_dummy_target_resp_nonconsec(cycles);
      (cpu_i_resp_accepted & cpu_i_resp_is_dummy_target)[->cycles] ;
   endsequence            
   
   sequence seq_subsys_ic_cpu_d_any_req_nonconsec(cycles);
      (cpu_d_req_accepted)[->cycles] ;
   endsequence 
   
   sequence seq_subsys_ic_cpu_d_any_resp_nonconsec(cycles);
      (cpu_d_resp_accepted)[->cycles] ;
   endsequence 

   // cpu d apb initiator request and response   
   sequence seq_subsys_ic_cpu_d_apb_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_apb)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_apb_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_apb)[->cycles] ;
   endsequence       
   
   // cpu d ahb initiator request and response   
   sequence seq_subsys_ic_cpu_d_ahb_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_ahb)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_ahb_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_ahb)[->cycles] ;
   endsequence      
   
   // cpu d axi initiator request and response   
   sequence seq_subsys_ic_cpu_d_axi_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_axi)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_axi_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_axi)[->cycles] ;
   endsequence       
   
   // cpu d tcm0 request and response   
   sequence seq_subsys_ic_cpu_d_tcm0_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_tcm0)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_tcm0_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_tcm0)[->cycles] ;
   endsequence  
   
   // cpu d tcm1 request and response   
   sequence seq_subsys_ic_cpu_d_tcm1_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_tcm1)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_tcm1_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_tcm1)[->cycles] ;
   endsequence 
     
   // cpu d udma_ctrl (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_udma_ctrl_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_udma_ctrl)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_udma_ctrl_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_udma_ctrl)[->cycles] ;
   endsequence  
   
   // cpu d subsys_cfg (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_subsys_cfg_d_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_subsys_cfg)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_subsys_cfg_d_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_subsys_cfg)[->cycles] ;
   endsequence  
      
   // cpu d dummy_target (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_dummy_target_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_dummy_target)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_dummy_target_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_dummy_target)[->cycles] ;
   endsequence                                                              
      
   // cpu d fence (illegal address) request and response   
   sequence seq_subsys_ic_cpu_d_fence_req_nonconsec(cycles);
      (cpu_d_req_accepted & cpu_d_req_is_fence)[->cycles] ;
   endsequence      
   
   sequence seq_subsys_ic_cpu_d_fence_resp_nonconsec(cycles);
      (cpu_d_resp_accepted & cpu_d_resp_is_fence)[->cycles] ;
   endsequence    
   
  genvar i_cover_seq;
  generate
  for (i_cover_seq = 1; i_cover_seq <= 5; i_cover_seq++) begin : gen_cover_req_resp_seq
  
    cover_subsys_ic_cpu_i_any_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_any_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_any_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_any_resp_consec(i_cover_seq));                                                       
                                                         
    cover_subsys_ic_cpu_i_apb_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_apb_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_apb_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_apb_resp_consec(i_cover_seq)); 
                                                         
    cover_subsys_ic_cpu_i_ahb_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_ahb_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_ahb_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_ahb_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_axi_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_axi_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_axi_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_axi_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_tcm0_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm0_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_tcm0_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm0_resp_consec(i_cover_seq));  
                                                                                                                  
    cover_subsys_ic_cpu_i_tcm1_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm1_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_tcm1_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm1_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_dummy_target_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_dummy_target_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_dummy_target_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_dummy_target_resp_consec(i_cover_seq));         
                                                         
    cover_subsys_ic_cpu_d_any_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_any_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_any_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_any_resp_consec(i_cover_seq));                                                       
                                                         
    cover_subsys_ic_cpu_d_apb_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_apb_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_apb_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_apb_resp_consec(i_cover_seq)); 
                                                         
    cover_subsys_ic_cpu_d_ahb_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_ahb_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_ahb_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_ahb_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_axi_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_axi_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_axi_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_axi_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_tcm0_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm0_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_tcm0_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm0_resp_consec(i_cover_seq));  
                                                                                                                  
    cover_subsys_ic_cpu_d_tcm1_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm1_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_tcm1_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm1_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_dummy_target_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_dummy_target_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_dummy_target_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_dummy_target_resp_consec(i_cover_seq));   
                                                         
    cover_subsys_ic_cpu_d_udma_ctrl_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_udma_ctrl_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_udma_ctrl_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_udma_ctrl_resp_consec(i_cover_seq));   
                                                         
    cover_subsys_ic_cpu_d_subsys_cfg_d_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_subsys_cfg_d_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_subsys_cfg_d_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_subsys_cfg_d_resp_consec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_fence_req_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_fence_req_consec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_fence_resp_consec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_fence_resp_consec(i_cover_seq));  
                                                         
                                                         
                                                         
                                                         
                                                         
    
    cover_subsys_ic_cpu_i_any_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_any_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_any_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_any_resp_nonconsec(i_cover_seq));                                                       
                                                         
    cover_subsys_ic_cpu_i_apb_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_apb_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_apb_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_apb_resp_nonconsec(i_cover_seq)); 
                                                         
    cover_subsys_ic_cpu_i_ahb_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_ahb_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_ahb_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_ahb_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_axi_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_axi_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_axi_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_axi_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_tcm0_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm0_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_tcm0_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm0_resp_nonconsec(i_cover_seq));  
                                                                                                                  
    cover_subsys_ic_cpu_i_tcm1_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm1_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_tcm1_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_tcm1_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_i_dummy_target_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_dummy_target_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_i_dummy_target_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_i_dummy_target_resp_nonconsec(i_cover_seq));         
                                                         
    cover_subsys_ic_cpu_d_any_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_any_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_any_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_any_resp_nonconsec(i_cover_seq));                                                       
                                                         
    cover_subsys_ic_cpu_d_apb_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_apb_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_apb_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_apb_resp_nonconsec(i_cover_seq)); 
                                                         
    cover_subsys_ic_cpu_d_ahb_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_ahb_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_ahb_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_ahb_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_axi_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_axi_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_axi_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_axi_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_tcm0_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm0_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_tcm0_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm0_resp_nonconsec(i_cover_seq));  
                                                                                                                  
    cover_subsys_ic_cpu_d_tcm1_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm1_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_tcm1_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_tcm1_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_dummy_target_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_dummy_target_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_dummy_target_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_dummy_target_resp_nonconsec(i_cover_seq));   
                                                         
    cover_subsys_ic_cpu_d_udma_ctrl_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_udma_ctrl_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_udma_ctrl_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_udma_ctrl_resp_nonconsec(i_cover_seq));   
                                                         
    cover_subsys_ic_cpu_d_subsys_cfg_d_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_subsys_cfg_d_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_subsys_cfg_d_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_subsys_cfg_d_resp_nonconsec(i_cover_seq));  
                                                         
    cover_subsys_ic_cpu_d_fence_req_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_fence_req_nonconsec(i_cover_seq));
  
    cover_subsys_ic_cpu_d_fence_resp_nonconsec: cover property (@(posedge clk) disable iff (~resetn)
                                                         seq_subsys_ic_cpu_d_fence_resp_nonconsec(i_cover_seq));                                                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                                                                                           
                                                                                                                
                                                         
  end
  endgenerate                                                                                    
                                                                                                                                                                   

`endif

endmodule


`default_nettype wire

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
// SVN $Revision: 43976 $
// SVN $Date: 2023-08-31 14:29:57 +0100 (Thu, 31 Aug 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
// SAR 120729 - Reserved OPSRV Register space for ASIC customer
// Notes:
// 	Memory space 0x6000 to 0x6FFF is allocated for SUBSYS Registers.
// 	Please see SAR 120729 - Reserved OPSRV Register space for ASIC customer
// 	To resolve this SAR the address range from 0x6C00 to 6FFF has been reserved by DCS for their application
// 	The address range available to the MIV_RV32 is therefore restricted to the range 0x6000 to 0x6BFC
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_regs.sv
//
//   Purpose:
//    subsys configuration and control registers
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_regs
//********************************************************************************
// Parameter description

  #(   
    

    parameter REGS_ADDR_WIDTH              = 12,
	parameter ECC_ENABLE                   = 0,
    parameter l_subsys_cfg_tcm0_present    = 1,
	parameter l_subsys_cfg_axi_present     = 1,
    parameter l_subsys_gpr_ded_reset_en    = 1,
	parameter ICACHE_EN                    = 0,
	parameter l_miv_rv32_version           = 32'h030100C8

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,
    
    input wire  logic                            sys_parity_disable,

    
    // CPU control interface
    input wire  logic                            cpu_regs_req_valid,
    output      logic                            cpu_regs_req_ready, 
    input wire  logic [3:0]                      cpu_regs_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_regs_req_wr_byte_en,
    input wire  logic                            cpu_regs_req_read,
    input wire  logic                            cpu_regs_req_write,
    input wire  logic [REGS_ADDR_WIDTH-1:0]      cpu_regs_req_addr,
    input wire  logic                            cpu_regs_req_addr_p,
    input wire  logic [31:0]                     cpu_regs_req_wr_data,
    input wire  logic [3:0]                      cpu_regs_req_wr_data_p,
    output      logic                            cpu_regs_resp_valid,
    input wire  logic                            cpu_regs_resp_ready,
    output      logic                            cpu_regs_resp_error,
    output      logic [31:0]                     cpu_regs_resp_rd_data,
    output      logic [3:0]                      cpu_regs_resp_rd_data_p,
       
	 
	
    input wire  logic                            cpu_regs_icache_ecc_err_correctable,  
    input wire  logic                            cpu_regs_icache_ecc_err_uncorrectable,
    input wire  logic                            cpu_regs_tcm0_ecc_err_correctable,  
    input wire  logic                            cpu_regs_tcm0_ecc_err_uncorrectable,
    input wire  logic                            cpu_regs_tcm1_ecc_err_correctable,  
    input wire  logic                            cpu_regs_tcm1_ecc_err_uncorrectable,
    input wire  logic                            cpu_regs_axi_wr_resp_err,
    input wire  logic                            cpu_regs_udma_ctrl_irq,
    
    output      logic [1:0]                      cpu_regs_subsys_irq,
    
    output      logic                            cpu_regs_subsys_parity_en,
    output      logic [1:0]                      cpu_regs_axi_rd_cfg_min_size,
    output      logic [1:0]                      cpu_regs_axi_wr_cfg_min_size,   
    output      logic                            cpu_regs_cfg_fence_all_src,  
    output      logic [3:0]                      cpu_regs_cfg_ar_cache,       
    output      logic [3:0]                      cpu_regs_cfg_aw_cache,       
    output      logic                            cpu_regs_cfg_raw_hzd_check,  
    output      logic                            cpu_regs_cfg_war_hzd_check,  
    
    output      logic                            cpu_regs_hart_soft_reset,                   //hart_soft_reset module output
    output      logic                            cpu_regs_hart_soft_irq,                     //hart_soft_irq module output
    
    input wire  logic                            gpr_ded_soft_reset,                          //gpr ded soft reset input
	
	
    output      logic [1:0]                      gpr_ecc_error_injection,
    output      logic [1:0]                      tcm_ecc_error_injection,
    output      logic [1:0]                      icache_ecc_error_injection
    
  );

//********************************************************************************
// Declarations

// localparams

  localparam REQ_BUFF_WIDTH = 7; //KOH
  localparam REQ_BUFF_DEPTH = 2;
  localparam LOG2_REQ_BUFF_DEPTH = 1;



// Internal nets

  logic                                       req_is_miv_rv32_ver_reg;
  logic                                       resp_is_miv_rv32_ver_reg;
  logic                                       read_miv_rv32_ver_reg;  
  logic                                       write_miv_rv32_ver_reg;  
  logic [31:0]                                miv_rv32_ver_reg;
  logic [31:0]                                miv_rv32_ver_reg_rd_data;
  
  
  logic                                       req_is_miv_rv32_err_inj_reg;
  logic                                       resp_is_miv_rv32_err_inj_reg;
  logic                                       read_miv_rv32_err_inj_reg;  
  logic                                       write_miv_rv32_err_inj_reg;  
  logic [31:0]                                miv_rv32_err_inj_reg;
  logic [31:0]                                miv_rv32_err_inj_reg_rd_data;
  
  logic                                       req_is_subsys_cfg_reg;
  logic                                       resp_is_subsys_cfg_reg;
  logic                                       read_subsys_cfg_reg;
  logic                                       write_subsys_cfg_reg;
  logic                                       subsys_parity_en_reg;
  logic                                       write_parity_en_reg;
  logic [31:0]                                subsys_cfg_reg;
  logic [31:0]                                subsys_cfg_reg_rd_data;
  
  
  logic                                       req_is_subsys_irq_en;
  logic                                       resp_is_subsys_irq_en;
  logic                                       read_subsys_irq_en_reg;
  logic                                       write_subsys_irq_en_reg;
  logic                                       subsys_irq_tcm0_ecc_err_corr_en_reg;
  logic                                       subsys_irq_tcm0_ecc_err_uncorr_en_reg;
  logic                                       subsys_irq_tcm1_ecc_err_corr_en_reg;
  logic                                       subsys_irq_tcm1_ecc_err_uncorr_en_reg;
  logic                                       subsys_irq_axi_write_err_en_reg;
  logic                                       subsys_irq_icache_ecc_err_corr_en_reg;
  logic                                       subsys_irq_icache_ecc_err_uncorr_en_reg;
  logic [31:0]                                subsys_irq_en_reg;
  logic [31:0]                                subsys_irq_en_reg_rd_data;
    
  logic                                       req_is_subsys_irq_pend;
  logic                                       resp_is_subsys_irq_pend;
  logic                                       read_subsys_irq_pend_reg;
  logic                                       write_subsys_irq_pend_reg;
  logic                                       subsys_irq_tcm0_ecc_err_corr_pend_reg;
  logic                                       subsys_irq_tcm0_ecc_err_uncorr_pend_reg;
  logic                                       subsys_irq_tcm1_ecc_err_corr_pend_reg;
  logic                                       subsys_irq_tcm1_ecc_err_uncorr_pend_reg;
  logic                                       subsys_irq_axi_write_err_pend_reg;
  logic                                       subsys_irq_icache_ecc_err_corr_pend_reg;
  logic                                       subsys_irq_icache_ecc_err_uncorr_pend_reg;
  logic [31:0]                                subsys_irq_pend_reg;
  logic [31:0]                                subsys_irq_pend_reg_rd_data;
  
  logic                                       req_buffer_req_valid;
  logic                                       req_buffer_req_ready;
  logic [REQ_BUFF_WIDTH-1:0]                  req_buffer_reg_sel;
  logic                                       req_buffer_resp_valid;
  logic [REQ_BUFF_WIDTH-1:0]                  req_buffer_resp_sel;
  logic [(REQ_BUFF_WIDTH*REQ_BUFF_DEPTH)-1:0] req_buffer_resp_sel_pkd;
  logic [REQ_BUFF_DEPTH-1:0]                  req_buffer_resp_valid_pkd;
  logic                                       resp_is_read;
  logic [31:0]                                reg_rd_data;
  logic                                       req_wr_hzd;
  
  // Internal nets for hart_soft_reset reg
  logic      								  resp_is_subsys_hart_soft_reg;
  logic                                       req_is_subsys_hart_soft_reg;
  logic                                       write_subsys_hart_soft_reg;
  logic                                       read_subsys_hart_soft_reg;
  logic [31:0]                                subsys_hart_soft_reg;
  logic [31:0]                                subsys_hart_soft_reg_rd_data;
  
  logic                                       toggle_hart_soft_reset;


//********************************************************************************
// Main code
//********************************************************************************

  
  //-------------------------------------
  // subsys_cfg 
  // SUBSYS configuration register
  // address: 0x000
  // bit description:
  //          [0] subsys_parity_en
  //
  //-------------------------------------
  
  assign req_is_subsys_cfg_reg  = (cpu_regs_req_addr == 12'h000) & cpu_regs_req_valid;
  assign read_subsys_cfg_reg    = resp_is_subsys_cfg_reg & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
  assign write_subsys_cfg_reg   = req_is_subsys_cfg_reg & cpu_regs_req_write & cpu_regs_req_ready;
  
  // subsys_parity_en_reg
  
  assign write_parity_en_reg = write_subsys_cfg_reg & cpu_regs_req_wr_byte_en[0];
  
  miv_rv32_csr_gpr_state_reg
  #(
    .WIDTH               (1),  
    .FIELD_RESET_EN      (1),
    .FIELD_RESET_VAL     (0)
  )
  u_subsys_parity_en_reg
  (
    .clk                         (clk),
    .resetn                      (resetn),
    .init_wr_en                  (1'b0),
    .init_wr_data                (1'b0),
    .machine_implicit_wr_en      (1'b0),
    .machine_implicit_wr_data    (1'b0),
    .machine_sw_wr_en            (1'b0), // REVISIT - Add write_parity_en_reg if parity used
    .machine_sw_wr_data          (1'b0), // REVISIT - Add cpu_regs_req_wr_data[0] if parity used
    .state_val                   (subsys_parity_en_reg)
  );
  
  
  assign subsys_cfg_reg = { {31{1'b0}}, subsys_parity_en_reg};
  
  assign subsys_cfg_reg_rd_data = {32{read_subsys_cfg_reg}} & subsys_cfg_reg;
  
  //-------------------------------------
  // interrupt registers.
  // SUBSYS has 2 interrupt status registers with corresponding enable registers
  // When an enabled interrupt is asserted, an interrupt is generated to the hart
  // Interrupt reg 0 (error bits)
  //  tcm0_ecc_err_correctable  
  //  tcm0_ecc_err_uncorrectable
  //  tcm1_ecc_err_correctable  
  //  tcm1_ecc_err_uncorrectable
  //  axi_d_wr_resp_err
  //  icache_ecc_err_correctable  
  //  icache_ecc_err_uncorrectable
  //
  // Interrupt reg 1 (udma) - not implemented yet
  //  udma_ctrl_irq 
  
  
  //-------------------------------------
  // subsys_irq_en 
  // SUBSYS IRQ enable register
  // address: 0x010
  // bit description:
  //          [0] tcm0 ecc_err_correctable enable   
  //          [1] tcm0 ecc_err_uncorrectable enable
  //          [2] tcm1 ecc_err_correctable enable 
  //          [3] tcm1 ecc_err_uncorrectable enable
  //          [4] Axi initiator_write response error enable
  //          [5] Reserved
  //          [6] icache ecc_err_correctable enable   
  //          [7] icache ecc_err_uncorrectable enable
  //
  //-------------------------------------
  
  assign req_is_subsys_irq_en      = (cpu_regs_req_addr == 12'h010) & cpu_regs_req_valid;
  assign read_subsys_irq_en_reg    = resp_is_subsys_irq_en & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
  assign write_subsys_irq_en_reg   = req_is_subsys_irq_en & cpu_regs_req_write & cpu_regs_req_ready;
  
  generate
  if(l_subsys_cfg_tcm0_present & ECC_ENABLE) begin: gen_tcm0_irq
  
    logic       write_subsys_irq_tcm0_ecc_err_en;
    logic [1:0] subsys_irq_tcm0_ecc_err_en_reg;
    
    assign write_subsys_irq_tcm0_ecc_err_en   = write_subsys_irq_en_reg & cpu_regs_req_wr_byte_en[0];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (2),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm0_ecc_err_en_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (2'b00),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (2'b00),
      .machine_sw_wr_en            (write_subsys_irq_tcm0_ecc_err_en),
      .machine_sw_wr_data          (cpu_regs_req_wr_data[1:0]),
      .state_val                   (subsys_irq_tcm0_ecc_err_en_reg)
    );
    
    assign subsys_irq_tcm0_ecc_err_corr_en_reg   = subsys_irq_tcm0_ecc_err_en_reg[0];
    assign subsys_irq_tcm0_ecc_err_uncorr_en_reg = subsys_irq_tcm0_ecc_err_en_reg[1];
  
  end
  else begin : ngen_tcm0_irq
    assign subsys_irq_tcm0_ecc_err_corr_en_reg   = 1'b0;
    assign subsys_irq_tcm0_ecc_err_uncorr_en_reg = 1'b0;
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_tcm1_present) begin: gen_tcm1_irq
  
    logic       write_subsys_irq_tcm1_ecc_err_en;
    logic [1:0] subsys_irq_tcm1_ecc_err_en_reg;
    
    assign write_subsys_irq_tcm1_ecc_err_en   = write_subsys_irq_en_reg & cpu_regs_req_wr_byte_en[0];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (2),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm1_ecc_err_en_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (2'b00),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (2'b00),
      .machine_sw_wr_en            (write_subsys_irq_tcm1_ecc_err_en),
      .machine_sw_wr_data          (cpu_regs_req_wr_data[3:2]),
      .state_val                   (subsys_irq_tcm1_ecc_err_en_reg)
    );
    
    assign subsys_irq_tcm1_ecc_err_corr_en_reg   = subsys_irq_tcm1_ecc_err_en_reg[0];
    assign subsys_irq_tcm1_ecc_err_uncorr_en_reg = subsys_irq_tcm1_ecc_err_en_reg[1];
  
  end
  else begin : ngen_tcm1_irq
    assign subsys_irq_tcm1_ecc_err_corr_en_reg   = 1'b0;
    assign subsys_irq_tcm1_ecc_err_uncorr_en_reg = 1'b0;
  end   
  endgenerate
  
  generate
  if(l_subsys_cfg_axi_present) begin:  gen_axi_irq
  
    logic        write_subsys_irq_axi_write_err_en;
    
    assign write_subsys_irq_axi_write_err_en   = write_subsys_irq_en_reg & cpu_regs_req_wr_byte_en[0];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_axi_ecc_err_en_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (1'b0),
      .machine_sw_wr_en            (write_subsys_irq_axi_write_err_en),
      .machine_sw_wr_data          (cpu_regs_req_wr_data[4]),
      .state_val                   (subsys_irq_axi_write_err_en_reg)
    );
    
  
  end
  else begin : ngen_axi_irq
    assign subsys_irq_axi_write_err_en_reg   = 1'b0;
  end   
  endgenerate
  
  generate
  if(ICACHE_EN & ECC_ENABLE) begin: gen_icache_irq
  
    logic       write_subsys_irq_icache_ecc_err_en;
    logic [1:0] subsys_irq_icache_ecc_err_en_reg;
    
    assign write_subsys_irq_icache_ecc_err_en   = write_subsys_irq_en_reg & cpu_regs_req_wr_byte_en[0];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (2),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_icache_ecc_err_en_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (2'b00),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (2'b00),
      .machine_sw_wr_en            (write_subsys_irq_icache_ecc_err_en),
      .machine_sw_wr_data          (cpu_regs_req_wr_data[7:6]),
      .state_val                   (subsys_irq_icache_ecc_err_en_reg)
    );
    
    assign subsys_irq_icache_ecc_err_corr_en_reg   = subsys_irq_icache_ecc_err_en_reg[0];
    assign subsys_irq_icache_ecc_err_uncorr_en_reg = subsys_irq_icache_ecc_err_en_reg[1];
  
  end
  else begin : ngen_icache_irq
    assign subsys_irq_icache_ecc_err_corr_en_reg   = 1'b0;
    assign subsys_irq_icache_ecc_err_uncorr_en_reg = 1'b0;
  end   
  endgenerate  
  
  assign subsys_irq_en_reg = { {24{1'b0}},
                              subsys_irq_icache_ecc_err_uncorr_en_reg,
                              subsys_irq_icache_ecc_err_corr_en_reg,
							  1'b0,
                              subsys_irq_axi_write_err_en_reg,
                              subsys_irq_tcm1_ecc_err_uncorr_en_reg,
                              subsys_irq_tcm1_ecc_err_corr_en_reg,
                              subsys_irq_tcm0_ecc_err_uncorr_en_reg,
                              subsys_irq_tcm0_ecc_err_corr_en_reg};
  
  assign subsys_irq_en_reg_rd_data = {32{read_subsys_irq_en_reg}} & subsys_irq_en_reg;
     
  //-------------------------------------
  // subsys_irq_pend 
  // SUBSYS IRQ pending register
  // address: 0x014
  // bit description:
  // bit description:
  //          [0] tcm0 ecc_err_correctable pending   
  //          [1] tcm0 ecc_err_uncorrectable pending
  //          [2] tcm1 ecc_err_correctable pending 
  //          [3] tcm1 ecc_err_uncorrectable pending
  //          [4] Axi initiator_write response error pending
  //          [5] Reserved
  //          [6] icache ecc_err_correctable pending   
  //          [7] icache ecc_err_uncorrectable pending
  //
  //-------------------------------------
  
  // pending bits are set when the interrupt source is asserted and remain set until 
  // cleared by the CPU writing a '1' to the register bit

  
  assign req_is_subsys_irq_pend      = (cpu_regs_req_addr == 12'h014) & cpu_regs_req_valid;
  assign read_subsys_irq_pend_reg    = resp_is_subsys_irq_pend & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
  assign write_subsys_irq_pend_reg   = req_is_subsys_irq_pend & cpu_regs_req_write & cpu_regs_req_ready;
  
  generate
  if(l_subsys_cfg_tcm0_present) begin: gen_tcm0_irq_pend
  
    logic       write_subsys_irq_tcm0_ecc_err_corr_pend;
    logic       write_subsys_irq_tcm0_ecc_err_uncorr_pend;
    
    assign write_subsys_irq_tcm0_ecc_err_corr_pend   = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[0];
    assign write_subsys_irq_tcm0_ecc_err_uncorr_pend = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[1];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm0_ecc_err_corr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_tcm0_ecc_err_correctable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_tcm0_ecc_err_corr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_tcm0_ecc_err_corr_pend_reg)
    );
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm0_ecc_err_uncorr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_tcm0_ecc_err_uncorrectable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_tcm0_ecc_err_uncorr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_tcm0_ecc_err_uncorr_pend_reg)
    );
   
  end
  else begin : ngen_tcm0_irq_pend
  
    assign subsys_irq_tcm0_ecc_err_corr_pend_reg   = 1'b0;
    assign subsys_irq_tcm0_ecc_err_uncorr_pend_reg = 1'b0;
    
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_tcm1_present) begin: gen_tcm1_irq_pend
  
    logic       write_subsys_irq_tcm1_ecc_err_corr_pend;
    logic       write_subsys_irq_tcm1_ecc_err_uncorr_pend;
    
    assign write_subsys_irq_tcm1_ecc_err_corr_pend   = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[2];
    assign write_subsys_irq_tcm1_ecc_err_uncorr_pend = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[3];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm1_ecc_err_corr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_tcm1_ecc_err_correctable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_tcm1_ecc_err_corr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_tcm1_ecc_err_corr_pend_reg)
    );
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_tcm1_ecc_err_uncorr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_tcm1_ecc_err_uncorrectable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_tcm1_ecc_err_uncorr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_tcm1_ecc_err_uncorr_pend_reg)
    );
   
  end
  else begin : ngen_tcm1_irq_pend
  
    assign subsys_irq_tcm1_ecc_err_corr_pend_reg   = 1'b0;
    assign subsys_irq_tcm1_ecc_err_uncorr_pend_reg = 1'b0;
    
  end   
  endgenerate  
  
  generate
  if(l_subsys_cfg_axi_present) begin:  gen_axi_irq_pend

    logic        write_subsys_irq_axi_write_err_pend;
    
    assign write_subsys_irq_axi_write_err_pend   = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[4];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_axi_ecc_err_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_axi_wr_resp_err),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_axi_write_err_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_axi_write_err_pend_reg)
    );   
  
  end
  else begin : ngen_axi_irq_pend
  
    assign subsys_irq_axi_write_err_pend_reg   = 1'b0;
    
  end   
  endgenerate
  
  
  generate
  if(ICACHE_EN & ECC_ENABLE) begin: gen_icache_irq_pend
  
    logic       write_subsys_irq_icache_ecc_err_corr_pend;
    logic       write_subsys_irq_icache_ecc_err_uncorr_pend;
    
    assign write_subsys_irq_icache_ecc_err_corr_pend   = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[6];
    assign write_subsys_irq_icache_ecc_err_uncorr_pend = write_subsys_irq_pend_reg & cpu_regs_req_wr_byte_en[0] & cpu_regs_req_wr_data[7];
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_icache_ecc_err_corr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_icache_ecc_err_correctable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_icache_ecc_err_corr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_icache_ecc_err_corr_pend_reg)
    );
    
    miv_rv32_csr_gpr_state_reg
    #(
      .WIDTH               (1),  
      .FIELD_RESET_EN      (1),
      .FIELD_RESET_VAL     (0)
    )
    u_subsys_irq_icache_ecc_err_uncorr_pend_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (cpu_regs_icache_ecc_err_uncorrectable),
      .machine_implicit_wr_data    (1'b1),
      .machine_sw_wr_en            (write_subsys_irq_icache_ecc_err_uncorr_pend),
      .machine_sw_wr_data          (1'b0),
      .state_val                   (subsys_irq_icache_ecc_err_uncorr_pend_reg)
    );
   
  end
  else begin : ngen_icache_irq_pend
  
    assign subsys_irq_icache_ecc_err_corr_pend_reg   = 1'b0;
    assign subsys_irq_icache_ecc_err_uncorr_pend_reg = 1'b0;
    
  end   
  endgenerate  
  assign subsys_irq_pend_reg = { {24{1'b0}},
                              subsys_irq_icache_ecc_err_uncorr_pend_reg,
                              subsys_irq_icache_ecc_err_corr_pend_reg,
							  1'b0,
                              subsys_irq_axi_write_err_pend_reg,
                              subsys_irq_tcm1_ecc_err_uncorr_pend_reg,
                              subsys_irq_tcm1_ecc_err_corr_pend_reg,
                              subsys_irq_tcm0_ecc_err_uncorr_pend_reg,
                              subsys_irq_tcm0_ecc_err_corr_pend_reg};
  
  assign subsys_irq_pend_reg_rd_data = {32{read_subsys_irq_pend_reg}} & subsys_irq_pend_reg;

  //-------------------

  //-------------------------------------
  // subsys_hart_soft_reg 
  // SUBSYS HART SOFT RESET REGISTER
  // address: 0x020
  // bit description:
  //          [0] hart_soft_reset_reg   
  //          [1] hart_soft_irq_reg
  //          [2] hart_gpr_ded_reset_reg
  //					
  //
  //-------------------------------------
  
  assign req_is_subsys_hart_soft_reg  = (cpu_regs_req_addr == 12'h020) & cpu_regs_req_valid;
  assign read_subsys_hart_soft_reg    = resp_is_subsys_hart_soft_reg & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
  assign write_subsys_hart_soft_reg   = req_is_subsys_hart_soft_reg & cpu_regs_req_write & cpu_regs_req_ready;
  
  logic write_subsys_hart_soft_reset;
  logic subsys_hart_soft_reset_reg;
  assign write_subsys_hart_soft_reset = write_subsys_hart_soft_reg & cpu_regs_req_wr_byte_en[0];
  
  logic gpr_ded_soft_reset_dly1;
  logic gpr_ded_soft_reset_dly2;
  logic write_gpr_ded_soft_reset;  
 
  
  //synchronous logic for toggling hart_soft_reset
  always @ (posedge clk)
  begin
  if(~resetn)
    toggle_hart_soft_reset = 1'b0;
  else
    begin
    if(subsys_hart_soft_reg[0])       //if the hart_soft_reset_reg has been written to,
        toggle_hart_soft_reset = 1'b0;  //reset it to zero one clock period later in order to prevent the cpu from being locked in reset  
    else 
        toggle_hart_soft_reset = 1'b1;
    end
  end
  
     //GPR DED delay
  always @ (posedge clk) 
  begin
  if(~resetn)
    begin
      gpr_ded_soft_reset_dly1 <= 1'b0;
      gpr_ded_soft_reset_dly2 <= 1'b0;   
    end
  else  //(if(l_subsys_gpr_ded_reset_en == 0) this should all synthesise out)
      begin
        gpr_ded_soft_reset_dly1 <= gpr_ded_soft_reset;
        gpr_ded_soft_reset_dly2 <= gpr_ded_soft_reset_dly1;      
      end 
  end
 
 assign  write_gpr_ded_soft_reset = (l_subsys_gpr_ded_reset_en) ? (!gpr_ded_soft_reset_dly2 && gpr_ded_soft_reset) : 1'b0 ;//pos edge detect generates write - on reset gpr_ded_soft_reset = 1'b0 ?? check;
  
  miv_rv32_csr_gpr_state_reg
  #(
    .WIDTH               (1),  
    .FIELD_RESET_EN      (1),
    .FIELD_RESET_VAL     (0)
  )
  u_subsys_hart_soft_reset_reg
    (
      .clk                         (clk),
      .resetn                      ((resetn && toggle_hart_soft_reset)), //toggle_reset logic above used to reset the register
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (1'b0),
      .machine_sw_wr_en            (write_subsys_hart_soft_reset || write_gpr_ded_soft_reset), //soft reset write is enabled when the register is written to in software or when there is a GPR DED
      .machine_sw_wr_data          (cpu_regs_req_wr_data[0] || gpr_ded_soft_reset), //soft reset is set to a 1 when the register is written to in software or when there is a GPR DED
      .state_val                   (subsys_hart_soft_reset_reg)
    );
  
  
  logic write_subsys_hart_soft_irq;
  logic subsys_hart_soft_irq_reg;
  
  assign write_subsys_hart_soft_irq = write_subsys_hart_soft_reg & cpu_regs_req_wr_byte_en[0];
  
  miv_rv32_csr_gpr_state_reg
  #(
    .WIDTH               (1),  
    .FIELD_RESET_EN      (1),
    .FIELD_RESET_VAL     (0)
  )
  u_subsys_hart_soft_irq_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (1'b0),
      .machine_sw_wr_en            (write_subsys_hart_soft_irq),
      .machine_sw_wr_data          (cpu_regs_req_wr_data[1]),
      .state_val                   (subsys_hart_soft_irq_reg)
    );
    
  
  logic write_subsys_hart_gpr_ded_reset;
  logic subsys_hart_gpr_ded_reset_reg;
  
  assign write_subsys_hart_gpr_ded_reset = write_subsys_hart_soft_reg & cpu_regs_req_wr_byte_en[0];
  
  miv_rv32_csr_gpr_state_reg 
  #(
    .WIDTH               (1),  
    .FIELD_RESET_EN      (1),
    .FIELD_RESET_VAL     (0)
  )
  u_subsys_hart_gpr_ded_reset_reg
    (
      .clk                         (clk),
      .resetn                      (resetn),
      .init_wr_en                  (1'b0),
      .init_wr_data                (1'b0),
      .machine_implicit_wr_en      (1'b0),
      .machine_implicit_wr_data    (1'b0),
	  .machine_sw_wr_en            (write_subsys_hart_gpr_ded_reset || gpr_ded_soft_reset), // always written, l_subsys_gpr_ded_reset_en == 0
      .machine_sw_wr_data          (cpu_regs_req_wr_data[2] || gpr_ded_soft_reset),
      .state_val                   (subsys_hart_gpr_ded_reset_reg)
    );
    
    assign subsys_hart_soft_reg = { {29{1'b0}},subsys_hart_gpr_ded_reset_reg, subsys_hart_soft_irq_reg, subsys_hart_soft_reset_reg};
    
    assign subsys_hart_soft_reg_rd_data = {32{read_subsys_hart_soft_reg}} & subsys_hart_soft_reg;
	
	
		
  //-------------------------------------
  // miv_rv32_err_inj 
  // MIV_RV32 ECC Error Injection register
  // address: 0xBF8
  // bit description:
  //          [0] tcm0 error injection bit-0
  //          [1] tcm0 error injection bit-1   
  //        [5:2] Reserved
  //          [6] icache error injection bit-0  
  //          [7] icache error injection bit-1
  //       [15:8] Reserved 
  //		 [16] GPR error injection bit-0 			
  //		 [17] GPR error injection bit-1 	
  //      [31:18] Reserved 		
  //
  //
  //-------------------------------------
  generate 
  if(ECC_ENABLE & l_cfg_ecc_err_inj_en)
    begin : gen_ecc_err_inj
        assign req_is_miv_rv32_err_inj_reg  = (cpu_regs_req_addr == 12'hBF8) & cpu_regs_req_valid;
        assign read_miv_rv32_err_inj_reg    = resp_is_miv_rv32_err_inj_reg & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
		assign write_miv_rv32_err_inj_reg   = req_is_miv_rv32_err_inj_reg & cpu_regs_req_write & cpu_regs_req_ready;
        
        miv_rv32_csr_gpr_state_reg
        #(
          .WIDTH               (32),  
          .FIELD_RESET_EN      (1),
          .FIELD_RESET_VAL     (0)
        )
        u_miv_rv32_ecc_err_inj_reg
        (
          .clk                         (clk),
          .resetn                      ( (resetn && toggle_hart_soft_reset) ),
          .init_wr_en                  (1'b0),
          .init_wr_data                (32'b0),
          .machine_implicit_wr_en      (1'b0),
          .machine_implicit_wr_data    (32'b0),
          .machine_sw_wr_en            (write_miv_rv32_err_inj_reg),
          .machine_sw_wr_data          (cpu_regs_req_wr_data[31:0]),
          .state_val                   (miv_rv32_err_inj_reg )
        );
        
        assign miv_rv32_err_inj_reg_rd_data = {32{read_miv_rv32_err_inj_reg}} & miv_rv32_err_inj_reg ;
		
        assign gpr_ecc_error_injection    = miv_rv32_err_inj_reg[17:16];
        assign icache_ecc_error_injection = miv_rv32_err_inj_reg[7:6];
		assign tcm_ecc_error_injection    = miv_rv32_err_inj_reg[1:0];
    end else begin  : ngen_ecc_err_inj
        assign req_is_miv_rv32_err_inj_reg  = 1'b0;
        assign read_miv_rv32_err_inj_reg    = 1'b0;  
        assign write_miv_rv32_err_inj_reg   = 1'b0; 
        assign miv_rv32_err_inj_reg         = 32'b0;
        assign miv_rv32_err_inj_reg_rd_data = 32'b0;
        assign gpr_ecc_error_injection      = 2'b0;
        assign icache_ecc_error_injection   = 2'b0;
		assign tcm_ecc_error_injection      = 2'b0;
	end
  endgenerate
	
  //-------------------------------------
  // miv_rv32_ver 
  // MIV_RV32 version register
  // address: 0xBFC
  // bit description:
  //          [31:0] miv_rv32_version
  //
  //-------------------------------------
  assign req_is_miv_rv32_ver_reg  = (cpu_regs_req_addr == 12'hBFC) & cpu_regs_req_valid;
  assign read_miv_rv32_ver_reg    = resp_is_miv_rv32_ver_reg & req_buffer_resp_valid & cpu_regs_resp_ready & resp_is_read;
  assign write_miv_rv32_ver_reg   = 1'b0;
  
  miv_rv32_csr_gpr_state_reg
  #(
    .WIDTH               (32),  
    .FIELD_RESET_EN      (1),
    .FIELD_RESET_VAL     (l_miv_rv32_version)
  )
  u_miv_rv32_ver_reg
  (
    .clk                         (clk),
    .resetn                      (resetn),
    .init_wr_en                  (1'b1),
    .init_wr_data                (l_miv_rv32_version),
    .machine_implicit_wr_en      (1'b0),
    .machine_implicit_wr_data    (32'b0),
    .machine_sw_wr_en            (1'b0),
    .machine_sw_wr_data          (32'b0),
    .state_val                   (miv_rv32_ver_reg )
  );
  
  assign miv_rv32_ver_reg_rd_data = {32{read_miv_rv32_ver_reg}} & miv_rv32_ver_reg ;
  
	
	
  //--------------------------------------
  
  
  // CPU hart expects read responses one or more cycles after the request is accepted
  // With a small number of registers, the request path is more critical than response path, therefore buffer requests and pipeline
  // The response is the returned directly
  // If acceptance of the response is delayed, this may allow a write to overtake the read, therefore hold off acceptance of 
  // write requests if there is a read still outstanding to the same location.
  
  

  
  assign req_buffer_req_valid = cpu_regs_req_valid & ~req_wr_hzd;
  
  assign req_buffer_reg_sel = {req_is_miv_rv32_err_inj_reg,
                               req_is_miv_rv32_ver_reg,
                               req_is_subsys_hart_soft_reg, //KOH
                               req_is_subsys_irq_pend,
                               req_is_subsys_irq_en,
                               req_is_subsys_cfg_reg,
                               cpu_regs_req_read}; 
  
  miv_rv32_buffer
  #(
    .BUFF_WIDTH         (REQ_BUFF_WIDTH), 
    .BUFF_SIZE          (REQ_BUFF_DEPTH),
    .PTR_SIZE           (LOG2_REQ_BUFF_DEPTH)
  )
  u_req_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (req_buffer_req_valid),
    .ready_in           (req_buffer_req_ready),
    .data_in            (req_buffer_reg_sel),
    .data_out           (req_buffer_resp_sel),     
    .valid_out          (req_buffer_resp_valid),     
    .ready_out          (cpu_regs_resp_ready),
    .data_out_pkd       (req_buffer_resp_sel_pkd), 
    .valid_out_pkd      (req_buffer_resp_valid_pkd), 
    .nearly_full        ()  //open
  );
  
  // check for writes request to registers with read requests outstanding
  // REVISIT. If this affects timing too much, make pessimistic but improve timing by blocking writes if any read outstanding
  
  always @*
  begin : wr_hzd_loop
    integer i;
    logic [REQ_BUFF_DEPTH-1:0] tmp_wr_hzd; 
    logic [REQ_BUFF_WIDTH-1:0] curr_resp_entry;
    tmp_wr_hzd = 1'b0;
    for(i=0; i<REQ_BUFF_DEPTH; i=i+1)
    begin
      curr_resp_entry    = req_buffer_resp_sel_pkd[(i*REQ_BUFF_WIDTH)+:REQ_BUFF_WIDTH];
      tmp_wr_hzd[i]      = ((req_buffer_resp_valid_pkd[i] & curr_resp_entry[REQ_BUFF_WIDTH-1]) &                // valid read response pending
                            (|(req_buffer_reg_sel[REQ_BUFF_WIDTH-2:0] & curr_resp_entry[REQ_BUFF_WIDTH-2:0]))); // to the same register
    end
    req_wr_hzd = cpu_regs_req_write & cpu_regs_req_valid &                                                      // valid write request pending
                 (|tmp_wr_hzd);
  end                  
  
  assign {resp_is_miv_rv32_err_inj_reg,
          resp_is_miv_rv32_ver_reg,
          resp_is_subsys_hart_soft_reg, //KOH
          resp_is_subsys_irq_pend,
          resp_is_subsys_irq_en,
          resp_is_subsys_cfg_reg,
          resp_is_read} = req_buffer_resp_sel;
          
  assign reg_rd_data = subsys_cfg_reg_rd_data |   
                       subsys_irq_en_reg_rd_data |
                       subsys_irq_pend_reg_rd_data |
                       subsys_hart_soft_reg_rd_data | //KOH
					   miv_rv32_ver_reg_rd_data |
					   miv_rv32_err_inj_reg_rd_data;   
  
  // assign outputs
  assign cpu_regs_req_ready      = req_buffer_req_ready & ~req_wr_hzd;  
  assign cpu_regs_resp_valid     = req_buffer_resp_valid;
  assign cpu_regs_resp_error     = req_buffer_resp_valid & ~(|req_buffer_resp_sel[REQ_BUFF_WIDTH-2:0]);
  assign cpu_regs_resp_rd_data   = reg_rd_data;
  assign cpu_regs_resp_rd_data_p = {4{cpu_regs_subsys_parity_en}} & {(^reg_rd_data[31:24]),
                                                                    (^reg_rd_data[23:16]),
                                                                    (^reg_rd_data[15:8]),
                                                                    (^reg_rd_data[7:0])};
  
  
  assign cpu_regs_axi_rd_cfg_min_size = l_subsys_axi_rd_cfg_min_size;
  assign cpu_regs_axi_wr_cfg_min_size = l_subsys_axi_wr_cfg_min_size;
  assign cpu_regs_subsys_parity_en     = subsys_parity_en_reg & ~sys_parity_disable;
  assign cpu_regs_cfg_fence_all_src   = l_cfg_fence_all_src;
  assign cpu_regs_cfg_ar_cache        = l_subsys_cfg_ar_cache;
  assign cpu_regs_cfg_aw_cache        = l_subsys_cfg_aw_cache;
  assign cpu_regs_cfg_raw_hzd_check   = l_subsys_cfg_raw_hzd_en;
  assign cpu_regs_cfg_war_hzd_check   = l_subsys_cfg_war_hzd_en;
  
  assign cpu_regs_hart_soft_reset     = subsys_hart_soft_reg[0];     //hart_soft_reset output assigned
  assign cpu_regs_hart_soft_irq       = subsys_hart_soft_reg[1];     //hart_soft_irq output assigned
  //assign cou_regs_hart_gpr_ded        = subsys_hart_soft_reg[2];     //hart_gpr_ded output assigned
  
  assign cpu_regs_subsys_irq[0] = 1'b0;  // UDMA interupts not cureently implemented
  assign cpu_regs_subsys_irq[1] = |(subsys_irq_en_reg & subsys_irq_pend_reg);
  
  

//********************************************************************************
// properties
//********************************************************************************
`ifdef SUBSYS_RTL_PROPS

`endif 

endmodule


`default_nettype wire
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
//   File:
//   miv_rv32_subsys_ahb_initiator.sv
//
//   Purpose:
//    MIV_RV32 Bridge AHB Initiator
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module  miv_rv32_subsys_ahb_initiator
//********************************************************************************
// Parameter description

  #(   
    parameter AHB_ADDR_WIDTH       = 32,
	parameter ICACHE_EN            = 0,
	parameter ICACHE_BURST_SIZE    = 8
	

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,

    // Control/status/config    
    input wire logic                             subsys_parity_en,
    output     logic                             trx_os_d_rd,
    output     logic                             trx_os_d_wr,

    // CPU interface    
    input wire  logic                            cpu_i_req_valid,
    output      logic                            cpu_i_req_ready, 
    input wire  logic [3:0]                      cpu_i_req_rd_byte_en,
    input wire  logic [AHB_ADDR_WIDTH-1:0]       cpu_i_req_addr,
    input wire  logic                            cpu_i_req_addr_p,
    output      logic                            cpu_i_resp_valid,
    output      logic                            cpu_i_resp_last,
    input wire  logic                            cpu_i_resp_ready,
    output      logic                            cpu_i_resp_error,
    output      logic [31:0]                     cpu_i_resp_rd_data, 
    output      logic [3:0]                      cpu_i_resp_rd_data_p, 
    input wire  logic                            cpu_d_req_valid,
    output      logic                            cpu_d_req_ready, 
    input wire  logic [3:0]                      cpu_d_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_d_req_wr_byte_en,
    input wire  logic                            cpu_d_req_read,  
    input wire  logic                            cpu_d_req_write,
    input wire  logic [AHB_ADDR_WIDTH-1:0]       cpu_d_req_addr,
    input wire  logic                            cpu_d_req_addr_p,
    input wire  logic [31:0]                     cpu_d_req_wr_data,
    input wire  logic [3:0]                      cpu_d_req_wr_data_p,
    output      logic                            cpu_d_resp_valid,
    input wire  logic                            cpu_d_resp_ready,
    output      logic                            cpu_d_resp_rd_error,
    output      logic [31:0]                     cpu_d_resp_rd_data,  
    output      logic [3:0]                      cpu_d_resp_rd_data_p,   
    
    input wire  logic                            udma_req_valid,      
    output      logic                            udma_req_ready,      
    input wire  logic [3:0]                      udma_req_rd_byte_en, 
    input wire  logic [3:0]                      udma_req_wr_byte_en, 
    input wire  logic                            udma_req_read,       
    input wire  logic                            udma_req_write,      
    input wire  logic [AHB_ADDR_WIDTH-1:0]       udma_req_addr,       
    input wire  logic                            udma_req_addr_p,     
    input wire  logic [3:0]                      udma_req_len,         
    input wire  logic [31:0]                     udma_req_wr_data,     
    input wire  logic [3:0]                      udma_req_wr_data_p,   
    input wire  logic                            udma_req_wr_data_last,
    output      logic                            udma_resp_valid,      
    output      logic                            udma_resp_last,       
    input wire  logic                            udma_resp_ready,      
    output      logic                            udma_resp_rd_error,   
    output      logic [31:0]                     udma_resp_rd_data,    
    output      logic [3:0]                      udma_resp_rd_data_p,  
    
    // AHB Initiator interface
    output      logic [AHB_ADDR_WIDTH-1:0]       haddr, 
    output      logic                            haddr_p,
    output      logic [2:0]                      hburst, 
    output      logic                            hmastlock, 
    output      logic [3:0]                      hprot, 
    output      logic [2:0]                      hsize, 
    output      logic [1:0]                      htrans,
    output      logic [31:0]                     hwdata,
    output      logic [3:0]                      hwdata_p,
    output      logic                            hwrite,
    input wire  logic [31:0]                     hrdata, 
    input wire  logic [3:0]                      hrdata_p,
    input wire  logic                            hready, 
    input wire  logic                            hresp
    
  );
//********************************************************************************
// Declarations


// localparams
  localparam ADDR_ST = 2'd0, DATA_ST = 2'd1, WAIT_ST = 2'd2;
  
  localparam burst_cnt_width    = (func_clog2(ICACHE_BURST_SIZE)) + 1;
  localparam [2:0] hburst_value = (ICACHE_BURST_SIZE == 16) ? 3'b111 : 
                                  (ICACHE_BURST_SIZE == 8)  ? 3'b101 :
                                  (ICACHE_BURST_SIZE == 4)  ? 3'b011 : 3'b001;
// Internal nets

  logic [1:0]                       req_valid;                   
  logic [3:0]                       req_rd_byte_en [1:0];        
  logic [3:0]                       req_wr_byte_en [1:0];        
  logic [AHB_ADDR_WIDTH-1:0]        req_addr [1:0];              
  //logic [1:0]                       req_addr_p;                  
  logic [31:0]                      req_wr_data [1:0];           
  logic [3:0]                       req_wr_data_p [1:0];         
      
  logic [1:0]                       ahb_src_req;
  logic [1:0]                       ahb_src_gnt;
  logic [1:0]                       ahb_src_sel; 
  logic [1:0]                       ahb_resp_sel;
  
  logic                             req_valid_mux;
  logic [3:0]                       req_wr_byte_en_mux;
  logic [3:0]                       req_rd_byte_en_mux;
  logic [AHB_ADDR_WIDTH-1:0]        req_addr_mux;
  logic                             req_addr_p_mux;
  logic [31:0]                      req_wr_data_mux;
  logic [3:0]                       req_wr_data_p_mux;
  
  logic [31:0]                      resp_rd_data; 
  logic                             resp_error;
  logic [3:0]                       resp_rd_data_p;
   
  
  logic                             req_complete;
  logic                             req_complete_reg;
  logic [1:0]                       ahb_st;
  logic [1:0]                       ahb_next_st;

  logic                             hwrite_int;
  logic [2:0]                       hsize_int; 
  logic [1:0]                       htrans_int;
  
  logic                             hwrite_reg;
  logic [2:0]                       hsize_reg; 
  logic [1:0]                       htrans_reg;
  logic [AHB_ADDR_WIDTH-1:0]        haddr_reg;
  logic                             haddr_p_reg;
  
  logic [burst_cnt_width-1:0]       req_addr_cnt;
  logic                             req_burst_read;
     
//********************************************************************************
// Main code
//********************************************************************************
// Assignments
   assign hwrite = hwrite_int;
   assign hsize  = ((ahb_st == ADDR_ST) & !hready) ? 3'b0 : hsize_int ;
   assign htrans = htrans_int;

   assign udma_req_ready      = 1'b0;      
   assign udma_resp_valid     = 1'b0;            
   assign udma_resp_last      = 1'b0;              
   assign udma_resp_rd_error  = 1'b0;         
   assign udma_resp_rd_data   = 32'b0;          
   assign udma_resp_rd_data_p = 4'b0;   


 // Arbitrate between I and D-side
 
 // CPU I
  assign req_valid[0]         = cpu_i_req_valid;
  assign req_rd_byte_en[0]    = cpu_i_req_rd_byte_en;
  assign req_wr_byte_en[0]    = {4{1'b0}};
  assign req_addr[0]          = cpu_i_req_addr; 
  //assign req_addr_p[0]        = cpu_i_req_addr_p;
  assign req_wr_data[0]       = {32{1'b0}};
  assign req_wr_data_p[0]     = {4{1'b0}};
  assign cpu_i_resp_error     = resp_error;  
  assign cpu_i_resp_rd_data   = resp_rd_data;  
  assign cpu_i_resp_rd_data_p = resp_rd_data_p;   

// CPU D
  assign req_valid[1]         = cpu_d_req_valid;
  assign req_rd_byte_en[1]    = cpu_d_req_rd_byte_en;
  assign req_wr_byte_en[1]    = cpu_d_req_wr_byte_en;
  assign req_addr[1]          = cpu_d_req_addr; 
  //assign req_addr_p[1]        = cpu_d_req_addr_p;
  assign req_wr_data[1]       = cpu_d_req_wr_data;
  assign req_wr_data_p[1]     = cpu_d_req_wr_data_p;
  assign cpu_d_resp_rd_error     = resp_error; 
  assign cpu_d_resp_rd_data   = resp_rd_data;  
  assign cpu_d_resp_rd_data_p = resp_rd_data_p; 

  assign ahb_src_req = req_valid;

  miv_rv32_rr_pri_arb
  //***************************************************************
  // Parameter description
  #(
    .NUM_REQS                  (2),
    .USE_FORMAL                (1),
    .USE_SIM                   (1)
   )

  u_ahb_req_arb
  //***************************************************************
  // Signal description
  (
    .resetn              (resetn),
    .clk                 (clk),
    .unlock              (req_complete),
    .req                 (ahb_src_req),
    .gnt                 (ahb_src_gnt),            
    .sel_seq             (ahb_resp_sel),
    .sel_early           (ahb_src_sel)                   
  );
  
  always @*
  begin : raddr_mux_loop
    integer i;
    req_wr_byte_en_mux   = {4{1'b0}};
    req_rd_byte_en_mux   = {4{1'b0}};
    req_addr_mux         = {AHB_ADDR_WIDTH{1'b0}};
    req_wr_data_mux      = {32{1'b0}};
    req_wr_data_p_mux    = {4{1'b0}};
    for(i=0; i<2; i=i+1)
    begin                                                                                      
      req_wr_byte_en_mux   = req_wr_byte_en_mux | ({4{ahb_src_sel[i]}} & req_wr_byte_en[i]);   
      req_rd_byte_en_mux   = req_rd_byte_en_mux | ({4{ahb_src_sel[i]}} & req_rd_byte_en[i]); 
      req_addr_mux         = req_addr_mux       | ({AHB_ADDR_WIDTH{ahb_src_sel[i]}} & req_addr[i]);      
      req_wr_data_mux      = req_wr_data_mux    | ({32{ahb_src_sel[i]}} & req_wr_data[i]);    
      req_wr_data_p_mux    = req_wr_data_p_mux  | ({4{ahb_src_sel[i]}} & req_wr_data_p[i]);  
    end
  end
  
  
////////////////////////////////////////////////////////////////////////////////  

  assign cpu_i_resp_valid = ahb_resp_sel[0] & (req_complete | (req_burst_read & hready));  
  assign cpu_d_resp_valid = ahb_resp_sel[1] & req_complete;
  
  assign hmastlock = 1'b0;   // No lock
  assign hprot = 4'b0;       // Currently not supported 
	
	
  always @(posedge clk or negedge resetn)
    begin
      if(~resetn) begin
          req_complete_reg <= 1'b0;
          hwdata           <= {32{1'b0}};
          hwdata_p         <= {4{1'b0}};  
		  
          req_addr_cnt     <= {4{1'b0}}; 		
          req_burst_read   <= 1'b0;
		  
		  hsize_reg   = {3{1'b0}}; 	
		  hwrite_reg  = {1{1'b0}};
          htrans_reg  = {2{1'b0}};
		  haddr_reg   = {32{1'b0}};
		  haddr_p_reg = {1{1'b0}};
      end else begin
          case(ahb_st)
              ADDR_ST: begin
                         req_complete_reg <= 1'b0;
                         if(req_valid_mux) begin             
                             hwdata     <= req_wr_data_mux;
                             hwdata_p   <= req_wr_data_p_mux;
                             
							 if(hready) begin
                                 if((|req_wr_byte_en_mux) == 0) begin
						             if(ahb_src_sel[0] & ICACHE_EN) begin
                                         req_burst_read <= 1'b1;
							     		 req_addr_cnt   <= req_addr_cnt + 1'd1;  
							         end            
                                 end
							 end else begin
							     hsize_reg  = hsize_int;
							     hwrite_reg = |req_wr_byte_en_mux;
                                 htrans_reg = 2'b10;
								 haddr_reg = (ahb_src_sel[0]) ? req_addr[0] : req_addr[1]; 
								 haddr_p_reg = ^req_addr_mux;
								 
                                 if((|req_wr_byte_en_mux) == 0) begin
						             if(ahb_src_sel[0] & ICACHE_EN) begin
                                         req_burst_read <= 1'b1;
							         end            
                                 end
							 end
                         end
                       end
		    WAIT_ST: begin
					     if(hready) begin
                             if((|req_wr_byte_en_mux) == 0) begin
					             if(ahb_src_sel[0] & ICACHE_EN) begin
					         		 req_addr_cnt   <= req_addr_cnt + 1'd1;  
					             end            
                             end
					     end
			         end
            DATA_ST: begin
                         if(hready) begin
						     if(req_burst_read) begin 
						         if(req_addr_cnt == ICACHE_BURST_SIZE) begin 
                                     req_complete_reg <= 1'b1;
									 req_burst_read   <= 1'b0;
									 req_addr_cnt     <= 4'd0;
									 hsize_reg         = {3{1'b0}};
								 end else begin 
							         req_addr_cnt <= req_addr_cnt + 1'd1;     
								 end
							 end else begin
                                 req_complete_reg <= 1'b1;
							     hsize_reg         = {3{1'b0}};
                                 
							 end
                         end
                       end
              default: begin
                         req_complete_reg <= 1'b0;
        
                         hwdata           <= {32{1'b0}};
                         hwdata_p         <= {4{1'b0}};
                         hsize_reg         = {3{1'b0}};
						 
                         req_addr_cnt     <= {4{1'b0}}; 		
                         req_burst_read	  <= 1'b0;
                       end
          endcase
      end
    end
  
    always @(*)
    begin
          ahb_next_st      = ADDR_ST;
          
          htrans_int       = 2'b00;
          hsize_int        = 3'b000;
          hwrite_int       = 1'b0;
		  hburst           = {3{1'b0}}; 
		  
          cpu_i_resp_last  = 1'b0;		  
          case(ahb_st)
              ADDR_ST: begin
                         if(req_valid_mux) begin
                             if(|req_wr_byte_en_mux) begin
                                 case(req_wr_byte_en_mux)
                                   4'b0011: hsize_int = 3'b001;
                                   4'b0110: hsize_int = 3'b001;
                                   4'b1100: hsize_int = 3'b001;
                                   4'b1111: hsize_int = 3'b010;
                                   default: hsize_int = 3'b000;
                                 endcase
                             end else begin
						         if(ahb_src_sel[0] & ICACHE_EN) begin
                                     hsize_int    = 3'b010;
                                     hburst       = hburst_value;  
								 end else begin
						             case(req_rd_byte_en_mux)
                                       4'b0011: hsize_int = 3'b001;
                                       4'b0110: hsize_int = 3'b001;
                                       4'b1100: hsize_int = 3'b001;
                                       4'b1111: hsize_int = 3'b010;
                                       default: hsize_int = 3'b000;
                                     endcase
								 end               
                             end
							 
							 if(hready) begin
                                 ahb_next_st = DATA_ST;          
                                 hwrite_int  = |req_wr_byte_en_mux;
                                 htrans_int  = 2'b10;
							 end else begin
                                 ahb_next_st = WAIT_ST;  
							 end
                         end else begin
                             ahb_next_st = ADDR_ST;
						 end
                       end
			WAIT_ST: begin 
					   
					   if(hready) begin
                           ahb_next_st = DATA_ST;      
                           hwrite_int  = hwrite_reg;
                           htrans_int  = htrans_reg;
					       hsize_int   = hsize_reg;
					       hburst       = (req_burst_read) ? hburst_value : 3'b000; 
					   end else begin
                           ahb_next_st = WAIT_ST;  
					   end 
			         end
            DATA_ST: begin
			             hsize_int  = ((req_addr_cnt != ICACHE_BURST_SIZE) & (req_burst_read)) ? hsize_reg    : 3'b000;
						 hburst     = ((req_addr_cnt != ICACHE_BURST_SIZE) & (req_burst_read)) ? hburst_value : 3'b000;
						 htrans_int = ((req_addr_cnt != ICACHE_BURST_SIZE) & (req_burst_read)) ? 2'b11        : 2'b00;
						 
                         if(hready) begin         
						     if(req_burst_read) begin
						         if(req_addr_cnt == ICACHE_BURST_SIZE) begin 
                                     ahb_next_st     = ADDR_ST;
                                     cpu_i_resp_last = 1'b1;		
								 end else begin      
                                     ahb_next_st = DATA_ST;   
								 end
							 end else begin
                                 ahb_next_st     = ADDR_ST;  
                                 cpu_i_resp_last = 1'b1;		
							 end
                         end else begin
                             ahb_next_st = DATA_ST;   
						 end
                       end
              default: begin
                         ahb_next_st = ADDR_ST;
        
                         htrans_int  = 2'b00;
                         hsize_int   = 3'b000;
                         hwrite_int  = 1'b0;
                         hburst      = {3{1'b0}};
                       end
          endcase
    end
 
  
  always @(posedge clk or negedge resetn)
    begin 
      if(~resetn) begin
          ahb_st <= ADDR_ST;
      end else begin
          ahb_st <= ahb_next_st;
      end 
    end
  
  assign req_valid_mux   = |ahb_src_gnt; 
  assign cpu_i_req_ready = ahb_src_gnt[0] | (req_burst_read & hready);
  assign cpu_d_req_ready = ahb_src_gnt[1];

  assign req_complete   = (req_burst_read) ? ((ahb_st == DATA_ST) & hready & (req_addr_cnt == ICACHE_BURST_SIZE)) : ((ahb_st == DATA_ST) & hready); 
  assign resp_rd_data   = hrdata;  
  assign resp_rd_data_p = hrdata_p; 
  assign resp_error  = hresp;
  
  assign haddr   = (ahb_st == WAIT_ST) ? haddr_reg  : (req_valid_mux | (ahb_src_sel[0] & ICACHE_EN)) ? req_addr_mux : {AHB_ADDR_WIDTH{1'b0}};
  assign haddr_p = (ahb_st == WAIT_ST) ? haddr_p_reg :(req_valid_mux | (ahb_src_sel[0] & ICACHE_EN)) ? ^req_addr_mux : 1'b0;

  assign trx_os_d_rd = 1'b0; // REVISIT
  assign trx_os_d_wr = 1'b0; // REVISIT

endmodule


`default_nettype wire


`default_nettype wire

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
//   File:
//   miv_rv32_subsys_apb_initiator.sv
//
//   Purpose:
//    Subsys_Bridge APB Initiator
//    Supports AMBA4 APB interface (also AMBA 3 without strb, prot signals)
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_subsys_apb_initiator
//********************************************************************************
// Parameter description

  #(   
    parameter APB_ADDR_WIDTH = 32,
    parameter APB_REGISTER_IO     = 1

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             presetn,
    input wire logic                             clk,

    // Control/status/config    
    input wire logic                             subsys_parity_en,
    output     logic                             trx_os_d_rd,
    output     logic                             trx_os_d_wr,

    // CPU interface    
    input wire  logic                            cpu_i_req_valid,
    output      logic                            cpu_i_req_ready, 
    input wire  logic [3:0]                      cpu_i_req_rd_byte_en,
    input wire  logic [APB_ADDR_WIDTH-1:0]  cpu_i_req_addr,
    input wire  logic                            cpu_i_req_addr_p,
    output      logic                            cpu_i_resp_valid,
    input wire  logic                            cpu_i_resp_ready,
    output      logic                            cpu_i_resp_error,
    output      logic [31:0]                     cpu_i_resp_rd_data, 
    output      logic [3:0]                      cpu_i_resp_rd_data_p, 
    input wire  logic                            cpu_d_req_valid,
    output      logic                            cpu_d_req_ready, 
    input wire  logic [3:0]                      cpu_d_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_d_req_wr_byte_en,
    input wire  logic [APB_ADDR_WIDTH-1:0]  cpu_d_req_addr,
    input wire  logic                            cpu_d_req_addr_p,
    input wire  logic [31:0]                     cpu_d_req_wr_data,
    input wire  logic [3:0]                      cpu_d_req_wr_data_p,
    output      logic                            cpu_d_resp_valid,
    input wire  logic                            cpu_d_resp_ready,
    output      logic                            cpu_d_resp_error,
    output      logic [31:0]                     cpu_d_resp_rd_data,  
    output      logic [3:0]                      cpu_d_resp_rd_data_p,   
    
    // APB Initiator interface
    output      logic [APB_ADDR_WIDTH-1:0]  paddr, 
    output      logic                            paddr_p,
    output      logic [2:0]                      pprot,
    output      logic                            psel,
    output      logic                            penable, 
    output      logic                            pwrite, 
    output      logic [31:0]                     pwdata,
    output      logic [3:0]                      pwdata_p,
    output      logic [3:0]                      pstrb, 
    input wire  logic                            pready, 
    input wire  logic [31:0]                     prdata,
    input wire  logic [3:0]                      prdata_p, 
    input wire  logic                            pslverr
    
  );

//********************************************************************************
// Declarations

// localparams
  localparam l_subsys_cfg_apb_byte_shim = 1'b1;
  localparam IDLE_ST = 3'd0, SETUP_ST = 3'd1, ACCESS_ST = 3'd2, BH_READ_0_ST = 3'd3, BH_READ_1_ST = 3'd4, BH_WRITE_ST = 3'd5;
  
// Internal nets

  logic [1:0]                       req_valid;                   
  //logic [3:0]                       req_rd_byte_en [1:0];        
  logic [3:0]                       req_wr_byte_en [1:0];        
  logic [APB_ADDR_WIDTH-1:0]   req_addr [1:0];              
  //logic [1:0]                       req_addr_p;                  
  logic [31:0]                      req_wr_data [1:0];           
  logic [3:0]                       req_wr_data_p [1:0];         
      
  logic [1:0]                       apb_src_req;
  logic [1:0]                       apb_src_gnt;
  logic [1:0]                       apb_src_sel;
  logic [1:0]                       apb_resp_sel;
  
  logic                             req_valid_mux;
  logic [3:0]                       req_wr_byte_en_mux;
  //logic [3:0]                       req_rd_byte_en_mux;
  logic [APB_ADDR_WIDTH-1:0]   req_addr_mux;
  logic                             req_addr_p_mux;
  logic [31:0]                      req_wr_data_mux;
  logic [3:0]                       req_wr_data_p_mux;
  
  logic [31:0]                      resp_rd_data; 
  logic                             resp_error;
  logic [3:0]                       resp_rd_data_p;
   
  logic [31:0]                      prdata_reg;    
  logic [3:0]                       prdata_p_reg;  
  logic                             pslverr_reg;   
  
  logic                             req_complete;
  logic                             req_complete_reg;
  logic [2:0]                       apb_st;
  

//********************************************************************************
// Main code
//********************************************************************************

 // Arbitrate between I and D-side
 
 // CPU I
  assign req_valid[0]         = cpu_i_req_valid;
  //assign req_rd_byte_en[0]    = cpu_i_req_rd_byte_en;
  assign req_wr_byte_en[0]    = {4{1'b0}};
  assign req_addr[0]          = cpu_i_req_addr;
  //assign req_addr_p[0]        = cpu_i_req_addr_p;
  assign req_wr_data[0]       = {32{1'b0}};
  assign req_wr_data_p[0]     = {4{1'b0}};
  assign cpu_i_resp_error     = resp_error;  
  assign cpu_i_resp_rd_data   = resp_rd_data;  
  assign cpu_i_resp_rd_data_p = resp_rd_data_p;   

// CPU D
  assign req_valid[1]         = cpu_d_req_valid;
  //assign req_rd_byte_en[1]    = cpu_d_req_rd_byte_en;
  assign req_wr_byte_en[1]    = cpu_d_req_wr_byte_en;
  assign req_addr[1]          = cpu_d_req_addr;
  //assign req_addr_p[1]        = cpu_d_req_addr_p;
  assign req_wr_data[1]       = cpu_d_req_wr_data;
  assign req_wr_data_p[1]     = cpu_d_req_wr_data_p;
  assign cpu_d_resp_error     = resp_error; 
  assign cpu_d_resp_rd_data   = resp_rd_data;  
  assign cpu_d_resp_rd_data_p = resp_rd_data_p; 

  assign apb_src_req = req_valid;

  miv_rv32_rr_pri_arb
  //***************************************************************
  // Parameter description
  #(
    .NUM_REQS                  (2),
    .USE_FORMAL                (1),
    .USE_SIM                   (1)
   )

  u_apb_req_arb
  //***************************************************************
  // Signal description
  (
    .resetn              (presetn),
    .clk                 (clk),
    .unlock              (req_complete),
    .req                 (apb_src_req),
    .gnt                 (apb_src_gnt),            //open
    .sel_seq             (apb_resp_sel),
    .sel_early           (apb_src_sel)                   
  );
  
  always @*
  begin : raddr_mux_loop
    integer i;
    req_wr_byte_en_mux   = {4{1'b0}};
    //req_rd_byte_en_mux   = {4{1'b0}};
    req_addr_mux         = {APB_ADDR_WIDTH{1'b0}};
    req_wr_data_mux      = {32{1'b0}};
    req_wr_data_p_mux    = {4{1'b0}};
    for(i=0; i<2; i=i+1)
    begin                                                                                      
      req_wr_byte_en_mux   = req_wr_byte_en_mux | ({4{apb_src_sel[i]}} & req_wr_byte_en[i]);   
      //req_rd_byte_en_mux   = req_rd_byte_en_mux | ({4{apb_src_sel[i]}} & req_rd_byte_en[i]); 
      req_addr_mux         = req_addr_mux       | ({APB_ADDR_WIDTH{apb_src_sel[i]}} & req_addr[i]);      
      req_wr_data_mux      = req_wr_data_mux    | ({32{apb_src_sel[i]}} & req_wr_data[i]);    
      req_wr_data_p_mux    = req_wr_data_p_mux  | ({4{apb_src_sel[i]}} & req_wr_data_p[i]);  
    end
  end
  
  
////////////////////////////////////////////////////////////////////////////////  
  
  assign cpu_i_resp_valid = apb_resp_sel[0] & req_complete;  
  assign cpu_d_resp_valid = apb_resp_sel[1] & req_complete;
  
  generate if(l_subsys_cfg_apb_byte_shim) begin : gen_apb_byte_shim
      always @(posedge clk or negedge presetn)
        begin
          if(~presetn) begin
              req_complete_reg <= 1'b0;
              apb_st   <= IDLE_ST;
              penable  <= 1'b0;
              psel     <= 1'b0;
			  pwrite   <= 1'b0;
			  pwdata   <= 32'b0;
			  pwdata_p <= 4'b0;
			  pstrb    <= 4'b0;
          end else begin
              case(apb_st)
                  IDLE_ST: begin
                             req_complete_reg <= 1'b0;
                             if(req_valid_mux) begin
                                 psel     <= 1'b1;
                                 pwdata   <= req_wr_data_mux;
                                 pwdata_p <= req_wr_data_p_mux;
                                 pstrb    <= req_wr_byte_en_mux;
							     if(req_wr_byte_en_mux != 4'b0000 & req_wr_byte_en_mux != 4'b1111) begin
								     apb_st <= BH_READ_0_ST;
                                     pwrite <= 1'b0;
								 end else begin								 
                                     apb_st   <= SETUP_ST;
                                     pwrite   <= |req_wr_byte_en_mux;
								 end 
                             end
                           end
             BH_READ_0_ST: begin
                             penable <= 1'b1;
                             apb_st  <= BH_READ_1_ST;
                           end
             BH_READ_1_ST: begin
                             if(pready) begin
                                 apb_st  <= BH_WRITE_ST;
                                 penable <= 1'b0;
                                 psel    <= 1'b0;
                             end
						   end
              BH_WRITE_ST : begin
							 apb_st <= SETUP_ST;
                             psel   <= 1'b1;
                             pwrite <= 1'b1;
							 
							 pwdata[31:24] <= (pstrb[3]) ? pwdata[31:24] : prdata_reg[31:24];
							 pwdata[23:16] <= (pstrb[2]) ? pwdata[23:16] : prdata_reg[23:16];
							 pwdata[15:8 ] <= (pstrb[1]) ? pwdata[15:8 ] : prdata_reg[15:8 ];
							 pwdata[ 7:0 ] <= (pstrb[0]) ? pwdata[ 7:0 ] : prdata_reg[ 7:0 ];
							 
							 pwdata_p[3] <= (pstrb[3]) ? pwdata_p[3] : prdata_p_reg[3];
							 pwdata_p[2] <= (pstrb[2]) ? pwdata_p[2] : prdata_p_reg[2];
							 pwdata_p[1] <= (pstrb[1]) ? pwdata_p[1] : prdata_p_reg[1];
							 pwdata_p[0] <= (pstrb[0]) ? pwdata_p[0] : prdata_p_reg[0];
				           end
                 SETUP_ST: begin
                             penable <= 1'b1;
                             apb_st  <= ACCESS_ST;
                           end
                ACCESS_ST: begin
                             if(pready) begin
                                 req_complete_reg <= 1'b1;
                                 apb_st  <= IDLE_ST;
                                 penable <= 1'b0;
                                 psel    <= 1'b0;
                             end
                           end
                  default: begin
                             req_complete_reg <= 1'b0;
                             apb_st  <= IDLE_ST;
                             penable <= 1'b0;
                             psel    <= 1'b0;
                           end
              endcase
          end
        end
    end else begin  : ngen_apb_byte_shim
      always @(posedge clk or negedge presetn)
        begin
          if(~presetn) begin
              req_complete_reg <= 1'b0;
              apb_st   <= IDLE_ST;
              penable  <= 1'b0;
              psel     <= 1'b0;
              pwrite   <= 1'b0;
              pstrb    <= {4{1'b0}};
              pwdata   <= {32{1'b0}};
              pwdata_p <= {4{1'b0}};  // REVISIT seperate this out to remove unecessary flops when not configured
          end else begin
              case(apb_st)
                  IDLE_ST: begin
                             req_complete_reg <= 1'b0;
                             if(req_valid_mux) begin
                                 apb_st   <= SETUP_ST;
                                 psel     <= 1'b1;
                                 pwrite   <= |req_wr_byte_en_mux;
                                 pstrb    <= req_wr_byte_en_mux;
                                 pwdata   <= req_wr_data_mux;
                                 pwdata_p <= req_wr_data_p_mux;
                             end
                           end
                 SETUP_ST: begin
                             penable <= 1'b1;
                             apb_st  <= ACCESS_ST;
                           end
                ACCESS_ST: begin
                             if(pready) begin
                                 req_complete_reg <= 1'b1;
                                 apb_st  <= IDLE_ST;
                                 penable <= 1'b0;
                                 psel    <= 1'b0;
                             end
                           end
                  default: begin
                             req_complete_reg <= 1'b0;
                             apb_st   <= IDLE_ST;
                             penable  <= 1'b0;
                             psel     <= 1'b0;
                             pwrite   <= 1'b0;
                             pstrb    <= {4{1'b0}};
                             pwdata   <= {32{1'b0}};
                             pwdata_p <= {4{1'b0}};
                           end
              endcase
          end
        end
  end
  endgenerate
  
  //paddr
  always @(posedge clk or negedge presetn)
    begin
      if(~presetn) begin
          paddr   <= {APB_ADDR_WIDTH{1'b0}};
          paddr_p <= 1'b0;
      end else if(req_valid_mux) begin
          paddr   <= req_addr_mux;
          paddr_p <= ^req_addr_mux;
      end
  end
  
  always @(posedge clk or negedge presetn)
    begin 
      if(~presetn) begin
          prdata_reg   <= {32{1'b0}};
          prdata_p_reg <= {4{1'b0}};
          pslverr_reg  <= 1'b0; 
      end else begin
          prdata_reg   <= prdata;
          prdata_p_reg <= prdata_p;
          pslverr_reg  <= pslverr; 
      end 
    end
  
  assign pprot           = 3'b000; // REVISIT could make prot[2] instruction hint accurate
  assign req_valid_mux   = |apb_src_gnt; 
  assign cpu_i_req_ready = apb_src_gnt[0];
  assign cpu_d_req_ready = apb_src_gnt[1];

  generate if(APB_REGISTER_IO) begin : gen_apb_reg 
	assign req_complete   = req_complete_reg;
    assign resp_rd_data   = prdata_reg;  
    assign resp_rd_data_p = prdata_p_reg;
    assign resp_error  = pslverr_reg;
  end else begin : gen_apb_no_reg
	assign req_complete   = ((apb_st == ACCESS_ST) & (pready)) ? 1'b1 : 1'b0;
    assign resp_rd_data   = prdata;  
    assign resp_rd_data_p = prdata_p; 
    assign resp_error  = pslverr;
  end 
  endgenerate
	
  assign trx_os_d_rd = 1'b0; // REVISIT
  assign trx_os_d_wr = 1'b0; // REVISIT

endmodule

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
//   File:
//   miv_rv32_subsys_axi_initiator.sv
//
//   Purpose:
//    MIV_RV32 Bridge AXI Initiator
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_axi_initiator
//********************************************************************************
// Parameter description

  #(   
    parameter AXI_ADDR_WIDTH = 32,
    parameter ICACHE_EN        = 0,                      
    parameter ICACHE_BURST_SIZE      = 8                        

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,
    input wire logic                             aclk_en,

    // Control/status/config    
    input wire logic [1:0]                       axi_rd_cfg_min_size,
    input wire logic [1:0]                       axi_wr_cfg_min_size,
    input wire logic                             subsys_parity_en,
    input wire logic                             cfg_fence_all_src,
    input wire logic [3:0]                       cfg_ar_cache,
    input wire logic [3:0]                       cfg_aw_cache,  
    input wire logic                             cfg_raw_hzd_check,
    input wire logic                             cfg_war_hzd_check,
    output     logic                             trx_os_d_rd,
    output     logic                             trx_os_d_wr,
    

    // CPU interface    
    input wire logic                             cpu_i_req_valid,
    output     logic                             cpu_i_req_ready, 
    input wire logic [3:0]                       cpu_i_req_rd_byte_en,
    input wire logic [AXI_ADDR_WIDTH-1:0]   cpu_i_req_addr,
    input wire logic                             cpu_i_req_addr_p,
    output     logic                             cpu_i_resp_valid,
    output     wire                              cpu_i_resp_last, 
    input wire logic                             cpu_i_resp_ready,
    output     logic                             cpu_i_resp_error,
    output     logic [31:0]                      cpu_i_resp_rd_data, 
    output     logic [3:0]                       cpu_i_resp_rd_data_p, 
    input wire logic                             cpu_d_req_valid,
    output     logic                             cpu_d_req_ready, 
    input wire logic [3:0]                       cpu_d_req_rd_byte_en,  
    input wire logic [3:0]                       cpu_d_req_wr_byte_en,
    input wire logic                             cpu_d_req_read, 
    input wire logic                             cpu_d_req_write,
    input wire logic [AXI_ADDR_WIDTH-1:0]   cpu_d_req_addr,
    input wire logic                             cpu_d_req_addr_p,
    input wire logic [31:0]                      cpu_d_req_wr_data,
    input wire logic [3:0]                       cpu_d_req_wr_data_p,
    output     logic                             cpu_d_resp_valid,
    input wire logic                             cpu_d_resp_ready,
    output     logic                             cpu_d_resp_rd_error,
    output     logic [31:0]                      cpu_d_resp_rd_data,  
    output     logic [3:0]                       cpu_d_resp_rd_data_p,  
    output     logic                             cpu_d_wr_resp_err,
  
    
    // uDMA interface 
    input wire logic                             udma_req_valid,
    output     logic                             udma_req_ready, 
    input wire logic [3:0]                       udma_req_rd_byte_en,  
    input wire logic [3:0]                       udma_req_wr_byte_en,
    input wire logic                             udma_req_read, 
    input wire logic                             udma_req_write,
    input wire logic [AXI_ADDR_WIDTH-1:0]   udma_req_addr,
    input wire logic                             udma_req_addr_p,
    input wire logic [3:0]                       udma_req_len,
    input wire logic [31:0]                      udma_req_wr_data,
    input wire logic [3:0]                       udma_req_wr_data_p,
    input wire logic                             udma_req_wr_data_last,
    output     logic                             udma_resp_valid,
    output     logic                             udma_resp_last,
    input wire logic                             udma_resp_ready,
    output     logic                             udma_resp_rd_error,
    output     logic [31:0]                      udma_resp_rd_data, 
    output     logic [3:0]                       udma_resp_rd_data_p,
    output     logic                             udma_wr_resp_err,
    
    // AXI Initiator interface
      // AXI Read channel interface
        //RADDR channel (and sidebands)
    output logic                                  axi_arid,
    output logic [AXI_ADDR_WIDTH-1:0]        axi_araddr,
    output logic [3:0]                            axi_arlen,
    output logic [2:0]                            axi_arsize,
    output logic [1:0]                            axi_arburst,
    output logic                                  axi_arlock,
    output logic [3:0]                            axi_arcache,
    output logic [2:0]                            axi_arprot,
    input wire logic                              axi_arready,
    output logic                                  axi_arvalid,
    output logic                                  axi_ar_addr_p,
        //RRESP channel (and sidebands)
    input wire logic [1:0]                        axi_rresp,
    input wire logic [31:0]                       axi_rdata,
    input wire logic                              axi_rlast,
    input wire logic                              axi_rid,
    output logic                                  axi_rready,
    input wire logic                              axi_rvalid,
    input wire logic [3:0]                        axi_r_data_p,
      // AXI Write channel interface
        //WADDR channel (and sidebands)
    output logic                                  axi_awid,
    output logic [AXI_ADDR_WIDTH-1:0]        axi_awaddr,
    output logic [3:0]                            axi_awlen,
    output logic [2:0]                            axi_awsize,
    output logic [1:0]                            axi_awburst,
    output logic                                  axi_awlock,
    output logic [3:0]                            axi_awcache,
    output logic [2:0]                            axi_awprot,
    output logic                                  axi_aw_addr_p,
    input wire logic                              axi_awready,
    output logic                                  axi_awvalid,
        //WDATA channel (and sidebands)
    output logic [31:0]                           axi_wdata,
    output logic [3:0]                            axi_wstrb,
    output logic                                  axi_wlast,
    output logic                                  axi_wid,
    input wire logic                              axi_wready,
    output logic                                  axi_wvalid,
    output logic [3:0]                            axi_w_data_p,   
        //BRESP channel
    input wire logic  [1:0]                       axi_bresp,
    input wire logic                              axi_bid,
    output logic                                  axi_bready,
    input wire logic                              axi_bvalid    
    
    
  );

//********************************************************************************
// Declarations

// localparams

    localparam NUM_READ_REQUESTERS  = 2 + l_subsys_cfg_udma_present;
    localparam NUM_WRITE_REQUESTERS = 1 + l_subsys_cfg_udma_present;
    localparam NUM_OS_WRITES        = 2;
    localparam LOG2_NUM_OS_WRITES   = 1;
    localparam NUM_OS_READS         = 2;
    localparam LOG2_NUM_OS_READS    = 1;


// Internal nets


  
   logic [AXI_ADDR_WIDTH-1:0]                      cpu_i_axi_araddr;
   logic [3:0]                                          cpu_i_axi_arlen;
   logic [2:0]                                          cpu_i_axi_arsize;
   logic                                                cpu_i_axi_arready;
   logic                                                cpu_i_axi_arvalid;
   logic                                                cpu_i_axi_rready;
   logic                                                cpu_i_axi_rvalid;
   logic                                                cpu_i_axi_rlast;
   logic [1:0]                                          cpu_i_axi_rresp;
   logic [31:0]                                         cpu_i_axi_rdata;
   logic [3:0]                                          cpu_i_axi_rdata_p;  
   logic                                                cpu_i_axi_fence_rd_flush;    
   logic                                                cpu_i_axi_fence_rd_os; 
   logic [1:0]                                          cpu_i_rd_size;
   logic [2:0]                                          cpu_i_req_addr_strb;
   //cpu d-side
   logic [AXI_ADDR_WIDTH-1:0]                      cpu_d_axi_araddr;
   logic [3:0]                                          cpu_d_axi_arlen;
   logic [2:0]                                          cpu_d_axi_arsize;
   logic                                                cpu_d_axi_arready;
   logic                                                cpu_d_axi_arvalid;
   logic                                                cpu_d_axi_rready;
   logic                                                cpu_d_axi_rvalid;
   logic [1:0]                                          cpu_d_axi_rresp;
   logic [31:0]                                         cpu_d_axi_rdata;
   logic [3:0]                                          cpu_d_axi_rdata_p;  
   logic                                                cpu_d_axi_fence_rd_flush;    
   logic                                                cpu_d_axi_fence_rd_os;  
   logic [1:0]                                          cpu_d_rd_size;
   logic [2:0]                                          cpu_d_req_rd_addr_strb;                    
   //udma
   logic [AXI_ADDR_WIDTH-1:0]                      udma_axi_araddr;
   logic [3:0]                                          udma_axi_arlen;
   logic [2:0]                                          udma_axi_arsize;
   logic                                                udma_axi_arready;
   logic                                                udma_axi_arvalid;
   logic                                                udma_axi_rready;
   logic                                                udma_axi_rvalid;
   logic [1:0]                                          udma_axi_rresp;
   logic                                                udma_axi_rlast;
   logic [31:0]                                         udma_axi_rdata;
   logic [3:0]                                          udma_axi_rdata_p; 
   logic                                                udma_axi_fence_rd_flush;    
   logic                                                udma_axi_fence_rd_os; 
   logic [1:0]                                          udma_rd_size;
   logic [2:0]                                          udma_req_rd_addr_strb;
   
   logic [(NUM_OS_READS*AXI_ADDR_WIDTH)-1:0]       os_read_addr_pkd;
   logic [NUM_OS_READS-1:0]                             os_read_valid_pkd;
   logic [NUM_OS_READS-1:0]                             os_read_cpu_d_valid_pkd;
   
   // cpu
   logic [AXI_ADDR_WIDTH-1:0]                      cpu_axi_awaddr;
   logic [2:0]                                          cpu_axi_awsize;
   logic                                                cpu_axi_awready;
   logic                                                cpu_axi_awvalid;
   logic [31:0]                                         cpu_axi_wdata;
   logic [3:0]                                          cpu_axi_wdata_p;
   logic                                                cpu_axi_wlast;
   logic [3:0]                                          cpu_axi_wstrb;
   logic                                                cpu_axi_wready;
   logic                                                cpu_axi_wvalid; 
   logic                                                cpu_axi_fence_wr_flush;  
   logic                                                cpu_axi_fence_wr_os;
   logic [1:0]                                          cpu_d_wr_size;
   logic [2:0]                                          cpu_d_req_wr_addr_strb;  
   //udma   
   logic [AXI_ADDR_WIDTH-1:0]                      udma_axi_awaddr;
   logic [3:0]                                          udma_axi_awlen;
   logic [2:0]                                          udma_axi_awsize;
   logic                                                udma_axi_awready;
   logic                                                udma_axi_awvalid;
   logic [31:0]                                         udma_axi_wdata;
   logic [3:0]                                          udma_axi_wdata_p;
   logic                                                udma_axi_wlast;
   logic [3:0]                                          udma_axi_wstrb;
   logic                                                udma_axi_wready;
   logic                                                udma_axi_wvalid;   
   logic                                                udma_axi_fence_wr_flush; 
   logic                                                udma_axi_fence_wr_os;
   logic [1:0]                                          udma_wr_size;
   logic [2:0]                                          udma_req_wr_addr_strb; 
   
   logic [(NUM_OS_WRITES*AXI_ADDR_WIDTH)-1:0]      os_write_addr_pkd;
   logic [NUM_OS_WRITES-1:0]                            os_write_valid_pkd;   

   logic [NUM_OS_WRITES-1:0]                            raw_hzd_i;
   logic [NUM_OS_WRITES-1:0]                            raw_hzd_d;
   logic [NUM_OS_READS-1:0]                             war_hzd_d;
   logic                                                axi_raw_hzd_i;
   logic                                                axi_raw_hzd_d;
   logic                                                axi_war_hzd_d;
   
   logic [NUM_WRITE_REQUESTERS-1:0]                     write_response_error;


//********************************************************************************
// Main code
//********************************************************************************


  // the rchan block will perform arbitrartion between the read sources (cpu_i, cpu_d, and uDMA (if implemented)
  // NUM_READ_REQUESTERS must = 2 if no uDMA and = 3 if uDMA present

  // convert rd strobes into address and size, and align AXI address accordingly
  miv_rv32_strb_to_addr
  #(
    .NUM_BYTES          (4)
  )
  u_strb_to_addr_cpu_i_rd
  (
    .clk                (clk),
    .resetn             (resetn),
    .strb               (cpu_i_req_rd_byte_en),
    .cfg_min_size       (axi_rd_cfg_min_size),
    .addr               (cpu_i_req_addr_strb),
    .size               (cpu_i_rd_size)
  ); 
  
  assign cpu_i_axi_araddr             = {cpu_i_req_addr[AXI_ADDR_WIDTH-1:2],cpu_i_req_addr_strb[1:0]};
  assign cpu_i_axi_arlen              = (ICACHE_EN) ? ICACHE_BURST_SIZE-1 : 4'd0;
  assign cpu_i_axi_arsize             = {1'b0,cpu_i_rd_size};
  assign cpu_i_axi_arvalid            = cpu_i_req_valid;       
  assign cpu_i_axi_rready             = cpu_i_resp_ready;  
  assign cpu_i_axi_fence_rd_flush      = 1'b0; // REVISIT 
  
  assign cpu_i_req_ready              = cpu_i_axi_arready;
  assign cpu_i_resp_valid             = cpu_i_axi_rvalid;
  assign cpu_i_resp_last              = cpu_i_axi_rlast;
  assign cpu_i_resp_error             = (cpu_i_axi_rresp == 2'b10) || (cpu_i_axi_rresp == 2'b11); 
  assign cpu_i_resp_rd_data           = cpu_i_axi_rdata;         
  assign cpu_i_resp_rd_data_p         = cpu_i_axi_rdata_p;
  

  miv_rv32_strb_to_addr
  #(
    .NUM_BYTES          (4)
  )
  u_strb_to_addr_cpu_d_rd
  (
    .clk                (clk),
    .resetn             (resetn),
    .strb               (cpu_d_req_rd_byte_en),
    .cfg_min_size       (axi_rd_cfg_min_size),
    .addr               (cpu_d_req_rd_addr_strb),
    .size               (cpu_d_rd_size)
  ); 
  
  assign cpu_d_axi_araddr             = {cpu_d_req_addr[AXI_ADDR_WIDTH-1:2],cpu_d_req_rd_addr_strb[1:0]};
  assign cpu_d_axi_arlen              = 4'd0;       // always 1 beat from CPU
  assign cpu_d_axi_arsize             = {1'b0,cpu_d_rd_size};
  assign cpu_d_axi_arvalid            = cpu_d_req_valid & cpu_d_req_read;       
  assign cpu_d_axi_rready             = cpu_d_resp_ready;  
  assign cpu_d_axi_fence_rd_flush     = 1'b0; // REVISIT 
  
  assign cpu_d_req_ready              = (cpu_d_req_read & cpu_d_axi_arready) |
                                        (cpu_d_req_write & cpu_axi_awready & cpu_axi_wready);
  assign cpu_d_resp_valid             = cpu_d_axi_rvalid;
  assign cpu_d_resp_rd_error          = (cpu_d_axi_rresp == 2'b10) || (cpu_d_axi_rresp == 2'b11); 
  assign cpu_d_resp_rd_data           = cpu_d_axi_rdata;         
  assign cpu_d_resp_rd_data_p         = cpu_d_axi_rdata_p;
  
  miv_rv32_strb_to_addr
  #(
    .NUM_BYTES          (4)
  )
  u_strb_to_addr_udma_rd
  (
    .clk                (clk),
    .resetn             (resetn),
    .strb               (udma_req_rd_byte_en),
    .cfg_min_size       (axi_rd_cfg_min_size),
    .addr               (udma_req_rd_addr_strb),
    .size               (udma_rd_size)
  ); 
  
  assign udma_axi_araddr             = {udma_req_addr[AXI_ADDR_WIDTH-1:2],udma_req_rd_addr_strb[1:0]};
  assign udma_axi_arlen              = udma_req_len;      
  assign udma_axi_arsize             = {1'b0,udma_rd_size};
  assign udma_axi_arvalid            = udma_req_valid & udma_req_read;        
  assign udma_axi_rready             = udma_resp_ready;  
  assign udma_axi_fence_rd_flush     = 1'b0; // REVISIT 
  
  assign udma_req_ready              = (udma_req_read & udma_axi_arready) |
                                       (udma_req_write & udma_axi_awready & udma_axi_wready);
  assign udma_resp_valid             = udma_axi_rvalid;
  assign udma_resp_last              = udma_axi_rlast;
  assign udma_resp_rd_error          = (udma_axi_rresp == 2'b10) || (udma_axi_rresp == 2'b11); 
  assign udma_resp_rd_data           = udma_axi_rdata;         
  assign udma_resp_rd_data_p         = udma_axi_rdata_p;



  // read side 
  // contains AR and R channels
                
  miv_rv32_axi_rchan
  //***************************************************************
  // Parameter description
  #(
    .AXI_RADDR_WIDTH           (AXI_ADDR_WIDTH),         
    .NUM_REQUESTERS                 (NUM_READ_REQUESTERS),                  
    .NUM_OS_READS                   (NUM_OS_READS),              
    .LOG2_NUM_OS_READS              (LOG2_NUM_OS_READS)               
   )
  u_axi_rchan
  //***************************************************************
  // Signal description
  (
    .resetn                         (resetn),
    .clk                            (clk),
    .aclk_en                        (aclk_en),
   // .initiator_r_idle                    ( ),  // open. not currently used
    .read_parity_error              ( ),  // open. not currently used
    .subsys_parity_en                (subsys_parity_en),
    .cfg_fence_all                  (cfg_fence_all_src),
    .cfg_ar_cache                   (cfg_ar_cache),
    .axi_arid                   (axi_arid),
    .axi_araddr                 (axi_araddr),
    .axi_arlen                  (axi_arlen),
    .axi_arsize                 (axi_arsize),
    .axi_arburst                (axi_arburst),
    .axi_arlock                 (axi_arlock),
    .axi_arcache                (axi_arcache),
    .axi_arprot                 (axi_arprot),
    .axi_arready                (axi_arready),
    .axi_arvalid                (axi_arvalid),
    .axi_ar_addr_p              (axi_ar_addr_p),
    .axi_rresp                  (axi_rresp),
    .axi_rdata                  (axi_rdata),
    .axi_rlast                  (axi_rlast),
    .axi_rid                    (axi_rid),
    .axi_rready                 (axi_rready),
    .axi_rvalid                 (axi_rvalid),
    .axi_r_data_p               (axi_r_data_p),
    .cpu_i_axi_araddr               (cpu_i_axi_araddr),
    .cpu_i_axi_arlen                (cpu_i_axi_arlen),
    .cpu_i_axi_arsize               (cpu_i_axi_arsize),
    .cpu_i_axi_arready              (cpu_i_axi_arready),
    .cpu_i_axi_arvalid              (cpu_i_axi_arvalid),
    .cpu_i_axi_rready               (cpu_i_axi_rready),
    .cpu_i_axi_rvalid               (cpu_i_axi_rvalid),
    .cpu_i_axi_rresp                (cpu_i_axi_rresp),
    .cpu_i_axi_rlast                (cpu_i_axi_rlast), 
    .cpu_i_axi_rdata                (cpu_i_axi_rdata),
    .cpu_i_axi_rdata_p              (cpu_i_axi_rdata_p),
    .cpu_i_axi_fence_rd_flush        (cpu_i_axi_fence_rd_flush),
    .cpu_i_axi_fence_rd_os          (cpu_i_axi_fence_rd_os),
    .cpu_i_axi_raw_hzd              (axi_raw_hzd_i),
    .cpu_d_axi_araddr               (cpu_d_axi_araddr),
    .cpu_d_axi_arlen                (cpu_d_axi_arlen),
    .cpu_d_axi_arsize               (cpu_d_axi_arsize),
    .cpu_d_axi_arready              (cpu_d_axi_arready),
    .cpu_d_axi_arvalid              (cpu_d_axi_arvalid),
    .cpu_d_axi_rready               (cpu_d_axi_rready),
    .cpu_d_axi_rvalid               (cpu_d_axi_rvalid),
    .cpu_d_axi_rresp                (cpu_d_axi_rresp),
    .cpu_d_axi_rlast                ( ), // open. CPU does not support multi-beat data transactions
    .cpu_d_axi_rdata                (cpu_d_axi_rdata),
    .cpu_d_axi_rdata_p              (cpu_d_axi_rdata_p),
    .cpu_d_axi_fence_rd_flush       (cpu_d_axi_fence_rd_flush),
    .cpu_d_axi_fence_rd_os          (cpu_d_axi_fence_rd_os),
    .cpu_d_axi_raw_hzd              (axi_raw_hzd_d),
    .udma_axi_araddr                (udma_axi_araddr),
    .udma_axi_arlen                 (udma_axi_arlen),
    .udma_axi_arsize                (udma_axi_arsize),
    .udma_axi_arready               (udma_axi_arready),
    .udma_axi_arvalid               (udma_axi_arvalid),
    .udma_axi_rready                (udma_axi_rready),
    .udma_axi_rvalid                (udma_axi_rvalid),
    .udma_axi_rresp                 (udma_axi_rresp),
    .udma_axi_rlast                 (udma_axi_rlast),
    .udma_axi_rdata                 (udma_axi_rdata),
    .udma_axi_rdata_p               (udma_axi_rdata_p),
    .udma_axi_fence_rd_flush        (udma_axi_fence_rd_flush),
    .udma_axi_fence_rd_os           (udma_axi_fence_rd_os),
    .udma_axi_raw_hzd               (1'b0 ), // REVISIT add when UDMA implemented
    .os_read_addr_pkd               (os_read_addr_pkd),
    .os_read_valid_pkd              (os_read_valid_pkd),
    .os_read_cpu_d_valid_pkd        (os_read_cpu_d_valid_pkd)
  ); 
  


  miv_rv32_strb_to_addr
  #(
    .NUM_BYTES          (4)
  )
  u_strb_to_addr_cpu_d_wr
  (
    .clk                (clk),
    .resetn             (resetn),
    .strb               (cpu_d_req_wr_byte_en),
    .cfg_min_size       (axi_wr_cfg_min_size),
    .addr               (cpu_d_req_wr_addr_strb),
    .size               (cpu_d_wr_size)
  ); 
  
  
    assign cpu_axi_awaddr         = {cpu_d_req_addr[AXI_ADDR_WIDTH-1:2],cpu_d_req_wr_addr_strb[1:0]};
    assign cpu_axi_awsize         = {1'b0,cpu_d_wr_size};
    assign cpu_axi_awvalid        = cpu_d_req_valid & cpu_d_req_write;
    assign cpu_axi_wdata          = cpu_d_req_wr_data;
    assign cpu_axi_wdata_p        = cpu_d_req_wr_data_p;
    assign cpu_axi_wlast          = 1'b1;  
    assign cpu_axi_wstrb          = cpu_d_req_wr_byte_en;
    assign cpu_axi_wvalid         = cpu_d_req_valid & cpu_d_req_write;      
    assign cpu_axi_fence_wr_flush = 1'b0; // REVISIT


  miv_rv32_strb_to_addr
  #(
    .NUM_BYTES          (4)
  )
  u_strb_to_addr_udma_wr
  (
    .clk                (clk),
    .resetn             (resetn),
    .strb               (udma_req_wr_byte_en),
    .cfg_min_size       (axi_wr_cfg_min_size),
    .addr               (udma_req_wr_addr_strb),
    .size               (udma_wr_size)
  );  
  
    assign udma_axi_awaddr         = {udma_req_addr[AXI_ADDR_WIDTH-1:2],udma_req_wr_addr_strb[1:0]};
    assign udma_axi_awsize         = {1'b0,udma_wr_size};
    assign udma_axi_awlen          = udma_req_len;
    assign udma_axi_awvalid        = udma_req_valid & udma_req_write;
    assign udma_axi_wdata          = udma_req_wr_data;
    assign udma_axi_wdata_p        = udma_req_wr_data_p;
    assign udma_axi_wlast          = udma_req_wr_data_last;  
    assign udma_axi_wstrb          = udma_req_wr_byte_en;
    assign udma_axi_wvalid         = udma_req_valid & udma_req_write;      
    assign udma_axi_fence_wr_flush = 1'b0; // REVISIT

      
  // write side
  // contains AW, W, and B channels
  
  miv_rv32_axi_wchan
  //***************************************************************
  // Parameter description
  #(
    .AXI_WADDR_WIDTH           (AXI_ADDR_WIDTH),             
    .NUM_OS_WRITES                  (NUM_OS_WRITES),  
    .NUM_REQUESTERS                 (NUM_WRITE_REQUESTERS),    
    .LOG2_NUM_OS_WRITES             (LOG2_NUM_OS_WRITES)                 
   )
  u_axi_wchan
  //***************************************************************
  // Signal description
  (
    .resetn                         (resetn),
    .clk                            (clk),
    .aclk_en                        (aclk_en),
    .initiator_w_idle                    ( ),  // open. not currently used
    .subsys_parity_en                (subsys_parity_en),
    .cfg_fence_all                  (cfg_fence_all_src),
    .write_response_error           (write_response_error),  
    .cfg_aw_cache                   (cfg_aw_cache),
    .axi_awid                   (axi_awid),
    .axi_awaddr                 (axi_awaddr),
    .axi_awlen                  (axi_awlen),
    .axi_awsize                 (axi_awsize),
    .axi_awburst                (axi_awburst),
    .axi_awlock                 (axi_awlock),
    .axi_awcache                (axi_awcache),
    .axi_awprot                 (axi_awprot),
    .axi_aw_addr_p              (axi_aw_addr_p),
    .axi_awready                (axi_awready),
    .axi_awvalid                (axi_awvalid),
    .axi_wdata                  (axi_wdata),
    .axi_wstrb                  (axi_wstrb),
    .axi_wlast                  (axi_wlast),
    .axi_wid                    (axi_wid),  // not used in AXI4 - same wchan ID output for AXI3 or AXI4 because single fixed ID
    .axi_wready                 (axi_wready),
    .axi_wvalid                 (axi_wvalid),
    .axi_w_data_p               (axi_w_data_p),
    .axi_bresp                  (axi_bresp),
    .axi_bid                    (axi_bid),
    .axi_bready                 (axi_bready),
    .axi_bvalid                 (axi_bvalid),
    .cpu_axi_awaddr                 (cpu_axi_awaddr),
    .cpu_axi_awsize                 (cpu_axi_awsize),
    .cpu_axi_awready                (cpu_axi_awready),
    .cpu_axi_awvalid                (cpu_axi_awvalid),
    .cpu_axi_wdata                  (cpu_axi_wdata),
    .cpu_axi_wdata_p                (cpu_axi_wdata_p),
    .cpu_axi_wlast                  (cpu_axi_wlast),
    .cpu_axi_wstrb                  (cpu_axi_wstrb),
    .cpu_axi_wready                 (cpu_axi_wready),
    .cpu_axi_wvalid                 (cpu_axi_wvalid),
    .cpu_axi_fence_wr_flush         (cpu_axi_fence_wr_flush),
    .cpu_axi_fence_wr_os            (cpu_axi_fence_wr_os),
    .cpu_axi_war_hzd                (axi_war_hzd_d),
    .udma_axi_awaddr                (udma_axi_awaddr),
    .udma_axi_awlen                 (udma_axi_awlen),
    .udma_axi_awsize                (udma_axi_awsize),
    .udma_axi_awready               (udma_axi_awready),
    .udma_axi_awvalid               (udma_axi_awvalid),
    .udma_axi_wdata                 (udma_axi_wdata),
    .udma_axi_wdata_p               (udma_axi_wdata_p),
    .udma_axi_wlast                 (udma_axi_wlast),
    .udma_axi_wstrb                 (udma_axi_wstrb),
    .udma_axi_wready                (udma_axi_wready),
    .udma_axi_wvalid                (udma_axi_wvalid),
    .udma_axi_fence_wr_flush        (udma_axi_fence_wr_flush),
    .udma_axi_fence_wr_os           (udma_axi_fence_wr_os),
    .udma_axi_war_hzd               (1'b0), // REVISIT add when UDMA implemented
    .os_write_addr_pkd              (os_write_addr_pkd),
    .os_write_valid_pkd             (os_write_valid_pkd)
    
  );
  
  assign cpu_d_wr_resp_err = write_response_error[0];
  
  generate 
  if(l_subsys_cfg_udma_present) begin : gen_udma_assign  
    assign udma_wr_resp_err  = write_response_error[1];
  end
  else begin : ngen_udma_assign 
    assign udma_wr_resp_err = 1'b0;
  end
  endgenerate

  // manage RAW and WAR hazards if enabled  
  
  always @*
  begin
    integer i;
    for(i=0; i<NUM_OS_WRITES; i=i+1)
    begin
      raw_hzd_i[i] =  ((os_write_addr_pkd[(i*AXI_ADDR_WIDTH)+:AXI_ADDR_WIDTH] & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000}) == 
                       (cpu_i_axi_araddr & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000})) & 
                       os_write_valid_pkd[i] &
                       cpu_i_axi_arvalid & 
                       cfg_raw_hzd_check;
                       
      raw_hzd_d[i] =  ((os_write_addr_pkd[(i*AXI_ADDR_WIDTH)+:AXI_ADDR_WIDTH] & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000}) == 
                       (cpu_d_axi_araddr & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000})) & 
                       os_write_valid_pkd[i] &
                       cpu_d_axi_arvalid &
                       cfg_raw_hzd_check;                      
    end
  end
  
  assign axi_raw_hzd_i = |raw_hzd_i;
  assign axi_raw_hzd_d = |raw_hzd_d;
  
  
  
  always @*
  begin
    integer i;
    for(i=0; i<NUM_OS_WRITES; i=i+1)
    begin                       
      war_hzd_d[i] =  ((os_read_addr_pkd[(i*AXI_ADDR_WIDTH)+:AXI_ADDR_WIDTH] & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000}) == 
                       (cpu_axi_awaddr & {{AXI_ADDR_WIDTH-4{1'b1}},4'b0000})) & 
                       os_read_valid_pkd[i] &
                       cpu_axi_awvalid &
                       cfg_war_hzd_check;                       
    end
  end
  
  assign axi_war_hzd_d = |war_hzd_d;
  
  
  
  // indicate to interconnect if outstanding requests for fence completion (hence don't need current request)
  assign trx_os_d_wr = |os_write_valid_pkd[NUM_OS_WRITES-1:0];
  assign trx_os_d_rd = |os_read_cpu_d_valid_pkd[NUM_OS_READS-1:0];
 

endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_subsys_tcm_tas_apb_target.sv
//
//   Purpose:
//    subsys APB target for local memory direct access.
//    Also provides access to the uDMA control registers to allow
//    External use without SUBSYS CPU.  
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module miv_rv32_subsys_tcm_tas_apb_target
//********************************************************************************
// Parameter description

  #(   
    parameter CPU_ADDR_WIDTH        = 32,
    parameter TCM_TAS_ADDR_WIDTH   = 32,
    parameter TCM0_ADDR_WIDTH      = 32,
    parameter TCM1_ADDR_WIDTH      = 32,
    parameter UDMA_CTRL_ADDR_WIDTH  = 32

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,

    // Control/status/config    
    input wire logic                             subsys_parity_en,   
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_udma_ctrl_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_udma_ctrl_end_addr, 
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_tcm0_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_tcm0_end_addr,  
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_tcm1_start_addr,
    input wire  logic [CPU_ADDR_WIDTH-1:0]       cfg_tcm_tas_tcm1_end_addr, 
    
    // APB Taeget interface
    input wire  logic [TCM_TAS_ADDR_WIDTH-1:0]  paddr, 
    input wire  logic                            paddr_p,
    input wire  logic [2:0]                      pprot,     //unsused
    input wire  logic                            psel,
    input wire  logic                            penable, 
    input wire  logic                            pwrite, 
    input wire  logic [31:0]                     pwdata,
    input wire  logic [3:0]                      pwdata_p,    
    output      logic                            pready, 
    output      logic [31:0]                     prdata,
    output      logic [3:0]                      prdata_p, 
    output      logic                            pslverr,
    
        // local memory 0 direct access port
      
    output     logic                             tcm0_tas_req_valid,
    input wire logic                             tcm0_tas_req_ready, 
    output     logic [3:0]                       tcm0_tas_req_rd_byte_en,  
    output     logic [3:0]                       tcm0_tas_req_wr_byte_en,
    output     logic [TCM0_ADDR_WIDTH-1:0]      tcm0_tas_req_addr,
    output     logic                             tcm0_tas_req_addr_p,
    output     logic [31:0]                      tcm0_tas_req_wr_data,
    output     logic [3:0]                       tcm0_tas_req_wr_data_p,
    input wire logic                             tcm0_tas_resp_valid,
    output     logic                             tcm0_tas_resp_ready,
    input wire logic                             tcm0_tas_resp_rd_error,
    input wire logic [31:0]                      tcm0_tas_resp_rd_data,  
    input wire logic [3:0]                       tcm0_tas_resp_rd_data_p,
    
        // local memory  1 direct access port
 
    output     logic                             tcm1_tas_req_valid,
    input wire logic                             tcm1_tas_req_ready, 
    output     logic [3:0]                       tcm1_tas_req_rd_byte_en,  
    output     logic [3:0]                       tcm1_tas_req_wr_byte_en,
    output     logic [TCM1_ADDR_WIDTH-1:0]      tcm1_tas_req_addr,
    output     logic                             tcm1_tas_req_addr_p,
    output     logic [31:0]                      tcm1_tas_req_wr_data,
    output     logic [3:0]                       tcm1_tas_req_wr_data_p,
    input wire logic                             tcm1_tas_resp_valid,
    output     logic                             tcm1_tas_resp_ready,
    input wire logic                             tcm1_tas_resp_rd_error,
    input wire logic [31:0]                      tcm1_tas_resp_rd_data,  
    input wire logic [3:0]                       tcm1_tas_resp_rd_data_p,
    
        // uDMA control interface
    output      logic                            udma_ctrl_req_valid,
    input wire  logic                            udma_ctrl_req_ready, 
    output      logic [3:0]                      udma_ctrl_req_rd_byte_en,  
    output      logic [3:0]                      udma_ctrl_req_wr_byte_en,
    output      logic [UDMA_CTRL_ADDR_WIDTH-1:0] udma_ctrl_req_addr,
    output      logic                            udma_ctrl_req_addr_p,
    output      logic [31:0]                     udma_ctrl_req_wr_data,
    output      logic [3:0]                      udma_ctrl_req_wr_data_p,
    input wire  logic                            udma_ctrl_resp_valid,
    output      logic                            udma_ctrl_resp_ready,
    input wire  logic                            udma_ctrl_resp_rd_error,
    input wire  logic [31:0]                     udma_ctrl_resp_rd_data,
    input wire  logic [3:0]                      udma_ctrl_resp_rd_data_p
    
  );

//********************************************************************************
// Declarations

// localparams



// Internal nets

  logic                            tas_req_is_tcm0_target;
  logic                            tas_req_is_tcm1_target;
  logic                            tas_req_is_udma_target;
  

//********************************************************************************
// Main code
//********************************************************************************

// REVISIT
	
// APB Outputs
    assign pready =   (tas_req_is_tcm0_target) ? tcm0_tas_resp_valid     : 
                      (tas_req_is_tcm1_target) ? tcm1_tas_resp_valid     : 
                      (tas_req_is_udma_target ) ? udma_ctrl_resp_valid     : 1'b0;
    assign prdata =   (tas_req_is_tcm0_target) ? tcm0_tas_resp_rd_data   : 
                      (tas_req_is_tcm1_target) ? tcm1_tas_resp_rd_data   : 
                      (tas_req_is_udma_target ) ? udma_ctrl_resp_rd_data   : 32'b0;
    assign prdata_p = (tas_req_is_tcm0_target) ? tcm0_tas_resp_rd_data_p : 
                      (tas_req_is_tcm1_target) ? tcm1_tas_resp_rd_data_p : 
                      (tas_req_is_udma_target ) ? udma_ctrl_resp_rd_data_p : 4'b0;
    assign pslverr =  (tas_req_is_tcm0_target) ? tcm0_tas_resp_rd_error  : 
                      (tas_req_is_tcm1_target) ? tcm1_tas_resp_rd_error  : 
                      (tas_req_is_udma_target ) ? udma_ctrl_resp_rd_error  : 1'b0;

// TCM0
    assign tas_req_is_tcm0_target     = (paddr[TCM_TAS_ADDR_WIDTH-1:12] >= cfg_tcm_tas_tcm0_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                      (paddr[TCM_TAS_ADDR_WIDTH-1:12] <= cfg_tcm_tas_tcm0_end_addr[CPU_ADDR_WIDTH-1:12]);  

    assign tcm0_tas_req_valid      = (tas_req_is_tcm0_target) ? penable & psel              : 1'b0;
    assign tcm0_tas_req_rd_byte_en = (tas_req_is_tcm0_target) ? {4{!pwrite}}                : 4'b0;  
    assign tcm0_tas_req_wr_byte_en = (tas_req_is_tcm0_target) ? {4{pwrite}}                 : 4'b0;  
    assign tcm0_tas_req_addr       = (tas_req_is_tcm0_target) ? paddr[TCM_TAS_ADDR_WIDTH-1:0] : {TCM0_ADDR_WIDTH{1'b0}};
    assign tcm0_tas_req_addr_p     = (tas_req_is_tcm0_target) ? paddr_p                     : 1'b0;
    assign tcm0_tas_req_wr_data    = (tas_req_is_tcm0_target) ? pwdata                      : 32'b0;
    assign tcm0_tas_req_wr_data_p  = (tas_req_is_tcm0_target) ? pwdata_p                    : 4'b0;
    assign tcm0_tas_resp_ready     = (tas_req_is_tcm0_target) ? 1'b1                        : 1'b0;
      

// TCM1
    assign tas_req_is_tcm1_target       = (paddr[TCM_TAS_ADDR_WIDTH-1:12] >= cfg_tcm_tas_tcm1_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                        (paddr[TCM_TAS_ADDR_WIDTH-1:12] <= cfg_tcm_tas_tcm1_end_addr[CPU_ADDR_WIDTH-1:12]);  

    assign tcm1_tas_req_valid      = (tas_req_is_tcm1_target) ? penable & psel              : 1'b0;
    assign tcm1_tas_req_rd_byte_en = (tas_req_is_tcm1_target) ? {4{!pwrite}}                : 4'b0;  
    assign tcm1_tas_req_wr_byte_en = (tas_req_is_tcm1_target) ? {4{pwrite}}                 : 4'b0;  
    assign tcm1_tas_req_addr       = (tas_req_is_tcm1_target) ? paddr[TCM_TAS_ADDR_WIDTH-1:0] : {TCM1_ADDR_WIDTH{1'b0}};
    assign tcm1_tas_req_addr_p     = (tas_req_is_tcm1_target) ? paddr_p                     : 1'b0;
    assign tcm1_tas_req_wr_data    = (tas_req_is_tcm1_target) ? pwdata                      : 32'b0;
    assign tcm1_tas_req_wr_data_p  = (tas_req_is_tcm1_target) ? pwdata_p                    : 4'b0;
    assign tcm1_tas_resp_ready     = (tas_req_is_tcm1_target) ? 1'b1                        : 1'b0;


// UDMA
    assign tas_req_is_udma_target       = (paddr[TCM_TAS_ADDR_WIDTH-1:12] >= cfg_tcm_tas_udma_ctrl_start_addr[CPU_ADDR_WIDTH-1:12]) &  
                                       (paddr[TCM_TAS_ADDR_WIDTH-1:12] <= cfg_tcm_tas_udma_ctrl_end_addr[CPU_ADDR_WIDTH-1:12]);  

    assign udma_ctrl_req_valid       = (tas_req_is_udma_target) ? penable & psel                  : 1'b0;
    assign udma_ctrl_req_rd_byte_en  = (tas_req_is_udma_target) ? {4{!pwrite}}                    : 4'b0;  
    assign udma_ctrl_req_wr_byte_en  = (tas_req_is_udma_target) ? {4{pwrite}}                     : 4'b0;  
    assign udma_ctrl_req_addr        = (tas_req_is_udma_target) ? paddr[TCM_TAS_ADDR_WIDTH-1:0]  : {UDMA_CTRL_ADDR_WIDTH{1'b0}};
    assign udma_ctrl_req_addr_p      = (tas_req_is_udma_target) ? paddr_p                         : 1'b0;
    assign udma_ctrl_req_wr_data     = (tas_req_is_udma_target) ? pwdata                          : 32'b0;
    assign udma_ctrl_req_wr_data_p   = (tas_req_is_udma_target) ? pwdata_p                        : 4'b0;
    assign udma_ctrl_resp_ready      = (tas_req_is_udma_target) ? 1'b1                            : 1'b0;

endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_egress_buffer.sv
//
//   Purpose: Egress buffer, buffers data leaving the AXI initiator/target
//            Write side is clocked at hart rate
//            Read side also clocked at hart rate, but enable can make it appear 
//            to be at a different (synchronous integer multiple) rate
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_axi_egress_buffer
//********************************************************************************
// Parameter description

  #(
    parameter BUFF_WIDTH = 36,
    parameter BUFF_SIZE = 2,
    parameter PTR_SIZE = 1
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    input wire                               clken,
    
    input wire                               valid_in,
    output wire                              ready_in,
    input wire [BUFF_WIDTH-1:0]              data_in,
    
    output wire [BUFF_WIDTH-1:0]             data_out,
    output wire                              valid_out,
    
    input wire                               ready_out,  
    
    output wire [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd,
    output wire [BUFF_SIZE-1:0]              valid_out_pkd,
    
    output wire                              nearly_full  
    
 
    
  );

//********************************************************************************
// localparams
  localparam BUFF_MAX = BUFF_SIZE-1;

// Declarations

  reg  [PTR_SIZE-1:0]              buff_wr_ptr;
  reg  [PTR_SIZE-1:0]              buff_rd_ptr;
  wire [PTR_SIZE-1:0]              next_buff_wr_ptr;
  wire [PTR_SIZE-1:0]              next_buff_rd_ptr;
  
  wire [BUFF_SIZE-1:0]             buff_wr_strb;
  wire [BUFF_SIZE-1:0]             buff_rd_strb;
  wire [BUFF_SIZE-1:0]             next_alloc;
  
  reg [BUFF_SIZE-1:0]              buff_valid;
  wire [BUFF_SIZE-1:0]             next_buff_valid;
  reg [BUFF_WIDTH-1:0]             buff_data[BUFF_SIZE-1:0]; 
  wire                             valid_out_net;
  
  wire                             rd_data;
  wire                             wr_data;
  
  wire                             full;
  wire                             empty;
  
  reg [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd_reg;
  reg [BUFF_SIZE-1:0]              valid_out_pkd_reg;
  
  wire                             next_buff_ready;
  reg                              buff_ready_reg;

  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************

  assign full     = &buff_valid;
  assign empty    = ~(|buff_valid);
  assign wr_data  = valid_in & buff_ready_reg;
  assign rd_data  = ready_out & valid_out_net & clken;
  
  
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_rd_ptr <= {PTR_SIZE{1'b0}};
    else
      if(rd_data)
        buff_rd_ptr <= next_buff_rd_ptr;        
  end 
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_wr_ptr <= {PTR_SIZE{1'b0}};
    else
      if(wr_data)
        buff_wr_ptr <= next_buff_wr_ptr;
  end
  
  assign next_buff_wr_ptr = (buff_wr_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_wr_ptr+1;
  assign next_buff_rd_ptr = (buff_rd_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_rd_ptr+1;
  
  
  
  generate
  genvar gen_buff;
  for(gen_buff = 0; gen_buff<BUFF_SIZE; gen_buff=gen_buff+1)
  begin : gen_buff_loop
  
    assign buff_wr_strb[gen_buff] = wr_data & (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign next_alloc[gen_buff] = (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign buff_rd_strb[gen_buff] = rd_data & (buff_rd_ptr == gen_buff[PTR_SIZE-1:0]);
	
	
    // Data not reset  // Intialized for simualation - causes x's without
	initial 
	  begin
	    buff_data[gen_buff] <= {BUFF_WIDTH{1'b0}};
	  end
	  
    always @(posedge clk)
    begin    
      begin
        if(buff_wr_strb[gen_buff])
        begin
          buff_data[gen_buff] <= data_in;
        end
      end
    end
  
  
    assign next_buff_valid[gen_buff] = (buff_valid[gen_buff] & ~buff_rd_strb[gen_buff]) | 
                                       buff_wr_strb[gen_buff];
  
    always @(posedge clk or negedge resetn)
    begin
      if(~resetn)
        buff_valid[gen_buff]  <=  1'b0;
      else
        buff_valid[gen_buff]  <= next_buff_valid[gen_buff]; 
    end  
    
  end
  endgenerate
  
  assign data_out      = buff_data[buff_rd_ptr];
  assign valid_out_net = buff_valid[buff_rd_ptr]; 
  assign valid_out     = valid_out_net;
  
  // only allow buffer to be written when aclk_en is asserted or
  // the location written will not be the same as the one read
  // This prevents the output value changing due to a buffer slot
  // being written on a core clock edge but not on a axi clk edge
  
  assign next_buff_ready = (~(&next_buff_valid)) & 
                           (clken | (buff_rd_ptr == buff_wr_ptr));
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_ready_reg <= 1'b0;
    else
      buff_ready_reg <= next_buff_ready;       
  end
  
  assign ready_in = buff_ready_reg;

  
  //assign packed outputs
  always @*
  begin: pkd_out_loop
    integer i;
    for(i=0;i<BUFF_SIZE; i=i+1)
    begin
      data_out_pkd_reg[(i*BUFF_WIDTH)+:BUFF_WIDTH] = buff_data[i];
      valid_out_pkd_reg[i] = buff_valid[i];
    end
  end
  
  assign data_out_pkd  = data_out_pkd_reg;
  assign valid_out_pkd = valid_out_pkd_reg; 
  
  // if the next buffer slot to be allocated would cause the buffer to become full if a write occurs
  // without a read, assert the nearly_full output
  assign nearly_full = &(buff_valid | next_alloc);
  


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_egress_buffer.sv
//
//   Purpose: Egress buffer, buffers data leaving the AXI initiator/target
//            Write side is clocked at hart rate
//            Read side also clocked at hart rate, but enable can make it appear 
//            to be at a different (synchronous integer multiple) rate
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_axi_egress_slip_buffer
//********************************************************************************
// Parameter description

  #(
    parameter BUFF_WIDTH = 1
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    input wire                               clken,
    
    input wire                               valid_in,
    output wire                              ready_in,
    input wire [BUFF_WIDTH-1:0]              data_in,
    
    output wire [BUFF_WIDTH-1:0]             data_out,
    output wire                              valid_out,    
    input wire                               ready_out,  
    
    output wire                              nearly_full  
    
 
    
  );

//********************************************************************************
// localparams

// Declarations

  wire                    alloc_output_buff;
  wire                    dealloc_output_buff; 
  reg                     output_buff_valid;
  wire                    next_output_buff_valid;  
  reg [BUFF_WIDTH-1:0]    output_buff_data;
  wire [BUFF_WIDTH-1:0]   next_output_buff_data;
  wire                    alloc_output_buff_from_slip;
  wire                    alloc_output_buff_from_din;
  
  wire                    alloc_slip_buff;
  wire                    dealloc_slip_buff;
  wire                    slip_buff_valid;
  wire [BUFF_WIDTH-1:0]   slip_buff_data;
 
  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************


  // output buffer (buff0)
  // AXI requires the output to be stable when clken is not asserted 
  // if the output buffer is empty and aclk is enabled assign the output buffer
  // directly, otherwise assign the slip buffer
  
  assign alloc_output_buff   = alloc_output_buff_from_slip | alloc_output_buff_from_din;
                                        
  assign alloc_output_buff_from_slip =  clken & slip_buff_valid & 
                                        ((~output_buff_valid) | dealloc_output_buff);
  
  assign alloc_output_buff_from_din =  clken & ~slip_buff_valid &
                                               valid_in & 
                                        ((~output_buff_valid) | dealloc_output_buff);                                      
                                                                             
  // deallocate output buffer (make invalid) when data is accepted
  assign dealloc_output_buff = clken & output_buff_valid & ready_out;
  
  // Data not reset  
  assign next_output_buff_data = alloc_output_buff ? (slip_buff_valid ? slip_buff_data : data_in) : output_buff_data;
  always @(posedge clk)
  begin
    if(clken)
      output_buff_data <= next_output_buff_data;
  end
    
  assign next_output_buff_valid = (output_buff_valid & ~dealloc_output_buff) | alloc_output_buff;
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      output_buff_valid  <=  1'b0;
    else if(clken)
      output_buff_valid  <= next_output_buff_valid;       
  end 
  
  assign valid_out = output_buff_valid;
  assign data_out  = output_buff_data;
  
  // the slip buffer is a 2 entry ping pong circular buffer (fifo)
  
  // Allocate the slip buffer unless the entry can be directly allocated to the
  // output buffer
  assign alloc_slip_buff     =  valid_in & ~alloc_output_buff_from_din;
  // when data is moved to output buffer, deallocate slot
  assign dealloc_slip_buff = alloc_output_buff;
  
  miv_rv32_buffer
  #(
    .BUFF_WIDTH         (BUFF_WIDTH), 
    .BUFF_SIZE          (2),
    .PTR_SIZE           (1)
  )
  u_req_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (alloc_slip_buff),
    .ready_in           (ready_in),
    .data_in            (data_in),
    .data_out           (slip_buff_data),
    .valid_out          (slip_buff_valid),
    .ready_out          (alloc_output_buff),
    .data_out_pkd       (), // open
    .valid_out_pkd      (), // open
    .nearly_full        (nearly_full)  // open
  );

  // REVISIT make ready_in more agressive?
  // can factor in output buffer ready too?
endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_ingress_buffer.sv
//
//   Purpose: Ingress buffer, buffers data entering the AXI initiator/target
//            Read side is clocked at hart rate
//            Write side also clocked at hart rate, but enable can make it appear 
//            to be at a different (synchronous integer multiple) rate
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_axi_ingress_buffer
//********************************************************************************
// Parameter description

  #(
    parameter BUFF_WIDTH = 36,
    parameter BUFF_SIZE = 2,
    parameter PTR_SIZE = 1
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    input wire                               clken,
    
    input wire                               valid_in,
    output wire                              ready_in,
    input wire [BUFF_WIDTH-1:0]              data_in,
    
    output wire [BUFF_WIDTH-1:0]             data_out,
    output wire                              valid_out,
    
    input wire                               ready_out,  
    
    output wire [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd,
    output wire [BUFF_SIZE-1:0]              valid_out_pkd,
    
    output wire                              nearly_full  
    
 
    
  );

//********************************************************************************
// localparams
  localparam BUFF_MAX = BUFF_SIZE-1;

// Declarations

  reg  [PTR_SIZE-1:0]              buff_wr_ptr;
  reg  [PTR_SIZE-1:0]              buff_rd_ptr;
  wire [PTR_SIZE-1:0]              next_buff_wr_ptr;
  wire [PTR_SIZE-1:0]              next_buff_rd_ptr;
  
  wire [BUFF_SIZE-1:0]             buff_wr_strb;
  wire [BUFF_SIZE-1:0]             buff_rd_strb;
  wire [BUFF_SIZE-1:0]             next_alloc;
  
  reg [BUFF_SIZE-1:0]              buff_valid;
  wire [BUFF_SIZE-1:0]             next_buff_valid;
  reg [BUFF_WIDTH-1:0]             buff_data[BUFF_SIZE-1:0]; 
  
  wire                             rd_data;
  wire                             wr_data;
  
  wire                             full;
  wire                             empty;
  
  reg [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd_reg;
  reg [BUFF_SIZE-1:0]              valid_out_pkd_reg;
  
  wire                             next_buff_ready;
  reg                              buff_ready_reg;

  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************

  assign full     = &buff_valid;
  assign empty    = ~(|buff_valid);
  assign wr_data  = valid_in & buff_ready_reg & clken;
  assign rd_data  = ready_out & ~empty;
  
  
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_rd_ptr <= {PTR_SIZE{1'b0}};
    else
      if(rd_data)
        buff_rd_ptr <= next_buff_rd_ptr;        
  end 
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_wr_ptr <= {PTR_SIZE{1'b0}};
    else
      if(wr_data)
        buff_wr_ptr <= next_buff_wr_ptr;
  end
  
  assign next_buff_wr_ptr = (buff_wr_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_wr_ptr+1;
  assign next_buff_rd_ptr = (buff_rd_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_rd_ptr+1;
  
  
  
  generate
  genvar gen_buff;
  for(gen_buff = 0; gen_buff<BUFF_SIZE; gen_buff=gen_buff+1)
  begin : gen_buff_loop
  
    assign buff_wr_strb[gen_buff] = wr_data & (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign next_alloc[gen_buff] = (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign buff_rd_strb[gen_buff] = rd_data & (buff_rd_ptr == gen_buff[PTR_SIZE-1:0]);
  
    // Data not reset  // Intialized for simualation - causes x's without
	initial 
	  begin
	    buff_data[gen_buff] <= {BUFF_WIDTH{1'b0}};
	  end
	  
    always @(posedge clk)
    begin    
      begin
        if(buff_wr_strb[gen_buff])
        begin
          buff_data[gen_buff] <= data_in;
        end
      end
    end
  
  
    assign next_buff_valid[gen_buff] = (buff_valid[gen_buff] & ~buff_rd_strb[gen_buff]) | 
                                       buff_wr_strb[gen_buff];
  
    always @(posedge clk or negedge resetn)
    begin
      if(~resetn)
        buff_valid[gen_buff]  <=  1'b0;
      else
        buff_valid[gen_buff]  <= next_buff_valid[gen_buff]; 
    end  
    
  end
  endgenerate
  
  assign data_out = buff_data[buff_rd_ptr];
  assign valid_out = buff_valid[buff_rd_ptr];
  
  assign next_buff_ready = ~(&next_buff_valid);
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_ready_reg <= 1'b0;
    else
      if(clken)
        buff_ready_reg <= next_buff_ready;       
  end
  
  assign ready_in = buff_ready_reg;

  
  //assign packed outputs
  always @*
  begin: pkd_out_loop
    integer i;
    for(i=0;i<BUFF_SIZE; i=i+1)
    begin
      data_out_pkd_reg[(i*BUFF_WIDTH)+:BUFF_WIDTH] = buff_data[i];
      valid_out_pkd_reg[i] = buff_valid[i];
    end
  end
  
  assign data_out_pkd  = data_out_pkd_reg;
  assign valid_out_pkd = valid_out_pkd_reg; 
  
  // if the next buffer slot to be allocated would cause the buffer to become full if a write occurs
  // without a read, assert the nearly_full output
  assign nearly_full = &(buff_valid | next_alloc);
  


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_rchan.sv
//
//   Purpose:
//    MIV_RV32 Bridge AXI Initiator read/read response channel
//   
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_axi_rchan
//********************************************************************************
// Parameter description

  #(   
    parameter AXI_RADDR_WIDTH = 32,
    parameter NUM_REQUESTERS = 2,
    parameter NUM_OS_READS = 4,
    parameter LOG2_NUM_OS_READS = 2
   )

//********************************************************************************
// Port description

  (    
    input wire                                           resetn,
    input wire                                           clk,
    input wire                                           aclk_en,
    // controls   
    //output wire                                          initiator_r_idle,
    output wire [NUM_REQUESTERS-1:0]                     read_parity_error,
    input wire                                           subsys_parity_en,
    input wire                                           cfg_fence_all,
    input wire [3:0]                                     cfg_ar_cache,
    //RADDR channel (and sidebands)
    output wire                                          axi_arid,
    output wire [AXI_RADDR_WIDTH-1:0]               axi_araddr,
    output wire [3:0]                                    axi_arlen,
    output wire [2:0]                                    axi_arsize,
    output wire [1:0]                                    axi_arburst,
    output wire                                          axi_arlock,
    output wire [3:0]                                    axi_arcache,
    output wire [2:0]                                    axi_arprot,
    input wire                                           axi_arready,
    output wire                                          axi_arvalid,
    output wire                                          axi_ar_addr_p,
    //RRESP channel (and sidebands)
    input wire [1:0]                                     axi_rresp,
    input wire [31:0]                                    axi_rdata,
    input wire                                           axi_rlast,
    input wire                                           axi_rid,
    output wire                                          axi_rready,
    input wire                                           axi_rvalid,
    input wire [3:0]                                     axi_r_data_p,
       
    //cpu i-side
    input wire [AXI_RADDR_WIDTH-1:0]                cpu_i_axi_araddr,
    input wire [3:0]                                     cpu_i_axi_arlen,
    input wire [2:0]                                     cpu_i_axi_arsize,
    output wire                                          cpu_i_axi_arready,
    input wire                                           cpu_i_axi_arvalid,
    input wire                                           cpu_i_axi_rready,
    output wire                                          cpu_i_axi_rvalid,
    output wire [1:0]                                    cpu_i_axi_rresp,
    output wire                                          cpu_i_axi_rlast,
    output wire [31:0]                                   cpu_i_axi_rdata,
    output wire [3:0]                                    cpu_i_axi_rdata_p,  
    input wire                                           cpu_i_axi_fence_rd_flush,    
    output wire                                          cpu_i_axi_fence_rd_os,   
    input wire                                           cpu_i_axi_raw_hzd,  
    //cpu d-side
    input wire [AXI_RADDR_WIDTH-1:0]                cpu_d_axi_araddr,
    input wire [3:0]                                     cpu_d_axi_arlen,
    input wire [2:0]                                     cpu_d_axi_arsize,
    output wire                                          cpu_d_axi_arready,
    input wire                                           cpu_d_axi_arvalid,
    input wire                                           cpu_d_axi_rready,
    output wire                                          cpu_d_axi_rvalid,
    output wire [1:0]                                    cpu_d_axi_rresp,
    output wire                                          cpu_d_axi_rlast,
    output wire [31:0]                                   cpu_d_axi_rdata,
    output wire [3:0]                                    cpu_d_axi_rdata_p,  
    input wire                                           cpu_d_axi_fence_rd_flush,    
    output wire                                          cpu_d_axi_fence_rd_os,  
    input wire                                           cpu_d_axi_raw_hzd,                     
    //udma
    input wire [AXI_RADDR_WIDTH-1:0]                udma_axi_araddr,
    input wire [3:0]                                     udma_axi_arlen,
    input wire [2:0]                                     udma_axi_arsize,
    output wire                                          udma_axi_arready,
    input wire                                           udma_axi_arvalid,
    input wire                                           udma_axi_rready,
    output wire                                          udma_axi_rvalid,
    output wire [1:0]                                    udma_axi_rresp,
    output wire                                          udma_axi_rlast,
    output wire [31:0]                                   udma_axi_rdata,
    output wire [3:0]                                    udma_axi_rdata_p, 
    input wire                                           udma_axi_fence_rd_flush,    
    output wire                                          udma_axi_fence_rd_os, 
    input wire                                           udma_axi_raw_hzd, 
    // outstanding read transaction addresses
    output wire [(NUM_OS_READS*AXI_RADDR_WIDTH)-1:0]   os_read_addr_pkd,
    output wire [NUM_OS_READS-1:0]                          os_read_valid_pkd,
    output wire [NUM_OS_READS-1:0]                          os_read_cpu_d_valid_pkd
  );

//********************************************************************************
// Declarations

// localparams
  localparam AR_BUFF_WIDTH = AXI_RADDR_WIDTH + 4 + 3 + 1;
  localparam R_BUFF_WIDTH  = 2 + 32 + 1 + 4;
  
  localparam RESP_OKAY   = 2'b00;
  localparam RESP_EXOKAY = 2'b01;
  localparam TGT_SLVERR  = 2'b10;
  localparam RESP_DECERR = 2'b11;

// Internal nets/regs

  logic [NUM_REQUESTERS-1:0]                                 cpu_ar_req;
  logic [NUM_REQUESTERS-1:0]                                 cpu_ar_gnt;
  logic                                                      raddr_buffer_ready;
  logic                                                      accept_req;
  logic                                                      r_os_buffer_ready;
  
  logic [31:0]                                               cpu_araddr[NUM_REQUESTERS-1:0];
  logic [1:0]                                                cpu_id [NUM_REQUESTERS-1:0];
  logic [3:0]                                                cpu_arlen[NUM_REQUESTERS-1:0]; 
  logic [2:0]                                                cpu_arsize[NUM_REQUESTERS-1:0];
  logic [NUM_REQUESTERS-1:0]                                 cpu_addr_p;        
  logic [NUM_REQUESTERS-1:0]                                 cpu_arvalid;
  logic [NUM_REQUESTERS-1:0]                                 cpu_rvalid;
  logic [NUM_REQUESTERS-1:0]                                 cpu_rlast;
  logic [NUM_REQUESTERS-1:0]                                 cpu_rready;
  logic [NUM_REQUESTERS-1:0]                                 raw_hzd; 
  
  logic [AXI_RADDR_WIDTH-1:0]                           cpu_araddr_mux;
  logic [3:0]                                                cpu_arlen_mux;
  logic [2:0]                                                cpu_arsize_mux;
  logic                                                      cpu_addr_p_mux;
  logic [1:0]                                                cpu_id_mux;
  logic                                                      cpu_num_mux;
  
  logic [AXI_RADDR_WIDTH-1:0]                           cpu_araddr_buff;
  logic [3:0]                                                cpu_arlen_buff;
  logic [3:0]                                                cpu_arcache_buff;
  logic [2:0]                                                cpu_arsize_buff;
  logic                                                      cpu_addr_p_buff;
  
  logic [1:0]                                                resp_buff_rresp;
  logic [31:0]                                               resp_buff_rdata;
  logic                                                      resp_buff_rlast;
  logic                                                      axi_resp_buff_rid; 
  logic                                                      cpu_resp_buff_rid;   
  logic [3:0]                                                resp_buff_rdata_p;
  logic                                                      resp_buff_valid;
  logic [1:0]                                                resp_id_index;
  
  logic [AR_BUFF_WIDTH-1:0]                                  ar_out_buff_in;
  logic [AR_BUFF_WIDTH-1:0]                                  ar_out_buff_out;
  
  logic [R_BUFF_WIDTH-1:0]                                   rresp_buff_in;
  logic [R_BUFF_WIDTH-1:0]                                   rresp_buff_out;
  logic                                                      resp_buff_ready;
  logic                                                      resp_buff_valid_last;
  logic [AXI_RADDR_WIDTH-3:0]                           curr_resp_id_addr;
  
  logic                                                      rbyte_parity_err;
  
  logic [NUM_REQUESTERS-1:0]                                 cpu_fence_flush;
  logic [NUM_REQUESTERS-1:0]                                 fence_flush;
  logic [NUM_REQUESTERS-1:0]                                 cpu_rd_os;
  
  logic [(NUM_OS_READS*AXI_RADDR_WIDTH)-1:0]            os_read_addr_pkd_net;
  logic [(NUM_OS_READS*2)-1:0]                               os_read_id_pkd_net;
  logic [NUM_OS_READS-1:0]                                   os_rd_cpud_dma_net;
  logic [((NUM_OS_READS+1)*2)-1:0]                           os_read_id_pkd;
  logic [(NUM_OS_READS*(AXI_RADDR_WIDTH-2))-1:0]        os_read_id_addr_pkd_net;
  logic [NUM_OS_READS-1:0]                                   os_read_valid_pkd_net;
  

//********************************************************************************
// Main code

  // Read requests from the CPU D-side are directly arbitrated.
  // Reads from the I-side are made to the prefetch unit which then makes a request to 
  // the initiator.
  
  // put in an array so can be dealt with in a loop 
// cpu i
    assign cpu_araddr[0]         = cpu_i_axi_araddr;
    assign cpu_id[0]             = 2'd0;
    assign cpu_arlen[0]          = cpu_i_axi_arlen;
    assign cpu_arsize[0]         = cpu_i_axi_arsize;
    assign cpu_arvalid[0]        = cpu_i_axi_arvalid;
    assign cpu_i_axi_arready     = cpu_ar_gnt[0];
    assign cpu_rready[0]         = cpu_i_axi_rready;
    assign cpu_i_axi_rvalid      = cpu_rvalid[0];
    assign cpu_i_axi_rlast       = cpu_rlast[0];
    assign cpu_i_axi_rresp       = resp_buff_rresp;
    assign cpu_i_axi_rdata       = resp_buff_rdata;
    assign cpu_i_axi_rdata_p     = resp_buff_rdata_p;
    assign read_parity_error[0]  = rbyte_parity_err & cpu_rvalid[0];
    assign cpu_fence_flush[0]     = cpu_i_axi_fence_rd_flush;
    assign cpu_i_axi_fence_rd_os  = (cfg_fence_all  & (|cpu_rd_os)) |
                                   (~cfg_fence_all  & cpu_rd_os[0]);
    assign raw_hzd[0]             = cpu_i_axi_raw_hzd;                            

// cpu d
    assign cpu_araddr[1]         = cpu_d_axi_araddr;
    assign cpu_id[1]             = 2'd1;
    assign cpu_arlen[1]          = cpu_d_axi_arlen;
    assign cpu_arsize[1]         = cpu_d_axi_arsize;
    assign cpu_arvalid[1]        = cpu_d_axi_arvalid;
    assign cpu_d_axi_arready     = cpu_ar_gnt[1];
    assign cpu_rready[1]         = cpu_d_axi_rready;
    assign cpu_d_axi_rvalid      = cpu_rvalid[1];
    assign cpu_d_axi_rlast       = cpu_rlast[1];
    assign cpu_d_axi_rresp       = resp_buff_rresp;
    assign cpu_d_axi_rdata       = resp_buff_rdata;
    assign cpu_d_axi_rdata_p     = resp_buff_rdata_p;
    assign read_parity_error[1]  = rbyte_parity_err & cpu_rvalid[1];
    assign cpu_fence_flush[1]     = cpu_d_axi_fence_rd_flush;
    assign cpu_d_axi_fence_rd_os  = (cfg_fence_all  & (|cpu_rd_os)) |
                                   (~cfg_fence_all  & cpu_rd_os[1]);
    assign raw_hzd[1]             = cpu_d_axi_raw_hzd;    

  generate
  if((NUM_REQUESTERS >= 3)) begin: gen_assign_udma_cons
    assign cpu_araddr[2]         = udma_axi_araddr;
    assign cpu_id[2]             = 2'd2;
    assign cpu_arlen[2]          = udma_axi_arlen;
    assign cpu_arsize[2]         = udma_axi_arsize;
    assign cpu_arvalid[2]        = udma_axi_arvalid;
    assign udma_axi_arready      = cpu_ar_gnt[2];
    assign cpu_rready[2]         = udma_axi_rready;
    assign udma_axi_rvalid       = cpu_rvalid[2];
    assign udma_axi_rlast        = cpu_rlast[2];
    assign udma_axi_rresp        = resp_buff_rresp;
    assign udma_axi_rdata        = resp_buff_rdata;
    assign udma_axi_rdata_p      = resp_buff_rdata_p;
    assign read_parity_error[2]  = rbyte_parity_err & cpu_rvalid[2];
    assign cpu_fence_flush[2]     = udma_axi_fence_rd_flush;
    assign udma_axi_fence_rd_os   = (cfg_fence_all  & (|cpu_rd_os)) |
                                   (~cfg_fence_all  & cpu_rd_os[2]);
    assign raw_hzd[2]             = udma_axi_raw_hzd;    
  end
  else begin : ngen_assign_udma_cons
    assign udma_axi_arready      = 1'b0;
    assign udma_axi_rvalid       = 1'b0;
    assign udma_axi_rlast        = 1'b0;
    assign udma_axi_rresp        = 2'b00;
    assign udma_axi_rdata        = {32{1'b0}};
    assign udma_axi_rdata_p      = {4{1'b0}};
    assign udma_axi_fence_rd_os   = 1'b0;
  end   
  endgenerate
 

  // When cfg_fence_all is asserted stop accepting requests from all cpus except the 
  // one(s) that issues a flush
  assign fence_flush = {NUM_REQUESTERS{(cfg_fence_all & (|cpu_fence_flush))}} 
                      & ~cpu_fence_flush;
  
  generate
  genvar i_req;
  for (i_req = 0; i_req < NUM_REQUESTERS; i_req = i_req+1) begin : gen_req
    // allow a request to propagate if there are:
    //   - no fence flushes in progress
    //   - there is space in the output buffer (ie ar channel not backpressured)
    //   - there is space in the read request os tracking buffer
    //   - theer are no read-after-write hazards outstanding for the current request
    assign cpu_ar_req[i_req] = cpu_arvalid[i_req] & 
                               (~fence_flush[i_req]) &
                                raddr_buffer_ready &
                                r_os_buffer_ready &
                                ~raw_hzd[i_req];
                                  
    // compute address parity in parallel for each source and multiplex so it can be computed 
    // whilst arbitrating    
    assign cpu_addr_p[i_req] = ^cpu_araddr[i_req];                               
 
  end
  endgenerate
  
  // arbitrate write requests
    
  miv_rv32_rr_pri_arb
  //***************************************************************
  // Parameter description
  #(
    .NUM_REQS                  (NUM_REQUESTERS),
    .USE_FORMAL                (1),
    .USE_SIM                   (1)
   )

  u_raddr_arb
  //***************************************************************
  // Signal description
  (
    .resetn              (resetn),
    .clk                 (clk),
    .unlock              (1'b1),
    .req                 (cpu_ar_req),
    .gnt                 (cpu_ar_gnt),
    .sel_seq             (),                   //open
    .sel_early           ()                    //open
  );
  
  // ar request multiplexer
  
  always @*
  begin : raddr_mux_loop
    integer i;
    cpu_araddr_mux    = {AXI_RADDR_WIDTH{1'b0}};  
    cpu_arlen_mux     = {4{1'b0}};
    cpu_id_mux        = 2'd0;
    cpu_arsize_mux    = {3{1'b0}};
    cpu_addr_p_mux    = 1'b0;
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_araddr_mux    = cpu_araddr_mux  | ({AXI_RADDR_WIDTH{cpu_ar_gnt[i]}} & cpu_araddr[i]); 
      cpu_id_mux        = cpu_id_mux      | ({2{cpu_ar_gnt[i]}}  & cpu_id[i]);  
      cpu_arlen_mux     = cpu_arlen_mux   | ({4{cpu_ar_gnt[i]}}  & cpu_arlen[i]); 
      cpu_arsize_mux    = cpu_arsize_mux  | ({3{cpu_ar_gnt[i]}}  & cpu_arsize[i]); 
      cpu_addr_p_mux    = cpu_addr_p_mux  | (cpu_ar_gnt[i]       & cpu_addr_p[i]);
    end
  end
  

  // request/data output buffers
  
  assign accept_req = |cpu_ar_gnt; 
  
  assign ar_out_buff_in = {cpu_araddr_mux,
                           cpu_arlen_mux,
                           cpu_arsize_mux,
                           cpu_addr_p_mux};
                           
  assign {cpu_araddr_buff,
          cpu_arlen_buff,
          cpu_arsize_buff,
          cpu_addr_p_buff} = ar_out_buff_out;
         
  
  
  miv_rv32_axi_egress_slip_buffer
  #(
    .BUFF_WIDTH         (AR_BUFF_WIDTH)
  )
  u_raddr_output_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .clken              (aclk_en),
    .valid_in           (accept_req),
    .ready_in           (raddr_buffer_ready),
    .data_in            (ar_out_buff_in),
    .data_out           (ar_out_buff_out),
    .valid_out          (axi_arvalid),
    .ready_out          (axi_arready), 
    .nearly_full        ()  //open  
  );
  
  // Read response buffer
  
  assign rresp_buff_in = 
         {axi_rresp,axi_rdata,axi_rlast,axi_r_data_p};
         
  assign {resp_buff_rresp,resp_buff_rdata,resp_buff_rlast,resp_buff_rdata_p} = 
         rresp_buff_out;
                
  
  miv_rv32_axi_ingress_buffer
  #(
    .BUFF_WIDTH         (R_BUFF_WIDTH), 
    .BUFF_SIZE          (2),
    .PTR_SIZE           (1)
  )
  u_rresp_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .clken              (aclk_en),
    .valid_in           (axi_rvalid),
    .ready_in           (axi_rready),
    .data_in            (rresp_buff_in),
    .data_out           (rresp_buff_out),
    .valid_out          (resp_buff_valid),
    .ready_out          (resp_buff_ready),
    .data_out_pkd       (), //open
    .valid_out_pkd      (), //open  
    .nearly_full        ()  //open  
  );
  
  
  // The response is forwarded to the appropriate destination based on the response ID by asserting valid
  // (all other fields broadcast)

  
  
  // select read from CPU that generated the request
  assign resp_id_index = curr_resp_id_addr[(AXI_RADDR_WIDTH-4)+:2];
  assign resp_buff_ready = |cpu_rready;
  
  always @*
  begin : respid_map_loop
    integer i;
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_rvalid[i] = (resp_id_index == i[1:0]) & resp_buff_valid;
      cpu_rlast[i]  = (resp_id_index == i[1:0]) & resp_buff_rlast;
    end
  end  
  
  always @*
  begin :rd_parity_err_loop
    reg tmp_err;
    integer i;
    tmp_err = 1'b0;
    for(i=0; i<4; i=i+1)
    begin
      tmp_err = tmp_err | (^{resp_buff_rdata_p[i],resp_buff_rdata[i*8+:8]});
    end
    rbyte_parity_err = tmp_err & subsys_parity_en;
  end 
  
  // assign AXI outputs
  assign axi_arid        = 1'b0;
  assign axi_araddr      = cpu_araddr_buff;
  assign axi_arlen       = cpu_arlen_buff;
  assign axi_arsize      = cpu_arsize_buff;
  assign axi_arburst     = 2'b01;    // Always incrementing
  assign axi_arlock      = 1'b0;    // Always normal (no lock, no exclusive) for now
  assign axi_arcache     = cfg_ar_cache;
  assign axi_arprot      = 3'b010;   // Always data, non-secure, normal
  assign axi_ar_addr_p   = cpu_addr_p_buff;


  

  // outstanding request buffer. 
  // This stores a list of the address (16B granularity) and Requester ID of outstanding read transactions 
  // such that the initiator can keep track of them to reassociate responses and manage WAR hazards.
  // An entry is added to the buffer when a request is successfully arbitrated
  // An entry is removed from the list when a read request  completes 
  // Since the SUBSYS AXI initiator only supports one ID, all responses are received in order so only a simple buffer
  // to maintain the list is required
  
  assign resp_buff_valid_last = resp_buff_valid & resp_buff_ready & resp_buff_rlast; 
  

  
    miv_rv32_buffer
  #(
    .BUFF_WIDTH         ((AXI_RADDR_WIDTH-2)), 
    .BUFF_SIZE          (NUM_OS_READS),
    .PTR_SIZE           (LOG2_NUM_OS_READS)
  )
  u_ros_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (accept_req),
    .ready_in           (r_os_buffer_ready),
    .data_in            ({cpu_id_mux,(cpu_araddr_mux[AXI_RADDR_WIDTH-1:4])}),
    .data_out           (curr_resp_id_addr),     
    .valid_out          (),     //open
    .ready_out          (resp_buff_valid_last),
    .data_out_pkd       (os_read_id_addr_pkd_net), 
    .valid_out_pkd      (os_read_valid_pkd_net),
    .nearly_full        ()
  );
  
  always @*
  begin :extract_addr_loop
    integer i;
    logic [AXI_RADDR_WIDTH-3:0] tmp_resp;
    logic [AXI_RADDR_WIDTH-5:0] tmp_addr;
    logic [1:0] tmp_id;
    
    for(i=0; i<NUM_OS_READS; i=i+1)
    begin
      tmp_resp = os_read_id_addr_pkd_net[(i*(AXI_RADDR_WIDTH-2))+:(AXI_RADDR_WIDTH-2)];
      {tmp_id, tmp_addr} = tmp_resp;
      os_read_addr_pkd_net[(i*AXI_RADDR_WIDTH)+:AXI_RADDR_WIDTH] = {tmp_addr,4'b0000};
      os_read_id_pkd_net[(i*2)+:2] = tmp_id;
      os_rd_cpud_dma_net[i] = (tmp_id == 2'd1) | (tmp_id == 2'd2);
    end
  end
  
  
  assign os_read_id_pkd          = {2'b0, os_read_id_pkd_net};
  assign os_read_addr_pkd        = os_read_addr_pkd_net;
  assign os_read_valid_pkd       = os_read_valid_pkd_net;  
  
  assign os_read_cpu_d_valid_pkd = (os_rd_cpud_dma_net & os_read_valid_pkd_net);
  
  // for each CPU work out if any reads are outstanding
  always @*
  begin : id_rd_os_loop
    integer i,j;
    logic tmp_id; 
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_rd_os[i] = 1'b0;
      for(j=0; j< NUM_OS_READS; j=j+1)
      begin
        tmp_id = os_read_id_pkd[j];
        cpu_rd_os[i] = cpu_rd_os[i] | ((tmp_id == i[0]) & os_read_valid_pkd[j]);
      end
      
    end
  end
  
 // assign initiator_r_idle = ~(|os_read_valid_pkd_net); 
  


 
  
endmodule

`default_nettype wire

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
//   File:
//   miv_rv32_axi_wchan.sv
//
//   Purpose:
//    MIV_RV32 Bridge AXI Initiator write (AW,W) channel
//    Simple initiator. 
//    Supports single requester with single AXI ID and fixed 4 byte width
//    Supports incrementing burst of 1 or 4 beats only
//   
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_axi_wchan
//********************************************************************************
// Parameter description

  #(
    parameter AXI_WADDR_WIDTH = 32,
    parameter NUM_REQUESTERS = 2,
    parameter NUM_OS_WRITES = 4,
    parameter LOG2_NUM_OS_WRITES = 2
   )

//********************************************************************************
// Port description

  (
    
    input wire logic                                            resetn,
    input wire logic                                            clk,
    input wire logic                                            aclk_en,
    // controls   
    input wire logic                                            subsys_parity_en,
    input wire logic                                            cfg_fence_all,
    output logic                                                initiator_w_idle,
    output logic [NUM_REQUESTERS-1:0]                           write_response_error,
    input wire logic [3:0]                                      cfg_aw_cache,
    //WADDR channel (and sidebands)
    output logic                                                axi_awid,
    output logic [AXI_WADDR_WIDTH-1:0]                     axi_awaddr,
    output logic [3:0]                                          axi_awlen,
    output logic [2:0]                                          axi_awsize,
    output logic [1:0]                                          axi_awburst,
    output logic                                                axi_awlock,
    output logic [3:0]                                          axi_awcache,
    output logic [2:0]                                          axi_awprot,
    output logic                                                axi_aw_addr_p,
    input wire logic                                            axi_awready,
    output logic                                                axi_awvalid,
    //WDATA channel (and sidebands)
    output logic [31:0]                                         axi_wdata,
    output logic [3:0]                                          axi_wstrb,
    output logic                                                axi_wlast,
    output logic                                                axi_wid,
    input wire logic                                            axi_wready,
    output logic                                                axi_wvalid,
    output logic [3:0]                                          axi_w_data_p,   
    //BRESP channel
    input wire logic  [1:0]                                     axi_bresp,
    input wire logic                                            axi_bid,
    output logic                                                axi_bready,
    input wire logic                                            axi_bvalid,
    
    //cpu dside   
    input wire logic [31:0]                                     cpu_axi_awaddr,
    input wire logic [2:0]                                      cpu_axi_awsize,
    output logic                                                cpu_axi_awready,
    input wire logic                                            cpu_axi_awvalid,
    input wire logic [31:0]                                     cpu_axi_wdata,
    input wire logic [3:0]                                      cpu_axi_wdata_p,
    input wire logic                                            cpu_axi_wlast,
    input wire logic [3:0]                                      cpu_axi_wstrb,
    output logic                                                cpu_axi_wready,
    input wire logic                                            cpu_axi_wvalid,  
    input wire logic                                            cpu_axi_fence_wr_flush,
    output logic                                                cpu_axi_fence_wr_os,
    input wire logic                                            cpu_axi_war_hzd,
    //udma   
    input wire logic [31:0]                                     udma_axi_awaddr,
    input wire logic [3:0]                                      udma_axi_awlen,
    input wire logic [2:0]                                      udma_axi_awsize,
    output logic                                                udma_axi_awready,
    input wire logic                                            udma_axi_awvalid,
    input wire logic [31:0]                                     udma_axi_wdata,
    input wire logic [3:0]                                      udma_axi_wdata_p,
    input wire logic                                            udma_axi_wlast,
    input wire logic [3:0]                                      udma_axi_wstrb,
    output logic                                                udma_axi_wready,
    input wire logic                                            udma_axi_wvalid,   
    input wire logic                                            udma_axi_fence_wr_flush,
    output logic                                                udma_axi_fence_wr_os, 
    input wire logic                                            udma_axi_war_hzd,   

    // outstanding write transaction addresses
    output logic [(NUM_OS_WRITES*AXI_WADDR_WIDTH)-1:0]     os_write_addr_pkd,
    output logic [NUM_OS_WRITES-1:0]                            os_write_valid_pkd
  );

//********************************************************************************
// Declarations

// localparams

  localparam AW_BUFF_WIDTH = AXI_WADDR_WIDTH + 4 + 3 + 1;
  localparam W_BUFF_WIDTH  = 32 + 4 + 4 + 1;

  localparam RESP_OKAY   = 2'b00;
  localparam RESP_EXOKAY = 2'b01;
  localparam TGT_SLVERR  = 2'b10;
  localparam RESP_DECERR = 2'b11;  

  // Internal nets

  logic [NUM_REQUESTERS-1:0]                                 cpu_aww_req;
  logic [NUM_REQUESTERS-1:0]                                 cpu_aww_gnt;
  logic [NUM_REQUESTERS-1:0]                                 cpu_aww_sel;
  logic [NUM_REQUESTERS-1:0]                                 rd_all_hzd;
  logic [NUM_REQUESTERS-1:0]                                 rd_self_hzd;
  logic [NUM_REQUESTERS-1:0]                                 rd_prefetch_hzd;
  logic                                                      waddr_buffer_ready;
  logic                                                      wdata_buffer_ready;
  logic                                                      w_os_buffer_ready;
  logic                                                      accept_aw_req;
  logic                                                      accept_w_data;

  logic [AXI_WADDR_WIDTH-1:0]                           cpu_awaddr[NUM_REQUESTERS-1:0];
  logic [NUM_REQUESTERS-1:0]                                 cpu_awid;   
  logic [3:0]                                                cpu_awlen[NUM_REQUESTERS-1:0]; 
  logic [2:0]                                                cpu_awsize[NUM_REQUESTERS-1:0];
  logic [NUM_REQUESTERS-1:0]                                 cpu_addr_p;        
  logic [NUM_REQUESTERS-1:0]                                 cpu_awvalid;      
  logic [31:0]                                               cpu_wdata[NUM_REQUESTERS-1:0];    
  logic [3:0]                                                cpu_wdata_p[NUM_REQUESTERS-1:0];  
  logic [3:0]                                                cpu_wstrb[NUM_REQUESTERS-1:0];  
  logic [NUM_REQUESTERS-1:0]                                 cpu_wvalid; 
  logic [NUM_REQUESTERS-1:0]                                 cpu_wlast;          
  logic [(AXI_WADDR_WIDTH-1):4]                         cpu_rd_hzd_addr [NUM_REQUESTERS-1:0];     
  logic [NUM_REQUESTERS-1:0]                                 cpu_rd_hzd_addr_valid;
  logic [NUM_REQUESTERS-1:0]                                 war_hzd;
  
  logic [AXI_WADDR_WIDTH-1:0]                           cpu_awaddr_mux;
  logic                                                      cpu_awid_mux;
  logic [3:0]                                                cpu_awlen_mux; 
  logic [2:0]                                                cpu_awsize_mux; 
  logic                                                      cpu_addr_p_mux;
  logic [31:0]                                               cpu_wdata_mux;
  logic [3:0]                                                cpu_wdata_p_mux;
  logic                                                      cpu_wlast_mux;
  logic [3:0]                                                cpu_wstrb_mux;
  logic                                                      axi_wid_mux;
  logic                                                      cpu_wvalid_mux;
  logic                                                      cpu_num_mux;
  
  logic [AXI_WADDR_WIDTH-1:0]                           cpu_awaddr_buff;
  logic [3:0]                                                cpu_awlen_buff; 
  logic [2:0]                                                cpu_awsize_buff; 
  logic [3:0]                                                cpu_awcache_buff;  
  logic                                                      cpu_addr_p_buff;
  logic [31:0]                                               cpu_wdata_buff;
  logic [3:0]                                                cpu_wdata_p_buff;
  logic                                                      cpu_wlast_buff;
  logic [3:0]                                                cpu_wstrb_buff;
  logic                                                      axi_awid_buff;
  logic                                                      axi_wid_buff;
  
  logic [AW_BUFF_WIDTH-1:0]                                  aw_buff_in;
  logic [AW_BUFF_WIDTH-1:0]                                  aw_buff_out;
  logic [W_BUFF_WIDTH-1:0]                                   w_buff_in;
  logic [W_BUFF_WIDTH-1:0]                                   w_buff_out; 

  logic [1:0]                                                bresp_buff;
  logic                                                      cpu_bid_buff;
  logic                                                      bvalid_buff; 
  logic                                                      bready_buff;    
  logic [NUM_REQUESTERS-1:0]                                 cpu_bresp_id_valid;
  logic                                                      b_valid_aclken;
  
  logic                                                      wlast_valid;
  
  logic [NUM_REQUESTERS-1:0]                                 fence_flush;
  logic [NUM_REQUESTERS-1:0]                                 cpu_wr_os;
  logic [(NUM_OS_WRITES*(AXI_WADDR_WIDTH-3))-1:0]       os_write_id_addr_pkd_net;
  logic [NUM_OS_WRITES-1:0]                                  os_write_id_pkd_net;
  logic [NUM_OS_WRITES:0]                                    os_write_id_pkd;
  logic [(NUM_OS_WRITES*AXI_WADDR_WIDTH)-1:0]           os_write_addr_pkd_net;
  logic [NUM_OS_WRITES-1:0]                                  os_write_valid_pkd_net; 
  logic [AXI_WADDR_WIDTH-4:0]                           curr_resp_id_addr;

//********************************************************************************
// Main code

  // write side 
  
    // a write request from a CPU can be considered for acceptance (arbitration)if:
    //   - there is no fence flush in progress
    //   - there is space in the write outstanding (os) buffer
    //   - there is space in the write request buffer
    //   - read hazarding is disabled or the write address does not hazard with os reads
  
// cpu
    assign cpu_awaddr[0]               = cpu_axi_awaddr;
    assign cpu_awid[0]                 = 1'b0;
    assign cpu_awlen[0]                = 4'd0; // CPU currently only generates single beat transactions
    assign cpu_awsize[0]               = cpu_axi_awsize;
    assign cpu_awvalid[0]              = cpu_axi_awvalid;
    assign cpu_wdata[0]                = cpu_axi_wdata;
    assign cpu_wdata_p[0]              = cpu_axi_wdata_p;
    assign cpu_wstrb[0]                = cpu_axi_wstrb;
    assign cpu_wlast[0]                = cpu_axi_wlast;
    assign cpu_wvalid[0]               = cpu_axi_wvalid;
    assign cpu_axi_awready             = cpu_aww_gnt[0];
    assign cpu_axi_wready              = cpu_aww_sel[0] & wdata_buffer_ready;
    assign cpu_axi_fence_wr_os          = (cfg_fence_all  & (|cpu_wr_os)) |
                                         (~cfg_fence_all  & cpu_wr_os[0]);
    assign war_hzd[0]                  = cpu_axi_war_hzd; 

  
  generate
  if((NUM_REQUESTERS >= 2)) begin: gen_assign_udma_cons
    assign cpu_awaddr[1]               = udma_axi_awaddr;
    assign cpu_awid[1]                 = 1'b1;
    assign cpu_awlen[1]                = udma_axi_awlen;
    assign cpu_awsize[1]               = udma_axi_awsize;
    assign cpu_awvalid[1]              = udma_axi_awvalid;
    assign cpu_wdata[1]                = udma_axi_wdata;
    assign cpu_wdata_p[1]              = udma_axi_wdata_p;
    assign cpu_wstrb[1]                = udma_axi_wstrb;
    assign cpu_wlast[1]                = udma_axi_wlast;
    assign cpu_wvalid[1]               = udma_axi_wvalid; 
    assign udma_axi_awready            = cpu_aww_gnt[1];
    assign udma_axi_wready             = cpu_aww_sel[1] & wdata_buffer_ready;
    assign udma_axi_fence_wr_os        = (cfg_fence_all  & (|cpu_wr_os)) |
                                         (~cfg_fence_all & cpu_wr_os[1]);
    assign war_hzd[1]                  = udma_axi_war_hzd;                                    
  end
  else begin: ngen_assign_udma_cons
    assign udma_axi_awready            = 1'b0;
    assign udma_axi_wready             = 1'b0;
    assign udma_axi_fence_wr_os        = 1'b0;
  end
  endgenerate

  
  generate
  genvar i_req;
  for (i_req = 0; i_req < NUM_REQUESTERS; i_req = i_req+1) begin : gen_cpu_req
    
    assign cpu_aww_req[i_req] = cpu_awvalid[i_req] & 
                                //cpu_wvalid[i_req] &
                                // (~fence_flush[i_req]) & REVISIT add fence logic back
                                w_os_buffer_ready &
                                waddr_buffer_ready &
                                ~war_hzd[i_req];
                                                       
    // compute address parity in parallel for each source and multiplex so it can be computed 
    // whilst arbitrating    
    assign cpu_addr_p[i_req] = ^cpu_awaddr[i_req];                                               
                                                       
  end
  endgenerate

                                    
  // arbitrate write requests
  // once arbitrated, lock the selection and do not re-arbitrate until last data beat is transferred 
    
  miv_rv32_rr_pri_arb
  //***************************************************************
  // Parameter description
  #(
    .NUM_REQS            (NUM_REQUESTERS),
    .USE_FORMAL          (1),
    .USE_SIM             (1)
   )

  u_waddr_arb
  //***************************************************************
  // Signal description
  (
    .resetn              (resetn),
    .unlock              (wlast_valid),  
    .clk                 (clk),
    .req                 (cpu_aww_req),
    .gnt                 (cpu_aww_gnt),
    .sel_seq             (), // open
    .sel_early           (cpu_aww_sel)
  );
  
  assign wlast_valid = cpu_wlast_mux & cpu_wvalid_mux & wdata_buffer_ready;
  
  // request/data multiplexer
  
  always @*
  begin : waddr_wdata_mux_loop
    integer i;
    cpu_awaddr_mux    = {32{1'b0}};
    cpu_awid_mux      = 1'b0; 
    cpu_awlen_mux     = {4{1'b0}}; 
    cpu_awsize_mux    = {3{1'b0}};
    cpu_addr_p_mux    = 1'b0;  
    cpu_wdata_mux     = {32{1'b0}};       
    cpu_wdata_p_mux   = {4{1'b0}};     
    cpu_wstrb_mux     = {4{1'b0}};
    cpu_wlast_mux     = 1'b0;
    cpu_wvalid_mux    = 1'b0;
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_awaddr_mux    = cpu_awaddr_mux  | ({AXI_WADDR_WIDTH{cpu_aww_gnt[i]}} & cpu_awaddr[i]); 
      cpu_awid_mux      = cpu_awid_mux    | (cpu_aww_gnt[i] & cpu_awid[i]);
      cpu_awlen_mux     = cpu_awlen_mux   | ({4{cpu_aww_gnt[i]}} & cpu_awlen[i]);
      cpu_awsize_mux    = cpu_awsize_mux  | ({3{cpu_aww_gnt[i]}} & cpu_awsize[i]);
      cpu_addr_p_mux    = cpu_addr_p_mux  | (cpu_aww_gnt[i] & cpu_addr_p[i]);        
      cpu_wdata_mux     = cpu_wdata_mux   | ({32{cpu_aww_sel[i]}} & cpu_wdata[i]);  
      cpu_wdata_p_mux   = cpu_wdata_p_mux | ({4{cpu_aww_sel[i]}}  & cpu_wdata_p[i]);  
      cpu_wstrb_mux     = cpu_wstrb_mux   | ({4{cpu_aww_sel[i]}}  & cpu_wstrb[i]);
      cpu_wlast_mux     = cpu_wlast_mux   | (cpu_aww_sel[i]  & cpu_wlast[i]);
      cpu_wvalid_mux    = cpu_wvalid_mux  | (cpu_aww_sel[i]  & cpu_wvalid[i]);
    end
  end

  
  // request/data output buffers
  
  assign accept_aw_req  = |cpu_aww_gnt;
                             
  
  // translate/map CPU transaction AWID to AXI AWID
  // SUBSYS AXI initiator supports only a single ID, so ditrect translation to CPU num to know where to send responses
  
  
  assign cpu_num_mux = cpu_awid_mux; 
  

  
  assign aw_buff_in = {cpu_awaddr_mux,
                       cpu_awlen_mux,
                       cpu_awsize_mux,
                       cpu_addr_p_mux};
                       
  assign {cpu_awaddr_buff,
          cpu_awlen_buff,
          cpu_awsize_buff,
          cpu_addr_p_buff} = aw_buff_out;
          
  
  
  
  miv_rv32_axi_egress_slip_buffer
  #(
    .BUFF_WIDTH         (AW_BUFF_WIDTH)
  )
  u_waddr_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .clken              (aclk_en),
    .valid_in           (accept_aw_req),
    .ready_in           (waddr_buffer_ready),
    .data_in            (aw_buff_in),
    .data_out           (aw_buff_out),
    .valid_out          (axi_awvalid),
    .ready_out          (axi_awready),  
    .nearly_full        ()  //open      
  );
  
  
  
  assign w_buff_in = {cpu_wdata_mux,
                      cpu_wdata_p_mux,
                      cpu_wstrb_mux,
                      cpu_wlast_mux};
  assign {cpu_wdata_buff,
          cpu_wdata_p_buff,
          cpu_wstrb_buff,
          cpu_wlast_buff} = w_buff_out;
          
  
  assign accept_w_data = |(cpu_aww_sel & cpu_wvalid);
  
  miv_rv32_axi_egress_slip_buffer
  #(
    .BUFF_WIDTH         (W_BUFF_WIDTH)
  )
  u_wdata_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .clken              (aclk_en),
    .valid_in           (accept_w_data),
    .ready_in           (wdata_buffer_ready),
    .data_in            (w_buff_in),
    .data_out           (w_buff_out),
    .valid_out          (axi_wvalid),
    .ready_out          (axi_wready), 
    .nearly_full        ()  //open   
  );
  
  // outstanding request buffer. 
  // This stores a list of the write address (16 byte granularity)  
  // such that the initiator can keep track of them and manage RAW hazards.
  // SUBSYS supports a single AXI ID therefore request always stay in order, so just need a simple buffer 
  // to maintain a list.
  
  
  miv_rv32_buffer
  #(
    .BUFF_WIDTH         (AXI_WADDR_WIDTH-3), 
    .BUFF_SIZE          (NUM_OS_WRITES),
    .PTR_SIZE           (LOG2_NUM_OS_WRITES)
  )
  u_wos_buffer
  (
    .clk                (clk),
    .resetn             (resetn),
    .valid_in           (accept_aw_req),    
    .ready_in           (w_os_buffer_ready),
    .data_in            ({cpu_num_mux,cpu_awaddr_mux[AXI_WADDR_WIDTH-1:4]}),
    .data_out           (curr_resp_id_addr),     //open
    .valid_out          (),     //open
    .ready_out          (bvalid_buff),
    .data_out_pkd       (os_write_id_addr_pkd_net),                         
    .valid_out_pkd      (os_write_valid_pkd_net),
    .nearly_full        () //open
  );
  
  always @*
  begin :extract_addr_loop
    integer i;
    for(i=0; i<NUM_OS_WRITES; i=i+1)
    begin
      os_write_addr_pkd_net[(i*AXI_WADDR_WIDTH)+:AXI_WADDR_WIDTH]  =
           {(os_write_id_addr_pkd_net[(i*(AXI_WADDR_WIDTH-3))+:(AXI_WADDR_WIDTH-4)]),4'b0000};
      os_write_id_pkd_net[i]   = os_write_id_addr_pkd_net[(i*(AXI_WADDR_WIDTH-3))+(AXI_WADDR_WIDTH-4)];
    end
  end
    
  
//  // append any write request arbitrated this cycle to the list of outstanding requests since it will not 
//  // yet be in the buffer list, but will still need to prevent writes following
//  assign os_write_id_pkd    = {cpu_awid_mux,os_write_id_pkd_net};
//  assign os_write_addr_pkd  = {{(cpu_awaddr_mux[AXI_WADDR_WIDTH-1:4]),4'b0000},os_write_addr_pkd_net};
//  assign os_write_valid_pkd = {accept_aw_req,os_write_valid_pkd_net};
  
  assign os_write_id_pkd    = {1'b0, os_write_id_pkd_net};
  assign os_write_addr_pkd  = os_write_addr_pkd_net;
  assign os_write_valid_pkd = os_write_valid_pkd_net;  
  
  // for each requester (cpu, udma) work out if any writes are outstanding
  
  always @*
  begin : id_wr_os_loop
    integer i,j;
    logic tmp_id; 
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_wr_os[i] = 1'b0;
      for(j=0; j<NUM_OS_WRITES; j=j+1)
      begin
        tmp_id = os_write_id_pkd[j];
        cpu_wr_os[i] = cpu_wr_os[i] | ((tmp_id == i[0]) & os_write_valid_pkd[j]);
      end      
    end
  end
  
  
  // Write response (BRESP) buffer
  // Buffer is here just for timing purposes since the response is not used except for indicating
  // that an outstanding write can be removed from the buffer and to generate an exception
  // in the case of a write error
  
  assign b_valid_aclken = axi_bvalid & aclk_en;
  
  always @(posedge clk)
  begin
    bresp_buff   <=  axi_bresp;         
  end
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      bvalid_buff <=  1'b0;
    else
      bvalid_buff <=  b_valid_aclken; 
  end
  

  

  
  always @*
  begin : respid_map_loop
    integer i;
    for(i=0; i<NUM_REQUESTERS; i=i+1)
    begin
      cpu_bresp_id_valid[i] = (curr_resp_id_addr[(AXI_WADDR_WIDTH-4)] == i[0]) & bvalid_buff;
    end
  end  
  
  // if the write response is TGTERR/DECERR then generate an exception
  // EXOKAY will be treated as OKAY since there are no exclusive transactions generated
  assign write_response_error = {NUM_REQUESTERS{((bresp_buff == 2'b10) | (bresp_buff == 2'b11))}} & cpu_bresp_id_valid;
  

  // assign AXI outputs
  
  assign axi_awid           = 1'b0;  
  assign axi_awaddr         = cpu_awaddr_buff;
  assign axi_awlen          = cpu_awlen_buff;  
  assign axi_awsize         = cpu_awsize_buff; 
  assign axi_awburst        = 2'b01;    // SUBSYS only supports incrementing bursts 
  assign axi_awlock         = 1'b0;    // Always normal (no lock, no exclusive) for now
  assign axi_awcache        = cfg_aw_cache;
  assign axi_awprot         = 3'b010;   // Always data, non-secure, normal
  assign axi_aw_addr_p      = cpu_addr_p_buff;     
  
  assign axi_wdata          = cpu_wdata_buff;
  assign axi_wstrb          = cpu_wstrb_buff;
  assign axi_wlast          = cpu_wlast_buff;
  assign axi_wid            = 1'b0;
  assign axi_w_data_p       = cpu_wdata_p_buff;
  
  assign axi_bready = 1'b1; // always accept write responses
  
  assign initiator_w_idle            = ~(|os_write_valid_pkd);
  

                           
    
endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_xaddr_buffer.sv
//
//   Purpose: Specialised version of the buffer for handling AXI a*addr channel
//            Supports 32 bit incr and wrapped bursts with burst address generation
//
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_axi_xaddr_buffer
//********************************************************************************
// Parameter description

  #(
    parameter ATTB_WIDTH = 5,
    parameter BUFF_SIZE = 2,
    parameter PTR_SIZE = 1,
    parameter NUM_DBYTES = 8
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    input wire                               clken,
    
    input wire                               addr_parity_en,
    
    input wire                               valid_in,
    output wire                              ready_in,
    input wire                               beat_accepted,
    input wire [31:0]                        addr_in,
    input wire                               addr_in_p,
    input wire [3:0]                         len_in,
    input wire [ATTB_WIDTH-1:0]              attb_in,
    input wire                               wrap_in,
    
    output wire [31:0]                       addr_out,
    output wire [3:0]                        len_out,
    output wire [ATTB_WIDTH-1:0]             attb_out,
    output wire                              valid_out,
    output wire                              addr_parity_err,
    output wire [(ATTB_WIDTH*BUFF_SIZE)-1:0] attb_out_pkd,
    output wire [BUFF_SIZE-1:0]              valid_out_pkd,
    input wire                               ready_out,
    output wire                              last_out  
    
 
    
  );

//********************************************************************************
// localparams
  localparam BUFF_MAX   = BUFF_SIZE-1;

// Declarations

  reg  [PTR_SIZE-1:0]   buff_wr_ptr;
  reg  [PTR_SIZE-1:0]   buff_rd_ptr;
  wire [PTR_SIZE-1:0]   next_buff_wr_ptr;
  wire [PTR_SIZE-1:0]   next_buff_rd_ptr;
  
  wire [BUFF_SIZE-1:0]  buff_wr_strb;
  wire [BUFF_SIZE-1:0]  buff_rd_strb;
  
  wire [BUFF_SIZE-1:0]   buff_valid;
  wire [BUFF_SIZE-1:0]   next_buff_valid;
  wire [31:0]            buff_addr[BUFF_SIZE-1:0]; 
  wire [3:0]             buff_len[BUFF_SIZE-1:0];  
  wire [ATTB_WIDTH-1:0]  buff_attb[BUFF_SIZE-1:0]; 
  wire [BUFF_SIZE-1:0]   buff_last_beat; 
  wire [BUFF_SIZE-1:0]   buff_wrap;
  wire [BUFF_SIZE-1:0]   buff_excl;  
  wire [BUFF_SIZE-1:0]   curr_beat_accepted;
  wire [BUFF_SIZE-1:0]   buff_addr_parity_err;
  
  wire                   next_buff_ready;
  reg                    buff_ready_reg;  

  wire                   rd_data;
  wire                   wr_data;
  
  wire                   full;
  wire                   empty;


  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************

  assign full     = &buff_valid;
  assign empty    = ~(|buff_valid);
  assign wr_data  = valid_in & buff_ready_reg & clken;
  assign rd_data  = ready_out & ~empty;
  
  assign next_buff_ready = ~(&next_buff_valid);

  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_ready_reg <= 1'b0;
    else
      if(clken)
        buff_ready_reg <= next_buff_ready;       
  end
  
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_rd_ptr <= {PTR_SIZE{1'b0}};
    else
      if(rd_data)
        buff_rd_ptr <= next_buff_rd_ptr;        
  end 
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_wr_ptr <= {PTR_SIZE{1'b0}};
    else
      if(wr_data)
        buff_wr_ptr <= next_buff_wr_ptr;
  end
  
  assign next_buff_wr_ptr = (buff_wr_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_wr_ptr+1;
  assign next_buff_rd_ptr = (buff_rd_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_rd_ptr+1;
 
  
  generate
  genvar gen_buff;
  for(gen_buff = 0; gen_buff<BUFF_SIZE; gen_buff=gen_buff+1)
  begin : gen_buff_loop
    
    assign curr_beat_accepted[gen_buff] = beat_accepted & 
                                          (buff_rd_ptr == gen_buff[PTR_SIZE-1:0]);
    
    assign buff_wr_strb[gen_buff] = wr_data & (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign buff_rd_strb[gen_buff] = rd_data & (buff_rd_ptr == gen_buff[PTR_SIZE-1:0]);
  
    miv_rv32_axi_xaddr_buffer_slot
    #(
      .ATTB_WIDTH         (ATTB_WIDTH),
      .NUM_DBYTES         (NUM_DBYTES)
    )
    u_miv_rv32_axi_xaddr_buffer_slot
    (
      .clk                (clk),
      .resetn             (resetn),
      .addr_parity_en     (addr_parity_en),
      .alloc_buffer       (buff_wr_strb[gen_buff]),
      .dealloc_buffer     (buff_rd_strb[gen_buff]),
      .update_address     (curr_beat_accepted[gen_buff]),
      .addr_in            (addr_in),
      .addr_in_p          (addr_in_p),
      .len_in             (len_in),
      .attb_in            (attb_in),
      .wrap_in            (wrap_in),
      .addr_out           (buff_addr[gen_buff]),
      .len_out            (buff_len[gen_buff]),
      .attb_out           (buff_attb[gen_buff]),
      .addr_parity_err    (buff_addr_parity_err[gen_buff]),
      .valid_out          (buff_valid[gen_buff]),
      .last_beat          (buff_last_beat[gen_buff]),
      .next_valid_out     (next_buff_valid[gen_buff])
    );

    assign attb_out_pkd[(ATTB_WIDTH*gen_buff)+:ATTB_WIDTH] = buff_attb[gen_buff];
    assign valid_out_pkd[gen_buff]                         = buff_valid[gen_buff];
    
  end
  endgenerate
  
  // output mux/assign
  assign addr_out        = buff_addr[buff_rd_ptr];
  assign len_out         = buff_len[buff_rd_ptr];
  assign attb_out        = buff_attb[buff_rd_ptr];     
  assign valid_out       = buff_valid[buff_rd_ptr];
  assign last_out        = buff_last_beat[buff_rd_ptr];
  
  assign ready_in        = buff_ready_reg;
  
  assign addr_parity_err = |buff_addr_parity_err; 
  


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_axi_xaddr_buffer_slot.sv
//
//   Purpose: slot buffer for a*addr requests
//
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_axi_xaddr_buffer_slot
//********************************************************************************
// Parameter description

  #(
    parameter ATTB_WIDTH = 4,
    parameter NUM_DBYTES = 8
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                    resetn,
    input wire                    clk,
    
    input wire                    addr_parity_en,
    
    input wire                    alloc_buffer,
    input wire                    dealloc_buffer,
    input wire                    update_address,
    input wire [31:0]             addr_in,
    input wire                    addr_in_p,
    input wire [3:0]              len_in,
    input wire [ATTB_WIDTH-1:0]   attb_in,
    input wire                    wrap_in,
    
    output wire [31:0]            addr_out,
    output wire [3:0]             len_out,
    output wire [ATTB_WIDTH-1:0]  attb_out,
    output wire                   addr_parity_err,
    output wire                   valid_out,
    output wire                   last_beat,
    output wire                   next_valid_out   
    
 
    
  );

//********************************************************************************
// localparams


// Declarations

 
  reg                   buff_valid;
  reg [31:0]            buff_addr; 
  reg [3:0]             buff_len;  
  reg [ATTB_WIDTH-1:0]  buff_attb;  
  reg                   buff_wrap; 
  reg [3:0]             beats_remaining;
  

  wire                  next_buff_valid;  
  wire [31:0]           next_buff_addr;
  wire [3:0]            next_buff_len;
  wire [ATTB_WIDTH-1:0] next_buff_attb;
  wire                  next_buff_wrap;
  
  wire [3:0]            next_buff_addr_wrap_bits;
  wire [9:0]            next_buff_addr_incr_bits; 
  wire [31:0]           next_buff_addr_sel; 
  wire [3:0]            next_beats_remaining;
  reg                   alloc_buffer_d1;
  reg                   orig_addr_parity;
  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************


    
  // Everything but address stays stable throughout the life of the transaction in the buffer
  // Address is re-computed each time a beat is accepted (indicated by beat_accepted)
  // First address is always the one in the request so only need updated address
  // for subsequent beats
  
  generate if(NUM_DBYTES == 8) begin : gen_64_bit_datapath
  
    // wrapping burst can only have max length 16 and since the size is always 8 bytes for a multibeat burst, 
    // can only be within a 64 byte region so only need to worry about bits [6:3] changing
    assign next_buff_addr_wrap_bits = ( buff_addr[6:3] & ~ buff_len) | 
                                      ((buff_addr[6:3]+4'd1) & buff_len);

    // incrementing bursts may not cross 4K boundary so only need to compute bottom 12 bits, since all 64 bit OPSx transactions
    // are 64-bit aligned then only need 10 bits.
    // single beat transactions can still be 32 bit aligned, so keep buff_addr[2]  
    assign next_buff_addr_incr_bits = buff_addr[11:2]+10'd2; 
  
    assign next_buff_addr_sel       = ~update_address ? buff_addr :
                                                        buff_wrap ? {buff_addr[31:7], next_buff_addr_wrap_bits,buff_addr[2], buff_addr[1:0]} :
                                                                    {buff_addr[31:12], next_buff_addr_incr_bits, buff_addr[1:0]};
  
  end else begin : gen_32_bit_datpath
  
    // wrapping burst can only have max length 16 and since the size is always 4 bytes, can only be within a 64 byte  
    // region so only need to worry about bits [5:2] changing
    assign next_buff_addr_wrap_bits = ( buff_addr[5:2] & ~ buff_len) | 
                                      ((buff_addr[5:2]+4'd1) & buff_len);

    // incrementing bursts may not cross 4K boundary so only need to compute bottom 12 bits, since all 32 bit OPSx transactions
    // are 32-bit aligned then only need 10 bits.
    assign next_buff_addr_incr_bits = buff_addr[11:2]+10'd1; 
  
    assign next_buff_addr_sel       = ~update_address ? buff_addr :
                                                        buff_wrap ? {buff_addr[31:6], next_buff_addr_wrap_bits, buff_addr[1:0]} :
                                                                    {buff_addr[31:12], next_buff_addr_incr_bits, buff_addr[1:0]};
  
  end
  endgenerate
  
  assign next_beats_remaining     = alloc_buffer ? len_in : (update_address ? (beats_remaining - 4'd1) :
                                                                              beats_remaining);
   
  assign next_buff_addr  =  alloc_buffer ? addr_in : next_buff_addr_sel;
  assign next_buff_len   =  alloc_buffer ? len_in  : buff_len; 
  assign next_buff_attb  =  alloc_buffer ? attb_in : buff_attb;  
  assign next_buff_wrap  =  alloc_buffer ? wrap_in : buff_wrap;
  
  // request attributes not reset
  always @(posedge clk)
  begin    
    begin
      buff_addr        <= next_buff_addr;
      buff_len         <= next_buff_len;
      buff_attb        <= next_buff_attb;
      buff_wrap        <= next_buff_wrap;
      beats_remaining  <= next_beats_remaining;
    end
  end
  

         
  assign next_buff_valid = (buff_valid & ~dealloc_buffer) | 
                            alloc_buffer;
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_valid  <=  1'b0;
    else
      buff_valid  <= next_buff_valid; 
  end  

  
  assign addr_out         = buff_addr;
  assign len_out          = buff_len;
  assign attb_out         = buff_attb;     
  assign valid_out        = buff_valid;
  assign next_valid_out   = next_buff_valid;
  assign last_beat        = (beats_remaining == 4'd0);
  
  // check the address parity when a request is allocated.
  // Becasue the address signals from AXI might be late, use the buffered version
  

  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      alloc_buffer_d1  <=  1'b0;
    else
      alloc_buffer_d1  <= alloc_buffer; 
  end
  
  always @(posedge clk)
  begin
    orig_addr_parity <= addr_in_p; 
  end
  
  assign addr_parity_err = (^{orig_addr_parity,buff_addr}) & alloc_buffer_d1 & addr_parity_en;
  
  
  


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_buffer.sv
//
//   Purpose:

//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_buffer
//********************************************************************************
// Parameter description

  #(
    parameter BUFF_WIDTH = 36,
    parameter BUFF_SIZE = 2,
    parameter PTR_SIZE = 1
 
   )

//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    
    input wire                               valid_in,
    output wire                              ready_in,
    input wire [BUFF_WIDTH-1:0]              data_in,
    
    output wire [BUFF_WIDTH-1:0]             data_out,
    output wire                              valid_out,
    
    input wire                               ready_out,  
    
    output wire [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd,
    output wire [BUFF_SIZE-1:0]              valid_out_pkd,
    
    output wire                              nearly_full  
    
 
    
  );

//********************************************************************************
// localparams
  localparam BUFF_MAX = BUFF_SIZE-1;

// Declarations

  reg  [PTR_SIZE-1:0]              buff_wr_ptr;
  reg  [PTR_SIZE-1:0]              buff_rd_ptr;
  wire [PTR_SIZE-1:0]              next_buff_wr_ptr;
  wire [PTR_SIZE-1:0]              next_buff_rd_ptr;
  
  wire [BUFF_SIZE-1:0]             buff_wr_strb;
  wire [BUFF_SIZE-1:0]             buff_rd_strb;
  wire [BUFF_SIZE-1:0]             next_alloc;
  
  reg [BUFF_SIZE-1:0]              buff_valid;
  wire [BUFF_SIZE-1:0]             next_buff_valid;
  reg [BUFF_WIDTH-1:0]             buff_data[BUFF_SIZE-1:0]; 
  
  wire                             rd_data;
  wire                             wr_data;
  
  wire                             full;
  wire                             empty;
  
  reg [(BUFF_SIZE*BUFF_WIDTH)-1:0] data_out_pkd_reg;
  reg [BUFF_SIZE-1:0]              valid_out_pkd_reg;
  
  wire                             next_buff_ready;
  reg                              buff_ready_reg;

  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************

  assign full     = &buff_valid;
  assign empty    = ~(|buff_valid);
  assign wr_data  = valid_in & buff_ready_reg;
  assign rd_data  = ready_out & ~empty;
  
  
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_rd_ptr <= {PTR_SIZE{1'b0}};
    else
      if(rd_data)
        buff_rd_ptr <= next_buff_rd_ptr;        
  end 
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_wr_ptr <= {PTR_SIZE{1'b0}};
    else
      if(wr_data)
        buff_wr_ptr <= next_buff_wr_ptr;
  end
  
  assign next_buff_wr_ptr = (buff_wr_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_wr_ptr+1;
  assign next_buff_rd_ptr = (buff_rd_ptr == BUFF_MAX) ? {PTR_SIZE{1'b0}} : buff_rd_ptr+1;
  
  
  
  generate
  genvar gen_buff;
  for(gen_buff = 0; gen_buff<BUFF_SIZE; gen_buff=gen_buff+1)
  begin : gen_buff_loop
  
    assign buff_wr_strb[gen_buff] = wr_data & (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign next_alloc[gen_buff] = (buff_wr_ptr == gen_buff[PTR_SIZE-1:0]);
    assign buff_rd_strb[gen_buff] = rd_data & (buff_rd_ptr == gen_buff[PTR_SIZE-1:0]);
  
    // Data not reset  // Intialized for simualation - causes x's without
	initial 
	  begin
	    buff_data[gen_buff] <= {BUFF_WIDTH{1'b0}};
	  end
	  
    always @(posedge clk)
      begin    
        if(buff_wr_strb[gen_buff])
        begin
          buff_data[gen_buff] <= data_in;
        end
      end
  
  
    assign next_buff_valid[gen_buff] = (buff_valid[gen_buff] & ~buff_rd_strb[gen_buff]) | 
                                       buff_wr_strb[gen_buff];
  
    always @(posedge clk or negedge resetn)
    begin
      if(~resetn)
        buff_valid[gen_buff]  <=  1'b0;
      else
        buff_valid[gen_buff]  <= next_buff_valid[gen_buff]; 
    end  
    
  end
  endgenerate
  
  assign data_out = buff_data[buff_rd_ptr];
  assign valid_out = buff_valid[buff_rd_ptr];
  
  assign next_buff_ready = ~(&next_buff_valid);
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      buff_ready_reg <= 1'b0;
    else
      buff_ready_reg <= next_buff_ready;       
  end
  
  assign ready_in = buff_ready_reg;

  
  //assign packed outputs
  always @*
  begin: pkd_out_loop
    integer i;
    for(i=0;i<BUFF_SIZE; i=i+1)
    begin
      data_out_pkd_reg[(i*BUFF_WIDTH)+:BUFF_WIDTH] = buff_data[i];
      valid_out_pkd_reg[i] = buff_valid[i];
    end
  end
  
  assign data_out_pkd  = data_out_pkd_reg;
  assign valid_out_pkd = valid_out_pkd_reg; 
  
  // if the next buffer slot to be allocated would cause the buffer to become full if a write occurs
  // without a read, assert the nearly_full output
  assign nearly_full = &(buff_valid | next_alloc);
  


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_fixed_arb.sv
//
//   Purpose: Parameterized fixed priority arbiter
//
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_fixed_arb
//********************************************************************************
// Parameter description

  #(
     parameter NUM_REQS = 3
   )

//********************************************************************************
// Port description

  (
    input wire [NUM_REQS-1:0]       req, 
    output wire [NUM_REQS-1:0]      gnt,
    output wire [(2*NUM_REQS)-1:0]  gnt_dbl 

  );

//********************************************************************************
// localparams
// Declarations


  reg  [NUM_REQS:0]     higher_pri_reqs;
  wire [NUM_REQS:0]     req_ext;
  wire [NUM_REQS-1:0]   tmp_gnt;
      
  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************
  
  // add a '0' so it works even when NUM_REQS == 1
  
  assign req_ext = {1'b0,req};
  
  always @*
  begin : higher_pri_loop
    integer i;
    higher_pri_reqs[0] = 1'b0;
    for(i=0; i < NUM_REQS; i=i+1)
    begin
      higher_pri_reqs[i+1] = req_ext[i] | higher_pri_reqs[i];
    end
  end
  
  assign tmp_gnt = req & ~higher_pri_reqs[NUM_REQS-1:0];
  assign gnt = tmp_gnt;
  assign gnt_dbl = {tmp_gnt,tmp_gnt};
     




endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_rr_pri_arb.sv
//
//   Purpose: Parameterized round-robin arbiter
//
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_rr_pri_arb
//********************************************************************************
// Parameter description

  #(
     parameter NUM_REQS = 3,
     parameter USE_FORMAL = 1,
     parameter USE_SIM = 1
   )

//********************************************************************************
// Port description

  (
    input wire                  resetn,
    input wire                  clk,
    input wire                  unlock,
    input wire [NUM_REQS-1:0]   req, 
    output wire [NUM_REQS-1:0]  gnt,  
    output wire [NUM_REQS-1:0]  sel_seq,
    output wire [NUM_REQS-1:0]  sel_early
    
 
    
  );

//********************************************************************************
// localparams
// Declarations

  wire                       go_next_pri; 
  reg [NUM_REQS-1:0]         hipri_req_ptr;
  wire [NUM_REQS-1:0]        next_hipri_req_ptr;
  wire [(2*NUM_REQS)-1:0]    hipri_req_ptr_dbl;
  
  wire [(2*NUM_REQS)-1:0]    req_dbl;
  wire [NUM_REQS-1:0]        gnt_fixarb[NUM_REQS-1:0];
  
  reg [NUM_REQS-1:0]         tmp_gnt;
  
  wire [NUM_REQS-1:0]        req_shifted [NUM_REQS-1:0];
  wire [NUM_REQS-1:0]        gnt_shifted [NUM_REQS-1:0];
  wire [(2*NUM_REQS)-1:0]    gnt_shifted_dbl [NUM_REQS-1:0];
  wire [NUM_REQS-1:0]        gnt_unshifted [NUM_REQS-1:0];
  
  wire [NUM_REQS-1:0]        req_masked;
  reg                        is_locked;
  reg  [NUM_REQS-1:0]        sel_reg;
  wire [NUM_REQS-1:0]        next_sel_reg;

// Internal nets

//********************************************************************************
// Main code
//********************************************************************************
  
  // REVISIT Round robin for now - change to pseudo random
  
  // Onehot encoding as needs to be speedy
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      hipri_req_ptr <= 1'b1;  //will be implicitly extended (a bit nasty)!!
    else
      hipri_req_ptr <= next_hipri_req_ptr;        
  end 

  assign go_next_pri = |tmp_gnt;
  //assign hipri_req_ptr_dbl = {hipri_req_ptr,hipri_req_ptr} >> 1;
  assign hipri_req_ptr_dbl = {tmp_gnt,tmp_gnt} << 1;
  assign next_hipri_req_ptr = go_next_pri ? hipri_req_ptr_dbl[NUM_REQS+:NUM_REQS] : hipri_req_ptr;  
  
  // implement rr arbiter as a set of fixed priortiy arbiters with the request rotated for each,
  // then select which to use based on the pointer - a bit big, but fast
  
  // mask new requests when locked.
  assign req_masked = req & {NUM_REQS{~is_locked}};  //{NUM_REQS{(unlock | ~is_locked)}};
  assign req_dbl = {req_masked,req_masked};
  
  generate
  genvar i_priarb;
  for (i_priarb = 0; i_priarb < NUM_REQS; i_priarb = i_priarb+1) begin : gen_pri_arb
    
    assign req_shifted[i_priarb] = req_dbl[i_priarb+:NUM_REQS];
  
    miv_rv32_fixed_arb
    //***************************************************************
    // Parameter description
   #(
      .NUM_REQS            (NUM_REQS)
    )

    u_miv_rv32_fixed_arb
    //***************************************************************
    // Signal description
    (
      .req                 (req_shifted[i_priarb]),
      .gnt                 (gnt_shifted[i_priarb]),
      .gnt_dbl             (gnt_shifted_dbl[i_priarb])
    ); 
    
    assign gnt_unshifted[i_priarb] = gnt_shifted_dbl[i_priarb][(NUM_REQS-i_priarb)+:NUM_REQS];
    
  end
  endgenerate 
  
  always @*
  begin : rr_pri_mux_loop
    integer i;
    tmp_gnt = {NUM_REQS{1'b0}};
    for(i=0; i<NUM_REQS; i=i+1)
    begin
      tmp_gnt = tmp_gnt | ({NUM_REQS{hipri_req_ptr[i]}} & gnt_unshifted[i]);
    end
  end
  
  assign gnt = tmp_gnt;    
  
  // if lock is enabled, when a request is granted, hold the selected request (sel output) until the unlock
  // signal is seen
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      is_locked <= 1'b0;  
    else
      is_locked <= ((|tmp_gnt) | is_locked) & ~unlock;      
  end 
  
  
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
      sel_reg <= {NUM_REQS{1'b0}};  
    else
      sel_reg <= next_sel_reg;      
  end 
  
  assign next_sel_reg = is_locked ? sel_reg : tmp_gnt; 
  
  assign sel_seq    = sel_reg;
  assign sel_early  = next_sel_reg;


endmodule


`default_nettype wire

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
//   File:
//   miv_rv32_strb_to_addr.sv
//
//   Purpose:

//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none


module  miv_rv32_strb_to_addr
//********************************************************************************
// Parameter description
  #(
      parameter NUM_BYTES = 8
   )
//********************************************************************************
// Port description

  (
    //inputs
    input wire                               resetn,
    input wire                               clk,
    
    input wire [NUM_BYTES-1:0]               strb,
    input wire [1:0]                         cfg_min_size,
    
    output wire [2:0]                        addr,
    output wire [1:0]                        size 

  );

//********************************************************************************
// localparams
// Declarations

  wire [2:0]  addr_nosmask;
  reg [1:0]   ax_size;
  wire [2:0]  ax_size_mask;
  wire [2:0]  cfg_size_mask;
  wire [1:0]  size_min;
  wire [7:0]  byte_strb;
  
// Internal nets

//********************************************************************************
// Main code
//********************************************************************************
  // extend strobes in 4 byte config
  generate if(NUM_BYTES == 4) begin : gen_4byte
    assign byte_strb = {4'b0000,strb};   
  end
  else begin : gen_8byte
    assign byte_strb = strb; 
  end
  endgenerate 

  // fully decode write strobes (only use simple be mode)
  // byte_strb    size  addr[2] [1] [0]   
  
  // 0000_0001    0         0   0   0   
  // 0000_0010    0         0   0   1
  // 0000_0100    0         0   1   0
  // 0000_1000    0         0   1   1
  // 0001_0000    0         1   0   0
  // 0010_0000    0         1   0   1
  // 0100_0000    0         1   1   0
  // 1000_0000    0         1   1   1
  // 0000_0011    1         0   0   x
  // 0000_1100    1         0   1   x
  // 0011_0000    1         1   0   x
  // 1100_0000    1         1   1   x
  // 0000_1111    2         0   x   x
  // 1111_0000    2         1   x   x
  // 1111_1111    3         x   x   x
   
  assign addr_nosmask[0] = byte_strb[7] | byte_strb[5] | byte_strb[3] | byte_strb[1];
  assign addr_nosmask[1] = byte_strb[7] | byte_strb[6] | byte_strb[3] | byte_strb[2];   
  assign addr_nosmask[2] = byte_strb[7] | byte_strb[6] | byte_strb[5] | byte_strb[4]; 
    // mask address bits based on size to ensure correct alignment
  always @*
  begin
    case(byte_strb)
      8'b0000_0001:  ax_size = 2'd0;
      8'b0000_0010:  ax_size = 2'd0;
      8'b0000_0100:  ax_size = 2'd0;
      8'b0000_1000:  ax_size = 2'd0;
      8'b0001_0000:  ax_size = 2'd0;
      8'b0010_0000:  ax_size = 2'd0;
      8'b0100_0000:  ax_size = 2'd0;
      8'b1000_0000:  ax_size = 2'd0;
      8'b0000_0011:  ax_size = 2'd1;
      8'b0000_1100:  ax_size = 2'd1;
      8'b0011_0000:  ax_size = 2'd1;
      8'b1100_0000:  ax_size = 2'd1;
      8'b0000_1111:  ax_size = 2'd2;
      8'b1111_0000:  ax_size = 2'd2;
      8'b1111_1111:  ax_size = 2'd3;
      default:       ax_size = 2'd3;
    endcase
  end
  
  assign ax_size_mask = (ax_size == 2'd0) ? 3'b000 :
                        (ax_size == 2'd1) ? 3'b001 :
                        (ax_size == 2'd2) ? 3'b011 :
                                            3'b111;
                                          
                                          
  assign cfg_size_mask = (cfg_min_size == 2'd0) ? 3'b000 :
                         (cfg_min_size == 2'd1) ? 3'b001 :
                         (cfg_min_size == 2'd2) ? 3'b011 :
                                                  3'b111;  
  
  assign size_min       = (ax_size >= cfg_min_size) ? ax_size : cfg_min_size;
                                                  
                                              
  assign addr =  addr_nosmask & ~ax_size_mask & ~cfg_size_mask; 
  assign size =  size_min;

endmodule


`default_nettype wire

////////////////////////////////////////////////////////////////////////////////
//                              PMC-Sierra, Inc.                              //
//                                                                            //
//                               Copyright 2010                               //
//                            All Rights Reserved                             //
//                         CONFIDENTIAL & PROPRIETARY                         //
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   lw10_62_60_subsys_macros.sv
//
//   Purpose:
//    Macros for SUBSYS
//   
//
//
//   Author: $Author:  $
//
//   Version: $Revision:  $
//
//   Date: $Date:  $
//
//   Revision History:
// 
//   Revision:
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`ifdef LW10_62_60_SUBSYS_MACROS
`else
  `define LW10_62_60_SUBSYS_MACROS 1
  `define LW10_62_60_SUBSYS_MACRO_MAX(a,b) (a)>(b)?(a):(b)
`endif

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
// SVN $Revision: 43837 $
// SVN $Date: 2023-08-18 14:07:33 +0100 (Fri, 18 Aug 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_tcm.sv
//
//   Purpose:
//    subsys local memory
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_tcm
//********************************************************************************
// Parameter description

  #(   
    parameter FAMILY                 = 26,
    parameter UDMA_PRESENT           = 0,
    parameter TCM_TAS_PRESENT        = 0,
    parameter DEBUG_PRESENT          = 0,
    parameter CPU_I_PRESENT          = 0,
    parameter CPU_D_PRESENT          = 0,
    parameter USE_RAM_PARITY_BITS    = 0,
    parameter RAM_SB_IN_WIDTH        = 4,
    parameter RAM_SB_OUT_WIDTH       = 4,
    parameter RAM_DEPTH              = 4096,
    parameter TCM_ADDR_WIDTH         = 16,
	parameter ECC_ENABLE             = 0,
    parameter ROM                    = 0,
    parameter BOOTROM_SRC_START_ADDR = 0,
    parameter BOOTROM_SRC_END_ADDR   = 0,
    parameter BOOTROM_DEST_ADDR      = 0,
	parameter TCM_REGS				 = 0,
	parameter RECONFIG_BOOTROM       = 0
   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,

    // Control/status/config    
    input wire logic                             subsys_parity_en,  
    output     logic                             trx_os_d_rd,
    output     logic                             trx_os_d_wr,
    output     logic                             ecc_err_correctable,
    output     logic                             ecc_err_uncorrectable,

    // CPU interface    
    input wire  logic                            cpu_i_req_valid,
    output      logic                            cpu_i_req_ready, 
    input wire  logic [3:0]                      cpu_i_req_rd_byte_en,
    input wire  logic [TCM_ADDR_WIDTH-1:0]       cpu_i_req_addr,
    input wire  logic                            cpu_i_req_addr_p,
    output      logic                            cpu_i_resp_valid,
    input wire  logic                            cpu_i_resp_ready,
    output      logic                            cpu_i_resp_error,
    output      logic [31:0]                     cpu_i_resp_rd_data, 
    output      logic [3:0]                      cpu_i_resp_rd_data_p, 
    input wire  logic                            cpu_d_req_valid,
    output      logic                            cpu_d_req_ready, 
    input wire  logic [3:0]                      cpu_d_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_d_req_wr_byte_en,
    input wire  logic                            cpu_d_req_read, 
    input wire  logic                            cpu_d_req_write,
    input wire  logic [TCM_ADDR_WIDTH-1:0]       cpu_d_req_addr,
    input wire  logic                            cpu_d_req_addr_p,
    input wire  logic [31:0]                     cpu_d_req_wr_data,
    input wire  logic [3:0]                      cpu_d_req_wr_data_p,
    output      logic                            cpu_d_resp_valid,
    input wire  logic                            cpu_d_resp_ready,
    output      logic                            cpu_d_resp_error,
    output      logic [31:0]                     cpu_d_resp_rd_data,  
    output      logic [3:0]                      cpu_d_resp_rd_data_p,   
    
    // uDMA interface 
    input wire logic                             udma_req_valid,
    output     logic                             udma_req_ready, 
    input wire logic [3:0]                       udma_req_rd_byte_en,  
    input wire logic [3:0]                       udma_req_wr_byte_en,
    input wire logic                             udma_req_read, 
    input wire logic                             udma_req_write,
    input wire logic [TCM_ADDR_WIDTH-1:0]        udma_req_addr,
    input wire logic                             udma_req_addr_p,
    input wire logic [3:0]                       udma_req_len,
    input wire logic [31:0]                      udma_req_wr_data,
    input wire logic [3:0]                       udma_req_wr_data_p,
    output     logic                             udma_resp_valid,
    input wire logic                             udma_resp_ready,
    output     logic                             udma_resp_rd_error,
    output     logic [31:0]                      udma_resp_rd_data, 
    output     logic [3:0]                       udma_resp_rd_data_p,    

    // local memory direct access port
    input wire logic                             tcm_cpu_access_disable,  
    input wire logic                             tcm_dma_access_disable, 
    input wire logic                             tcm_tas_access_disable, 
    input wire logic                             tcm_tas_req_valid,
    output     logic                             tcm_tas_req_ready, 
    input wire logic [3:0]                       tcm_tas_req_rd_byte_en,  
    input wire logic [3:0]                       tcm_tas_req_wr_byte_en,
    input wire logic [TCM_ADDR_WIDTH-1:0]        tcm_tas_req_addr,
    input wire logic                             tcm_tas_req_addr_p,
    input wire logic [31:0]                      tcm_tas_req_wr_data,
    input wire logic [3:0]                       tcm_tas_req_wr_data_p,
    output     logic                             tcm_tas_resp_valid,
    input wire logic                             tcm_tas_resp_ready,
    output     logic                             tcm_tas_resp_rd_error,
    output     logic [31:0]                      tcm_tas_resp_rd_data,  
    output     logic [3:0]                       tcm_tas_resp_rd_data_p,
    output     logic [RAM_SB_OUT_WIDTH-1:0]      tcm_ram_sb_out,         
    input wire logic [RAM_SB_IN_WIDTH-1:0]       tcm_ram_sb_in,
    input wire logic [1:0]                       tcm_ecc_error_injection
  );

//********************************************************************************
// Declarations

// localparams
  localparam l_subsys_cfg_tcm_byte_shim = 1;
  localparam RAM_DATA_WIDTH       = 32 + (USE_RAM_PARITY_BITS*4);
  localparam CPU_D_DEBUG_PRESENT  = (DEBUG_PRESENT[0] | CPU_D_PRESENT[0]) ? 1 : 0;
  localparam NUM_REQUESTERS       = UDMA_PRESENT + TCM_TAS_PRESENT + CPU_I_PRESENT + CPU_D_DEBUG_PRESENT;  
  localparam RAM_WEN_WIDTH        = l_subsys_cfg_tcm_byte_shim ? 1 : 4; 
  localparam UDMA_TAS_PRESENT     = (UDMA_PRESENT[0] | TCM_TAS_PRESENT[0]) ? 1 : 0;
  
  
  logic [2:0]                      req_valid;                                 
  logic [3:0]                      req_wr_byte_en [2:0];  
  logic [2:0]                      req_read;
  logic [2:0]                      req_write; 
  logic [TCM_ADDR_WIDTH-1:0]       req_addr [2:0];                             
  logic [31:0]                     req_wr_data [2:0];             
  logic [3:0]                      req_wr_data_p [2:0];           

// Internal nets

  logic                             tcm_cpu_access_disable_reg;
  logic                             tcm_dma_access_disable_reg;
  logic                             tcm_tas_access_disable_reg;
                             
  logic                             udma_tas_req_valid;
  logic [3:0]                       udma_tas_req_wr_byte_en;
  logic [3:0]                       udma_tas_req_rd_byte_en;  
  logic                             udma_tas_write;
  logic                             udma_tas_read;
  logic [TCM_ADDR_WIDTH-1:0]        udma_tas_req_addr;
  logic                             udma_tas_req_addr_p;
  logic [31:0]                      udma_tas_req_wr_data;
  logic [3:0]                       udma_tas_req_wr_data_p;
  logic                             udma_tas_resp_valid;    
  logic                             udma_tas_resp_rd_error; 
  logic [31:0]                      udma_tas_resp_rd_data;  
  logic [3:0]                       udma_tas_resp_rd_data_p;
  logic                             udma_tas_req_ready;
    
  logic [2:0]                       TCM_src_req;
  logic [2:0]                       TCM_src_gnt;
  
  logic                             req_valid_mux;
  logic [3:0]                       req_wr_byte_en_mux;


  logic [TCM_ADDR_WIDTH-1:0]        req_addr_mux;
  logic [31:0]                      req_wr_data_mux;
  logic [3:0]                       req_wr_data_p_mux;
  
  logic [31:0]                      resp_rd_data; 
  logic [3:0]                       resp_rd_data_p;
  logic [2:0]                       resp_dest; // REVISIT add extra bit to differentiate udma and tas when UDAM added
  
  logic [RAM_DATA_WIDTH-1:0]        wr_data_comb;
  logic [RAM_DATA_WIDTH-1:0]        rd_data_comb;




//********************************************************************************
// Main code
//********************************************************************************

// ram arbitration is critical path so register external controls
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
    begin
      tcm_cpu_access_disable_reg <= 1'b0;
      tcm_dma_access_disable_reg <= 1'b0;
      tcm_tas_access_disable_reg <= 1'b0;
    end
    else
      begin
        tcm_cpu_access_disable_reg <= tcm_cpu_access_disable;
        tcm_dma_access_disable_reg <= tcm_dma_access_disable;
        tcm_tas_access_disable_reg <= tcm_tas_access_disable;
      end       
  end 


// Request Arbiter
// Round robin arbitration between CPU I, CPU D, and memory dma/tas ports
// The RAM timing is on the critical path for hart performance so dma/tas port arbitration/multiplexing is performed seperately
// All requests are single beat


// uDMA-TAS arbiter/mux

  // REVISIT add first stage arbiter/mux here when uDMA and TCM TAS support added
  // For now only TCM TAS may possibly exist, so connect directly
  //******************
  
  assign udma_tas_req_valid       = tcm_tas_req_valid & ~tcm_tas_access_disable_reg;
  assign udma_tas_req_wr_byte_en  = tcm_tas_req_rd_byte_en; 
  assign udma_tas_req_rd_byte_en  = tcm_tas_req_wr_byte_en; 
  assign udma_tas_write           = |tcm_tas_req_wr_byte_en;
  assign udma_tas_read            = |tcm_tas_req_rd_byte_en;
  assign udma_tas_req_addr        = tcm_tas_req_addr;     
  assign udma_tas_req_addr_p      = tcm_tas_req_addr_p;   
  assign udma_tas_req_wr_data     = tcm_tas_req_wr_data;  
  assign udma_tas_req_wr_data_p   = tcm_tas_req_wr_data_p;
  
  assign tcm_tas_req_ready       = udma_tas_req_ready; 
  assign tcm_tas_resp_valid      = udma_tas_resp_valid;    
  assign tcm_tas_resp_rd_error   = udma_tas_resp_rd_error; 
  assign tcm_tas_resp_rd_data    = udma_tas_resp_rd_data;  
  assign tcm_tas_resp_rd_data_p  = udma_tas_resp_rd_data_p;
  
 // REVISIT Temporary tie-offs UDMA npot currently implemented

  assign udma_req_ready       = 1'b0; 
  assign udma_resp_valid      = 1'b0;
  assign udma_resp_rd_error   = 1'b0;
  assign udma_resp_rd_data    = {32{1'b0}}; 
  assign udma_resp_rd_data_p  = {4{1'b0}};  
  
//////////////////////////////////////////////////////////////////////////////////////////
// SHIM SB SH FSM
   
  localparam BH_INIT = 2'd0, BH_READ = 2'd1, BH_WRITE = 2'd2;
  
  logic [1:0]                      cpu_d_wr_rd_state;
  
  logic [TCM_ADDR_WIDTH-1:0]       cpu_d_req_addr_reg;
  logic [31:0]                     cpu_d_req_wr_data_reg;
 
  logic [3:0]                      cpu_d_req_rd_byte_en_int;  
  logic [3:0]                      cpu_d_req_wr_byte_en_int;
  logic [3:0]                      cpu_d_req_wr_byte_en_reg;
	 
  logic [TCM_ADDR_WIDTH-1:0]       cpu_d_req_addr_sel;
  logic [31:0]                     cpu_d_req_wr_data_sel;
  logic [3:0]                      cpu_d_req_rd_byte_en_sel;  
  logic [3:0]                      cpu_d_req_wr_byte_en_sel;
  logic [RAM_WEN_WIDTH-1:0]        req_wr_byte_en_mux_sel;
  
  logic [1:0]                      ecc_err;
	  

  generate if(l_subsys_cfg_tcm_byte_shim) begin : gen_TCM_byte_shim
	  assign req_wr_byte_en_mux_sel      = |req_wr_byte_en_mux;
      assign cpu_d_req_wr_byte_en_sel    = (cpu_d_wr_rd_state == BH_INIT) & ((&cpu_d_req_wr_byte_en) | (~|cpu_d_req_wr_byte_en)) ? cpu_d_req_wr_byte_en :  cpu_d_req_wr_byte_en_int;
      assign cpu_d_req_rd_byte_en_sel    = (cpu_d_wr_rd_state == BH_INIT) & ((&cpu_d_req_wr_byte_en) | (~|cpu_d_req_wr_byte_en)) ? cpu_d_req_rd_byte_en :  cpu_d_req_rd_byte_en_int;    
      assign cpu_d_req_wr_data_sel       = (cpu_d_wr_rd_state == BH_INIT) & ((&cpu_d_req_wr_byte_en) | (~|cpu_d_req_wr_byte_en)) ? cpu_d_req_wr_data    :  cpu_d_req_wr_data_reg;       
      assign cpu_d_req_addr_sel          = (cpu_d_wr_rd_state == BH_INIT)                                                        ? cpu_d_req_addr       :  cpu_d_req_addr_reg;
  end else begin : ngen_TCM_byte_shim
	  assign req_wr_byte_en_mux_sel      = req_wr_byte_en_mux;
      assign cpu_d_req_wr_byte_en_sel    = cpu_d_req_wr_byte_en;
      assign cpu_d_req_rd_byte_en_sel    = cpu_d_req_rd_byte_en;    
      assign cpu_d_req_wr_data_sel       = cpu_d_req_wr_data;                
      assign cpu_d_req_addr_sel          = cpu_d_req_addr;
  end
  endgenerate
  
  assign cpu_d_req_ready             =  (cpu_d_req_wr_byte_en == 4'b1111 | cpu_d_req_wr_byte_en == 4'b0000 ) & (cpu_d_wr_rd_state == BH_INIT)   ? TCM_src_gnt[1]  : (cpu_d_wr_rd_state == BH_WRITE) ? resp_dest[1] : 1'b0; 
  assign cpu_d_resp_valid            =                                                                         (cpu_d_wr_rd_state == BH_INIT)   ? resp_dest[1]     : (cpu_d_wr_rd_state == BH_WRITE) ? resp_dest[1] : 1'b0; 
  assign cpu_d_req_rd_byte_en_int    = ((cpu_d_req_wr_byte_en != 4'b1111 & cpu_d_req_wr_byte_en != 4'b0000 ) & (cpu_d_wr_rd_state == BH_INIT))  ? 4'b1111          : 4'b0000;

  always @(posedge clk or negedge resetn)
    begin
      if(~resetn) begin
          cpu_d_req_addr_reg       <= {TCM_ADDR_WIDTH{1'b0}};
          cpu_d_req_wr_data_reg    <= {32{1'b0}};
          cpu_d_req_wr_byte_en_reg <= 4'b0000;
          cpu_d_req_wr_byte_en_int <= 4'b0000;
          cpu_d_wr_rd_state        <= BH_INIT;
      end else begin
          case (cpu_d_wr_rd_state)
               BH_INIT : begin
                          if((cpu_d_req_wr_byte_en != 4'b1111 & cpu_d_req_wr_byte_en != 4'b0000 ) & (cpu_d_req_valid)) begin
                              cpu_d_req_addr_reg       <= cpu_d_req_addr;
                              cpu_d_req_wr_data_reg    <= cpu_d_req_wr_data;
                              cpu_d_req_wr_byte_en_reg <= cpu_d_req_wr_byte_en;
                              cpu_d_req_wr_byte_en_int <= 4'b0000;
                              cpu_d_wr_rd_state        <= BH_READ;
                          end else begin
                              cpu_d_wr_rd_state <= BH_INIT;
                          end
                        end
               BH_READ : begin
                          if(resp_dest[1]) begin
                              cpu_d_req_wr_data_reg[31:24] <= (cpu_d_req_wr_byte_en_reg[3]) ? cpu_d_req_wr_data_reg[31:24] : cpu_d_resp_rd_data[31:24];
                              cpu_d_req_wr_data_reg[23:16] <= (cpu_d_req_wr_byte_en_reg[2]) ? cpu_d_req_wr_data_reg[23:16] : cpu_d_resp_rd_data[23:16];
                              cpu_d_req_wr_data_reg[15:8 ] <= (cpu_d_req_wr_byte_en_reg[1]) ? cpu_d_req_wr_data_reg[15:8 ] : cpu_d_resp_rd_data[15:8 ];
                              cpu_d_req_wr_data_reg[ 7:0 ] <= (cpu_d_req_wr_byte_en_reg[0]) ? cpu_d_req_wr_data_reg[ 7:0 ] : cpu_d_resp_rd_data[ 7:0 ];
                              cpu_d_req_wr_byte_en_int     <= 4'b1111;
                              cpu_d_wr_rd_state            <= BH_WRITE;
                          end else begin
                              cpu_d_wr_rd_state <= BH_READ;
                          end
                        end
             BH_WRITE : begin
                          cpu_d_req_wr_byte_en_int <= 4'b0000;
                          cpu_d_wr_rd_state        <= BH_INIT;
                        end
              default : begin
                          cpu_d_req_addr_reg       <= {TCM_ADDR_WIDTH{1'b0}};
                          cpu_d_req_wr_data_reg    <= {32{1'b0}};
                          cpu_d_req_wr_byte_en_reg <= 4'b0000;
                          cpu_d_req_wr_byte_en_int <= 4'b0000;
                          cpu_d_wr_rd_state        <= BH_INIT;
                        end
          endcase
      end
    end
////////////////////////////////////////////////////////////////////////////////////////// 

// CPU I
  generate if(CPU_I_PRESENT) begin : gen_cpu_i_req
    assign req_valid[0]         = cpu_i_req_valid & ~tcm_cpu_access_disable_reg;
    assign cpu_i_req_ready      = TCM_src_gnt[0];
    assign req_wr_byte_en[0]    = {4{1'b0}};
    assign req_read[0]          = 1'b1;
    assign req_write[0]         = 1'b0;
    assign req_addr[0]          = cpu_i_req_addr;
    
    assign req_wr_data[0]       = {32{1'b0}};
    assign req_wr_data_p[0]     = {4{1'b0}};
    assign cpu_i_resp_valid     = resp_dest[0];
    assign cpu_i_resp_error     = 1'b0;  // REVISIT
    assign cpu_i_resp_rd_data   = resp_rd_data;  
    assign cpu_i_resp_rd_data_p = resp_rd_data_p;   
  end else begin :ngen_cpu_i_req
    assign req_valid[0]         = 1'b0;
    assign cpu_i_req_ready      = 1'b0;
    assign req_wr_byte_en[0]    = {4{1'b0}};
    assign req_read[0]          = 1'b0;
    assign req_write[0]         = 1'b0;
    assign req_addr[0]          = {TCM_ADDR_WIDTH{1'b0}};
    assign req_wr_data[0]       = {32{1'b0}};
    assign req_wr_data_p[0]     = {4{1'b0}};
    assign cpu_i_resp_valid     = 1'b0;
    assign cpu_i_resp_error     = 1'b0;  
    assign cpu_i_resp_rd_data   = {32{1'b0}};
    assign cpu_i_resp_rd_data_p = {4{1'b0}};
  end
  endgenerate
// CPU D
  generate if(CPU_D_DEBUG_PRESENT) begin : gen_cpu_d_req
	assign req_valid[1]         = cpu_d_req_valid & ~tcm_cpu_access_disable_reg;
    assign req_wr_byte_en[1]    = cpu_d_req_wr_byte_en_sel;
    assign req_read[1]          = |cpu_d_req_rd_byte_en_sel; // REVISIT replace these with term generated directly from cpu_d_req_read via shim 
    assign req_write[1]         = |cpu_d_req_wr_byte_en_sel; // REVISIT replace these with term generated directly from cpu_d_req_write via shim 
    assign req_addr[1]          = cpu_d_req_addr_sel;
    assign req_wr_data[1]       = cpu_d_req_wr_data_sel;
    assign req_wr_data_p[1]     = cpu_d_req_wr_data_p;  
    assign cpu_d_resp_error     = 1'b0;  
    assign cpu_d_resp_rd_data   = resp_rd_data;  
    assign cpu_d_resp_rd_data_p = resp_rd_data_p; 
  end else begin :ngen_cpu_d_req
    assign req_valid[1]         = 1'b0;
    assign req_wr_byte_en[1]    = {4{1'b0}};
    assign req_read[1]          = 1'b0;
    assign req_write[1]         = 1'b0;
    assign req_addr[1]          = {TCM_ADDR_WIDTH{1'b0}};
    assign req_wr_data[1]       = {32{1'b0}};
    assign req_wr_data_p[1]     = {4{1'b0}};
    assign cpu_d_resp_error     = 1'b0;  
    assign cpu_d_resp_rd_data   = {32{1'b0}};
    assign cpu_d_resp_rd_data_p = {4{1'b0}};
  end
  endgenerate
// TAS
  generate if(UDMA_TAS_PRESENT) begin : gen_tcm_tas_req                                     
    assign req_valid[2]            = udma_tas_req_valid;                                     
    assign udma_tas_req_ready      = TCM_src_gnt[2];                                                                     
    assign req_wr_byte_en[2]       = udma_tas_req_rd_byte_en;
    assign req_read[2]             = udma_tas_read;
    assign req_write[2]            = udma_tas_write;                              
    assign req_addr[2]             = udma_tas_req_addr;                                                                    
    assign req_wr_data[2]          = udma_tas_req_wr_data;                                 
    assign req_wr_data_p[2]        = udma_tas_req_wr_data_p;                               
    assign udma_tas_resp_valid     = resp_dest[2];                            
    assign udma_tas_resp_rd_error  = 1'b0;              // REVISIT No error possible for now                                      
    assign udma_tas_resp_rd_data   = resp_rd_data;                                           
    assign udma_tas_resp_rd_data_p = resp_rd_data_p;                                         
  end else begin :ngen_tcm_tas_req                                                          
    assign req_valid[2]            = 1'b0;                                                   
    assign udma_tas_req_ready      = 1'b0;                                               
    assign req_wr_byte_en[2]       = {4{1'b0}};
    assign req_read[2]             = 1'b0;
    assign req_write[2]            = 1'b0;
    assign req_addr[2]             = {TCM_ADDR_WIDTH{1'b0}};
    assign req_wr_data[2]          = {32{1'b0}};
    assign req_wr_data_p[2]        = {4{1'b0}};
    assign udma_tas_resp_valid     = 1'b0;
    assign udma_tas_resp_rd_error  = 1'b0;  
    assign udma_tas_resp_rd_data   = {32{1'b0}};
    assign udma_tas_resp_rd_data_p = {4{1'b0}};
  end
  endgenerate
  
  assign TCM_src_req = req_valid;

  miv_rv32_rr_pri_arb
  //***************************************************************
  // Parameter description
  #(
    .NUM_REQS                  (3),
    .USE_FORMAL                (1),
    .USE_SIM                   (1)
   )

  u_TCM_req_arb
  //***************************************************************
  // Signal description
  (
    .resetn              (resetn),
    .clk                 (clk),
    .unlock              (1'b1),
    .req                 (TCM_src_req),
    .gnt                 (TCM_src_gnt),
    .sel_seq             (),                  //open
    .sel_early           ()                   //open
  );
  
  always @*
  begin : raddr_mux_loop
    integer i;
    req_wr_byte_en_mux   = {4{1'b0}};
    req_addr_mux         = {TCM_ADDR_WIDTH{1'b0}};
    req_wr_data_mux      = {32{1'b0}};
    req_wr_data_p_mux    = {4{1'b0}};
    for(i=0; i<3; i=i+1)
    begin                                                                                      
      req_wr_byte_en_mux   = req_wr_byte_en_mux | ({4{TCM_src_gnt[i]}} & req_wr_byte_en[i]);   
      req_addr_mux         = req_addr_mux       | ({TCM_ADDR_WIDTH{TCM_src_gnt[i]}} & req_addr[i]);       
      
      req_wr_data_mux      = req_wr_data_mux    | ({32{TCM_src_gnt[i]}} & req_wr_data[i]);    
      req_wr_data_p_mux    = req_wr_data_p_mux  | ({4{TCM_src_gnt[i]}} & req_wr_data_p[i]);  
    end
  end
  
  assign req_valid_mux = |TCM_src_gnt; 
  
  // keep a list of requests to RAM so know where to send response
  // only one request outstanding for sysnchronous RAM with a single pipeline delay.
  // Requester must be able to accept the response immediately (no buffering here)
  // REVIST add source bit for uDMA/TAS
  always @(posedge clk or negedge resetn)
  begin
    if(~resetn)
    begin
      resp_dest        <= 3'b000;
    end
    else
    begin
      resp_dest        <= TCM_src_gnt;
    end
  end   
  
  assign trx_os_d_rd = 1'b0; // REVISIT
  assign trx_os_d_wr = 1'b0; // REVISIT 
  
  
  // RAM
  //-----------
  
  generate if(USE_RAM_PARITY_BITS) begin : gen_ram_data_parity
    assign wr_data_comb                   = {req_wr_data_p_mux,req_wr_data_mux};
    assign {resp_rd_data_p,resp_rd_data}  = rd_data_comb;
  end
  else begin : gen_ram_data_no_parity
    assign wr_data_comb   = req_wr_data_mux;
    assign resp_rd_data   = rd_data_comb;
    assign resp_rd_data_p = {4{1'b0}};
  end
  endgenerate
  
  generate
  if ((!ROM) & TCM_REGS) begin : tcm_ram_reg // 1. If TCM Registers is enabled and ROM is not selected, infer Register-based TCM  - ALL Families
      // *******************************************************
      // Instantiate technology/implementation specific RAM here
      // *******************************************************
    
      miv_rv32_ram_singleport_addreg
      //******************************************************************
      // Parameter description
      #(
        .RAM_DEPTH                     (RAM_DEPTH),
        .ADDR_WIDTH                    (TCM_ADDR_WIDTH),
        .DATA_WIDTH                    (RAM_DATA_WIDTH),
    	.WEN_WIDTH                     (RAM_WEN_WIDTH),
        .RAM_SB_IN_WIDTH               (RAM_SB_IN_WIDTH),
        .RAM_SB_OUT_WIDTH              (RAM_SB_OUT_WIDTH),
		.TCM_REGS					   (TCM_REGS)
       )
    
      u_ram_0
      //******************************************************************
      // Signal description
      (
        .rstb                          (resetn),
        .clk                           (clk),
        .addr                          (req_addr_mux[TCM_ADDR_WIDTH-1:0]),
        .ce                            (req_valid_mux),
        .we                            (req_wr_byte_en_mux_sel),
        .ret1n                         (1'b1),
        .pg_override                   (1'b0),
        .ecc_bypass                    (1'b0),
        .ram_err_inject                (tcm_ecc_error_injection),
        .din                           (wr_data_comb),
        .dout                          (rd_data_comb),
        .ecc_err                       (), // open
        .ecc_err_int                   (),  // open
        .ram_sb_out                    (tcm_ram_sb_out),
        .ram_sb_in                     (tcm_ram_sb_in)
      );
      
      assign ecc_err_correctable    = 1'b0;
      assign ecc_err_uncorrectable  = 1'b0;
      assign ecc_err                = 1'b0;
  end else if((!ROM) & (ECC_ENABLE) & (FAMILY != 26 | !l_cfg_hard_tcm0_en)) begin : tcm_ram_ecc // 2. - ECC enabled inferred RAM - ALL families
      miv_rv32_dpr_hqa_dual_storage_rbcw
      //******************************************************************
      // Parameter description
      #(
        .RAM_DEPTH                     (RAM_DEPTH),
        .ADDR_WIDTH                    (TCM_ADDR_WIDTH),
        .DATA_WIDTH                    (RAM_DATA_WIDTH)
       )
      u_TCM_ecc_0
      //******************************************************************
      // Signal description
      (
        .arstb                          (resetn),
        .aclk                           (clk),
        .aaddr                          (req_addr_mux[TCM_ADDR_WIDTH-1:0]),
        .aceb                           (req_valid_mux),
        .aweb                           (req_wr_byte_en_mux_sel),
        .brstb                          (1'b0),
        .bclk                           (1'b0),
        .baddr                          ({TCM_ADDR_WIDTH{1'b0}}),
        .bceb                           (1'b0),
        .bweb                           (1'b0),
        .ret1n                          (1'b1),
        .pg_override                    (1'b0),
        .ecc_bypass                     (1'b0),
        .ram_err_inject                 (tcm_ecc_error_injection),
        .adin                           (wr_data_comb),
        .adout                          (rd_data_comb),
        .bdin                           (32'b0),
        .bdout                          (),
        .ecc_aerr                       (), // open
        .ecc_aerr_int                   (ecc_err),  // open
        .ecc_berr                       (), // open
        .ecc_berr_int                   ()  // open
      );  
       
      assign ecc_err_correctable    = ecc_err[0];
      assign ecc_err_uncorrectable  = ecc_err[1];
	  
	  
      assign tcm_ram_sb_out = {RAM_SB_OUT_WIDTH{1'b0}};
    end else if((!ROM) & (ECC_ENABLE) & (FAMILY == 26 & l_cfg_hard_tcm0_en)) begin : tcm_ram_macro_ecc // 3. - ECC en using PF hard RAM - Only PF Family
        miv_rv32_ram_singleport_lp_ecc #(.RAM_DEPTH(RAM_DEPTH),
                                         .ADDR_WIDTH (TCM_ADDR_WIDTH-2)	
		                                 ) u_ram_0 ( .W_DATA    (wr_data_comb),
                                                     .R_DATA    (rd_data_comb), 
                                                     .W_ADDR    (req_addr_mux[TCM_ADDR_WIDTH-1:2]),
                                                     .R_ADDR    (req_addr_mux[TCM_ADDR_WIDTH-1:2]),
                                                     .W_EN      (req_wr_byte_en_mux_sel),
                                                     .R_EN      (!req_wr_byte_en_mux_sel),
                                                     .CLK       (clk),
                                                     .SB_CORRECT(ecc_err_correctable),
                                                     .DB_DETECT (ecc_err_uncorrectable)
                                                    );
       
        assign ecc_err    = 2'b0;
        assign tcm_ram_sb_out = {RAM_SB_OUT_WIDTH{1'b0}};
  end else if ((!ROM) & (FAMILY != 26 | !l_cfg_hard_tcm0_en)) begin : tcm_ram // . no ECC inferred RAM - ALL Families
      // *******************************************************
      // Instantiate technology/implementation specific RAM here
      // *******************************************************
    
      miv_rv32_ram_singleport_addreg
      //******************************************************************
      // Parameter description
      #(
        .RAM_DEPTH                     (RAM_DEPTH),
        .ADDR_WIDTH                    (TCM_ADDR_WIDTH),
        .DATA_WIDTH                    (RAM_DATA_WIDTH),
    	.WEN_WIDTH                     (RAM_WEN_WIDTH),
        .RAM_SB_IN_WIDTH               (RAM_SB_IN_WIDTH),
        .RAM_SB_OUT_WIDTH              (RAM_SB_OUT_WIDTH),
		.TCM_REGS					   (TCM_REGS)
       )
    
      u_ram_0
      //******************************************************************
      // Signal description
      (
        .rstb                          (resetn),
        .clk                           (clk),
        .addr                          (req_addr_mux[TCM_ADDR_WIDTH-1:0]),
        .ce                            (req_valid_mux),
        .we                            (req_wr_byte_en_mux_sel),
        .ret1n                         (1'b1),
        .pg_override                   (1'b0),
        .ecc_bypass                    (1'b0),
        .ram_err_inject                (tcm_ecc_error_injection),
        .din                           (wr_data_comb),
        .dout                          (rd_data_comb),
        .ecc_err                       (), // open
        .ecc_err_int                   (),  // open
        .ram_sb_out                    (tcm_ram_sb_out),
        .ram_sb_in                     (tcm_ram_sb_in)
      );
      
      assign ecc_err_correctable    = 1'b0;
      assign ecc_err_uncorrectable  = 1'b0;
      assign ecc_err                = 1'b0;
	end else if ((!ROM) & (FAMILY == 26 & l_cfg_hard_tcm0_en)) begin : tcm_ram_macro // 5. no ECC instantiate PF hard RAM
      // *******************************************************
      // Instantiate technology/implementation specific RAM here
      // *******************************************************
      miv_rv32_ram_singleport_lp #( .RAM_DEPTH(RAM_DEPTH),
                                    .ADDR_WIDTH (TCM_ADDR_WIDTH-2)	  
                                   ) u_ram_0 ( .W_DATA (wr_data_comb),
                                               .R_DATA (rd_data_comb),
                                               .W_ADDR (req_addr_mux[TCM_ADDR_WIDTH-1:2]),
                                               .R_ADDR (req_addr_mux[TCM_ADDR_WIDTH-1:2]),
                                               .W_EN   (req_wr_byte_en_mux_sel),
                                               .R_EN   (!req_wr_byte_en_mux_sel),
                                               .CLK    (clk)
                                              );
        
      assign ecc_err_correctable    = 1'b0;
      assign ecc_err_uncorrectable  = 1'b0;
      assign ecc_err                = 1'b0;
	end else if (ROM) begin : bootloader_rom
      // *******************************************************
      // Instantiate technology/implementation specific RAM here
      // *******************************************************
    
      miv_rv32_bootrom
      //******************************************************************
      // Parameter description
      #(
        .RAM_DEPTH                     (RAM_DEPTH),
        .ADDR_WIDTH                    (TCM_ADDR_WIDTH),
        .DATA_WIDTH                    (RAM_DATA_WIDTH),
    	.WEN_WIDTH                     (RAM_WEN_WIDTH),
        .RAM_SB_IN_WIDTH               (RAM_SB_IN_WIDTH),
        .RAM_SB_OUT_WIDTH              (RAM_SB_OUT_WIDTH),
        .BOOTROM_SRC_START_ADDR        (BOOTROM_SRC_START_ADDR),
        .BOOTROM_SRC_END_ADDR          (BOOTROM_SRC_END_ADDR),
        .BOOTROM_DEST_ADDR             (BOOTROM_DEST_ADDR),
		.RECONFIG_BOOTROM              (RECONFIG_BOOTROM)
       )
    
      u_bootrom_memory
      //******************************************************************
      // Signal description
      (
        .rstb                          (resetn),
        .clk                           (clk),
        .addr                          (req_addr_mux[TCM_ADDR_WIDTH-1:0]),
        .ce                            (req_valid_mux),
        .we                            (req_wr_byte_en_mux_sel),
        .ret1n                         (1'b1),
        .pg_override                   (1'b0),
        .ecc_bypass                    (1'b0),
        .ram_err_inject                (tcm_ecc_error_injection),
        .din                           (wr_data_comb),
        .dout                          (rd_data_comb),
        .ecc_err                       (), // open
        .ecc_err_int                   (),  // open
        .ram_sb_out                    (tcm_ram_sb_out),
        .ram_sb_in                     (tcm_ram_sb_in)
      );
      
      assign ecc_err_correctable    = 1'b0;
      assign ecc_err_uncorrectable  = 1'b0;
      assign ecc_err                = 1'b0;
	end
  endgenerate
//******************************************************************************
// properties
`ifdef SUBSYS_RTL_PROPS

  // requester must be able to accept a response
                                                     
                                                    
  // a request will eventually be granted (unless access disabled)                                                 

`endif 

endmodule


`default_nettype wire

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
// SVN $Revision: 41752 $
// SVN $Date: 2023-01-16 16:15:11 +0000 (Mon, 16 Jan 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////
module miv_rv32_bootrom
//********************************************************************************
// Parameter description

  #(
    parameter RAM_DEPTH            = 4096,
    parameter ADDR_WIDTH           = 12  ,
    parameter DATA_WIDTH           = 36,
    parameter WEN_WIDTH            = 4,
    parameter RAM_SB_IN_WIDTH      = 4,
    parameter RAM_SB_OUT_WIDTH      = 4,
    parameter BOOTROM_SRC_START_ADDR = 0,
    parameter BOOTROM_SRC_END_ADDR = 0,
    parameter BOOTROM_DEST_ADDR = 0,
	parameter RECONFIG_BOOTROM = 0
  )

//********************************************************************************
// Port description

  (
    input  wire logic                           rstb,
    input  wire logic                           clk,
    input  wire logic [ADDR_WIDTH-1:0]          addr,
    input  wire logic                           ce,
    input  wire logic [WEN_WIDTH-1:0]           we,
    input  wire logic                           ret1n,
    input  wire logic                           pg_override,
    input  wire logic                           ecc_bypass,
    input  wire logic [2-1:0]                   ram_err_inject,
    input  wire logic [DATA_WIDTH-1:0]          din,
    output      logic [DATA_WIDTH-1:0]          dout,
    output      logic [2-1:0]                   ecc_err,
    output      logic [2-1:0]                   ecc_err_int,
    input  wire logic [RAM_SB_IN_WIDTH-1: 0]    ram_sb_in,
    output      logic [RAM_SB_OUT_WIDTH-1: 0]   ram_sb_out

  );
//********************************************************************************
// Declarations

// localparams

// Internal nets
   logic [DATA_WIDTH - 1:0] start_addr, end_addr, dest_addr;
   logic [DATA_WIDTH - 1:0] dout_reg;


//********************************************************************************
// Main code
//********************************************************************************


  //  assign ecc_err = ECC_TCM_0_ERR_NET;
  assign ecc_err = 2'b0; // tied to 0
  assign ecc_err_int = 2'b0;// tied to 0
  assign ram_sb_out = {RAM_SB_OUT_WIDTH{1'b0}}; // Signal temp tied to 0, DCS to assign registered o/p.
  
  /* Firmware bootloader flow
  
    li x5, 0xA100 
    lw x6, 0(x5) //source start
    lw x7, 4(x5) //source end
    lw x8, 8(x5) //dest addr
    lw x1, 8(x5) //ret dest addr in x1

    1:
    lw x5, (x6)
    sw x5, (x8)
    addi x6, x6, 4
    addi x8, x8, 4
    bgeu x7, x6, 1b

    ret
  
  */

generate
  if(RECONFIG_BOOTROM)
    begin : reconfig_bootrom
	
    always @(posedge clk or negedge rstb) begin
        if (~rstb) begin
            start_addr <= BOOTROM_SRC_START_ADDR;
            end_addr   <= BOOTROM_SRC_END_ADDR;
            dest_addr  <= BOOTROM_DEST_ADDR;
			dout_reg   <= '0;
        end else
        
        if (we) begin
            if (addr[11:0] == 12'h100)
                start_addr <= din;
            if (addr[11:0] == 12'h104)
                end_addr <= din;
            if (addr[11:0] == 12'h108)
                dest_addr <= din;
        end else begin
            if (addr[11:0] == 12'h0) 
                dout_reg <= 32'h0000a537;
            if (addr[11:0] == 12'h4)
                dout_reg <= 32'h10050513;
            if (addr[11:0] == 12'h8)
                dout_reg <= 32'h00052283;
            if (addr[11:0] == 12'hc)
                dout_reg <= 32'h00452303;
            if (addr[11:0] == 12'h10)
                dout_reg <= 32'h00852383;
            if (addr[11:0] == 12'h14)
                dout_reg <= 32'h00852083;
            if (addr[11:0] == 12'h18)
                dout_reg <= 32'h0002a403;
            if (addr[11:0] == 12'h1c)
                dout_reg <= 32'h0083a023;
            if (addr[11:0] == 12'h20)
                dout_reg <= 32'h00428293;
            if (addr[11:0] == 12'h24)
                dout_reg <= 32'h00438393;
            if (addr[11:0] == 12'h28)
                dout_reg <= 32'hfe5378e3;
            if (addr[11:0] == 12'h2c)
                dout_reg <= 32'h00008067;
            /* source and destination registers */
            if (addr[11:0] == 12'h100)
                dout_reg <= start_addr;
            if (addr[11:0] == 12'h104)
                dout_reg <= end_addr;
            if (addr[11:0] == 12'h108)
                dout_reg <= dest_addr;
        end 
    end

end else begin : bootrom

    always @(posedge clk or negedge rstb) begin
        if (~rstb) begin
            start_addr <= BOOTROM_SRC_START_ADDR;
            end_addr   <= BOOTROM_SRC_END_ADDR;
            dest_addr  <= BOOTROM_DEST_ADDR;
			dout_reg   <= '0;
        end else begin
            if (addr[11:0] == 12'h0) 
                dout_reg <= 32'h0000a537;
            if (addr[11:0] == 12'h4)
                dout_reg <= 32'h10050513;
            if (addr[11:0] == 12'h8)
                dout_reg <= 32'h00052283;
            if (addr[11:0] == 12'hc)
                dout_reg <= 32'h00452303;
            if (addr[11:0] == 12'h10)
                dout_reg <= 32'h00852383;
            if (addr[11:0] == 12'h14)
                dout_reg <= 32'h00852083;
            if (addr[11:0] == 12'h18)
                dout_reg <= 32'h0002a403;
            if (addr[11:0] == 12'h1c)
                dout_reg <= 32'h0083a023;
            if (addr[11:0] == 12'h20)
                dout_reg <= 32'h00428293;
            if (addr[11:0] == 12'h24)
                dout_reg <= 32'h00438393;
            if (addr[11:0] == 12'h28)
                dout_reg <= 32'hfe5378e3;
            if (addr[11:0] == 12'h2c)
                dout_reg <= 32'h00008067;
            /* source and destination registers */
            if (addr[11:0] == 12'h100)
                dout_reg <= start_addr;
            if (addr[11:0] == 12'h104)
                dout_reg <= end_addr;
            if (addr[11:0] == 12'h108)
                dout_reg <= dest_addr;
        end 
    end
end
endgenerate

    assign dout = dout_reg;

endmodule

`default_nettype wire
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
// SVN $Revision: 42436 $
// SVN $Date: 2023-04-17 15:46:55 +0100 (Mon, 17 Apr 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_icache.sv
//
//   Purpose:ICACHE
//    subsys top-level
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_icache
//********************************************************************************
// Parameter description

  #(
  parameter SYNC_RESET         = 0, 
  parameter ICACHE_DEPTH       = 256,   
  parameter ICACHE_ADDR_WIDTH  = 32,
  parameter ICACHE_DATA_WIDTH  = 32,
  parameter ICACHE_BURST_SIZE  = 8, 
  parameter ECC_ENABLE         = 0,
  parameter I_REGS             = 0
  )
  
//********************************************************************************
// Port description
  (
  // clk/reset
  input wire  logic                              clk,
  input wire  logic                              resetn,
				           
 //                        
  input wire  logic                              parity_en,
  input wire  logic                              icache_flush,
	
  // external memory bus interface
  input wire  logic                              ifu_emi_req_valid,         
  output      logic                              ifu_emi_req_ready,         
  input wire  logic [(ICACHE_ADDR_WIDTH/8)-1:0]  ifu_emi_req_rd_byte_en,    
  input wire  logic [ICACHE_ADDR_WIDTH-1:0]      ifu_emi_req_addr,            
  input wire  logic                              ifu_emi_req_addr_p,       
  output      logic                              ifu_emi_resp_valid,        
  input  wire logic                              ifu_emi_resp_ready,        
  output      logic [ICACHE_DATA_WIDTH-1:0]      ifu_emi_resp_data,        
  output      logic [(ICACHE_DATA_WIDTH/8)-1:0]  ifu_emi_resp_data_p,       
  output      logic                              ifu_emi_resp_error,
													  
  output      logic                              cpu_i_req_valid,         
  input wire  logic                              cpu_i_req_ready,         
  output      logic [(ICACHE_ADDR_WIDTH/8)-1:0]  cpu_i_req_rd_byte_en,     
  output      logic [ICACHE_ADDR_WIDTH-1:0]      cpu_i_req_addr,    
  output      logic                              cpu_i_req_addr_p,       
  input wire  logic                              cpu_i_resp_valid,        
  output      logic                              cpu_i_resp_ready,       
  input wire  logic [ICACHE_DATA_WIDTH-1:0]      cpu_i_resp_rd_data,        
  input wire  logic [(ICACHE_DATA_WIDTH/8)-1:0]  cpu_i_resp_rd_data_p,     
  input wire  logic                              cpu_i_resp_error,
      
  input wire logic [1:0]                         icache_ecc_error_injection,       
  output      logic                              icache_ecc_err_correctable,       
  output      logic                              icache_ecc_err_uncorrectable,
  input wire  logic                              icache_ram_init_soft_debug_reset, //signal to re-init  icache ram on a soft or debug reset
  output      logic                              icache_ram_init_done, // icache ram init done output signal
  input wire  logic                              gpr_ram_init_done
  );

//********************************************************************************
// lpcalparam 
  localparam data_addr_offset = func_clog2(ICACHE_ADDR_WIDTH/8);   
  localparam da_data_width    = ICACHE_DATA_WIDTH + (ICACHE_DATA_WIDTH/8); // data + parity bits
  localparam da_addr_width    = (func_clog2(ICACHE_DEPTH)); 
  
  localparam burst_addr_width   = ICACHE_DATA_WIDTH - data_addr_offset;
  localparam burst_offset       = (func_clog2(ICACHE_BURST_SIZE)) ;
  localparam burst_offset_width = burst_offset + 1 ;
  
  localparam index_msb          = (da_addr_width + data_addr_offset) - 1; 
  localparam ta_data_lsb        = index_msb + 1; 
  localparam ta_index_lsb       = burst_offset + data_addr_offset;

  localparam tag_addr_width     = da_addr_width - burst_offset; 
  localparam tag_data_width     = ICACHE_ADDR_WIDTH - (da_addr_width + data_addr_offset) ; 
  
// FSM states
  localparam INIT_ST = 2'd0, CACHE_READ_ST = 2'd1, BURST_READ_ST = 2'd2, BURST_WAIT_ST = 2'd3;
  
// Declarations 
  logic [ICACHE_ADDR_WIDTH-1:0]  ifu_emi_req_addr_reg;
  logic [burst_addr_width-1:0]   icache_burst_addr;          
  logic [tag_data_width-1:0]     icache_tag_data_in; 
  logic [tag_addr_width-1:0]     icache_tag_index;     
  logic [da_addr_width-1:0]      icache_data_in_index;
  logic [da_addr_width-1:0]      icache_data_out_index;  
  logic [ICACHE_DEPTH-1:0]       valid_hit;            
  logic [1:0]                    cache_st;                
  logic [1:0]                    cache_next_st;        
  logic                          aresetn;
  logic                          sresetn; 
  
  logic                          burst_addr_comp; 
  
  logic [burst_offset_width-1:0] da_burst_offset;         
  logic [da_data_width-1:0]      da_data_in_comb; 
  logic [da_data_width-1:0]      da_data_in_reg;  
  logic [da_data_width-1:0]      da_data_out_comb;
  logic                          da_addr_sel;
  logic                          da_data_out_sel;
  logic [da_addr_width-1:0]      da_waddr;            
  logic [da_addr_width-1:0]      da_raddr;            
  logic                          da_re;
  logic                          da_we;
  
  logic [tag_data_width-1:0]     ta_data_in;
  logic [tag_data_width-1:0]     ta_tag_data_out;
  logic [tag_addr_width-1:0]     ta_waddr;  
  logic [tag_addr_width-1:0]     ta_raddr ; 
  logic                          ta_we;
  logic                          ta_re;
  
  genvar                         i;
// Internal nets

//********************************************************************************
// Assignments
 assign aresetn = (SYNC_RESET==1) ? 1'b1 : resetn;
 assign sresetn = (SYNC_RESET==1) ? resetn : 1'b1;
  
 assign icache_burst_addr       = (da_addr_sel) ? {ifu_emi_req_addr_reg[ICACHE_ADDR_WIDTH-1:ta_index_lsb], {burst_offset{1'b0}}} : {ifu_emi_req_addr[ICACHE_ADDR_WIDTH-1:ta_index_lsb], {burst_offset{1'b0}}} ;  

 assign icache_tag_data_in    = ifu_emi_req_addr_reg[ICACHE_ADDR_WIDTH-1:ta_data_lsb];
 assign icache_tag_index      = (da_addr_sel) ? ifu_emi_req_addr_reg[index_msb:ta_index_lsb]  : ifu_emi_req_addr[index_msb:ta_index_lsb]  ; 
 assign icache_data_in_index  = (da_addr_sel) ? ifu_emi_req_addr_reg[index_msb:data_addr_offset]  : ifu_emi_req_addr[index_msb:data_addr_offset]  ;  
 assign icache_data_out_index = cpu_i_req_addr[index_msb:data_addr_offset] ;   
     
 assign   cpu_i_req_addr       = (icache_burst_addr + da_burst_offset) << data_addr_offset;               // REVISIT: For 32bit data bursts, if we enhance to 64bit data bursts this needs to 
 assign   cpu_i_req_addr_p     = (^ cpu_i_req_addr) & parity_en; 
 assign   cpu_i_req_rd_byte_en = {(ICACHE_ADDR_WIDTH/8){ cpu_i_req_valid}}; 
 assign   cpu_i_resp_ready     = 1'b1; // When a request is made it will always be accepted
 
 assign da_data_in_comb  = {cpu_i_resp_rd_data_p,   cpu_i_resp_rd_data};
 assign da_waddr         = icache_data_out_index- 1;
 assign da_raddr         = icache_data_in_index;
 
 assign ta_data_in = icache_tag_data_in;
 assign ta_waddr   = icache_tag_index;
 assign ta_raddr   = icache_tag_index;
 
 assign ifu_emi_resp_error = cpu_i_resp_error;

 assign burst_addr_comp = (cpu_i_req_addr-4 == ifu_emi_req_addr_reg) ? 1'b1 : 1'b0;

//********************************************************************************
// Controller Logic

  always @(posedge clk or negedge aresetn) begin
    if ((!aresetn) || (!sresetn))  begin
		ifu_emi_req_addr_reg <= {ICACHE_ADDR_WIDTH{1'b0}};
		da_data_in_reg       <= {da_data_width{1'b0}};
		da_burst_offset      <= {burst_offset_width{1'b0}};
		da_data_out_sel      <= 1'b0;
        cache_st             <= INIT_ST;
    end else begin
	    cache_st <= cache_next_st;
		
        case(cache_st)
                INIT_ST : begin
                            if(ifu_emi_req_valid) begin 
							    ifu_emi_req_addr_reg <= ifu_emi_req_addr;
                                if((valid_hit[icache_data_in_index] == 1'b0) & ( cpu_i_req_ready)) begin
							        da_burst_offset <= da_burst_offset + 1;
                                end
                            end 
                          end
          CACHE_READ_ST : begin 
                            if ((icache_tag_data_in == ta_tag_data_out) & (ifu_emi_req_valid))  begin
                                ifu_emi_req_addr_reg <= ifu_emi_req_addr;
							
                                if((valid_hit[icache_data_in_index] == 1'b0) & ( cpu_i_req_ready)) begin
							        da_burst_offset <= da_burst_offset + 1;
                                end
						    end	
                          end
          BURST_READ_ST : begin 
                            if( cpu_i_req_ready) begin
                                da_burst_offset <= da_burst_offset + 1;
                            end
                          end
          BURST_WAIT_ST : begin
		  				    if(cpu_i_resp_valid) begin					        
						        if(burst_addr_comp) begin  
								     da_data_in_reg <= da_data_in_comb;
                                     if(da_burst_offset == ICACHE_BURST_SIZE) begin
						                 da_burst_offset <= {burst_offset_width{1'b0}};
						    	         da_data_out_sel <= 1'b0;
                                     end else begin
						    	         da_data_out_sel <= 1'b1;
										 da_burst_offset <= da_burst_offset + 1;
                                     end
						        end else begin
                                     if(da_burst_offset == ICACHE_BURST_SIZE) begin
						                da_burst_offset <= {burst_offset_width{1'b0}};
						    	     	da_data_out_sel <= 1'b0;
                                     end else begin
					                    da_burst_offset <= da_burst_offset + 1;
									 end
						        end
						    end
                          end
                default : begin
		                    ifu_emi_req_addr_reg <= {ICACHE_ADDR_WIDTH{1'b0}};
		                    da_burst_offset      <= {burst_offset_width{1'b0}};
		                    da_data_out_sel      <= 1'b0;
                            cache_st             <= INIT_ST;
                          end
        endcase
	end
  end
    
  always @(*) begin
    cache_next_st      <= INIT_ST;
    ifu_emi_req_ready  <= 1'b0;
    ifu_emi_resp_valid <= 1'b0;	
    cpu_i_req_valid    <= 1'b1; 	
    da_addr_sel        <= 1'b0;	
    da_we              <= 1'b0;
    da_re              <= 1'b0;
    ta_we              <= 1'b0;
    ta_re              <= 1'b0;
	
	{ifu_emi_resp_data_p, ifu_emi_resp_data}  <= {da_data_width{1'b0}};
    case(cache_st)
            INIT_ST : begin						
                        if(ifu_emi_req_valid) begin 
			                ifu_emi_req_ready <= 1'b1;
						    if(valid_hit[icache_data_in_index] == 1'b1) begin
						        cache_next_st   <= CACHE_READ_ST;
							    cpu_i_req_valid <= 1'b0;
								ta_re           <= 1'b1;
								da_re           <= 1'b1;
							end else begin								
								if( cpu_i_req_ready) begin
								    cache_next_st <= BURST_WAIT_ST;
								end else begin
								    cache_next_st <= BURST_READ_ST;
								end   
							end
						end else begin
						    cpu_i_req_valid <= 1'b0; 	
						    cache_next_st <= INIT_ST;
						end
                      end
      CACHE_READ_ST : begin 	
	                    ta_re <= 1'b1;
					    da_re <= 1'b1;
						
                        if (icache_tag_data_in == ta_tag_data_out)  begin
                            {ifu_emi_resp_data_p, ifu_emi_resp_data} <= da_data_out_comb;
                            ifu_emi_resp_valid                       <= 1'b1;
							
                            if(ifu_emi_req_valid) begin 
			                    ifu_emi_req_ready <= 1'b1;
						        if(valid_hit[icache_data_in_index] == 1'b1) begin
						            cache_next_st   <= CACHE_READ_ST;
							        cpu_i_req_valid <= 1'b0;
						    		ta_re           <= 1'b1;
						    	end else begin					    		
						    		if( cpu_i_req_ready) begin
						    		    cache_next_st <= BURST_WAIT_ST;
						    		end else begin
						    		    cache_next_st <= BURST_READ_ST;
						    		end   
						    	end
						    end else begin
						        cpu_i_req_valid <= 1'b0; 	
						        cache_next_st   <= INIT_ST;
						    end	
                        end else begin
                            cache_next_st   <= BURST_READ_ST;
                            cpu_i_req_valid <= 1'b0; 	
                        end					
                      end
      BURST_READ_ST : begin
					    da_addr_sel <= 1'b1; 
                        da_re       <= 1'b1;
					    if( cpu_i_req_ready) begin
					        cache_next_st <= BURST_WAIT_ST;
					    end else begin
					        cache_next_st <= BURST_READ_ST;
					    end 				
                      end
      BURST_WAIT_ST : begin	
					    cpu_i_req_valid <= 1'b0;
					    da_addr_sel     <= 1'b1; 
					   					
					    if( cpu_i_resp_valid) begin
                            da_we <= 1'b1;
					    	
                            if(da_burst_offset == ICACHE_BURST_SIZE) begin 
					    	    {ifu_emi_resp_data_p, ifu_emi_resp_data} <= (da_data_out_sel) ? da_data_in_reg : da_data_in_comb;
                                cache_next_st                            <= INIT_ST;
                                ifu_emi_resp_valid                       <= 1'b1;
	                            ta_we                                    <= 1'b1;
                            end else begin  
					            cache_next_st <= BURST_WAIT_ST;
                            end
					    end else begin
					        cache_next_st <= BURST_WAIT_ST;
					        da_re         <= da_data_out_sel;
					    end
                      end
            default : begin
                        cache_next_st      <= INIT_ST;                   
                        ifu_emi_req_ready  <= 1'b0;
                        ifu_emi_resp_valid <= 1'b0;			 
                        da_we              <= 1'b0;
                        da_re              <= 1'b0;
                        ta_we              <= 1'b0;
                        ta_re              <= 1'b0;
	                    
	                    {ifu_emi_resp_data_p, ifu_emi_resp_data}  <= {da_data_width{1'b0}};
                      end
    endcase
  end

//********************************************************************************
// Valid Logic
  for(i = 0; i < ICACHE_DEPTH; i = i + 1) begin
    always @(posedge clk or negedge aresetn) begin
      if ((!aresetn) || (!sresetn))  begin
          valid_hit[i] <= 1'h0;
      end else begin
  	    if(icache_flush) begin
  		    valid_hit[i] <= 1'h0;
  		end else begin
		    if ((da_we) & (i == da_waddr)) begin   
                if ( cpu_i_resp_error) begin
                    valid_hit[i] <= 1'h0;
                end else begin
                    valid_hit[i] <= 1'b1;
                end
		    end
        end
      end
    end
  end

//********************************************************************************
// Instances
  generate
  if(ECC_ENABLE)
    begin : gen_ecc
        
      localparam DA_RAM_DEPTH   = 2**da_addr_width;
      localparam TAG_RAM_DEPTH  = 2**tag_addr_width;
      localparam D_ADDR_WIDTH   = da_addr_width + 6;
      localparam T_ADDR_WIDTH = tag_addr_width + 6;
  	  
      logic [D_ADDR_WIDTH-1:0]   da_aaddr;   
      logic [T_ADDR_WIDTH-1:0] ta_aaddr;   
  	  logic [1:0]                da_ecc_err;
  	  logic [1:0]                ta_ecc_err;
  	  logic                      da_req_valid; 
  	  logic                      ta_req_valid;
	  
      logic [da_data_width-1:0]  icache_ram_init_data;
      logic [D_ADDR_WIDTH-1:0]   icache_ram_init_addr;
      logic                      icache_ram_init_write_en;
      logic [da_data_width-1:0]  icache_da_mux_data;
      logic [D_ADDR_WIDTH-1:0]   icache_da_mux_addr;
      logic                      icache_da_mux_write_en;
      logic [tag_data_width-1:0] icache_ta_mux_data;
      logic [T_ADDR_WIDTH-1:0] icache_ta_mux_addr;
      logic                      icache_ta_mux_write_en;
	  
	 miv_rv32_icache_ram_init #( .ECC_ENABLE     (ECC_ENABLE),
                                 .da_data_width  (da_data_width),
                                 .da_depth       (ICACHE_DEPTH),  
                                 .da_addr_width  (D_ADDR_WIDTH)
                               ) miv_rv32_icache_ram_init ( .clk               (clk),
                                                            .resetn            (resetn),
                                                            .debug_soft_reset  (icache_ram_init_soft_debug_reset),
                                                            .init_done         (icache_ram_init_done),
                                                            .data              (icache_ram_init_data),
                                                            .addr              (icache_ram_init_addr),
                                                            .write_en          (icache_ram_init_write_en),
															.gpr_ram_init_done (gpr_ram_init_done)
                                                          );

      miv_rv32_icache_ram_mux #( .data_width  (da_data_width),
                                 .addr_width  (D_ADDR_WIDTH)
						       ) u_icache_da_mux_0 ( .clk          (clk),
                                                     .resetn       (resetn),
                                                     .mux_sel      (icache_ram_init_done),
                                                     .addr_0       (icache_ram_init_addr),
                                                     .data_0       (icache_ram_init_data),
                                                     .write_en_0   (icache_ram_init_write_en),
                                                     .addr_1       (da_aaddr),
                                                     .data_1       (da_data_in_comb),
                                                     .write_en_1   (da_we),
                                                     .addr_out     (icache_da_mux_addr),
                                                     .data_out     (icache_da_mux_data),
                                                     .write_en_out (icache_da_mux_write_en)
                                                  );
												 
      miv_rv32_icache_ram_mux #( .data_width  (tag_data_width),
                                 .addr_width  (T_ADDR_WIDTH)
						       ) u_icache_ta_mux_0 ( .clk          (clk),
                                                     .resetn       (resetn),
                                                     .mux_sel      (icache_ram_init_done),
                                                     .addr_0       (icache_ram_init_addr),
                                                     .data_0       (icache_ram_init_data),
                                                     .write_en_0   (icache_ram_init_write_en),
                                                     .addr_1       (ta_aaddr),
                                                     .data_1       (ta_data_in),
                                                     .write_en_1   (ta_we),
                                                     .addr_out     (icache_ta_mux_addr),
                                                     .data_out     (icache_ta_mux_data),
                                                     .write_en_out (icache_ta_mux_write_en)
                                                  );			 
	  
        miv_rv32_dpr_hqa_dual_storage_rbcw
        //******************************************************************
        // Parameter description
        #(
          .RAM_DEPTH                     (DA_RAM_DEPTH),
          .ADDR_WIDTH                    (D_ADDR_WIDTH),
          .DATA_WIDTH                    (da_data_width)
         )
        data_array
        //******************************************************************
        // Signal description                                               
        (                                                                   
          .arstb                          (resetn),                         
          .aclk                           (clk),                            
          .aaddr                          (icache_da_mux_addr),                       
          .aceb                           (da_req_valid),                   
          .aweb                           (icache_da_mux_write_en),                          
          .brstb                          (1'b0),                           
          .bclk                           (1'b0),                           
          .baddr                          ({D_ADDR_WIDTH{1'b0}}),                              
          .bceb                           (1'b0),                           
          .bweb                           (1'b0),                           
          .ret1n                          (1'b1),                           
          .pg_override                    (1'b0),                           
          .ecc_bypass                     (1'b0),                           
          .ram_err_inject                 (icache_ecc_error_injection),                          
          .adin                           (icache_da_mux_data),                
          .adout                          (da_data_out_comb),               
          .bdin                           (32'b0),
          .bdout                          (),
          .ecc_aerr                       (), // open
          .ecc_aerr_int                   (da_ecc_err),
          .ecc_berr                       (), // open
          .ecc_berr_int                   ()  // open
        );  
		
        miv_rv32_dpr_hqa_dual_storage_rbcw
        //******************************************************************
        // Parameter description
        #(
          .RAM_DEPTH                     (TAG_RAM_DEPTH),
          .ADDR_WIDTH                    (T_ADDR_WIDTH),
          .DATA_WIDTH                    (tag_data_width)
         )
        tag_array
        //******************************************************************
        // Signal description                                               
        (                                                                   
          .arstb                          (resetn),                         
          .aclk                           (clk),                            
          .aaddr                          (icache_ta_mux_addr),                       
          .aceb                           (ta_req_valid),                   
          .aweb                           (icache_ta_mux_write_en),                          
          .brstb                          (1'b0),                           
          .bclk                           (1'b0),                           
          .baddr                          ({T_ADDR_WIDTH{1'b0}}),                              
          .bceb                           (1'b0),                           
          .bweb                           (1'b0),                           
          .ret1n                          (1'b1),                           
          .pg_override                    (1'b0),                           
          .ecc_bypass                     (1'b0),                           
          .ram_err_inject                 (icache_ecc_error_injection),                          
          .adin                           (icache_ta_mux_data),                
          .adout                          (ta_tag_data_out),               
          .bdin                           (32'b0),
          .bdout                          (),
          .ecc_aerr                       (), // open
          .ecc_aerr_int                   (ta_ecc_err),
          .ecc_berr                       (), // open
          .ecc_berr_int                   ()  // open
        );  
         
  	  assign icache_ecc_err_correctable   = (icache_ram_init_done) ? ta_ecc_err[0] | da_ecc_err[0] : 1'b0;
      assign icache_ecc_err_uncorrectable = (icache_ram_init_done) ? ta_ecc_err[1] | da_ecc_err[1] : 1'b0;
		
  	  assign da_req_valid              = da_re | da_we | icache_da_mux_write_en;
  	  assign ta_req_valid              = ta_re | ta_we | icache_ta_mux_write_en;
  	  assign da_aaddr                  = (da_we) ? da_waddr << 2 : da_raddr << 2;
  	  assign ta_aaddr                  = (ta_we) ? ta_waddr << 2 : ta_raddr << 2;
    end
  else
    begin : ngen_ecc
      //Data Array
         miv_rv32_icache_array
          #(
            .SYNC_RESET(SYNC_RESET),
            .DATA_WIDTH(da_data_width),
            .ADDR_WIDTH(da_addr_width),
			.I_REGS(I_REGS)
          )
          data_array
          (
          .data_in    (da_data_in_comb),
          .waddr      (da_waddr),
          .raddr      (da_raddr),
          .re         (da_re),
          .we         (da_we),
          .clk        (clk), 
          .resetn     (resetn),
          .data_out   (da_data_out_comb),
          .db_detect  (),
          .sb_correct ()
          );
        
      //Tag Array
         miv_rv32_icache_array
          #(
            .SYNC_RESET(SYNC_RESET),
            .DATA_WIDTH(tag_data_width),
            .ADDR_WIDTH(tag_addr_width),
			.I_REGS(I_REGS)
          )
          tag_array
          (
          .data_in    (ta_data_in),
          .waddr      (ta_waddr), 
          .raddr      (ta_raddr),
          .re         (ta_re),
          .we         (ta_we),
          .clk        (clk), 
          .resetn     (resetn),
          .data_out   (ta_tag_data_out),
          .db_detect  (),
          .sb_correct ()
          );
  		
        assign icache_ecc_err_correctable    = 1'b0;
        assign icache_ecc_err_uncorrectable  = 1'b0;
        assign icache_ram_init_done          = 1'b1;
	  
    end
  endgenerate

endmodule
`default_nettype wire

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
// SVN $Revision: 42164 $
// SVN $Date: 2023-03-01 10:49:28 +0000 (Wed, 01 Mar 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_icache_array.sv
//
//   Purpose:
//    subsys top-level
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module miv_rv32_icache_array 
//********************************************************************************
// Parameter description
  #(
    parameter SYNC_RESET = 0,
    parameter DATA_WIDTH = 33,
    parameter ADDR_WIDTH = 8,
	parameter I_REGS     = 0
  )
//********************************************************************************
// Port description
  (
  input  wire  logic [DATA_WIDTH-1:0] data_in,
  input  wire  logic [ADDR_WIDTH-1:0] waddr,
  input  wire  logic [ADDR_WIDTH-1:0] raddr,
  input  wire  logic re,
  input  wire  logic we,
  input  wire  logic clk, 
  input  wire  logic resetn,
  output       logic [DATA_WIDTH-1:0] data_out,
  output       logic db_detect,
  output       logic sb_correct
  );

// localparam
  localparam RAM_DEPTH = 2**ADDR_WIDTH;

// Declarations
  logic [DATA_WIDTH-1:0] data_int;
  logic aresetn;
  logic sresetn; 
  
  generate
    if(I_REGS) begin: gen_mem_array
      reg [DATA_WIDTH-1:0] mem_array [0:RAM_DEPTH-1] /* synthesis syn_ramstyle="registers" */;
    end else begin: gen_mem_array
      reg [DATA_WIDTH-1:0] mem_array [0:RAM_DEPTH-1];
    end
  endgenerate
//********************************************************************************
// Assignments
 assign aresetn = (SYNC_RESET==1) ? 1'b1 : resetn;
 assign sresetn = (SYNC_RESET==1) ? resetn : 1'b1;
 
 assign db_detect  = 0;
 assign sb_correct = 0;
 
//********************************************************************************
// Logic


  
//WRITE 
always @(posedge clk)
  begin  
    if (we) begin
        gen_mem_array.mem_array[waddr] <= data_in; 
    end
  end 

//READ
always @(posedge clk or negedge aresetn)
  begin
    if((!aresetn) || (!sresetn)) begin  
        data_out <= {DATA_WIDTH{1'b0}}; 
    end else begin
        if(re) begin
            data_out <= data_int; 
        end else begin
            data_out <= {DATA_WIDTH{1'b0}};  
        end
    end
  end

always@(*)
  data_int <= gen_mem_array.mem_array[raddr]; 		  
 
endmodule

`default_nettype wire


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
// SVN $Revision: 42317 $
// SVN $Date: 2023-03-22 11:16:17 +0000 (Wed, 22 Mar 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

module miv_rv32_icache_ram_init
    //****************************************************************************
    // Parameter description
    #(
    parameter ECC_ENABLE     = 1, 
    parameter da_data_width  = 32,
    parameter da_depth       = 256,   
    parameter da_addr_width  = 32
    )
    //******************************************************************************
    // Port Description
    (
    input clk,
    input resetn,
    input debug_soft_reset,
	input gpr_ram_init_done,
    output reg init_done,
    output reg [da_data_width-1:0] data,
    output reg [da_addr_width-1:0] addr,
    output reg write_en

    );
    //******************************************************************************  
    // Declarations
    reg [1:0] init_state;

    //******************************************************************************
    // Main code
    generate
        if(ECC_ENABLE)
        begin
            always @ (posedge clk)
                begin
                    if(~resetn)
                        begin
                        init_state <= 2'b0;
                        data <= {da_data_width{1'b0}};
                        addr <= {da_addr_width{1'b0}};
                        write_en <= 1'b0;
                        init_done <= 1'b0;
                        end
                    else
                        begin
                            case(init_state)
                                2'd0: begin //STATE 0: INIT START
                                      $display("Initialisation of ICACHE RAM - Start");
                                      init_state <= 2'd1; //move to state 1: init in progress
                                      data <= {da_data_width{1'b0}};
                                      addr <= {da_addr_width{1'b0}};
                                      write_en <= 1'b1;
                                      init_done <= 1'b0;
                                      end
                                      
                                2'd1: begin //STATE 1: INIT IN PROGRESS
                                      if(addr == (da_depth << 2) - 4) //end of icaches reached, init done 
                                        begin
                                            init_state <= 2'd2; //move to init 2: init done
                                            data <= {da_data_width{1'b0}};
                                            addr <= {da_addr_width{1'b0}};
                                            init_done <= 1'b1; //icache ram init done
                                            $display("Initialisation of ICACHE RAM - Complete");
                                        end
                                      else 
                                        begin
                                            addr <= addr + 3'd4; //increment to next address
                                            init_state <= 2'b1; //init still in progress
                                        end
                                      end
                                      
                                2'd2: begin //STATE 2: INIT DONE
                                        init_state <= 2'd2;
                                        
                                        if (debug_soft_reset & gpr_ram_init_done) //if init is complete and a soft reset or debug reset is triggered, go to init start
                                            begin
                                                init_state <= 2'd0;
                                            end
                                      end
                            default: begin  //DEFAULT STATE
                                        init_state <= 2'd0;
                                        data <= {da_data_width{1'b0}};
                                        addr <= {da_addr_width{1'b0}} + 3'd4;
                                        init_done <= 1'b0;
                                     end
                            endcase
                        end
                end
        end
        else
        begin
            always @ (*)
                begin
                    init_state <= 2'b0;
                    data <= {da_data_width{1'b0}};
                    addr <= {da_addr_width{1'b0}};
                    write_en <= 1'b0;
                    init_done <= 1'b1;
                end
        end
    endgenerate
endmodule


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
// SVN $Revision: 41752 $
// SVN $Date: 2023-01-16 16:15:11 +0000 (Mon, 16 Jan 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

module miv_rv32_icache_ram_mux
    //******************************************************************************
    // Parameter description
    #(
    parameter data_width  = 32,
    parameter addr_width  = 32
    )
    //******************************************************************************
    // Port Description
    (
    input clk,
    input resetn,
    input mux_sel,
    
    input [addr_width-1:0]  addr_0,
    input [data_width-1:0] data_0,
    input write_en_0,
    
    input [addr_width-1:0]  addr_1,
    input [data_width-1:0] data_1,
    input write_en_1, 
   
    output reg [addr_width-1:0] addr_out,
    output reg [data_width-1:0] data_out,
    output reg write_en_out
    );
    //******************************************************************************
    // Main code
    
    always @ (*)
        begin
            case(mux_sel)
            1'b0: begin
                    addr_out <= addr_0;
                    data_out <= data_0;
                    write_en_out <= write_en_0;
                  end
            1'b1: begin
                    addr_out <= addr_1;
                    data_out <= data_1;
                    write_en_out <= write_en_1;
                    end
         default: begin
                    addr_out <= {addr_width{1'b0}};
                    data_out <= {data_width{1'b0}};
                    write_en_out <= 1'b0;
                  end
            endcase
        end
endmodule
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
// SVN $Revision: 43408 $
// SVN $Date: 2023-07-20 14:36:43 +0100 (Thu, 20 Jul 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////
module miv_rv32_ram_singleport_addreg
//********************************************************************************
// Parameter description

  #(
    parameter RAM_DEPTH            = 4096,
    parameter ADDR_WIDTH           = 12  ,
    parameter DATA_WIDTH           = 36,
    parameter WEN_WIDTH            = 4,   // Supports 1 or 4
    parameter RAM_SB_IN_WIDTH      = 4,
    parameter RAM_SB_OUT_WIDTH     = 4,
	parameter TCM_REGS             = 0
  )

//********************************************************************************
// Port description

  (
    input  wire logic                           rstb,
    input  wire logic                           clk,
    input  wire logic [ADDR_WIDTH-1:0]          addr,
    input  wire logic                           ce,
    input  wire logic [WEN_WIDTH-1:0]           we,
    input  wire logic                           ret1n,
    input  wire logic                           pg_override,
    input  wire logic                           ecc_bypass,
    input  wire logic [2-1:0]                   ram_err_inject,
    input  wire logic [DATA_WIDTH-1:0]          din,
    output      logic [DATA_WIDTH-1:0]          dout,
    output      logic [2-1:0]                   ecc_err,
    output      logic [2-1:0]                   ecc_err_int,
    input  wire logic [RAM_SB_IN_WIDTH-1: 0]    ram_sb_in,
    output      logic [RAM_SB_OUT_WIDTH-1: 0]   ram_sb_out

  );
//********************************************************************************
// Declarations

// localparams

// Internal nets
   reg [ADDR_WIDTH-1:0] addr_reg;
   
//********************************************************************************
// Main code
//********************************************************************************

  assign ecc_err = 2'b0; // tied to 0
  assign ecc_err_int = 2'b0;// tied to 0
  assign ram_sb_out = {RAM_SB_OUT_WIDTH{1'b0}}; // Signal temp tied to 0, DCS to assign registered o/p.


  // SAR 131586 Fix - All portions of RTL must be in one generate statement to prevent Synplify compile from taking x30 time longer to complete.
    generate
    if ((WEN_WIDTH == 1) & (TCM_REGS == 0)) begin : gen_tcm
        reg [DATA_WIDTH - 1:0] mem [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="lsram" */;
    
    	assign dout = mem[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	
        always@(posedge clk)
        begin
            addr_reg <= addr;
            if(we[0]) mem[addr[ADDR_WIDTH-1:0] >> 2][(DATA_WIDTH - 1):0] <= din[(DATA_WIDTH - 1):0];  // Changed to account for parity bits
        end
    end else if ((WEN_WIDTH == 1) & (TCM_REGS == 1)) begin : gen_tcm
        reg [DATA_WIDTH - 1:0] mem [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="registers" */;
    
    	assign dout = mem[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	
        always@(posedge clk)
        begin
            addr_reg <= addr;
            if(we[0]) mem[addr[ADDR_WIDTH-1:0] >> 2][(DATA_WIDTH - 1):0] <= din[(DATA_WIDTH - 1):0];  // Changed to account for parity bits
        end
    end else if ((WEN_WIDTH == 4) & (TCM_REGS == 0)) begin : gen_tcm
        reg [7:0] mem_3  [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="lsram" */;
        reg [7:0] mem_2  [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="lsram" */;
        reg [7:0] mem_1  [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="lsram" */;
        reg [7:0] mem_0  [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="lsram" */;
    
      	assign dout[31:24] = mem_3[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[23:16] = mem_2[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[15:8 ] = mem_1[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[ 7:0 ] = mem_0[addr_reg[ADDR_WIDTH-1:0] >> 2];
    		
        always@(posedge clk)
        begin
            addr_reg <= addr;
            if(we[3]) mem_3[addr[ADDR_WIDTH-1:0] >> 2] <= din[31:24]; // REVISIT - Add parity bits
            if(we[2]) mem_2[addr[ADDR_WIDTH-1:0] >> 2] <= din[23:16];
            if(we[1]) mem_1[addr[ADDR_WIDTH-1:0] >> 2] <= din[15:8 ];
            if(we[0]) mem_0[addr[ADDR_WIDTH-1:0] >> 2] <= din[ 7:0 ];
        end
    end else if ((WEN_WIDTH == 4) & (TCM_REGS == 1)) begin : gen_tcm
        reg [7:0] mem_3 [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="registers" */;
        reg [7:0] mem_2 [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="registers" */;
        reg [7:0] mem_1 [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="registers" */;
        reg [7:0] mem_0 [RAM_DEPTH-1:0] /* synthesis syn_ramstyle="registers" */;
    
    
      	assign dout[31:24] = mem_3[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[23:16] = mem_2[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[15:8 ] = mem_1[addr_reg[ADDR_WIDTH-1:0] >> 2];
    	assign dout[ 7:0 ] = mem_0[addr_reg[ADDR_WIDTH-1:0] >> 2];
    		
        always@(posedge clk)
        begin
            addr_reg <= addr;
            if(we[3]) mem_3[addr[ADDR_WIDTH-1:0] >> 2] <= din[31:24]; // REVISIT - Add parity bits
            if(we[2]) mem_2[addr[ADDR_WIDTH-1:0] >> 2] <= din[23:16];
            if(we[1]) mem_1[addr[ADDR_WIDTH-1:0] >> 2] <= din[15:8 ];
            if(we[0]) mem_0[addr[ADDR_WIDTH-1:0] >> 2] <= din[ 7:0 ];
        end
    end
	endgenerate
    
endmodule


`default_nettype wire
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
// SVN $Revision: 42035 $
// SVN $Date: 2023-02-14 15:29:22 +0000 (Tue, 14 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

import miv_rv32_subsys_pkg::*;

module miv_rv32_subsys_mtime_irq 
//********************************************************************************
// Parameter description
  #(
   parameter INTERNAL_MTIME               = 0,
   parameter INTERNAL_MTIME_IRQ           = 0,
   parameter MTIME_PRESCALER     		  = 16'h63
   )

//********************************************************************************
// Port description

     ( 

      input wire logic        pclk,       // APB clock
      input wire logic        presetn,    // APB reset 
      input wire logic        penable,    // APB enable
      input wire logic        psel,       // APB select
      input wire logic [31:0] paddr,      // APB address bus
      input wire logic        pwrite,     // APB write
      input wire logic [31:0] pwdata,     // APB write data
      output     logic [31:0] prdata,     // APB read data
      output     logic        pready,     // APB ready	
	  output     logic        pslverr,    // APB target error	
	  
      input      logic        m_timer_stall,
	  output     logic        m_timer_irq,   
	  input      logic [63:0] mtime_count_in,
	  output     logic [63:0] mtime_count_out
    );                      
	
	  
    //-----------------------------------------------------------------------------
    // Parameters
    //-----------------------------------------------------------------------------
      localparam        SYNC_RESET = 1;

      localparam logic [31:0] l_mtime_addr_u    = l_mtime_addr_base + 4; 
      localparam logic [31:0] l_mtimecmp_addr_u = l_mtimecmp_addr_base + 4; 
    //-----------------------------------------------------------------------------
    // Signal Declarations
    //-----------------------------------------------------------------------------

      logic aresetn;
      logic sresetn;
      logic rtc_tick;

      logic T_l_En;   
      logic T_h_En;  
      logic Tc0_l_En;
      logic Tc0_h_En;

      logic [63:0] mtimecmp;
      logic [15:0] rtc_count;// was 32 bit - prescaler is only 16 bits (max value)
	  logic [63:0] mtime_count_sel; 

    //-----------------------------------------------------------------------------
    // Assignments
    //-----------------------------------------------------------------------------
      // APB
	  assign pslverr = 1'b0;
      assign pready  = (psel && penable);
	  
	  // Enables
      assign T_l_En   = ((INTERNAL_MTIME)     & (paddr == l_mtime_addr_base   )) ? (pwrite && psel && penable) : 1'b0;
      assign T_h_En   = ((INTERNAL_MTIME)     & (paddr == l_mtime_addr_u      )) ? (pwrite && psel && penable) : 1'b0;
      assign Tc0_l_En = ((INTERNAL_MTIME_IRQ) & (paddr == l_mtimecmp_addr_base)) ? (pwrite && psel && penable) : 1'b0;
      assign Tc0_h_En = ((INTERNAL_MTIME_IRQ) & (paddr == l_mtimecmp_addr_u   )) ? (pwrite && psel && penable) : 1'b0;
     
	  // Interrupts
	  assign mtime_count_sel = (INTERNAL_MTIME) ? mtime_count_out : mtime_count_in;
      assign m_timer_irq     = ((INTERNAL_MTIME_IRQ) & (mtime_count_sel >= mtimecmp)) ? 1'b1 : 1'b0;
	
      // Sync Reset
      assign aresetn = (SYNC_RESET == 1) ? 1'b1 : presetn;
      assign sresetn = (SYNC_RESET == 1) ? presetn : 1'b1;
	  
      // RTC Tick
      assign rtc_tick = (rtc_count == MTIME_PRESCALER - 1) ? 1'b1 : 1'b0; //Bug fix SAR#117814 MTIME_PRESCALER parameter value needs to be reduced by 1 to implement correct mtime tick
	
    //-----------------------------------------------------------------------------
    // Logic 
    //-----------------------------------------------------------------------------
      //RTC
      always_ff @(negedge aresetn or posedge pclk) 
	    begin
          if ((!aresetn) || (!sresetn)) begin
              rtc_count <= 16'h0;
          end else begin
              if(rtc_tick || !INTERNAL_MTIME) begin
                  rtc_count <= 16'h0;
              end else begin
				  if (!m_timer_stall) rtc_count <= rtc_count + 16'h1;	// Bug fix SAR#128467 MIV_RV32 internal MTIMER should be stalled in Debug Mode		  
              end
          end
        end
	    
      // mtime_count_out Register
      always_ff @(negedge aresetn or posedge pclk)
        begin : p_MTIME
          if ((!aresetn) || (!sresetn))		  
              mtime_count_out <= 64'b0; //Bug fix SAR#123679 MIV_RV32 MTIME reset rtl should specify 64 bits			  
			else if (!INTERNAL_MTIME)
              mtime_count_out <= 64'b0;
            else
			  begin
              if (T_l_En) begin
                  mtime_count_out[31:0] <= pwdata[31:0];
              end else if (T_h_En) begin
                  mtime_count_out[63:32] <= pwdata[31:0];
              end else if (rtc_tick && !m_timer_stall) begin //SAR#128467 when prescaler value set to 1, rtc_tick is always 1. !m_timer_stall required here to stall in this use case.
                  mtime_count_out <= mtime_count_out + 64'h1;
              end
          end
        end
		
      // MTIMECMP Register
        always_ff @(negedge aresetn or posedge pclk)
          begin : p_MTIMECMP
            if ((!aresetn) || (!sresetn)) begin
                mtimecmp <= 64'hFFFF_FFFF_FFFF_FFFF;
            end else begin
                if (Tc0_l_En) mtimecmp[31:0]  <= pwdata[31:0]; 
                if (Tc0_h_En) mtimecmp[63:32] <= pwdata[31:0];
            end
          end
	
      // APB_0 Read Register
        always_ff @(posedge pclk)
          begin : p_APB_0_Read
            if (!pwrite && psel) begin
                case (paddr)
                  l_mtime_prescaler_addr: prdata <= {15'b0, MTIME_PRESCALER[15:0]};
                    l_mtimecmp_addr_base: prdata <= mtimecmp[31:0];
                       l_mtimecmp_addr_u: prdata <= mtimecmp[63:32];
                       l_mtime_addr_base: prdata <= mtime_count_sel[31:0];
                          l_mtime_addr_u: prdata <= mtime_count_sel[63:32];
                                 default: prdata <= 32'b0;
                endcase
            end else begin
                prdata <= 32'b0;
            end
          end
	
endmodule
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
// SVN $Revision: 42059 $
// SVN $Date: 2023-02-16 16:00:08 +0000 (Thu, 16 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_udma.sv
//
//   Purpose:
//    MIV_RV32 MicroDMA engine (Not used. This feature Provided by Core MIV_ESS)
//   
//
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////

`default_nettype none

import miv_rv32_subsys_pkg::*;

module  miv_rv32_subsys_udma
//********************************************************************************
// Parameter description

  #(   
    

    parameter AXI_ADDR_WIDTH             = 32,
    parameter AHB_ADDR_WIDTH             = 32,
    parameter UDMA_CTRL_ADDR_WIDTH            = 32,    
    parameter TCM0_ADDR_WIDTH                = 32,
    parameter TCM1_ADDR_WIDTH                = 32

   )

//********************************************************************************
// Port description

  (    
    input wire logic                             resetn,
    input wire logic                             clk,

    // Control/status/config    
    input wire logic                             subsys_parity_en,   
    output     logic                             trx_os_d_rd,
    output     logic                             trx_os_d_wr,
    
    // CPU control interface
    input wire  logic                            cpu_udma_ctrl_req_valid,
    output      logic                            cpu_udma_ctrl_req_ready, 
    input wire  logic [3:0]                      cpu_udma_ctrl_req_rd_byte_en,  
    input wire  logic [3:0]                      cpu_udma_ctrl_req_wr_byte_en,
    input wire  logic                            cpu_udma_ctrl_req_read,
    input wire  logic                            cpu_udma_ctrl_req_write,
    input wire  logic [UDMA_CTRL_ADDR_WIDTH-1:0] cpu_udma_ctrl_req_addr,
    input wire  logic                            cpu_udma_ctrl_req_addr_p,
    input wire  logic [31:0]                     cpu_udma_ctrl_req_wr_data,
    input wire  logic [3:0]                      cpu_udma_ctrl_req_wr_data_p,
    output      logic                            cpu_udma_ctrl_resp_valid,
    input wire  logic                            cpu_udma_ctrl_resp_ready,
    output      logic                            cpu_udma_ctrl_resp_error,
    output      logic [31:0]                     cpu_udma_ctrl_resp_rd_data,
    output      logic [3:0]                      cpu_udma_ctrl_resp_rd_data_p,
    output      logic                            cpu_udma_ctrl_irq,
    
    // tcm0 interface   
    output     logic                             udma_tcm0_req_valid,
    input wire logic                             udma_tcm0_req_ready, 
    output     logic [3:0]                       udma_tcm0_req_rd_byte_en,  
    output     logic [3:0]                       udma_tcm0_req_wr_byte_en,
    output     logic                             udma_tcm0_req_read,
    output     logic                             udma_tcm0_req_write,
    output     logic [TCM0_ADDR_WIDTH-1:0]      udma_tcm0_req_addr,
    output     logic                             udma_tcm0_req_addr_p,
    output     logic [3:0]                       udma_tcm0_req_len,
    output     logic [31:0]                      udma_tcm0_req_wr_data,
    output     logic [3:0]                       udma_tcm0_req_wr_data_p,
    output     logic                             udma_tcm0_req_wr_data_last,
    input wire logic                             udma_tcm0_resp_valid,
    input wire logic                             udma_tcm0_resp_last,
    output     logic                             udma_tcm0_resp_ready,
    input wire logic                             udma_tcm0_resp_rd_error,
    input wire logic [31:0]                      udma_tcm0_resp_rd_data, 
    input wire logic [3:0]                       udma_tcm0_resp_rd_data_p,     
    
    // tcm1 interface
    output     logic                             udma_tcm1_req_valid,
    input wire logic                             udma_tcm1_req_ready, 
    output     logic [3:0]                       udma_tcm1_req_rd_byte_en,  
    output     logic [3:0]                       udma_tcm1_req_wr_byte_en,
    output     logic                             udma_tcm1_req_read,
    output     logic                             udma_tcm1_req_write,
    output     logic [TCM1_ADDR_WIDTH-1:0]      udma_tcm1_req_addr,
    output     logic                             udma_tcm1_req_addr_p,
    output     logic [3:0]                       udma_tcm1_req_len,
    output     logic [31:0]                      udma_tcm1_req_wr_data,
    output     logic [3:0]                       udma_tcm1_req_wr_data_p,
    output     logic                             udma_tcm1_req_wr_data_last,
    input wire logic                             udma_tcm1_resp_valid,
    input wire logic                             udma_tcm1_resp_last,
    output     logic                             udma_tcm1_resp_ready,
    input wire logic                             udma_tcm1_resp_rd_error,
    input wire logic [31:0]                      udma_tcm1_resp_rd_data, 
    input wire logic [3:0]                       udma_tcm1_resp_rd_data_p,           
    
    // AXI initiator interface
    output     logic                             udma_axi_req_valid,
    input wire logic                             udma_axi_req_ready, 
    output     logic [3:0]                       udma_axi_req_rd_byte_en,  
    output     logic [3:0]                       udma_axi_req_wr_byte_en,
    output     logic                             udma_axi_req_read,  
    output     logic                             udma_axi_req_write,
    output     logic [AXI_ADDR_WIDTH-1:0]   udma_axi_req_addr,
    output     logic                             udma_axi_req_addr_p,
    output     logic [3:0]                       udma_axi_req_len,
    output     logic [31:0]                      udma_axi_req_wr_data,
    output     logic [3:0]                       udma_axi_req_wr_data_p,
    output     logic                             udma_axi_req_wr_data_last,
    input wire logic                             udma_axi_resp_valid,
    input wire logic                             udma_axi_resp_last,
    output     logic                             udma_axi_resp_ready,
    input wire logic                             udma_axi_resp_rd_error,
    input wire logic [31:0]                      udma_axi_resp_rd_data, 
    input wire logic [3:0]                       udma_axi_resp_rd_data_p,
    input wire logic                             udma_axi_wr_resp_err,
    
    // AHB initiator interface
    output     logic                             udma_ahb_req_valid,
    input wire logic                             udma_ahb_req_ready, 
    output     logic [3:0]                       udma_ahb_req_rd_byte_en,  
    output     logic [3:0]                       udma_ahb_req_wr_byte_en,
    output     logic                             udma_ahb_req_read,  
    output     logic                             udma_ahb_req_write,
    output     logic [AHB_ADDR_WIDTH-1:0]   udma_ahb_req_addr,
    output     logic                             udma_ahb_req_addr_p,
    output     logic [3:0]                       udma_ahb_req_len,
    output     logic [31:0]                      udma_ahb_req_wr_data,
    output     logic [3:0]                       udma_ahb_req_wr_data_p,
    output     logic                             udma_ahb_req_wr_data_last,
    input wire logic                             udma_ahb_resp_valid,
    input wire logic                             udma_ahb_resp_last,
    output     logic                             udma_ahb_resp_ready,
    input wire logic                             udma_ahb_resp_rd_error,
    input wire logic [31:0]                      udma_ahb_resp_rd_data, 
    input wire logic [3:0]                       udma_ahb_resp_rd_data_p,   
    
    // APB TAS interface   
    input wire  logic                            apb_tas_udma_ctrl_req_valid,
    output      logic                            apb_tas_udma_ctrl_req_ready, 
    input wire  logic [3:0]                      apb_tas_udma_ctrl_req_rd_byte_en,  
    input wire  logic [3:0]                      apb_tas_udma_ctrl_req_wr_byte_en,
    input wire  logic [UDMA_CTRL_ADDR_WIDTH-1:0] apb_tas_udma_ctrl_req_addr,
    input wire  logic                            apb_tas_udma_ctrl_req_addr_p,
    input wire  logic [31:0]                     apb_tas_udma_ctrl_req_wr_data,
    input wire  logic [3:0]                      apb_tas_udma_ctrl_req_wr_data_p,
    output      logic                            apb_tas_udma_ctrl_resp_valid,
    input wire  logic                            apb_tas_udma_ctrl_resp_ready,
    output      logic                            apb_tas_udma_ctrl_resp_rd_error,
    output      logic [31:0]                     apb_tas_udma_ctrl_resp_rd_data,
    output      logic [3:0]                      apb_tas_udma_ctrl_resp_rd_data_p,
    output      logic                            apb_tas_udma_ctrl_irq
    
    
  );

//********************************************************************************
// Declarations

// localparams



// Internal nets


 logic                            cpu_udma_ctrl_sys_bus_rd_err;
 logic                            cpu_udma_ctrl_sys_bus_wr_err;
 logic                            cpu_udma_ctrl_tcm0_correctable_ecc_err;
 logic                            cpu_udma_ctrl_tcm0_uncorrectable_ecc_err;
 logic                            cpu_udma_ctrl_tcm1_correctable_ecc_err;
 logic                            cpu_udma_ctrl_tcm1_uncorrectable_ecc_err;



//********************************************************************************
// Main code
//********************************************************************************


 

endmodule


`default_nettype wire

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
// SVN $Revision: 41986 $
// SVN $Date: 2023-02-08 22:00:53 +0000 (Wed, 08 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
// 127668 11/21/22   KOH   Debugger - Add Address bit to access F Registers
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_subsys_debug.sv
//
//   Purpose:
//    Subsys debug unit
//    Contains :
//      - SUBSYS debug unit
//      - SUBSYS debug req fifo
//      - SUBSYS debug resp fifo
//      - SUBSYS debug dtm jtag
//
//   Author: 
//
//   Version: 1.2
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
`default_nettype none

import miv_rv32_subsys_pkg::*;

module miv_rv32_subsys_debug
//********************************************************************************
// Parameter description
   #( parameter l_subsys_cfg_hart_debug = 1)


//********************************************************************************
// Port description

  (
// clocks/resets
    input  wire logic                    clk,
    input  wire logic                    resetn,
// external jtag interface    
    input wire  logic                    jtag_trst,
    input wire  logic                    jtag_tck,
    input wire  logic                    jtag_tdi,
    input wire  logic                    jtag_tms,
    output      logic                    jtag_tdo,
    output      logic                    jtag_tdo_dr,
// hart debug unit interface    
    output logic                         debug_reset, 
    output logic                         debug_hart_reset,
    output logic                         debug_sys_reset,
    output logic                         debug_active,
    
    output logic [L_XLEN-1:0]            debug_op_wr_data, // muxed write o/p for CSR\GPR 
    
    output logic                         debug_csr_valid,          //***New***// assert this when debug_csr_wr_en | debug_csr_rd_en asserted          
    input  wire  logic                   debug_csr_ready, 
    output logic                         debug_csr_wr_en, 
    output logic                         debug_csr_rd_en, 
    output logic [11:0]                  debug_csr_addr,     
    input  wire  logic [L_XLEN-1:0]      debug_csr_rd_data, 
    input  wire  logic                   debug_csr_rd_data_valid,  //***New***// This is the data valid qualifier for CSR reads as requested 
    output logic                         debug_csr_rd_data_ready,  //***New***// Indicates read data can be accepted - doesn't do anything in the hart 
                                                                                 // for now as the hart always expects debuuger can accept data for requests 
                                                                                 // it makes, so tie to 1 or assert in debug mode, or something like that 
                                                                                      
    output logic                         debug_gpr_valid,          //***New***// assert this when debug_gpr_wr_en | debug_gpr_rd_en asserted        
    input  wire  logic                   debug_gpr_ready, 
    output logic                         debug_gpr_wr_en, 
    output logic                         debug_gpr_rd_en, 
    output logic [5:0]                   debug_gpr_addr,
    input  wire  logic [L_XLEN-1:0]      debug_gpr_rd_data, 
    input  wire  logic                   debug_gpr_rd_data_valid,  //***New***// This is the data valid qualifier for GPR reads as requested 
    output logic                         debug_gpr_rd_data_ready,  //***New***// Indicates read data can be accepted - doesn't do anything in the hart 
                                                                                 // for now as the hart always expects debuuger can accept data for requests 
                                                                                 // it makes, so tie to 1 or assert in debug mode, or something like that  
    output logic                         debug_halt_req,   
    input  wire  logic                   debug_halt_ack, 
    output logic                         debug_resethalt_req,   
    //input  wire  logic                   debug_resethalt_ack, 
    output logic                         debug_resume_req,   
    input  wire  logic                   debug_resume_ack,
    input  wire  logic                   debug_mode,
    input wire  logic                    debug_trx_os,
// system bus interface  
    output      logic                    debug_sysbus_req_valid,
    input wire  logic                    debug_sysbus_req_ready, 
    output      logic [3:0]              debug_sysbus_req_rd_byte_en,  
    output      logic [3:0]              debug_sysbus_req_wr_byte_en,
    output      logic [31:0]             debug_sysbus_req_addr,
    output      logic [31:0]             debug_sysbus_req_wr_data,
    input wire  logic                    debug_sysbus_resp_valid,
    output      logic                    debug_sysbus_resp_ready,
    input wire  logic                    debug_sysbus_resp_error,
    input wire  logic [31:0]             debug_sysbus_resp_rd_data 
    
  );

//********************************************************************************
// Main code
//********************************************************************************

logic non_debug_reset;
logic resetb;

/*always_comb
  begin: DTM_reset // used for resethalt feature
     resetb = 1'b0;
    if (debug_resethalt_req)
        resetb = 1'b1;
    else
        resetb = resetn;
  end
*/
assign resetb = resetn;
assign debug_reset = !debug_active;
assign debug_hart_reset = non_debug_reset;
assign debug_sys_reset = non_debug_reset;



// DU Signals
logic dtm_req_valid;
logic dtm_req_ready;
logic [DMI_REQ_DATA_WIDTH-1:0] dtm_req_data;

logic dtm_resp_valid;
logic dtm_resp_ready;
logic [DMI_RESP_DATA_WIDTH-1:0] dtm_resp_data;

logic dmi_req_valid;
logic dmi_req_ready;
logic [DMI_REQ_DATA_WIDTH-1:0] dmi_req_data;

logic dmi_resp_valid;
logic dmi_resp_ready;
logic [DMI_RESP_DATA_WIDTH-1:0] dmi_resp_data;

logic fifo_reset;


miv_rv32_debug_dtm_jtag #( .l_subsys_cfg_hart_debug(l_subsys_cfg_hart_debug)) 
    /*# (
    .IR_REG_WIDTH                (IR_REG_WIDTH),
    .DR_REG_WIDTH                (DR_REG_WIDTH),
    .ACTIVE_HIGH_RESET           (0)

)*/ MIV_subsys_debug_transport_module_jtag_0 (

   //JTAG SIDE
   // Inputs
   .tdi                           (jtag_tdi),
   .tck                           (jtag_tck),
   .tms                           (jtag_tms),
   .trst                          (jtag_trst), // Revisit, add active High/Low option
   
   // Outputs
   .tdo                           (jtag_tdo),
   .dr_tdo                        (jtag_tdo_dr),

   .fifo_reset                    (fifo_reset),

   // TO CDC fifos
   // DM Write 
   .dtm_req_valid                 (dtm_req_valid),
   .dtm_req_ready                 (dtm_req_ready),
   .dtm_req_data                  (dtm_req_data), //concatenated req_data {addr,wr_data,op}
   
   // DM Read
   .dtm_resp_valid                (dtm_resp_valid),
   .dtm_resp_ready                (dtm_resp_ready),
   .dtm_resp_data                 (dtm_resp_data) //concatenated resp_data {rd_data, op}
    );


      miv_rv32_debug_fifo #(.WIDTH(DBG_DMI_OP_WIDTH + DBG_DMI_ADDR_WIDTH + DBG_DMI_DATA_WIDTH),
                  .RESET_SYNC_WR_2_RD(1))
      debug_req_fifo(
                      // Write Interface
                      
                      .clk_wr(!jtag_tck),
					  //.rst_wr(fifo_reset),
                      .rst_wr(!fifo_reset), //inverted to active low
                      .ready_wr(dtm_req_ready),
                      .valid_wr(dtm_req_valid),
                      .data_wr(dtm_req_data),

                      .clk_rd(clk),
					  //.rst_rd(~resetb),
                      .rst_rd(resetb), //inverted to active low
                      .ready_rd(dmi_req_ready),
                      .valid_rd(dmi_req_valid),
                      .data_rd(dmi_req_data)
                      
                      );
      
     miv_rv32_debug_fifo #(.WIDTH(DBG_DMI_OP_WIDTH + DBG_DMI_DATA_WIDTH),
                  .RESET_SYNC_WR_2_RD(1))
                  debug_resp_fifo(
                                   .clk_wr(clk),
								   //.rst_wr(~resetb),
                                   .rst_wr(resetb),	//inverted to active low
                                   .ready_wr(dmi_resp_ready),
                                   .valid_wr(dmi_resp_valid),
                                   .data_wr(dmi_resp_data),

                                   .clk_rd(jtag_tck),
								   //.rst_rd(fifo_reset),
                                   .rst_rd(!fifo_reset), //inverted to active low
                                   .ready_rd(dtm_resp_ready),
                                   .valid_rd(dtm_resp_valid),
                                   .data_rd(dtm_resp_data) 
                                   );  



miv_rv32_debug_du miv_rv32_debug_du_0(
    .clk                         (clk),
    .resetb                      (resetb),
    
    // DMI Signals
    .dmi_req_valid               (dmi_req_valid),
    .dmi_req_ready               (dmi_req_ready),
    .dmi_req_data                (dmi_req_data),

    .dmi_resp_valid              (dmi_resp_valid),
    .dmi_resp_ready              (dmi_resp_ready),    
    .dmi_resp_data               (dmi_resp_data),
    
   

    .debug_op_wr_data           (debug_op_wr_data),
    
    .debug_csr_valid             (debug_csr_valid),
    .debug_csr_ready             (debug_csr_ready),
    .debug_csr_wr_en             (debug_csr_wr_en),
    .debug_csr_rd_en             (debug_csr_rd_en),
    .debug_csr_addr              (debug_csr_addr),
    .debug_csr_rd_data           (debug_csr_rd_data),
    .debug_csr_rd_data_valid     (debug_csr_rd_data_valid),
    .debug_csr_rd_data_ready     (debug_csr_rd_data_ready),
    
    .debug_gpr_valid             (debug_gpr_valid),
    .debug_gpr_ready             (debug_gpr_ready),
    .debug_gpr_wr_en             (debug_gpr_wr_en),
    .debug_gpr_rd_en             (debug_gpr_rd_en),
    .debug_gpr_addr              (debug_gpr_addr),
    .debug_gpr_rd_data           (debug_gpr_rd_data),
    .debug_gpr_rd_data_valid     (debug_gpr_rd_data_valid),
    .debug_gpr_rd_data_ready     (debug_gpr_rd_data_ready),


    // SBA Signals
    .sba_req_ready               (debug_sysbus_req_ready), 
    .sba_req_valid               (debug_sysbus_req_valid), 
    .sba_req_addr                (debug_sysbus_req_addr),
    .sba_req_wr_data             (debug_sysbus_req_wr_data),
    .sba_req_wr_byte_en          (debug_sysbus_req_wr_byte_en),
    .sba_req_rd_byte_en          (debug_sysbus_req_rd_byte_en),
    .sba_resp_valid              (debug_sysbus_resp_valid),
    .sba_resp_ready              (debug_sysbus_resp_ready),
    .sba_resp_error              (debug_sysbus_resp_error),
    .sba_resp_rd_data            (debug_sysbus_resp_rd_data),

    // Ext Pipe Signals
    .debug_trx_os                (debug_trx_os),
    .debug_active                (debug_active),
    .nondebug_reset              (non_debug_reset),
    .debug_mode                  (debug_mode),
    .debug_halt_req              (debug_halt_req),
    .debug_halt_ack              (debug_halt_ack), // HART -> DM
    .debug_resume_req            (debug_resume_req),    
    .debug_resume_ack            (debug_resume_ack),
    .debug_resethalt_req         (debug_resethalt_req)
    //.debug_resethalt_ack         (debug_resethalt_ack)
    );

endmodule

`default_nettype wire // debug top

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
// SVN $Revision: 41986 $
// SVN $Date: 2023-02-08 22:00:53 +0000 (Wed, 08 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
// 127668 11/21/22   KOH   Debugger - Add Address bit to access F Registers
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_debug_du.sv
//
//   Purpose:
//    MIV_RV32 debug unit
//    Contains :
//      - MIV_RV32 debug module debug unit, v1.1 with FIFO I/F
//      - Error flags v1.2
//      - MIV_RV32 debug module debug sba, v1.6
//
//
//
//
//   Author:
//
//   Version: 1.4
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// default net type..
// include package (import)
// use seperate package for DU.
`default_nettype none

import miv_rv32_subsys_pkg::*;


module miv_rv32_debug_du(
   input wire logic                    clk,
   input wire logic                    resetb,

   // DMI Signals
   input wire  logic                   dmi_req_valid,
   output      logic                   dmi_req_ready,
   input wire  logic [DMI_REQ_DATA_WIDTH-1:0] dmi_req_data,
   
   output      logic                   dmi_resp_valid,
   input wire  logic                   dmi_resp_ready,
   output      logic [DMI_RESP_DATA_WIDTH-1:0] dmi_resp_data,
   

   
   //Muxed Debug CSR\GPR write
   output      logic  [DATA_WIDTH-1:0] debug_op_wr_data, 

   // Debug CSR Signals
   
   output logic                        debug_csr_valid,
   input wire                          debug_csr_ready,
   output      logic                   debug_csr_wr_en,
   output      logic                   debug_csr_rd_en,
   output      logic  [11:0]           debug_csr_addr,
   input wire         [DATA_WIDTH-1:0] debug_csr_rd_data,
   input wire                          debug_csr_rd_data_valid,
   output      logic                   debug_csr_rd_data_ready,
   


   // Debug GPR Signals
   output logic                        debug_gpr_valid,
   input wire                          debug_gpr_ready,   
   output      logic                   debug_gpr_wr_en,
   output      logic                   debug_gpr_rd_en,
   output      logic  [5:0]            debug_gpr_addr,
   input wire         [DATA_WIDTH-1:0] debug_gpr_rd_data,   
   input wire                          debug_gpr_rd_data_valid,
   output logic                        debug_gpr_rd_data_ready,   


   //HART/Subsystem Signal
   input wire                          sba_resp_error,
   input wire         [DATA_WIDTH-1:0] sba_resp_rd_data,

   input wire                          sba_req_ready,

   input wire                          sba_resp_valid,
   output      logic                   sba_req_valid,
   output      logic  [ADDR_WIDTH-1:0] sba_req_addr,
   output      logic  [3:0]            sba_req_rd_byte_en,
   output      logic  [3:0]            sba_req_wr_byte_en,
   output      logic  [DATA_WIDTH-1:0] sba_req_wr_data,
   output      logic                   sba_resp_ready,

   // Ext Pipe Signals
   input wire                          debug_trx_os,
   input wire                          debug_halt_ack,
   input wire                          debug_resume_ack,
   //input wire                          debug_resethalt_ack,
   input wire                          debug_mode,
   output      logic                   debug_active,
   output      logic                   nondebug_reset,
   output      logic                   debug_halt_req,
   output      logic                   debug_resume_req,
   output      logic                   debug_resethalt_req
);


enum logic [5:0] {
                  INIT          = 6'b000001,
                  WR_ABST_CMD   = 6'b000010,
                  RD_ABST_CMD   = 6'b000100,
                  WR_REGNO_ADDR = 6'b001000,
                  RD_REGNO_ADDR = 6'b010000,
                  ERROR         = 6'b100000		            
                 } command_reg_state, next_state;

// debug state
// 000001 - INIT_DBG
// 000010 - RUNNING
// 000100 - HALT WAIT ACK
// 001000 - HALT STATE
// 010000 - COMMAND ACCESS STATE
// 100000 - RESUME WAIT ACT


enum logic[5:0] {
                 INIT_DBG              = 6'b000001,
                 RUNNING               = 6'b000010,
                 HALT_WAIT_ACK         = 6'b000100,
                 HALT_STATE            = 6'b001000,
                 COMMAND_ACCESS_STATE  = 6'b010000,
                 RESUME_WAIT_ACT       = 6'b100000	
               } debug_state; 



logic                   dmi_wr;
logic                   dmi_rd;// new signal
logic [DBG_DMI_ADDR_WIDTH-1:0]  dmi_addr;
logic [DATA_WIDTH-1:0]  dmi_wdata;
logic [DATA_WIDTH-1:0]  dmi_rdata;

logic dmi_mem_resp;
logic valid_dmi;
logic valid_sba;

logic [31:0] data_0_reg;
logic [31:0] data_csr_reg;
logic [31:0] data_gpr_reg;

// DMCONTROL
logic            dmcontrol_haltreq       ;
logic            dmcontrol_resumereq      ;
logic            dmcontrol_ackhavereset   ;
//logic            dmcontrol_setresethaltreq;
//logic            dmcontrol_clrresethaltreq;
logic            dmcontrol_ndmreset       ;
logic            dmcontrol_dmactive       ;

// DMSTATUS
logic            dmstatus_allany_havereset ;
logic            havereset_skip_pwrup      ;
logic            dmstatus_allany_resumeack ;
logic            dmstatus_allany_running   ;
logic            dmstatus_allany_halted    ;


// Abstract regs
logic [7:0]  abs_cmd_cmb;
logic [2:0]  abs_cmd_regsize_cmb;
logic        abs_cmd_transfer_cmb;
logic        abs_cmd_regwr_cmb;
logic [3:0]  abs_cmd_regtype_cmb;
logic [11:0] abs_cmd_regno_cmb;
logic        debug_cmd_access;

// Register Access.
logic dmi_req_dmcontrol      ;
logic dmi_req_command        ;
logic dmi_req_abst_data0     ;
logic dmi_req_abst           ;


logic [2:0] abstractcs_cmderr;
logic [2:0] abstractcs_cmderr_cmb;
logic abstractcs_busy;
logic abstractcs_busy_cmb;
logic abstractcs_busyerr_cmb;
logic abstractcs_busyerr;

logic sba_busy;
logic sba_busyerr;


// DM Clock Enable
logic clk_en_dm;
logic clk_en_dm_cmb;

logic [31:0] mem_rdata;
logic debug_halt_req_comb;
logic debug_resume_req_comb;

assign dmi_addr = dmi_req_data[40:34]; 
assign dmi_wdata = dmi_req_data[33:2];
assign dmi_wr = (dmi_req_data[1:0] == 2'b10) ? 1'b1 : 1'b0;
assign dmi_rd = (dmi_req_data[1:0] == 2'b01) ? 1'b1 : 1'b0;
assign dmi_resp_data[33:2] = dmi_rdata; //(dmi_resp_ready & dmi_resp_valid) ? dmi_rdata : 32'b0;
assign dmi_resp_data[1:0] = (abstractcs_busyerr | sba_busyerr) ? 2'b11 : 2'b00; 

assign  dmi_req_dmcontrol   = (dmi_addr == DMCONTROL_ADDR) & dmi_req_ready ? 'b1:'b0;
assign  dmi_req_abst        = (dmi_addr == ABST_CONTROL_AND_STATUS_ADDR) & dmi_req_ready ? 'b1:'b0;
assign  dmi_req_abst_data0  = (dmi_addr == ABS_DATA_0_ADDR) & dmi_req_ready ? 'b1:'b0;
assign  dmi_req_command     = (dmi_addr == ABST_COMMAND_ADDR) & dmi_req_ready ? 'b1:'b0;

assign valid_dmi =  |{ dmi_addr[6:0] == ABST_CONTROL_AND_STATUS_ADDR,
                                        dmi_addr[6:0] == DMCONTROL_ADDR,
                                        dmi_addr[6:0] == DMSTATUS_ADDR,
                                        dmi_addr[6:0] == ABST_COMMAND_ADDR,
                                        dmi_addr[6:0] == ABS_DATA_0_ADDR,
                                        dmi_addr[6:0] == HALT_SUM_0_ADDR,
                                        dmi_addr[6:0] == HALT_SUM_1_ADDR};

assign valid_sba = |{ dmi_addr[6:0] == SBA_CONTROL_AND_STATUS_ADDR,
                      dmi_addr[6:0] == SYS_BUS_ADDR_0_ADDR,
                      dmi_addr[6:0] == SYS_BUS_DATA_0_ADDR};

assign dmi_req_ready = dmi_req_valid & ~(sba_busy | abstractcs_busy) ; //  
assign dmi_resp_valid = (dmi_mem_resp | (dmi_rd & valid_dmi)| (dmi_rd & ~valid_sba) | dmi_wr); // sba mem resp or dmi reg reg or a read request from a non existent dmi reg (32'h0 data returned)| (dmi_rd & ~valid_sba)
                                                                               
                                                                                             
                                                                                
                                                                                  
assign dmstatus_allany_running = ~dmstatus_allany_halted;


miv_rv32_debug_sba miv_rv32_debug_sba_0(
    .clk                         (clk),
    .resetb                      (resetb),
    .sba_en                      (dmcontrol_dmactive),
    .halted                      (debug_mode),
    .trx_os                      (debug_trx_os),
    .sba_busy                    (sba_busy),
    .sba_busyerr                 (sba_busyerr),

    // DMI Signals
    .mem_rd_resp                 (dmi_mem_resp), 
    .mem_req                     (dmi_req_ready),
    .mem_wr                      (dmi_wr),
    .mem_rd                      (dmi_rd),
    .mem_addr                    (dmi_addr),
    .mem_rdata                   (mem_rdata),
    .mem_wdata                   (dmi_wdata),

    // SBA Signals
    .sba_req_ready               (sba_req_ready), 
    .sba_req_valid               (sba_req_valid), 
    .sba_req_addr                (sba_req_addr),
    .sba_req_rd_byte_en          (sba_req_rd_byte_en),
    .sba_req_wr_byte_en          (sba_req_wr_byte_en),
    .sba_req_wr_data             (sba_req_wr_data),
    .sba_resp_valid              (sba_resp_valid),
    .sba_resp_ready              (sba_resp_ready),
    .sba_resp_error              (sba_resp_error),
    .sba_resp_rd_data            (sba_resp_rd_data));


always_comb   
  begin  
  dmi_rdata[31:0] = 32'b0; //RTG4 default
  
   case(dmi_addr)
      ABST_CONTROL_AND_STATUS_ADDR:
         begin
            dmi_rdata[31:29]  = ABSTRACTCS_RESERVEDD; 
            dmi_rdata[28:24]  = ABSTRACTCS_PROGBUFSIZE;
            dmi_rdata[23:13]  = ABSTRACTCS_RESERVEDC;
            dmi_rdata[12]     = abstractcs_busy;
            dmi_rdata[11]     = ABSTRACTCS_RESERVEDB;
            dmi_rdata[10:8]   = abstractcs_cmderr;
            dmi_rdata[7:4]    = ABSTRACTCS_RESERVEDA;
            dmi_rdata[3:0]    = ABSTRACTCS_DATACOUNT;
         end
       DMCONTROL_ADDR:
         begin
            dmi_rdata[31]     = dmcontrol_haltreq;
            dmi_rdata[30]     = dmcontrol_resumereq;
            dmi_rdata[29]     = DMCONTROL_HARTRESET;
            dmi_rdata[28]     = dmcontrol_ackhavereset;
            dmi_rdata[27]     = DMCONTROL_RESERVEDB;
            dmi_rdata[26]     = DMCONTROL_HASEL;
            dmi_rdata[25:16]  = DMCONTROL_HARTSELLO;
            dmi_rdata[15:6]   = DMCONTROL_HARTSELHI;
            dmi_rdata[5:2]    = DMCONTROL_RESERVEDA;
            dmi_rdata[1]      = dmcontrol_ndmreset;
            dmi_rdata[0]      = dmcontrol_dmactive;
         end
      DMSTATUS_ADDR:
         begin
            dmi_rdata[31:23]  = DMSTATUS_RESERVEDC;
            dmi_rdata[22]     = DMSTATUS_IMPEBREAK;
            dmi_rdata[21:20]  = DMSTATUS_RESERVEDB;
            dmi_rdata[19]     = dmstatus_allany_havereset;
            dmi_rdata[18]     = dmstatus_allany_havereset;
            dmi_rdata[17]     = dmstatus_allany_resumeack;
            dmi_rdata[16]     = dmstatus_allany_resumeack;
            dmi_rdata[15]     = DMSTATUS_ALLANYNONEXIST;
            dmi_rdata[14]     = DMSTATUS_ALLANYNONEXIST;
            dmi_rdata[13]     = DMSTATUS_ALLANYUNAVAIL;
            dmi_rdata[12]     = DMSTATUS_ALLANYUNAVAIL;
            dmi_rdata[11]     = dmstatus_allany_running;
            dmi_rdata[10]     = dmstatus_allany_running;
            dmi_rdata[9]      = dmstatus_allany_halted;
            dmi_rdata[8]      = dmstatus_allany_halted;
            dmi_rdata[7]      = DMSTATUS_AUTHENTICATED;
            dmi_rdata[6]      = DMSTATUS_AUTHBUSY;
            dmi_rdata[5]      = DMSTATUS_HASRESETHALTREQ;
            dmi_rdata[4]      = DMSTATUS_CONFSTRPTRVALID;
            dmi_rdata[3:0]    = DMSTATUS_VERSION;
         end
      ABS_DATA_0_ADDR:
         begin
            dmi_rdata = data_0_reg;
         end
      HALT_SUM_0_ADDR:
         begin
            dmi_rdata = {31'b0,dmstatus_allany_halted};
         end
      HALT_SUM_1_ADDR:
         begin
            dmi_rdata = {31'b0,dmstatus_allany_halted};
         end
      SBA_CONTROL_AND_STATUS_ADDR:
        begin
            dmi_rdata = mem_rdata;
        end
      SYS_BUS_ADDR_0_ADDR:
        begin
            dmi_rdata = mem_rdata;
        end
      SYS_BUS_DATA_0_ADDR:
        begin
            dmi_rdata = mem_rdata;
        end
      default:
         begin
            dmi_rdata[31:0] = 32'b0;
         end
    endcase
  end
  


// debugger active output
assign debug_active = clk_en_dm;

// Reset Controls

// Clock enable and DM reset 
always@( posedge clk or negedge resetb)
begin
   if (~resetb)
      begin
         dmcontrol_dmactive <= 1'b0;
         clk_en_dm          <= 1'b0;
      end
   else if( clk_en_dm_cmb )
      begin
         if( dmi_req_dmcontrol & dmi_wr )
            begin
               dmcontrol_dmactive <= dmi_wdata[0];
            end
      clk_en_dm <= dmcontrol_dmactive;
      end
end

assign clk_en_dm_cmb = (dmi_req_dmcontrol & dmi_wr) |
                             dmcontrol_dmactive | clk_en_dm;

// External Reset Request( Not the Debug Module)
always@( posedge clk or negedge resetb)
   begin
      if (~resetb)
         begin
            dmcontrol_ndmreset        <= 1'b0;
            dmcontrol_ackhavereset    <= 1'b0;
         end
      else if( clk_en_dm_cmb )
         begin
            if( ~dmcontrol_dmactive )
               begin
                  dmcontrol_ndmreset        <= 1'b0;
                  dmcontrol_ackhavereset    <= 1'b0;
               end
      else
         begin
            if( dmi_req_dmcontrol & dmi_wr )
               begin
                  dmcontrol_ndmreset <= dmi_wdata[1];
                  // Clear sticky NotDM reset status
                  dmcontrol_ackhavereset <= dmi_wdata[28];
               end
         end
      end
   end

// External Reset status
always @(posedge clk or negedge resetb)
   begin
      if( ~resetb )
         begin
            havereset_skip_pwrup      <= 1'b1;
            dmstatus_allany_havereset <= 1'b0;
         end
      else if( clk_en_dm_cmb )
         begin
            if( ~dmcontrol_dmactive )
               begin
                  havereset_skip_pwrup      <= 1'b1;
                  dmstatus_allany_havereset <= 1'b0;
               end
      else
         begin
            if( havereset_skip_pwrup )
               begin
                  havereset_skip_pwrup <= debug_state == INIT_DBG & ~dmcontrol_ndmreset;
               end

            if( ~havereset_skip_pwrup & debug_state == INIT_DBG )
               begin
                  dmstatus_allany_havereset <= 1'b1;
               end
            else if( dmcontrol_ackhavereset )
               begin
                  dmstatus_allany_havereset <= 1'b0;
               end
         end
      end
   end

// Reset signal for system controlled by Debug Module
assign nondebug_reset     = dmcontrol_ndmreset;

/* // Resethalt feature controls
always_ff @(posedge clk, negedge resetb)
 begin
   if( ~resetb ) 
      begin
         dmcontrol_setresethaltreq             <= 1'b0;
         dmcontrol_clrresethaltreq             <= 1'b0;
      end 
   else if( clk_en_dm_cmb )
      begin
         if( ~dmcontrol_dmactive ) 
            begin
               dmcontrol_setresethaltreq       <= 1'b0;
               dmcontrol_clrresethaltreq       <= 1'b0;
            end
         else 
            begin
               if( dmi_req_dmcontrol & dmi_wr )
                  begin
                     dmcontrol_setresethaltreq <= dmi_wdata[3];
                     dmcontrol_clrresethaltreq <= dmi_wdata[2];
                  end
            end
      end
 end
*/



// Halt/Resume Control.
always_ff @(posedge clk, negedge resetb)
 begin
   if( ~resetb) 
      begin
         dmcontrol_haltreq         <= 1'b0;
         dmcontrol_resumereq       <= 1'b0;
      end 
   else if( clk_en_dm_cmb )
      begin
         if( ~dmcontrol_dmactive ) 
            begin
               dmcontrol_haltreq         <= 1'b0;
               dmcontrol_resumereq       <= 1'b0;
            end
         else 
            begin
               if( dmi_req_dmcontrol & dmi_wr )
                  begin
                     dmcontrol_haltreq   <= dmi_wdata[31];
                     dmcontrol_resumereq <= dmi_wdata[30];
                  end
            end
      end
 end

// Halt status
always_ff @(posedge clk, negedge resetb)
begin
   if( ~resetb )
      begin
         dmstatus_allany_halted <= 1'b0;
      end
   else if( clk_en_dm_cmb )
      begin
         if( ~dmcontrol_dmactive )
            begin
               dmstatus_allany_halted <= 1'b0;
            end
         else
            begin
               if( debug_state == HALT_STATE ) //Debug Halted State
                  begin
                     dmstatus_allany_halted <= 1'b1;
                  end
                  else if(debug_state == RUNNING ) // Debug Run State 
                     begin
                        dmstatus_allany_halted <= 1'b0;
                     end
            end
      end
end

// Resume status
always_ff @(posedge clk, negedge resetb)
begin
   if( ~resetb ) begin
      dmstatus_allany_resumeack <= 1'b0;
   end
   else if( clk_en_dm_cmb )
      begin
         if( ~dmcontrol_dmactive )
            begin
               dmstatus_allany_resumeack <= 1'b0;
            end
         else
            begin
               if( ~dmcontrol_resumereq )
                  begin
                     dmstatus_allany_resumeack <= 1'b0;
                  end
               else if( debug_state == RUNNING && dmcontrol_resumereq == 1'b1 ) // Debug Run State
                  begin
                     dmstatus_allany_resumeack <= 1'b1;
                  end
            end
         end
end

// Abstract Control and Status //
logic [2:0] cmderr_cmb ;
logic [2:0] cmderr_ff ;


// Abstract Command // Decode and Execute Reads and Writes of GPRs and CSRs.
// ----------------
logic [31:0] command_reg;
logic [31:0] command_cmb;
logic abs_cmd_regsize_valid_cmb;

assign command_cmb               = dmi_req_command ? dmi_wdata[31:0] : command_reg[31:0];

assign abs_cmd_cmb               = dmi_req_command ? dmi_wdata[31:24] : command_reg[31:24];
assign abs_cmd_regsize_cmb       = dmi_req_command ? dmi_wdata[22:20] : command_reg[22:20];
assign abs_cmd_transfer_cmb      = dmi_req_command ? dmi_wdata[17]    : command_reg[17];
assign abs_cmd_regwr_cmb         = dmi_req_command ? dmi_wdata[16]    : command_reg[16];
assign abs_cmd_regtype_cmb       = dmi_req_command ? dmi_wdata[15:12] : command_reg[15:12];
assign abs_cmd_regno_cmb         = dmi_req_command ? dmi_wdata[0+:12] : command_reg[0+:12];

assign abs_cmd_regsize_valid_cmb = abs_cmd_regsize_cmb == 3'b010;




////////////////////////////////
// New Abstract Command FSM
////////////////////////////////
logic valid_read, valid_write;
logic access_reg_valid;
logic abs_cmd_transfer_ff;


//Registers initialized  when ~dmactive
always_ff @(posedge clk, negedge resetb)
   begin
      if( ~resetb) begin
        command_reg_state <= INIT;
        abs_cmd_transfer_ff <= 'b0;
        abstractcs_cmderr <= 3'b000;
        cmderr_ff <= 3'b000;
        command_reg <= 'b0;
        abstractcs_busy <= 1'b0;
        abstractcs_busyerr <= 1'b0;
      end
    else   
      if( clk_en_dm_cmb ) begin
        if( ~dmcontrol_dmactive) begin
          command_reg_state <= INIT;
          abs_cmd_transfer_ff <= 'b0;
          abstractcs_cmderr <= 3'b000;
          cmderr_ff <= 3'b000;
          command_reg <= 'b0;
          abstractcs_busy <= 1'b0;
          abstractcs_busyerr <= 1'b0;
         end
        else
         begin
            command_reg_state <= next_state;
            abs_cmd_transfer_ff <= abs_cmd_transfer_cmb;
            abstractcs_cmderr <= abstractcs_cmderr_cmb;
            cmderr_ff <= cmderr_cmb;
            command_reg <= command_cmb;
            abstractcs_busy <= abstractcs_busy_cmb;
            abstractcs_busyerr <= abstractcs_busyerr_cmb;
         end
        end
   end

assign access_reg_valid = abs_cmd_cmb == 8'b0 & abs_cmd_regsize_valid_cmb; 
assign debug_cmd_access = debug_state == COMMAND_ACCESS_STATE ? 1'b1 : 1'b0;

assign valid_read  = access_reg_valid & debug_cmd_access & ~abs_cmd_regwr_cmb;
assign valid_write = access_reg_valid & debug_cmd_access &  abs_cmd_regwr_cmb;

//assign abstractcs_busy_cmb = (dmi_req_command && ~|abstractcs_cmderr) ? 1'b1 : ((debug_csr_rd_en || debug_csr_wr_en) || (debug_gpr_rd_en || debug_gpr_wr_en) || (command_reg_state == ERROR)) ? 1'b0 : abstractcs_busy; //
assign abstractcs_busyerr_cmb = (abstractcs_busy && |{(dmi_req_command && command_reg_state != INIT), dmi_req_abst, dmi_req_abst_data0}) ? 1'b1 : abstractcs_busyerr;

always_comb
  begin : abs_busy_cmb_mux
	if (dmi_req_command && ~|abstractcs_cmderr)
		abstractcs_busy_cmb = 1'b1;
	else if ((debug_csr_rd_en || debug_csr_wr_en) || (debug_gpr_rd_en || debug_gpr_wr_en) || (command_reg_state == ERROR))
		abstractcs_busy_cmb = 1'b0;
	else
		abstractcs_busy_cmb = abstractcs_busy;
  end

always_comb
  begin : command_logic

    cmderr_cmb = (dmi_req_abst && |abstractcs_cmderr) ?  (abstractcs_cmderr & ~dmi_wdata[10:8]) : cmderr_ff;
    abstractcs_cmderr_cmb =  abstractcs_busy_cmb ? abstractcs_cmderr : cmderr_ff;
    next_state = command_reg_state; 
    
      case ( command_reg_state )
         INIT:       if (debug_cmd_access && abstractcs_busy_cmb)
                        begin                        
                        if  (abs_cmd_cmb == 8'b0 && ~|abstractcs_cmderr)//   ensure no errors pending
                           begin
                              if (valid_read)
                                 begin
                                      next_state = RD_ABST_CMD;
                                 end
                              else 
                              if (valid_write)
                                 begin    
                                      next_state = WR_ABST_CMD;
                                 end
                              else
                                 begin
                                    cmderr_cmb = ABSTRACT_ERR_EXCEPTION ;
                                    next_state = ERROR;
                                 end
                           end
                        else
                           begin
                             if (abs_cmd_cmb != 8'b0)
                               begin
                                 cmderr_cmb = ABSTRACT_ERR_CMD ; // unsupported
                                 next_state = ERROR;
                               end
                             else
                             if (|{dmcontrol_haltreq, dmcontrol_resumereq, dmcontrol_ackhavereset})
                                begin
                                 cmderr_cmb = ABSTRACT_ERR_NOHALT ; // halt/resume/reset pending
                                 next_state = ERROR;
                                end
                            else
                                next_state = ERROR; // existing command errors
                           end
                        end
					else if (abstractcs_busyerr)  
						begin
							cmderr_cmb = ABSTRACT_ERR_BUSY;
							next_state = ERROR; // captured busy error
                        end
                    else
                        begin
                           next_state = INIT;
                        end
         RD_ABST_CMD:   if ( abs_cmd_transfer_ff )
                           begin
                              next_state = RD_REGNO_ADDR;
                           end
                        else
                           begin
                              cmderr_cmb = ABSTRACT_ERR_CMD;
                              next_state = ERROR;
                           end
         WR_ABST_CMD:   if ( abs_cmd_transfer_ff )
                           begin
                              next_state = WR_REGNO_ADDR;
                           end
                        else
                           begin
                              cmderr_cmb = ABSTRACT_ERR_CMD;
                              next_state = ERROR;
                           end
         RD_REGNO_ADDR: if ( (debug_csr_ready && debug_csr_rd_data_valid) || (debug_csr_ready && debug_gpr_rd_data_valid) )
                           begin
                              next_state = INIT;
                           end
                        else
                           begin
                              next_state = RD_REGNO_ADDR; 
                           end
         WR_REGNO_ADDR: if ( debug_csr_ready || debug_gpr_ready)
                           begin
                              next_state = INIT;
                           end
                        else
                           begin
                              next_state = WR_REGNO_ADDR; 
                           end
         ERROR:         
                        begin
                          next_state = INIT;
                        end
         default:
         	begin
              if (abstractcs_busyerr) 
                begin
                  cmderr_cmb = ABSTRACT_ERR_BUSY;
                  next_state = ERROR;
                end
              else
         		next_state = INIT;
            end
      endcase      
    end  

  always_ff @(posedge clk, negedge resetb)
        begin
          if (~resetb)
            begin
              debug_csr_valid           <= 1'b0;
              debug_csr_wr_en           <= 1'b0;    
              debug_csr_rd_en           <= 1'b0;    
              debug_csr_addr            <= 12'h0;
              debug_csr_rd_data_ready   <= 1'b0;    
              data_csr_reg              <= 32'h0;
                
              debug_gpr_valid           <= 1'b0;    
              debug_gpr_wr_en           <= 1'b0;    
              debug_gpr_rd_en           <= 1'b0;    
              debug_gpr_addr            <= 6'h0;
              debug_gpr_rd_data_ready   <= 1'b0;    
              data_gpr_reg              <= 32'h0;
                
              debug_op_wr_data          <= 32'b0;
            end
          else
            begin
              if (~debug_active && ~clk_en_dm)
                begin
                  debug_csr_valid           <= 1'b0;
                  debug_csr_wr_en           <= 1'b0;    
                  debug_csr_rd_en           <= 1'b0;    
                  debug_csr_addr            <= 12'h0;
                  debug_csr_rd_data_ready   <= 1'b0;    
                  data_csr_reg              <= 32'h0;
                
                  debug_gpr_valid           <= 1'b0;    
                  debug_gpr_wr_en           <= 1'b0;    
                  debug_gpr_rd_en           <= 1'b0;    
                  debug_gpr_addr            <= 6'h0;
                  debug_gpr_rd_data_ready   <= 1'b0;    
                  data_gpr_reg              <= 32'h0;
                
                  debug_op_wr_data          <= 32'b0;
                end          
              else
          case (abs_cmd_regtype_cmb)
          4'h0:
            begin //CSR read write          
              if ( command_reg_state == RD_REGNO_ADDR & debug_csr_ready )
                begin                
                  debug_csr_valid           <= 1'b1;
                  debug_csr_wr_en           <= 1'b0;
                  debug_csr_rd_en           <= 1'b1;
                  debug_csr_addr            <= abs_cmd_regno_cmb[11:0];
                  debug_csr_rd_data_ready   <= 1'b1;
                  data_csr_reg              <= debug_csr_rd_data_valid ? debug_csr_rd_data : 32'h0;
                  
                  debug_op_wr_data          <= 32'b0;

                end
              else if ( command_reg_state == WR_REGNO_ADDR & debug_csr_ready )
                begin
                  debug_csr_valid           <= 1'b1;
                  debug_csr_wr_en           <= 1'b1;
                  debug_csr_rd_en           <= 1'b0;
                  debug_csr_addr            <= abs_cmd_regno_cmb[11:0];
                  debug_csr_rd_data_ready   <= 1'b0;
                  data_csr_reg              <= 32'h0;
                  
                  debug_op_wr_data          <= data_0_reg;

                end
              else
                begin
                  debug_csr_valid           <= 1'b0;
                  debug_csr_wr_en           <= 1'b0;
                  debug_csr_rd_en           <= 1'b0;
                  debug_csr_addr            <= 12'h0;
                  debug_csr_rd_data_ready   <= 1'b0;
                  data_csr_reg              <= 32'h0;
                  
                  debug_op_wr_data          <= 32'b0;
                end
            end
            
          4'h1:
            begin //GPR read write 
              if ( command_reg_state == RD_REGNO_ADDR  & debug_gpr_ready )
                begin
                  debug_gpr_valid           <= 1'b1;
                  debug_gpr_wr_en           <= 1'b0;
                  debug_gpr_rd_en           <= 1'b1;
                  debug_gpr_addr            <= abs_cmd_regno_cmb[5:0];
                  debug_gpr_rd_data_ready   <= 1'b1;
                  data_gpr_reg              <= debug_gpr_rd_data_valid ? debug_gpr_rd_data : 32'h0;
                  
                  debug_op_wr_data          <= 32'b0;

                end
              else if ( command_reg_state == WR_REGNO_ADDR  & debug_gpr_ready )
                begin
                  debug_gpr_valid           <= 1'b1;
                  debug_gpr_wr_en           <= 1'b1;
                  debug_gpr_rd_en           <= 1'b0;
                  debug_gpr_addr            <= abs_cmd_regno_cmb[5:0];
                  debug_gpr_rd_data_ready   <= 1'b0;
                  data_gpr_reg              <= 32'h0;
                  
                  debug_op_wr_data          <= data_0_reg;

                end
              else
                begin
                  debug_gpr_valid           <= 1'b0;
                  debug_gpr_wr_en           <= 1'b0;
                  debug_gpr_rd_en           <= 1'b0;
                  debug_gpr_addr            <= 6'h0;
                  debug_gpr_rd_data_ready   <= 1'b0;
                  data_gpr_reg              <= 32'h0;
                  
                  debug_op_wr_data          <= 32'b0;
                end
            end
            
          default:
            begin
                debug_csr_valid           <= 1'b0;
                debug_csr_wr_en           <= 1'b0;
                debug_csr_rd_en           <= 1'b0;
                debug_csr_addr            <= 12'h0;
                debug_csr_rd_data_ready   <= 1'b0;
                data_csr_reg              <= 32'h0;
                
                debug_gpr_valid           <= 1'b0;
                debug_gpr_wr_en           <= 1'b0;
                debug_gpr_rd_en           <= 1'b0;
                debug_gpr_addr            <= 6'h0;
                debug_gpr_rd_data_ready   <= 1'b0;
                data_gpr_reg              <= 32'h0;
                
                debug_op_wr_data          <= 32'b0;
            end
          endcase
        end
    end



always_ff @(posedge clk, negedge resetb)
begin
   if (~resetb)
      begin
         data_0_reg <= 32'b0;
      end
   else
      begin
         if (~debug_active && ~clk_en_dm)
            begin
               data_0_reg <= 32'b0;
            end
         else
            if( dmi_req_abst_data0 && dmi_wr )
               begin
                  data_0_reg <= dmi_wdata;
               end
            else if ( debug_csr_rd_en )
               begin
                  data_0_reg <= data_csr_reg;
               end
            else if ( debug_gpr_rd_en )
               begin
                  data_0_reg <= data_gpr_reg;
               end
      end         
end

////////////////////////////////
// End
////////////////////////////////

// logic for resethalt 

assign debug_resethalt_req = 1'b0; // feature disabled

/*
always_ff @(posedge clk, negedge resetb)
begin
   if (~resetb)
      begin      
       debug_resethalt_req <= 1'b0;
      end
    else if (dmcontrol_clrresethaltreq)
      begin
        debug_resethalt_req <= 1'b0;
      end
   else    
      begin
         debug_resethalt_req <= dmcontrol_setresethaltreq;
      end
end
*/

// logic for halt request to exu pipe

assign debug_halt_req_comb = dmcontrol_haltreq && (debug_state ==  RUNNING | debug_state == HALT_WAIT_ACK); 


always_ff @(posedge clk, negedge resetb)
begin
   if (~resetb)
      begin
        debug_halt_req <= 1'b0;
      end
    else if (debug_halt_ack)
      begin
        debug_halt_req <= 1'b0;
      end
   else    
      begin
         debug_halt_req <= debug_halt_req_comb;
      end
end

assign debug_resume_req_comb = dmcontrol_resumereq && ~dmstatus_allany_resumeack && (debug_state ==  HALT_STATE | debug_state == RESUME_WAIT_ACT) && ~debug_trx_os;

always_ff @(posedge clk, negedge resetb)
begin
   if (~resetb)
      begin
        debug_resume_req <= 1'b0;
      end
    else if (debug_resume_ack)
      begin
        debug_resume_req <= 1'b0;
      end
   else    
      begin
         debug_resume_req <= debug_resume_req_comb;
      end
end




// Debug State Machine
always_ff @(posedge clk, negedge resetb)
  begin
    if (~resetb)
        begin
            debug_state <= INIT_DBG;
        end
    else
        begin
            case(debug_state)
                INIT_DBG:
                  begin
                     debug_state <= RUNNING;
                  end
                RUNNING: // RUNNING
                    begin
                        if ( debug_halt_req == 1'b1 )
                            begin
                                debug_state <= HALT_WAIT_ACK;
                            end
                       else if (debug_mode) // Hart entered debug mode; 1. step, 2. breakpoint 
                       begin
                           debug_state <= HALT_STATE;
                       end
                        else
                            begin
                                debug_state <= RUNNING;
                            end
                    end

                HALT_WAIT_ACK: // HALT WAIT ACK
                     begin
                        if ( debug_halt_ack == 1'b1 )
                            begin
                                debug_state <= HALT_STATE;
                            end
                        else
                            begin
                                debug_state <= HALT_WAIT_ACK;
                            end
                     end

                HALT_STATE: // HALT STATE
                     begin
                        if ( dmcontrol_resumereq == 1'b1 & ~dmstatus_allany_resumeack)

                            begin
                                debug_state <= RESUME_WAIT_ACT;
                            end
                        else
                            begin
                                if ( abstractcs_busy_cmb)
                                    begin
                                      debug_state <= COMMAND_ACCESS_STATE;                                                                
                                    end
                                else
                                if (~debug_mode & ~dmcontrol_ndmreset)
                                    begin
                                        debug_state <= RUNNING;
                                    end
                                else
                                    begin
                                        debug_state <= HALT_STATE;
                                    end
                            end
                     end

                COMMAND_ACCESS_STATE: // COMMAND ACCESS STATE
                    begin
                        if ( ~abstractcs_busy_cmb)
                            begin                        
                                debug_state <= HALT_STATE;
                            end
                        else
                            begin
                                debug_state <= COMMAND_ACCESS_STATE;
                            end
                     end

               RESUME_WAIT_ACT: // RESUME WAIT ACK
                     begin
                        if ( debug_resume_ack == 1'b1 )
                            begin
                                debug_state <= RUNNING;
                            end
                        else
                            begin
                                debug_state <= RESUME_WAIT_ACT;
                            end
                     end

                default:
                       debug_state <= INIT_DBG;
            endcase
        end
  end

endmodule//tiny_du


`default_nettype wire
// Formal Comments

/*
   - We cannot have a DMI Response without having a DMI Request (assertion ? )
   - We cannot be halted and running at the same time
   - Check that load_* only occurs when expected.

*/
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
// SVN $Revision: 42035 $
// SVN $Date: 2023-02-14 15:29:22 +0000 (Tue, 14 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//    miv_rv32_debug_sba.sv
//
//   Purpose:
//    MIV_RV32 DM System Bus Access
//    Contains :
//      - MIV_RV32 debug SBA module 
//      
//   Note:  
//    A misaligned address error sets both sbcs_to_err (timeout) and sbcs_ba_err (bad address) bits in SBCS
//    Timeout counter present with prescaler, default 8*255 clock ticks before transaction timeout
//    DMI modified to work with CDC Fifo's. Changed to a req/resp interface - ver 1.5 
//
//    Modification to resolve test 2 compliance fail in ver 1.5, 
//      1. remove Neither READ or WRITE section from DMI - MEM Interface section in v1.5
//      2. mem_rd_resp assertions moved into case statement in DMI - MEM Interface, READ section.
//    sbcs_uar_err_ff write added to // fsm outputs on transition section -- ver 1.6
//
//     Ver 1.7: Lower range of SBA moved from 0xffff to 0x5fff so that SUBSYS Regs(0x6000) and BootROM (0xA000) can be seen in debugger 
//
//   Author: 
//
//   Version: 1.7
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// default net type..
// include package (import)
// use separate package for DU . 
`default_nettype none

import miv_rv32_subsys_pkg::*;


module miv_rv32_debug_sba(
   input wire logic                             clk,
   input wire logic                             resetb,
   input wire logic                             sba_en,
   input wire logic                             halted,
   input wire logic                             trx_os,
   output     logic                             sba_busy,
   output     logic                             sba_busyerr,
   
   // DMI Signals
   input wire  logic                             mem_req,
   input wire  logic                             mem_wr,
   input wire  logic                             mem_rd,
   input wire  logic [DBG_DMI_ADDR_WIDTH-1:0]    mem_addr,
   input wire  logic [DBG_DMI_DATA_WIDTH-1:0]    mem_wdata,
   output      logic [DBG_DMI_DATA_WIDTH-1:0]    mem_rdata,
   output      logic                             mem_rd_resp,

   //HART/Subsystem Signal
   input wire                                   sba_resp_error,
   input wire         [DATA_WIDTH-1:0]          sba_resp_rd_data,
   input wire                                   sba_req_ready,  
   input wire                                   sba_resp_valid,
   output      logic                            sba_req_valid,  
   output      logic  [ADDR_WIDTH-1:0]          sba_req_addr,
   output      logic  [3:0]                     sba_req_rd_byte_en,
   output      logic  [3:0]                     sba_req_wr_byte_en,
   output      logic  [DATA_WIDTH-1:0]          sba_req_wr_data,
   output      logic                            sba_resp_ready

);


// SBA FSM
enum logic [1:0] {
                  IDLE          = 2'b00,
                  START         = 2'b01,
                  BUSTFR        = 2'b10,
                  RETN          = 2'b11
                 } sba_state, next_state;

logic [2:0] increment; // sbaccess byte, hword or word addr increment
logic dmi_valid; // dmi address valid
logic access_valid; // valid sb access
logic misaligned_sbaddr; // misaligned address detect

logic sba_req_valid_int;
logic [ADDR_WIDTH-1:0] sba_req_addr_int;
logic [3:0] sba_req_rd_byte_en_int;
logic [3:0] sba_req_wr_byte_en_int;
logic [DATA_WIDTH-1:0] sba_req_wr_data_int;
logic sba_resp_ready_int;


logic sba_rd_req_ff, sba_rd_req_cmb; 
logic sba_wr_req_ff, sba_wr_req_cmb;


// SBA Registers /* 
//system bus control & status (0x38)
logic        sbcs_busyerror,sbcs_busyerror_ff; 
logic        sbcs_busy, sbcs_busy_ff;
logic        sbcs_readonaddr, sbcs_readonaddr_ff;
logic [2:0]  sbcs_access, sbcs_access_ff;
logic        sbcs_autoincrement, sbcs_autoincrement_ff;
logic        sbcs_readondata, sbcs_readondata_ff;
logic        sbcs_uar_err, sbcs_uar_err_ff;
logic        sbcs_ba_err, sbcs_ba_err_ff;
logic        sbcs_to_err, sbcs_to_err_ff;

logic [ADDR_WIDTH-1:0]    sbaddr_ff, sbaddr; // System Bus Address0 register(0x39).
logic [DATA_WIDTH-1:0]    sbdata_ff, sbdata; // System Bus Data0 register (0x3c)

// generic counter, used on handshake transaction
logic [3:0] prescale_counter; // timeout = prescale_counter >= timeout_val
logic [7:0] counter;
logic count_en;
logic timeout;

// Assignments. 

assign sba_req_valid = sba_req_valid_int; 
assign sba_req_addr = (sba_state == START | sba_state == BUSTFR) ? sba_req_addr_int : 32'b0;
assign sba_req_rd_byte_en = (sba_rd_req_ff & (sba_state == START | sba_state == BUSTFR)) ? sba_req_rd_byte_en_int : 4'b0000;
assign sba_req_wr_byte_en = (sba_wr_req_ff & (sba_state == START | sba_state == BUSTFR)) ? sba_req_wr_byte_en_int : 4'b0000;
assign sba_req_wr_data = (sba_wr_req_ff & (sba_state == START | sba_state == BUSTFR)) ? sba_req_wr_data_int : 32'h0;
assign sba_resp_ready = sba_resp_ready_int;

/*assign increment =  (sbcs_access == BYTE_ACCESS)  ? 3'b001 : // increment value for word 4, halfword 2, byte 1
                    (sbcs_access == HWORD_ACCESS) ? 3'b010 :
                    (sbcs_access == WORD_ACCESS)  ? 3'b100 : 3'b000;
*/
assign access_valid = |{sbcs_access == BYTE_ACCESS, sbcs_access == HWORD_ACCESS,  sbcs_access == WORD_ACCESS};

assign misaligned_sbaddr = (sbcs_access == HWORD_ACCESS & sbaddr[0]) | (sbcs_access == WORD_ACCESS & ^sbaddr[1:0]);

assign dmi_valid =  |{mem_addr[6:0] == SBA_CONTROL_AND_STATUS_ADDR, mem_addr[6:0] == SYS_BUS_ADDR_0_ADDR, mem_addr[6:0] == SYS_BUS_DATA_0_ADDR}; 

assign sba_busy = sbcs_busy_ff;

assign sba_busyerr = sbcs_busyerror_ff;

always_comb 
	begin : increment_value_mux // increment value for word 4, halfword 2, byte 1
	  case (sbcs_access)
		WORD_ACCESS:  increment = 3'b100;
		HWORD_ACCESS: increment = 3'b010;
		BYTE_ACCESS:  increment = 3'b001;
		default:	  increment = 3'b000;
	  endcase
	end
  
//DMI - MEM Interface
always_comb
  begin
      
      sba_rd_req_cmb = sba_rd_req_ff;
      sba_wr_req_cmb = sba_wr_req_ff;
      
      sbcs_busy = sbcs_busy_ff;
      sbcs_busyerror = sbcs_busyerror_ff;
      sbcs_readonaddr =  sbcs_readonaddr_ff;
      sbcs_access = sbcs_access_ff; 
      sbcs_autoincrement = sbcs_autoincrement_ff;
      sbcs_readondata = sbcs_readondata_ff;
      sbcs_uar_err = sbcs_uar_err_ff;
      sbcs_ba_err = sbcs_ba_err_ff;
      sbcs_to_err = sbcs_to_err_ff;


      sbaddr = sbaddr_ff;
      sbdata = sbdata_ff;

      mem_rdata = 32'h0;
      mem_rd_resp = 1'b0;

      if (mem_req & dmi_valid) 
        begin                            
            if (mem_rd) //READ
              begin
              case(mem_addr [6:0])
              SBA_CONTROL_AND_STATUS_ADDR:
                begin
                  mem_rdata = {SBCS_VER,
                              6'b000000,
                              sbcs_busyerror_ff,
                              sbcs_busy_ff,
                              sbcs_readonaddr_ff, 
                              sbcs_access_ff, 
                              sbcs_autoincrement_ff,
                              sbcs_readondata_ff,
                              sbcs_uar_err_ff, //sbcs_error 4
                              sbcs_ba_err_ff,  //sbcs_error 2
                              sbcs_to_err_ff,  //sbcs_error 1
                              SBCS_SIZE,
                              SBCS_ACCESSES
                              };
                      mem_rd_resp = 1'b1;
                end
              SYS_BUS_ADDR_0_ADDR:
                begin
                  mem_rdata = sbaddr_ff;
                  mem_rd_resp = 1'b1;
                end
              SYS_BUS_DATA_0_ADDR: // [3]Read call SBA FSM and;1. set sbcs_busy, 2. if sbcs_readondata asserted, read from address location pointed at by sbaddr, 3. if sbcs_autoincrement asserted, sbaddr++, 4. clear sbcs_busy.
                begin
                  if (~sbcs_busy) // assumed - not explicitly stated
                  begin  
                    mem_rdata = sbdata_ff; // return the data
                      if (sbcs_readondata & (sbaddr > 32'h5FFF)) // sbaddr needs to be > abstract Reg address space
                        begin                          
                          sba_rd_req_cmb = 1'b1; // sbdata updated after bus access, new value not returned to debugger
                          mem_rd_resp = 1'b1;
                        end
                      else
                         begin
                           sba_rd_req_cmb = 1'b0;
                           mem_rd_resp = 1'b1;
                         end
                  end
                  else // read request whilst busy
                  begin
                    mem_rdata = 32'b0; 
                    sbcs_busyerror = 1'b1; // busy error if debugger sbdata read whilst SB access in flight
                  end
                end

              default:
                begin
                  mem_rdata = 32'b0;
                  sba_rd_req_cmb = 1'b0;
                end
              endcase
              end
        
            if (mem_wr)//WRITE
              begin
              mem_rd_resp = 1'b0;
              mem_rdata = 32'b0;
              case(mem_addr [6:0])
              SBA_CONTROL_AND_STATUS_ADDR:
                begin
                     
                  sbcs_readonaddr = mem_wdata[20];
                  sbcs_access = mem_wdata[19:17]; 
                  sbcs_autoincrement = mem_wdata[16];
                  sbcs_readondata = mem_wdata[15];
                  if (mem_wdata[22]) sbcs_busyerror = 1'b0; //RW1C error bits
                  if (mem_wdata[14])sbcs_uar_err = 1'b0;
                  if (mem_wdata[13])sbcs_ba_err = 1'b0; 
                  if (mem_wdata[12])sbcs_to_err = 1'b0;
                    //other bits read only
                                          
                end
              SYS_BUS_ADDR_0_ADDR: //[1] Writes - call SBA FSM and; 1. set sbcs_busy, 2. if sbcs_readonaddr asserted, read from address location pointed at by sbaddr (assuming legitimate memory space!) 3. if sbcs_autoincrement asserted then sbaddr++, 4. clear sbcs_busy
                begin
                  if (~sbcs_busy)
                    begin
                      sbaddr = mem_wdata;
                      if (~|{sbcs_uar_err, sbcs_ba_err, sbcs_to_err, sbcs_busyerror} & sbcs_readonaddr & (sbaddr > 32'h5FFF) )// sbaddr needs to be > abstract Reg address space
                          begin   
                            sba_rd_req_cmb = 1'b1; // sba read fsm, sbdata updated on FSM bus tfr
                          end
                        else
                          sba_rd_req_cmb = 1'b0;
                      end
                  else                  
                    sbcs_busyerror = 1'b1; // attempted writes whilst sbcs_busy asserted, set busy error bit
                end
              SYS_BUS_DATA_0_ADDR:// [2] Writes call SBA FSM and; 1. set sbcs_busy, 2. sba write data to address in sbaddr,, set busy error bit,3. if write OK and sbcs_autoincrement asserted then sbaddr++, 4. clear sbcs_busy.
                begin
                  if (~sbcs_busy)
                    begin
                      sbdata  =  mem_wdata;
                        if (~|{sbcs_uar_err, sbcs_ba_err, sbcs_to_err, sbcs_busyerror} & (sbaddr > 32'h5FFF) )// sbaddr needs to be > abstract Reg address space
                          begin 
                            sba_wr_req_cmb = 1'b1;
                          end
                        else
                          sba_wr_req_cmb = 1'b0;
                    end
                  else
                    sbcs_busyerror = 1'b1; 
                end
    
              default:
                begin
                  sba_rd_req_cmb = 1'b0;
                  sba_wr_req_cmb = 1'b0;
                  //set error?
                end
              endcase
            end
        end
    end


   // SBA Initiator FSM 
always_ff @( posedge clk or negedge resetb)
    begin
      if (~resetb) // reset regs etc
        begin
          sba_state <= IDLE; 
        end
      else
        begin
          sba_state <= next_state;
        end
    end

       
always_comb 
    begin
        count_en = 1'b0;
        next_state = sba_state;


      case (sba_state)// IDLE 
        IDLE:
          begin           
            if (halted  & (sba_rd_req_cmb | sba_wr_req_cmb) & ~trx_os)
                next_state = START;
            else            
                next_state = IDLE;

            end
        START:
          begin
            if ((sba_rd_req_cmb | sba_wr_req_cmb)  & sba_req_ready) 
              begin
                if (access_valid & ~misaligned_sbaddr) // check valid access and not misaligned address  & ~misaligned_sbaddr
                  begin
                    next_state = BUSTFR;
                    count_en = 1'b0;
                  end
                else
                    next_state = IDLE; 
              end
            else

            if (timeout | misaligned_sbaddr | ~access_valid )
                next_state = IDLE;
                if (timeout) count_en = 1'b0; // disable count, to_err set
            else
                count_en = 1'b1; // count
        end
  
        BUSTFR: //TRANSFER 
          begin
            if ((sba_rd_req_cmb | sba_wr_req_cmb) & (sba_resp_valid |sba_resp_error))
              begin  
                next_state         = RETN;
              end
            else
               count_en            = 1'b1; // count
          end //

        RETN:
            begin
            next_state             = IDLE;
            end //

        endcase
    end

always_ff @( posedge clk, negedge resetb) // fsm outputs on transition
    begin
    if (~resetb) // reset regs etc
      begin

        sbcs_readonaddr_ff        <= 1'b0;
        sbcs_access_ff            <= 3'b010; //Default WORD_ACCESS
        sbcs_autoincrement_ff     <= 1'b0;
        sbcs_readondata_ff        <= 1'b0;

        sba_rd_req_ff             <= 1'b0;
        sba_wr_req_ff             <= 1'b0;

        sbcs_busyerror_ff         <= 1'b0;
        sbcs_busy_ff              <= 1'b0; 
        
        sbaddr_ff                 <= 32'h0;
        sbdata_ff                 <= 32'h0;

        sbcs_uar_err_ff           <= 1'b0;
        sbcs_to_err_ff            <= 1'b0;
        sbcs_ba_err_ff            <= 1'b0;
          
        sba_req_valid_int         <= 1'b0;
        sba_req_addr_int          <= 32'b0;
        sba_req_wr_data_int       <= 32'b0;
        sba_req_wr_byte_en_int    <= 4'b0000;
        sba_req_rd_byte_en_int    <= 4'b0000;
        sba_resp_ready_int        <= 1'b0;
       
      end
      
    else if (~sba_en) // DM not active
    
      begin

        sbcs_readonaddr_ff        <= 1'b0;
        sbcs_access_ff            <= WORD_ACCESS; //Default 
        sbcs_autoincrement_ff     <= 1'b0;
        sbcs_readondata_ff        <= 1'b0;

        sba_rd_req_ff             <= 1'b0;
        sba_wr_req_ff             <= 1'b0;

        sbcs_busyerror_ff         <= 1'b0;
        sbcs_busy_ff              <= 1'b0; 
        
        sbaddr_ff                 <= 32'h0;
        sbdata_ff                 <= 32'h0;

        sbcs_uar_err_ff           <= 1'b0;
        sbcs_to_err_ff            <= 1'b0;
        sbcs_ba_err_ff            <= 1'b0;
          
        sba_req_valid_int         <= 1'b0;
        sba_req_addr_int          <= 32'b0;
        sba_req_wr_data_int       <= 32'b0;
        sba_req_wr_byte_en_int    <= 4'b0000;
        sba_req_rd_byte_en_int    <= 4'b0000;
        sba_resp_ready_int        <= 1'b0;
       
      end

    else
      begin
        sbcs_readonaddr_ff        <= sbcs_readonaddr;
        sbcs_access_ff            <= sbcs_access;
        sbcs_autoincrement_ff     <= sbcs_autoincrement;
        sbcs_readondata_ff        <= sbcs_readondata;
          


        sbcs_busyerror_ff      <= sbcs_busyerror;
        sbcs_busy_ff           <= sbcs_busy; 
        sbcs_uar_err_ff       <= sbcs_uar_err;
        sbcs_to_err_ff        <= sbcs_to_err;
        sbcs_ba_err_ff        <= sbcs_ba_err;
 
        sbaddr_ff              <= sbaddr;
        sbdata_ff              <= sbdata;

        sba_rd_req_ff         <= sba_rd_req_cmb;
        sba_wr_req_ff         <= sba_wr_req_cmb;

        sba_req_valid_int     <= sba_req_valid;  
        sba_req_addr_int      <= sba_req_addr;  
        sba_req_wr_data_int   <= sba_req_wr_data;  
        sba_req_wr_byte_en_int <= sba_req_wr_byte_en;  
        sba_req_rd_byte_en_int <= sba_req_rd_byte_en;  
        sba_resp_ready_int     <= sba_resp_ready;


        case (next_state)

        IDLE:
          begin
            sbcs_busy_ff              <= 1'b0;
            sba_rd_req_ff             <= 1'b0;
            sba_wr_req_ff             <= 1'b0;
            sba_req_valid_int         <= 1'b0;
            sba_resp_ready_int        <= 1'b0;
            if (sbcs_autoincrement & (sba_state == RETN)) sbaddr_ff <= sbaddr + {29'b0, increment};
            if (~sbcs_ba_err & sba_resp_error ) sbcs_ba_err_ff <= 1'b1; // late reported bad address error
            if (timeout & ~sbcs_to_err) sbcs_to_err_ff  <= 1'b1; // timeout and back to IDLE if req_ready not received (set timeout_err flag)
            if (~access_valid & ~sbcs_uar_err) sbcs_uar_err_ff <= 1'b1; // v1.6 addition, check this koh (SS) //unsupported access request error
          end

        START:
          begin
            if (access_valid & ~misaligned_sbaddr)
              begin
                sba_req_valid_int <= 1'b1;
                sba_resp_ready_int <= 1'b1;
                sbcs_busy_ff <= 1'b1;
                
                if (sba_rd_req_cmb) 
                  begin
                    case (sbcs_access)
                    BYTE_ACCESS:
                      begin
                        sba_req_addr_int <= sbaddr;
                        sba_req_wr_byte_en_int  <= 4'b0000;
                        sba_req_rd_byte_en_int  <= (sbaddr[1:0] == 2'b00) ? 4'b0001 :
                                                   (sbaddr[1:0] == 2'b01) ? 4'b0010 :
                                                   (sbaddr[1:0] == 2'b10) ? 4'b0100 :
                                                   (sbaddr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
                      end
                      
                    HWORD_ACCESS:
                      begin
                        sba_req_addr_int <= sbaddr;
                        sba_req_wr_byte_en_int  <= 4'b0000;
                        sba_req_rd_byte_en_int  <= (sbaddr[1] == 1'b0) ? 4'b0011 :
                                                   (sbaddr[1] == 1'b1) ? 4'b1100 : 4'b0000;

                      end
                    WORD_ACCESS:
                      begin
                        sba_req_addr_int        <= sbaddr;
                        sba_req_wr_byte_en_int  <= 4'b0000;
                        sba_req_rd_byte_en_int  <= 4'b1111;

                      end
                    default:
                      begin
                        sba_req_valid_int           <= 1'b0;
                        sba_req_addr_int            <= 32'h0;//
                        sba_req_rd_byte_en_int      <= 4'b0000;
                        sba_req_wr_byte_en_int      <= 4'b0000;
                     end
                    endcase
                  end
                  
                else
                  
                if (sba_wr_req_cmb)
                  begin                   
                    case (sbcs_access)
                    BYTE_ACCESS:
                      begin
                        sba_req_addr_int        <= sbaddr;
                        sba_req_wr_data_int     <= (sbaddr[1:0] == 2'b00) ? {24'b0, sbdata[7:0]}:
                                                   (sbaddr[1:0] == 2'b01) ? {16'b0, sbdata[7:0], 8'b0}:
                                                   (sbaddr[1:0] == 2'b10) ? {8'b0, sbdata[7:0], 16'b0}:
                                                   (sbaddr[1:0] == 2'b11) ? {sbdata[7:0], 24'b0}: 32'b0;

                        sba_req_wr_byte_en_int  <= (sbaddr[1:0] == 2'b00) ? 4'b0001 :
                                                   (sbaddr[1:0] == 2'b01) ? 4'b0010 :
                                                   (sbaddr[1:0] == 2'b10) ? 4'b0100 :
                                                   (sbaddr[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
                        sba_req_rd_byte_en_int  <= 4'b0000;

                      end
                    HWORD_ACCESS:
                      begin
                        sba_req_addr_int        <= sbaddr;
                        sba_req_wr_data_int     <= (sbaddr[1] == 1'b0) ? {16'b0, sbdata[15:0]}:
                                                   (sbaddr[1] == 1'b1) ? {sbdata[15:0],16'b0} : 32'b0;

                        sba_req_wr_byte_en_int  <= (sbaddr[1] == 1'b0) ? 4'b0011 :
                                                   (sbaddr[1] == 1'b1) ? 4'b1100 : 4'b0000;
                        sba_req_rd_byte_en_int  <= 4'b0000;

                      end
                    WORD_ACCESS:
                      begin
                        sba_req_addr_int        <= sbaddr;
                        sba_req_wr_data_int     <= sbdata;
                        sba_req_wr_byte_en_int  <= 4'b1111;
                        sba_req_rd_byte_en_int  <= 4'b0000;

                      end
                    default:
                      begin
                        sba_req_valid_int           <= 1'b0;
                        sba_req_addr_int            <= 32'h0;
                        sba_req_wr_data_int         <= 32'h0;
                        sba_req_wr_byte_en_int      <= 4'b0000;
                        sba_req_rd_byte_en_int      <= 4'b0000;
                      end
                    endcase
                  end
                  
                else
                  begin
                    sba_req_valid_int           <= 1'b0;
                    sba_req_addr_int            <= 32'h0;
                    sba_req_wr_data_int         <= 32'h0;
                    sba_req_wr_byte_en_int      <= 4'b0000;
                    sba_req_rd_byte_en_int      <= 4'b0000;
                  end                
              end
            else
              if (~access_valid & ~sbcs_uar_err) sbcs_uar_err_ff <= 1'b1; //unsupported access request error
              if (misaligned_sbaddr & (~sbcs_to_err | ~sbcs_ba_err)) // sbaddr misaligned
              begin
                sbcs_to_err_ff <= 1'b1; // both these errors set to signify misaligned address error 
                sbcs_ba_err_ff <= 1'b1;
              end
          end

        BUSTFR:
          begin
            if (sba_wr_req_cmb & sba_req_ready)
              begin
                 sba_req_valid_int <= 1'b0;
              end
            else
            if (sba_rd_req_cmb & (sba_resp_valid & ~sba_resp_error))
              begin
              sba_req_valid_int <= 1'b0;
              sba_resp_ready_int <= 1'b0;
              end
            else
            // wait for timeout
              begin
                if (timeout)
                begin
                    sba_req_valid_int           <= 1'b0;
                    sba_req_addr_int            <= 32'h0;
                    sba_req_wr_byte_en_int      <= 4'b0000;
                    sba_req_rd_byte_en_int      <= 4'b0000;
                    if (~sbcs_to_err) sbcs_to_err_ff  <= 1'b1; // timeout error
                end
              end 
            end // 

        RETN:
          begin
            if (sba_rd_req_cmb & (sba_resp_valid & ~sba_resp_error))
              begin
              sba_resp_ready_int <= 1'b0;
              case (sbcs_access)
              BYTE_ACCESS:
                begin
                  sbdata_ff[7:0]     <= (sbaddr[1:0] == 2'b00) ? sba_resp_rd_data[7:0]:
                                        (sbaddr[1:0] == 2'b01) ? sba_resp_rd_data[15:8]:
                                        (sbaddr[1:0] == 2'b10) ? sba_resp_rd_data[23:16]:
                                        (sbaddr[1:0] == 2'b11) ? sba_resp_rd_data[31:24]: 8'b0;
                end
              HWORD_ACCESS:
                begin
                  sbdata_ff[15:0]   <= (sbaddr[1] == 1'b0) ? sba_resp_rd_data[15:0]:
                                       (sbaddr[1] == 1'b1) ? sba_resp_rd_data[31:16]: 16'b0;
                 end
              WORD_ACCESS:
                begin
                  sbdata_ff       <=  sba_resp_rd_data;
                end
			  default:
				  sbdata_ff       <=  32'b0; //default
              endcase
              end
            else

            if (sba_resp_error | timeout)
              begin
                sba_resp_ready_int               <= 1'b0;
                sba_req_addr_int                 <= 32'h0;
                sba_req_wr_byte_en_int           <= 4'b0000;
                sba_req_rd_byte_en_int           <= 4'b0000;
                if (~sbcs_ba_err & sba_resp_error ) sbcs_ba_err_ff <= 1'b1; // bad address error
                if (~sbcs_to_err & timeout) sbcs_to_err_ff  <= 1'b1; // timeout error
              end
          end //
        endcase
      end
    end

always_ff @( posedge clk or negedge resetb) // timeout counter
    begin
      if (~resetb) // reset regs etc
        begin
         prescale_counter <= 4'h0;
         counter <= 8'h00;
         timeout <= 1'b0;
        end
      else
        if (count_en)
          begin
            if (counter == 8'hff)
              begin
                prescale_counter <= prescale_counter + 1'b1;
                counter <= 8'h00;
                timeout <= (prescale_counter >= TIMEOUT_VAL);
              end
            else
                counter <= counter + 1'b1;
          end
        else
          begin
            prescale_counter <= 4'h0;
            counter <= 8'h00;
            timeout <= 1'b0;
          end
    end // timeout counter
    
 endmodule//SBA

`default_nettype wire
// Formal Comments

/*

   - We cannot have an Sys Bus Access with  (assertion ? )
   - We cannot be halted and running at the same time
   - Check that load_* only occurs when expected. 
*/
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
// SVN $Revision: 41986 $
// SVN $Date: 2023-02-08 22:00:53 +0000 (Wed, 08 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//    miv_rv32_debug_fifo.sv
//
//   Purpose:
//    SUBSYS DTM to DM interface
//    Clock domain crossing between DTM (JTAG TCK) and DM (Sys Clock).
//    Async FIFO on req and resp paths 
//      
//      
//   Note:
//      Changed to active low reset
//
//
//
//   Author: Sebastian Slowikowski
//
//   Version: 2.0
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// default net type..
// include package (import)
// 
`default_nettype none

module miv_rv32_debug_fifo
// Parameter description
#(
	WIDTH      = 32,
	RESET_SYNC_WR_2_RD = 0
)
// Port description
(
	input wire logic clk_wr,
	input wire logic rst_wr,
	input wire logic valid_wr,
	input wire logic [WIDTH-1:0] data_wr,
	output logic 	 ready_wr,
	
	input wire logic clk_rd,
	input wire logic rst_rd,
	input wire logic ready_rd,
	output logic     valid_rd,
	output logic 	 [WIDTH-1:0] data_rd

);

//For now FIFO's depth will be fixed
localparam DEPTH = 1;
//localparam DEPTH = 2;

//Reset signals//
logic wr_reset;
logic rd_reset;
logic [1:0] rst_synch_reg;

logic [WIDTH-1:0] fifo_memory [0:((1<<DEPTH)-1)]; /* synthesis syn_ramstyle = "registers" */; 

//Write and read addresses//
logic [DEPTH-1:0] wr_addr, rd_addr;

//Write and read address pointers
logic [DEPTH:0] wr_ptr, rd_ptr;
logic [DEPTH:0] wr_ptr_next, rd_ptr_next;

//The gray pointers require more depth
logic [DEPTH:0] wr_gray_ptr, rd_gray_ptr;
logic [DEPTH:0] wr_gray_ptr_next, rd_gray_ptr_next;

logic [DEPTH:0] rd_gray_ptr_in_write;
logic [DEPTH:0] wr_gray_ptr_in_read;

logic [DEPTH:0] wr_gray_ptr_synch, rd_gray_ptr_synch;


// Control signals
logic write_en;
logic read_en;
logic empty_rd;	
logic full_wr;

assign ready_wr = ~full_wr;	//FIFO is ready to write data if it's not full
assign valid_rd = ~empty_rd;//FIFO valid read if it's not empty
assign write_en = (valid_wr && ready_wr); //FIFO's write enable signal
assign read_en = (valid_rd && ready_rd);  //FIFO's read enable signal

assign wr_ptr_next = wr_ptr + { {(DEPTH){1'b0}}, write_en };
assign rd_ptr_next = rd_ptr + { {(DEPTH){1'b0}}, read_en };

assign wr_gray_ptr_next = (wr_ptr_next >> 1) ^ wr_ptr_next;
assign rd_gray_ptr_next = (rd_ptr_next >> 1) ^ rd_ptr_next;


////////////////////////
// Reset Synchronizer //
////////////////////////

// Reset synchronizer to synchronize the reset from either the read domain to the 
// write domain or from the write domain to the read domain based on the
// RESET_SYNC_WR_2_RD parameter. Synchronized reset will be asynchronously
// asserted and synchronously deasserted.

generate
	if (RESET_SYNC_WR_2_RD == 1)
		begin
			always_ff @ (posedge clk_rd or negedge rst_wr)
				begin
					if(!rst_wr)
						rst_synch_reg <= 2'b00;
					else
						rst_synch_reg <= {1'b1, rst_synch_reg[1]};
				end
					
			always_comb
				begin
					wr_reset = rst_wr;
					rd_reset = rst_rd | rst_synch_reg[0];
				end
		end
	else
		begin
			always_ff @ (posedge clk_wr or negedge rst_rd)
				begin
					if(!rst_rd)
						rst_synch_reg <= 2'b00;
					else
						rst_synch_reg <= {1'b1, rst_synch_reg[1]};
				end
					
			always_comb
				begin
					wr_reset = rst_wr | rst_synch_reg[0];
					rd_reset = rst_rd;
				end
		end
endgenerate


////////////////////////
// Pointers and Bins  //
////////////////////////

always @ (posedge clk_wr or negedge wr_reset)
	if(!wr_reset)
		{wr_ptr, wr_gray_ptr} <= 0;	//both write pointers are set to 0
	else	//write and write gray pointers are updated by corresponding next pointers
		{wr_ptr, wr_gray_ptr} <= {wr_ptr_next, wr_gray_ptr_next}; 
		
always @ (posedge clk_rd or negedge rd_reset)
	if(!rd_reset)
		{rd_ptr, rd_gray_ptr} <= 0;	//both read pointers are set to 0
	else	//read and read gray pointer are updated by corresponding next pointers
		{rd_ptr, rd_gray_ptr} <= {rd_ptr_next, rd_gray_ptr_next};
		
		
assign wr_addr = wr_ptr[DEPTH-1:0];	//Write and Read pointers will reach inaccessible addresses
assign rd_addr = rd_ptr[DEPTH-1:0]; //and overflow. These serve to only navigate to existing addresses.
		
		
//Read Gray Pointer in Write Domain - required to check if the AFIFO is full
always @ (posedge clk_wr or negedge wr_reset)
	if(!wr_reset)
		{rd_gray_ptr_in_write, rd_gray_ptr_synch} <= 0;
	else	//Read Gray Pointer is synchronized over two clk_wr ticks
		{rd_gray_ptr_in_write, rd_gray_ptr_synch} <= {rd_gray_ptr_synch, rd_gray_ptr};
		
		
//Write Gray Pointer in Read Domain - required to check if the AFIFO is empty
always @ (posedge clk_rd or negedge rd_reset)
	if(!rd_reset)
		{wr_gray_ptr_in_read, wr_gray_ptr_synch} <= 0;
	else	//Write Gray Pointer is synchronized over two clk_rd ticks
		{wr_gray_ptr_in_read, wr_gray_ptr_synch} <= {wr_gray_ptr_synch, wr_gray_ptr};


//////////////////////
// FIFO's Status    //
//////////////////////

//Deriving logic for when the FIFO should be empty. The signal is next as it will be used with a clock
assign empty_rd  = (~rd_reset) ? 1'b0 : (rd_gray_ptr == wr_gray_ptr_synch);

//Comparing the gray write pointers, predicting whether gray coded overflow will occur on next clock edge
//which will then signify that FIFO is full. This is depth dependent and different depth requires different overflow logic.

//To use a 4 DEPTH AFIFO - use the logic found below for 'full_next' and change the DEPTH parameter to 2.
//assign full_wr = (~wr_reset) ? 1'b1 : (wr_gray_ptr == {~rd_gray_ptr_in_write[DEPTH:DEPTH-1], rd_gray_ptr_in_write[DEPTH-2:0]});

//To use a 2 DEPTH AFIFO - use the logic found below for 'full_wr' and change the DEPTH parameter to 1.
assign full_wr = (~wr_reset) ? 1'b1 : (wr_gray_ptr == {~rd_gray_ptr_in_write[DEPTH:DEPTH], rd_gray_ptr_in_write[DEPTH-1:0]});


//////////////////////
// FIFO's Memory    //
//////////////////////

always @ (posedge clk_wr)
		if (write_en)	//Write enable is not asserted in reset. When valid write and valid read make up write en
			fifo_memory[wr_addr] <= data_wr;
			
assign data_rd = valid_rd ? fifo_memory[rd_addr] : 'b0; //read fifo's memory on valid read


///////////////////
// AFIFO End     //
///////////////////

endmodule // miv_rv32_debug_fifo
`default_nettype wire
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
// SVN $Revision: 41986 $
// SVN $Date: 2023-02-08 22:00:53 +0000 (Wed, 08 Feb 2023) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File:
//   miv_rv32_debug_jtag_dtm.v
//
//   Purpose:
//    MIV_RV32 debug transport module (JTAG)
//    Contains :
//      - MIV_RV32 JTAG and DM FIFO interfaces
//      - REG_BYPASS
//      - REG_IDCODE 
//      - REG_DTMCS 
//      - REG_DMI_ACCESS
//
//   Author: 
//
//   Version: 1.9 
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
`default_nettype none

import miv_rv32_subsys_pkg::*;

module miv_rv32_debug_dtm_jtag #( parameter l_subsys_cfg_hart_debug = 1) (
   input wire                                   tck,
   input wire                                   trst,
   input wire                                   tms,
   input wire                                   tdi,
   
   output logic                                 tdo,
   output logic                                 dr_tdo,

   output logic                                 fifo_reset,
   
   output    logic                              dtm_req_valid,
   input wire                                   dtm_req_ready,
   output    logic   [DMI_REQ_DATA_WIDTH-1:0]   dtm_req_data,
   
   input wire                                   dtm_resp_valid,
   output    logic                              dtm_resp_ready,
   input wire        [DMI_RESP_DATA_WIDTH-1:0]  dtm_resp_data                                                                                      
   
);

////////////////////////////////////////////////////////////////////////////////
// Parameters
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
// Port directions
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
// Internal signal declarations
////////////////////////////////////////////////////////////////////////////////

logic     [3:0]                 currTapState;
logic     [3:0]                 nextTapState;
logic                           irShift;
logic                           drShift;
logic                           irCapture;
logic                           drCapture;
logic                           irUpdate;
logic                           drUpdate;
logic                           shiftBP;
logic     [IR_REG_WIDTH-1:0]    shiftIR;
logic     [DR_REG_WIDTH-1:0]    shiftDR;
logic     [DMI_REG_WIDTH-1:0]   shiftDMI;

logic     [IR_REG_WIDTH-1:0]    irReg;

logic                           shiftBP_ne_0; 
logic                           shiftIR_ne_0;
logic                           shiftDR_ne_0 ;
logic                           shiftDMI_ne_0;

logic                           dtmcs_dmihardreset;
logic                           dtmcs_dmireset;
logic   [1:0]                   dtmcs_dmistat;


////////////////////////////////////////////////////////////////////////////////
// TAP Control FSM
////////////////////////////////////////////////////////////////////////////////
// Current state register
generate if (l_subsys_cfg_hart_debug)
    begin: gen_current_state_register_active_high
    if (ACTIVE_HIGH_RESET == 1)
        begin
            always_ff @ (posedge tck or posedge trst)
                begin
                    if (trst | dtmcs_dmihardreset)
                        begin
                            currTapState <= TEST_LOGIC_RESET;
                        end
                    else
                        begin
                            currTapState <= nextTapState;
                        end
                end
        end
    else
        begin: gen_current_state_register_active_low
            always_ff @ (posedge tck or negedge trst)
                begin
                    if (!trst | dtmcs_dmihardreset)
                        begin
                            currTapState <= TEST_LOGIC_RESET;
                        end
                    else
                        begin
                            currTapState <= nextTapState;
                        end
                end
        end
   end     
endgenerate

// Combinatorial outputs
//assign tlReset   = (currTapState == TEST_LOGIC_RESET) ? 1'b1 : 1'b0;
assign drCapture = (currTapState == CAPTURE_DR)       ? 1'b1 : 1'b0;
assign drShift   = (currTapState == SHIFT_DR)         ? 1'b1 : 1'b0;
assign drUpdate  = (currTapState == UPDATE_DR)        ? 1'b1 : 1'b0;
assign irCapture = (currTapState == CAPTURE_IR)       ? 1'b1 : 1'b0;
assign irShift   = (currTapState == SHIFT_IR)         ? 1'b1 : 1'b0;
assign irUpdate  = (currTapState == UPDATE_IR)        ? 1'b1 : 1'b0;

// Next state combinatorial logic
always_comb
    begin
        case (currTapState)
            TEST_LOGIC_RESET: nextTapState = (!tms) ? RUN_TEST_IDLE    : currTapState;
            RUN_TEST_IDLE:    nextTapState = (tms)  ? SELECT_DR        : currTapState;
            SELECT_DR:        nextTapState = (!tms) ? CAPTURE_DR       : SELECT_IR;
            CAPTURE_DR:       nextTapState = (tms)  ? EXIT1_DR         : SHIFT_DR;
            SHIFT_DR:         nextTapState = (tms)  ? EXIT1_DR         : currTapState;
            EXIT1_DR:         nextTapState = (tms)  ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR:         nextTapState = (tms)  ? EXIT2_DR         : currTapState;
            EXIT2_DR:         nextTapState = (tms)  ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR:        nextTapState = (tms)  ? SELECT_DR        : RUN_TEST_IDLE;
            SELECT_IR:        nextTapState = (tms)  ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR:       nextTapState = (tms)  ? EXIT1_IR         : SHIFT_IR;
            SHIFT_IR:         nextTapState = (tms)  ? EXIT1_IR         : currTapState;
            EXIT1_IR:         nextTapState = (!tms) ? PAUSE_IR         : UPDATE_IR;
            PAUSE_IR:         nextTapState = (tms)  ? EXIT2_IR         : currTapState;
            EXIT2_IR:         nextTapState = (tms)  ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR:        nextTapState = (tms)  ? SELECT_DR        : RUN_TEST_IDLE;
        endcase
    end


////////////////////////////////////////////////////////////////////////////////
// Shift register
////////////////////////////////////////////////////////////////////////////////
generate if (l_subsys_cfg_hart_debug)
   begin: gen_shift_register_active_high
    if (ACTIVE_HIGH_RESET == 1)
        begin
            always_ff @ (posedge tck or posedge trst)
                begin
                    if (trst | dtmcs_dmihardreset)
                        begin
                            shiftBP  <= 1'b0;
                            shiftIR  <= {IR_REG_WIDTH{1'b0}};
                            shiftDR  <= {DR_REG_WIDTH{1'b0}};
                            shiftDMI <={DMI_REG_WIDTH{1'b0}};
                            dtmcs_dmistat   <= 2'b0;
                            fifo_reset      <= 1'b1;
							dtm_resp_ready  <= 1'b0; 
                        end
                    else
                        begin
							dtm_resp_ready          <= 1'b0; //defaults
					        fifo_reset              <= 1'b0; //defaults
							
							if (dtmcs_dmireset)
								begin
								dtmcs_dmistat <= 2'b0;
								fifo_reset    <= 1'b1;
							end
						
                            else if (irCapture)
                                begin
                                    shiftIR <= REG_IDCODE;
                                end
                            else if (drCapture)
                                begin
                                  case(irReg)
                                    REG_BYPASS      : shiftBP <= shiftBP;
                                    REG_IDCODE      : shiftDR <= ID_CODE;
                                    REG_DTMCS       : shiftDR <= {DTMCS_RESERVEDB,dtmcs_dmihardreset, dtmcs_dmireset, DTMCS_RESERVEDA, DTMCS_IDLE, dtmcs_dmistat, DTMCS_ABITS, DTMCS_VERSION};
                                    REG_DMI_ACCESS  : begin
                                                        shiftDMI <= dtm_resp_valid ? { 7'b0, dtm_resp_data [33:0]} : 41'b0;
                                                        dtm_resp_ready <= dtm_resp_valid ? 1'b1 : 1'b0;
                                                        if (dtmcs_dmistat == 2'b0) dtmcs_dmistat <=  dtm_resp_data [1:0]; 
                                                      end
                                    default         : shiftBP <= shiftBP; //Bypass
                                  endcase                                  
                                end
                            else if (irShift)
                                begin
                                    shiftIR <= {tdi, shiftIR[(IR_REG_WIDTH-1):1]};
                                end
                            else if (drShift)
                                begin
                                  case(irReg)  
                                    REG_BYPASS      :   shiftBP  <= tdi; 
                                    REG_IDCODE      :   shiftDR  <= {tdi, shiftDR[(DR_REG_WIDTH-1):1]};
                                    REG_DTMCS       :   shiftDR  <= {tdi, shiftDR[(DR_REG_WIDTH-1):1]};
                                    REG_DMI_ACCESS  :   shiftDMI <= {tdi, shiftDMI[(DMI_REG_WIDTH-1):1]};
                                    default         :   shiftBP  <= tdi;
                                  endcase
                                end
                            else
                                begin
                                    shiftIR  <= shiftIR;
                                    shiftBP  <= shiftBP;
                                    shiftDR  <= shiftDR;
                                    shiftDMI <= shiftDMI;
                                end
                        end
                end
        end
    else
        begin:gen_shift_register_active_low
            always_ff @ (posedge tck or negedge trst)
                begin
                    if (!trst | dtmcs_dmihardreset)
                        begin
                            shiftBP  <= 1'b0;
                            shiftIR  <= {IR_REG_WIDTH{1'b0}};
                            shiftDR  <= {DR_REG_WIDTH{1'b0}};
                            shiftDMI <={DMI_REG_WIDTH{1'b0}};
                            dtmcs_dmistat   <= 2'b0;
                            fifo_reset      <= 1'b1;
							dtm_resp_ready  <= 1'b0; 
                        end
                    else
                        begin
							dtm_resp_ready          <= 1'b0; //defaults
					        fifo_reset              <= 1'b0; //defaults
							
							if (dtmcs_dmireset)
								begin
								dtmcs_dmistat <= 2'b0;
								fifo_reset    <= 1'b1;
							end
						
                            else if (irCapture)
                                begin
                                    shiftIR <= REG_IDCODE;
                                end
                            else if (drCapture)
                                begin
                                  case(irReg)
                                    REG_BYPASS      :   shiftBP <= shiftBP;
                                    REG_IDCODE      :   shiftDR <= ID_CODE;
                                    REG_DTMCS       :   shiftDR <= {DTMCS_RESERVEDB, dtmcs_dmihardreset, dtmcs_dmireset, DTMCS_RESERVEDA, DTMCS_IDLE, dtmcs_dmistat, DTMCS_ABITS, DTMCS_VERSION};
                                    REG_DMI_ACCESS  :   begin
                                                            shiftDMI <= dtm_resp_valid ? { 7'b0, dtm_resp_data [33:0]} : 41'b0;
                                                            dtm_resp_ready <= dtm_resp_valid ? 1'b1 : 1'b0;
                                                            if (dtmcs_dmistat == 2'b0) dtmcs_dmistat <=  dtm_resp_data [1:0]; 
                                                        end
                                    default         :   shiftBP <= shiftBP; //Bypass
                                  endcase                                  
                                end

                            else if (irShift)
                                begin
                                    shiftIR <= {tdi, shiftIR[(IR_REG_WIDTH-1):1]};
                                end
                            else if (drShift)
                                begin
                                  case(irReg)  
                                    REG_BYPASS      :   shiftBP  <= tdi; 
                                    REG_IDCODE      :   shiftDR  <= {tdi, shiftDR[(DR_REG_WIDTH-1):1]};
                                    REG_DTMCS       :   shiftDR  <= {tdi, shiftDR[(DR_REG_WIDTH-1):1]};
                                    REG_DMI_ACCESS  :   shiftDMI <= {tdi, shiftDMI[(DMI_REG_WIDTH-1):1]};
                                    default         :   shiftBP  <= tdi;
                                  endcase 
                                end
                            else
                                begin
                                    shiftIR  <= shiftIR;
                                    shiftBP  <= shiftBP;
                                    shiftDR  <= shiftDR;
                                    shiftDMI <= shiftDMI;
                                end
                        end		
                end
        end
   end 
endgenerate



// *****************************************************************************
// Debug Module Interface (DMI)
// *****************************************************************************
generate if (l_subsys_cfg_hart_debug)
  begin: dmi_outputs_and_dtmcs_resets
    always_comb
      begin
        dtm_req_valid           = 1'b0;
        dtm_req_data            = 41'b0;
    
        if( drUpdate && irReg == REG_DMI_ACCESS) 
          begin    
            dtm_req_valid       = shiftDMI[ 1 : 0 ] != 2'b00; 
            dtm_req_data        = shiftDMI[ 40: 0 ];  
          end
      end

    if (ACTIVE_HIGH_RESET == 1)
      begin: dtmcs_resets_active_high
        always_ff @ (posedge tck or posedge trst)
          begin        
            if (trst | dtmcs_dmihardreset )
              begin
                dtmcs_dmihardreset  <= 1'b0;
                dtmcs_dmireset      <= 1'b0;
              end
            else
            if( drUpdate && irReg == REG_DTMCS) 
              begin
                dtmcs_dmihardreset     <= dtmcs_dmihardreset ? 1'b0 : shiftDR[17];
                dtmcs_dmireset         <= dtmcs_dmireset ? 1'b0 : shiftDR[16];
              end
          end
      end
    else
      begin: dtmcs_resets_active_low
        always_ff @ (posedge tck or negedge trst)
          begin        
            if (!trst | dtmcs_dmihardreset )
              begin
                dtmcs_dmihardreset        <= 1'b0;
                dtmcs_dmireset <= 1'b0;
              end
            else
            if( drUpdate && irReg == REG_DTMCS) 
              begin
                dtmcs_dmihardreset     <= dtmcs_dmihardreset ? 1'b0 : shiftDR[17];
                dtmcs_dmireset         <= dtmcs_dmireset ? 1'b0 : shiftDR[16];
              end
          end
      end
    end
endgenerate


generate if (l_subsys_cfg_hart_debug)
  begin
  
	always_comb 
	  begin : tdo_mux
	    if (drShift)
		  case (irReg)
			REG_BYPASS: 	tdo = shiftBP_ne_0;
			REG_IDCODE: 	tdo = shiftDR_ne_0;
			REG_DTMCS:  	tdo = shiftDR_ne_0;
			REG_DMI_ACCESS:	tdo = shiftDMI_ne_0;
			default:		tdo = shiftBP_ne_0;
		  endcase
		else if (irShift)
			tdo = shiftIR_ne_0;
		else
			tdo =  shiftBP_ne_0;
      end

   begin: shift_active_high
   if (ACTIVE_HIGH_RESET == 1)
     begin
       always_ff @ (negedge tck or posedge trst)
         begin
           if (trst | dtmcs_dmihardreset) begin
               shiftIR_ne_0  <= 1'b0;
               shiftDR_ne_0  <= 1'b0;
               shiftBP_ne_0  <= 1'b0;
               shiftDMI_ne_0 <= 1'b0;
               dr_tdo <= 1'b0;
           end else begin  
    
               shiftIR_ne_0 <= shiftIR[0];
               shiftDR_ne_0 <= shiftDR[0];
               shiftBP_ne_0 <= shiftBP;
               shiftDMI_ne_0 <=shiftDMI[0];
               
               if(irShift || drShift) begin
                   dr_tdo <= 1'b1;
               end else begin
                   dr_tdo <= 1'b0;
               end
           end
         end
     end
   else
     begin:shift_active_low
       always_ff @ (negedge tck or negedge trst)
          begin
            if (!trst | dtmcs_dmihardreset) begin
               shiftIR_ne_0  <= 1'b0;
               shiftDR_ne_0  <= 1'b0;
               shiftBP_ne_0  <= 1'b0;
               shiftDMI_ne_0 <= 1'b0;
               dr_tdo <= 1'b0;
            end 
          else 
            begin
           
               shiftIR_ne_0 <= shiftIR[0];
               shiftDR_ne_0 <= shiftDR[0];
               shiftBP_ne_0 <= shiftBP;
               shiftDMI_ne_0 <=shiftDMI[0];
               
               if(irShift || drShift) begin
                   dr_tdo <= 1'b1;
               end else begin
                   dr_tdo <= 1'b0;
               end
            end
         end
     end
    end
    end
endgenerate


////////////////////////////////////////////////////////////////////////////////
// IR & Instruction register
////////////////////////////////////////////////////////////////////////////////
generate if (l_subsys_cfg_hart_debug)
   begin : ir_and_Instruction_register
    if (ACTIVE_HIGH_RESET == 1)
        begin
            always_ff @ (negedge tck or posedge trst)        
                begin
                    if (trst | dtmcs_dmihardreset)
                        begin
                            irReg <= REG_IDCODE;
                        end
                    else
                        begin
                            if (irUpdate)
                                begin
                                    irReg <= shiftIR[IR_REG_WIDTH-1:0];
                                end
                            else
                                begin
                                    irReg <= irReg;
                                end
                        end
                end
        end
    else
        begin:gen_ir_and_Instruction_register_active_low
            always_ff @ (negedge tck or negedge trst)
                begin
                    if (!trst | dtmcs_dmihardreset)
                        begin
                            irReg <= REG_IDCODE;
                        end
                    else
                        begin 
                            if (irUpdate)
                                begin
                                    irReg <= shiftIR[IR_REG_WIDTH-1:0];                                                                                                            
                                end
                            else
                                begin
                                    irReg <= irReg;
                                end
                        end
                end
        end
   end
endgenerate

endmodule // MIV_DTM_JTAG
`default_nettype wire
