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
// v1.1 HW trigger local params uncommented
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//
//   File: core_pkg.sv
//
//   Purpose: core configuration package
//
//   Author: 
//
//   Version: 1.1
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none


package miv_rv32_hart_cfg_pkg;



//****************************************************************************
// Core Configuration
//****************************************************************************

//  localparam logic[31:0] l_core_mtvec_offset               = 32'h34;
  localparam logic l_core_cfg_archid_reg                   = 1'b0;
  localparam logic l_core_cfg_extension_state              = 1'b0;
  localparam logic l_core_cfg_fpu                          = 1'b0;
  localparam logic l_core_cfg_hartid_reg                   = 1'b0; 
  localparam logic l_core_cfg_hw_dp_fpu                    = 1'b0;
  localparam logic l_core_cfg_hw_sp_fpu                    = 1'b0;
  localparam logic l_core_cfg_impid_reg                    = 1'b0;
  localparam logic l_core_cfg_num_harts                    = 1'b0;
  localparam logic l_core_cfg_supervisor_mode              = 1'b0;
  localparam logic l_core_cfg_user_mode                    = 1'b0;
  localparam logic l_core_cfg_vendorid_reg                 = 32'h29;
//  localparam logic l_core_cfg_static_mtvec_base            = 1'b0;
//  localparam logic[31:0] l_core_static_mtvec_base          = 32'h6000_0000;
//  localparam logic l_core_cfg_static_mtvec_mode            = 1'b0;
//  localparam logic[1:0] l_core_static_mtvec_mode           = 2'b00;
  localparam l_core_cfg_num_pmp                            = 0;
  localparam l_core_cfg_cycle_count_width                  = 0;
//  localparam l_core_cfg_time_count_width                   = 0;
  localparam l_core_cfg_instret_count_width                = 0;
  localparam l_core_cfg_num_hpm_counters                   = 0;
  localparam l_core_cfg_hpm_count_width                    = 0;
  localparam l_core_cfg_hpm_event_sel_width                = 0;
  localparam logic l_core_cfg_hw_atomics                   = 1'b0;
//  localparam logic l_core_cfg_hw_compressed                = 1'b1;
  localparam logic l_core_cfg_hw_economy                   = 1'b0;
  localparam logic l_core_cfg_hw_float                     = 1'b1;
  localparam logic l_core_cfg_hw_integer                   = 1'b1;
//  localparam logic l_core_cfg_hw_multiply_divide           = 1'b1;
  localparam logic l_core_cfg_hw_multiply                  = 1'b1;
//  localparam logic l_core_cfg_hw_macc_multiplier           = 1'b1;
  localparam logic l_core_cfg_hw_divide                    = 1'b1;
  localparam logic l_core_cfg_mscratch                     = 1'b1;
  localparam logic l_core_cfg_user_mode_traps              = 1'b0;
  localparam logic l_cfg_core_trigger_both                 = 1'b0;
  
  //localparam logic l_core_cfg_hw_debug                     = 1'b1;
  //localparam l_core_cfg_num_triggers                       = 2;
  //localparam l_core_cfg_trigger_bus_width                  = (l_core_cfg_num_triggers > 0) ? l_core_cfg_num_triggers : 1;
  localparam l_core_cfg_trigger_select_width               = 1;
  localparam logic l_core_cfg_debug_reg_ctrl_pipeline      = 1'b1;
  
  localparam logic l_core_cfg_irq_ext_capture              = 1'b1;
  localparam logic l_core_cfg_irq_sw_capture               = 1'b1;
//  localparam logic l_core_cfg_lsu_fwd                      = 1'b0;
//  localparam logic l_core_cfg_csr_fwd                      = 1'b1;
//  localparam logic l_core_cfg_exu_fwd                      = 1'b1;
  localparam logic l_core_cfg_gpr_rd_ex                    = 1'b1;
  localparam logic l_core_cfg_spec_load                    = 1'b0;
  localparam logic l_core_cfg_formal_dbg_if                = 1'b0;
//  localparam logic l_core_cfg_gpr_type                     = 0; // 0 = RAM, 1 = Fabric
  
//  localparam logic[31:0] l_core_reset_vector                 = 32'h6000_0000;
  localparam logic[4:0]  l_core_mcause_code_reset_state      = 5'h0;
  localparam logic       l_core_mcause_interrupt_reset_state = 1'b0;
  localparam logic[31:0] l_core_marchid                      = 32'h0000_0000; // OS ID's allocated by RISCV Foundation
  localparam logic[31:0] l_core_mimpid                       = 32'hE501_0302; // Core E501, Ver 3.1.200
  localparam logic[31:0] l_core_vendorid                     = 32'h0000_0029; // Microchip
  
//  localparam       l_core_num_sys_ext_irqs                 = 0; // max 8
  //localparam logic l_core_cfg_gpr_ecc_uncorrectable_irq    = 1'b0;
  //localparam logic l_core_cfg_gpr_ecc_correctable_irq      = 1'b0;
  localparam logic l_core_cfg_instret_count_irq            = 1'b0;
  localparam logic l_core_cfg_cycle_count_irq              = 1'b0;
  localparam logic l_core_cfg_hpm_count_irq                = 1'b0;  
  localparam logic l_core_cfg_i_bus_error_excpt            = 1'b1;
  localparam logic l_core_cfg_i_parity_error_excpt         = 1'b1;
  localparam logic l_core_cfg_d_bus_error_excpt            = 1'b1;
  localparam logic l_core_cfg_d_parity_error_excpt         = 1'b1;
  
  // l_core_pulp_divsqrt = 0 enables T-head-based DivSqrt unit. Supported only for FP32-only instances of Fpnew
  localparam logic l_core_pulp_divsqrt                     = 1'b0;
  
  localparam MEM_SECURITY_REGIONS         = 1;
  localparam LOG2_MEM_SECURITY_REGIONS    = 1;

  localparam MEM_REGIONS                  = 1;
  localparam LOG2_MEM_REGIONS             = 1;


   
                
 
endpackage


`default_nettype wire
