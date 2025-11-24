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
//   File: core_pkg.sv
//
//   Purpose: core shared package
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

`ifdef core_MACROS
`else
  `define core_MACROS 1
  `define core_MACRO_MAX(a,b) (a)>(b)?(a):(b)
`endif

package miv_rv32_pkg;

//------------------
// Global definitions
//------------------

  localparam L_XLEN = 32;

//------------------
// Instruction list
//------------------



//----------------
// Register file
//----------------

          
 
//----------------
// CSR
//----------------   

  localparam logic [1:0] l_core_mode_machine     = 2'd3;   
  localparam logic [1:0] l_core_mode_supervisor  = 2'd1;
  localparam logic [1:0] l_core_mode_user        = 2'd0;                      
                                       
//****************************************************************************
// csr address literals
//**************************************************************************** 
  
  localparam logic [1:0] l_mtvec_mode_direct = 2'd0;
  localparam logic [1:0] l_mtvec_mode_vectored = 2'd1;
  
//Machine Information Registers  
  localparam logic [11:0] l_core_csr_addr_mvendorid      =   12'hF11;   // Vendor ID.
  localparam logic [11:0] l_core_csr_addr_marchid        =   12'hF12;   // Architecture ID.
  localparam logic [11:0] l_core_csr_addr_mimpid         =   12'hF13;   // Implementation ID.
  localparam logic [11:0] l_core_csr_addr_mhartid        =   12'hF14;   // Hardware thread ID.
//Machine Trap Setup
  localparam logic [11:0] l_core_csr_addr_mstatus        =   12'h300;   // Machine status register.
  localparam logic [11:0] l_core_csr_addr_misa           =   12'h301;   // ISA and extensions
  localparam logic [11:0] l_core_csr_addr_medeleg        =   12'h302;   // Machine exception delegation register.
  localparam logic [11:0] l_core_csr_addr_mideleg        =   12'h303;   // Machine interrupt delegation register.
  localparam logic [11:0] l_core_csr_addr_mie            =   12'h304;   // Machine interrupt-enable register.
  localparam logic [11:0] l_core_csr_addr_mtvec          =   12'h305;   // Machine trap-handler base address.
  localparam logic [11:0] l_core_csr_addr_mcounteren     =   12'h306;   // Machine counter enable.
//Machine Trap Handling
  localparam logic [11:0] l_core_csr_addr_mscratch       =   12'h340;   // Scratch register for machine trap handlers.
  localparam logic [11:0] l_core_csr_addr_mepc           =   12'h341;   // Machine exception program counter.
  localparam logic [11:0] l_core_csr_addr_mcause         =   12'h342;   // mcause Machine trap cause.
  localparam logic [11:0] l_core_csr_addr_mtval          =   12'h343;   // mtval Machine bad address or instruction.
  localparam logic [11:0] l_core_csr_addr_mip            =   12'h344;   // mip Machine interrupt pending.
//Machine Protection and Translation
  localparam logic [11:0] l_core_csr_addr_pmpcfg0        =   12'h3A0;   // pmpcfg0 Physical memory protection configuration.
  localparam logic [11:0] l_core_csr_addr_pmpcfg1        =   12'h3A1;   // pmpcfg1 Physical memory protection configuration.
  localparam logic [11:0] l_core_csr_addr_pmpcfg2        =   12'h3A2;   // pmpcfg2 Physical memory protection configuration.
  localparam logic [11:0] l_core_csr_addr_pmpcfg3        =   12'h3A3;   // pmpcfg3 Physical memory protection configuration.
  localparam logic [11:0] l_core_csr_addr_pmpaddr0       =   12'h3B0;   // Physical memory protection address register 0.
  localparam logic [11:0] l_core_csr_addr_pmpaddr1       =   12'h3B1;   // Physical memory protection address register 1.
  localparam logic [11:0] l_core_csr_addr_pmpaddr2       =   12'h3B2;   // Physical memory protection address register 2.
  localparam logic [11:0] l_core_csr_addr_pmpaddr3       =   12'h3B3;   // Physical memory protection address register 3.
  localparam logic [11:0] l_core_csr_addr_pmpaddr4       =   12'h3B4;   // Physical memory protection address register 4.
  localparam logic [11:0] l_core_csr_addr_pmpaddr5       =   12'h3B5;   // Physical memory protection address register 5.
  localparam logic [11:0] l_core_csr_addr_pmpaddr6       =   12'h3B6;   // Physical memory protection address register 6.
  localparam logic [11:0] l_core_csr_addr_pmpaddr7       =   12'h3B7;   // Physical memory protection address register 7.
  localparam logic [11:0] l_core_csr_addr_pmpaddr8       =   12'h3B8;   // Physical memory protection address register 8.
  localparam logic [11:0] l_core_csr_addr_pmpaddr9       =   12'h3B9;   // Physical memory protection address register 9.
  localparam logic [11:0] l_core_csr_addr_pmpaddr10      =   12'h3BA;   // Physical memory protection address register 10.
  localparam logic [11:0] l_core_csr_addr_pmpaddr11      =   12'h3BB;   // Physical memory protection address register 11.
  localparam logic [11:0] l_core_csr_addr_pmpaddr12      =   12'h3BC;   // Physical memory protection address register 12.
  localparam logic [11:0] l_core_csr_addr_pmpaddr13      =   12'h3BD;   // Physical memory protection address register 13.
  localparam logic [11:0] l_core_csr_addr_pmpaddr14      =   12'h3BE;   // Physical memory protection address register 14.
  localparam logic [11:0] l_core_csr_addr_pmpaddr15      =   12'h3BF;   // Physical memory protection address register 15.
//Machine Counter/Timers
  localparam logic [11:0] l_core_csr_addr_mcycle         =   12'hB00;   // Machine cycle counter.
  localparam logic [11:0] l_core_csr_addr_minstret       =   12'hB02;   // Machine instructions-retired counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter3   =   12'hB03;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter4   =   12'hB04;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter5   =   12'hB05;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter6   =   12'hB06;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter7   =   12'hB07;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter8   =   12'hB08;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter9   =   12'hB09;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter10  =   12'hB0A;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter11  =   12'hB0B;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter12  =   12'hB0C;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter13  =   12'hB0D;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter14  =   12'hB0E;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter15  =   12'hB0F;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter16  =   12'hB10;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter17  =   12'hB11;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter18  =   12'hB12;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter19  =   12'hB13;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter20  =   12'hB14;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter21  =   12'hB15;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter22  =   12'hB16;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter23  =   12'hB17;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter24  =   12'hB18;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter25  =   12'hB19;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter26  =   12'hB1A;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter27  =   12'hB1B;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter28  =   12'hB1C;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter29  =   12'hB1D;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter30  =   12'hB1E;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mhpmcounter31  =   12'hB1F;   // Machine performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_mcycleh        =   12'hB80;   // Upper 32 bits of mcycle, RV32I only.
  localparam logic [11:0] l_core_csr_addr_minstreth      =   12'hB82;   // Upper 32 bits of minstret, RV32I only.  
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh3  =   12'hB83;   // Upper 32 bits of mhpmcounter3 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh4  =   12'hB84;   // Upper 32 bits of mhpmcounter4 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh5  =   12'hB85;   // Upper 32 bits of mhpmcounter5 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh6  =   12'hB86;   // Upper 32 bits of mhpmcounter6 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh7  =   12'hB87;   // Upper 32 bits of mhpmcounter7 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh8  =   12'hB88;   // Upper 32 bits of mhpmcounter8 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh9  =   12'hB89;   // Upper 32 bits of mhpmcounter9 
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh10 =   12'hB8A;   // Upper 32 bits of mhpmcounter10
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh11 =   12'hB8B;   // Upper 32 bits of mhpmcounter11
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh12 =   12'hB8C;   // Upper 32 bits of mhpmcounter12
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh13 =   12'hB8D;   // Upper 32 bits of mhpmcounter13
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh14 =   12'hB8E;   // Upper 32 bits of mhpmcounter14
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh15 =   12'hB8F;   // Upper 32 bits of mhpmcounter15
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh16 =   12'hB90;   // Upper 32 bits of mhpmcounter16
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh17 =   12'hB91;   // Upper 32 bits of mhpmcounter17
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh18 =   12'hB92;   // Upper 32 bits of mhpmcounter18
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh19 =   12'hB93;   // Upper 32 bits of mhpmcounter19
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh20 =   12'hB94;   // Upper 32 bits of mhpmcounter20
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh21 =   12'hB95;   // Upper 32 bits of mhpmcounter21
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh22 =   12'hB96;   // Upper 32 bits of mhpmcounter22
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh23 =   12'hB97;   // Upper 32 bits of mhpmcounter23
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh24 =   12'hB98;   // Upper 32 bits of mhpmcounter24
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh25 =   12'hB99;   // Upper 32 bits of mhpmcounter25
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh26 =   12'hB9A;   // Upper 32 bits of mhpmcounter26
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh27 =   12'hB9B;   // Upper 32 bits of mhpmcounter27
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh28 =   12'hB9C;   // Upper 32 bits of mhpmcounter28
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh29 =   12'hB9D;   // Upper 32 bits of mhpmcounter29
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh30 =   12'hB9E;   // Upper 32 bits of mhpmcounter30
  localparam logic [11:0] l_core_csr_addr_mhpmcounterh31 =   12'hB9F;   // Upper 32 bits of mhpmcounter31
//Machine Counter Setup
  localparam logic [11:0] l_core_csr_addr_mcounterinhibit =   12'h320;   // Machine counter-inhibit register.
  localparam logic [11:0] l_core_csr_addr_mhpmevent3     =   12'h323;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent4     =   12'h324;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent5     =   12'h325;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent6     =   12'h326;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent7     =   12'h327;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent8     =   12'h328;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent9     =   12'h329;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent10    =   12'h32A;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent11    =   12'h32B;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent12    =   12'h32C;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent13    =   12'h32D;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent14    =   12'h32E;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent15    =   12'h32F;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent16    =   12'h330;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent17    =   12'h331;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent18    =   12'h332;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent19    =   12'h333;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent20    =   12'h334;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent21    =   12'h335;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent22    =   12'h336;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent23    =   12'h337;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent24    =   12'h338;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent25    =   12'h339;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent26    =   12'h33A;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent27    =   12'h33B;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent28    =   12'h33C;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent29    =   12'h33D;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent30    =   12'h33E;   // Machine performance-monitoring event selector.
  localparam logic [11:0] l_core_csr_addr_mhpmevent31    =   12'h33F;   // Machine performance-monitoring event selector
  
//Supervisor Trap Setup
  localparam logic [11:0] l_core_csr_addr_sstatus        =   12'h100;   // Supervisor status register. 
  localparam logic [11:0] l_core_csr_addr_sedeleg        =   12'h102;   // Supervisor exception delegation register..
  localparam logic [11:0] l_core_csr_addr_sideleg        =   12'h103;   // Supervisor interrupt delegation register.
  localparam logic [11:0] l_core_csr_addr_sie            =   12'h104;   // Supervisor interrupt-enable register.
  localparam logic [11:0] l_core_csr_addr_stvec          =   12'h105;   // Supervisor trap handler base address.
  localparam logic [11:0] l_core_csr_addr_scounteren     =   12'h106;   // Supervisor counter enable.
//Supervisor Trap Handling
  localparam logic [11:0] l_core_csr_addr_sscratch       =   12'h140;   // Scratch register for supervisor trap handlers.
  localparam logic [11:0] l_core_csr_addr_sepc           =   12'h141;   // Supervisor exception program counter.
  localparam logic [11:0] l_core_csr_addr_scause         =   12'h142;   // Supervisor trap cause.
  localparam logic [11:0] l_core_csr_addr_stval          =   12'h143;   // Supervisor bad address or instruction.
  localparam logic [11:0] l_core_csr_addr_sip            =   12'h144;   // Supervisor interrupt pending.
//Supervisor Protection and Translation
  localparam logic [11:0] l_core_csr_addr_satp           =   12'h180;   // Supervisor address translation and protection.
  
  
//User Trap Setup
  localparam logic [11:0] l_core_csr_addr_ustatus        =   12'h000;   // User status register.
  localparam logic [11:0] l_core_csr_addr_uie            =   12'h004;   // User interrupt-enable register.
  localparam logic [11:0] l_core_csr_addr_utvec          =   12'h005;   // utvec User trap handler base address.
//User Trap Handling
  localparam logic [11:0] l_core_csr_addr_uscratch       =   12'h040;   // Scratch register for user trap handlers.
  localparam logic [11:0] l_core_csr_addr_uepc           =   12'h041;   // User exception program counter.
  localparam logic [11:0] l_core_csr_addr_ucause         =   12'h042;   // User trap cause.
  localparam logic [11:0] l_core_csr_addr_utval          =   12'h043;   // User bad address or instruction.
  localparam logic [11:0] l_core_csr_addr_uip            =   12'h044;   // User interrupt pending.
//User Floating-Point CSRs
  localparam logic [11:0] l_core_csr_addr_fflags         =   12'h001;   // Floating-Point Accrued Exceptions.
  localparam logic [11:0] l_core_csr_addr_frm            =   12'h002;   // Floating-Point Dynamic Rounding Mode.
  localparam logic [11:0] l_core_csr_addr_fcsr           =   12'h003;   // Floating-Point Control and Status Register (frm + fflags).
//User Counter/Timers
  localparam logic [11:0] l_core_csr_addr_cycle          =   12'hC00;   // Cycle counter for RDCYCLE instruction.
  localparam logic [11:0] l_core_csr_addr_time           =   12'hC01;   // Timer for RDTIME instruction.
  localparam logic [11:0] l_core_csr_addr_instret        =   12'hC02;   // Instructions-retired counter for RDINSTRET instruction.
  localparam logic [11:0] l_core_csr_addr_hpmcounter3    =   12'hC03;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter4    =   12'hC04;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter5    =   12'hC05;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter6    =   12'hC06;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter7    =   12'hC07;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter8    =   12'hC08;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter9    =   12'hC09;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter10   =   12'hC0A;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter11   =   12'hC0B;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter12   =   12'hC0C;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter13   =   12'hC0D;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter14   =   12'hC0E;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter15   =   12'hC0F;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter16   =   12'hC10;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter17   =   12'hC11;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter18   =   12'hC12;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter19   =   12'hC13;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter20   =   12'hC14;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter21   =   12'hC15;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter22   =   12'hC16;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter23   =   12'hC17;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter24   =   12'hC18;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter25   =   12'hC19;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter26   =   12'hC1A;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter27   =   12'hC1B;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter28   =   12'hC1C;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter29   =   12'hC1D;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter30   =   12'hC1E;   // performance-monitoring counter.
  localparam logic [11:0] l_core_csr_addr_hpmcounter31   =   12'hC1F;   // performance-monitoring counter.

  localparam logic [11:0] l_core_csr_addr_cycleh         =   12'hC80;   // Upper 32 bits of cycle, RV32I only.
  localparam logic [11:0] l_core_csr_addr_timeh          =   12'hC81;   // Upper 32 bits of time, RV32I only.
  localparam logic [11:0] l_core_csr_addr_instreth       =   12'hC82;   // Upper 32 bits of instret, RV32I only.
  localparam logic [11:0] l_core_csr_addr_hpmcounterh3   =   12'hC83;   // Upper 32 bits of hpmcounter3 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh4   =   12'hC84;   // Upper 32 bits of hpmcounter4 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh5   =   12'hC85;   // Upper 32 bits of hpmcounter5 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh6   =   12'hC86;   // Upper 32 bits of hpmcounter6 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh7   =   12'hC87;   // Upper 32 bits of hpmcounter7 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh8   =   12'hC88;   // Upper 32 bits of hpmcounter8 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh9   =   12'hC89;   // Upper 32 bits of hpmcounter9 
  localparam logic [11:0] l_core_csr_addr_hpmcounterh10  =   12'hC8A;   // Upper 32 bits of hpmcounter10
  localparam logic [11:0] l_core_csr_addr_hpmcounterh11  =   12'hC8B;   // Upper 32 bits of hpmcounter11
  localparam logic [11:0] l_core_csr_addr_hpmcounterh12  =   12'hC8C;   // Upper 32 bits of hpmcounter12
  localparam logic [11:0] l_core_csr_addr_hpmcounterh13  =   12'hC8D;   // Upper 32 bits of hpmcounter13
  localparam logic [11:0] l_core_csr_addr_hpmcounterh14  =   12'hC8E;   // Upper 32 bits of hpmcounter14
  localparam logic [11:0] l_core_csr_addr_hpmcounterh15  =   12'hC8F;   // Upper 32 bits of hpmcounter15
  localparam logic [11:0] l_core_csr_addr_hpmcounterh16  =   12'hC90;   // Upper 32 bits of hpmcounter16
  localparam logic [11:0] l_core_csr_addr_hpmcounterh17  =   12'hC91;   // Upper 32 bits of hpmcounter17
  localparam logic [11:0] l_core_csr_addr_hpmcounterh18  =   12'hC92;   // Upper 32 bits of hpmcounter18
  localparam logic [11:0] l_core_csr_addr_hpmcounterh19  =   12'hC93;   // Upper 32 bits of hpmcounter19
  localparam logic [11:0] l_core_csr_addr_hpmcounterh20  =   12'hC94;   // Upper 32 bits of hpmcounter20
  localparam logic [11:0] l_core_csr_addr_hpmcounterh21  =   12'hC95;   // Upper 32 bits of hpmcounter21
  localparam logic [11:0] l_core_csr_addr_hpmcounterh22  =   12'hC96;   // Upper 32 bits of hpmcounter22
  localparam logic [11:0] l_core_csr_addr_hpmcounterh23  =   12'hC97;   // Upper 32 bits of hpmcounter23
  localparam logic [11:0] l_core_csr_addr_hpmcounterh24  =   12'hC98;   // Upper 32 bits of hpmcounter24
  localparam logic [11:0] l_core_csr_addr_hpmcounterh25  =   12'hC99;   // Upper 32 bits of hpmcounter25
  localparam logic [11:0] l_core_csr_addr_hpmcounterh26  =   12'hC9A;   // Upper 32 bits of hpmcounter26
  localparam logic [11:0] l_core_csr_addr_hpmcounterh27  =   12'hC9B;   // Upper 32 bits of hpmcounter27
  localparam logic [11:0] l_core_csr_addr_hpmcounterh28  =   12'hC9C;   // Upper 32 bits of hpmcounter28
  localparam logic [11:0] l_core_csr_addr_hpmcounterh29  =   12'hC9D;   // Upper 32 bits of hpmcounter29
  localparam logic [11:0] l_core_csr_addr_hpmcounterh30  =   12'hC9E;   // Upper 32 bits of hpmcounter30
  localparam logic [11:0] l_core_csr_addr_hpmcounterh31  =   12'hC9F;   // Upper 32 bits of hpmcounter31
  
  localparam logic [11:0] l_core_csr_addr_tselect        =   12'h7A0;   // Debug/Trace trigger register select.
  localparam logic [11:0] l_core_csr_addr_tdata1         =   12'h7A1;   // First Debug/Trace trigger data register.
  localparam logic [11:0] l_core_csr_addr_tdata2         =   12'h7A2;   // Second Debug/Trace trigger data register.
  localparam logic [11:0] l_core_csr_addr_tdata3         =   12'h7A3;   // Third Debug/Trace trigger data register.
  localparam logic [11:0] l_core_csr_addr_tcontrol       =   12'h7A5;   // Trigger control register register
  localparam logic [11:0] l_core_csr_addr_mcontext       =   12'h7A8;   // Trigger machine context register
  localparam logic [11:0] l_core_csr_addr_scontext       =   12'h7AA;   // Trigger supervisor context register
  
  localparam logic [11:0] l_core_csr_addr_dcsr           =   12'h7B0;   // Debug control and status register.
  localparam logic [11:0] l_core_csr_addr_dpc            =   12'h7B1;   // Debug PC
  localparam logic [11:0] l_core_csr_addr_dscratch0      =   12'h7B2;   // Debug scratch register 0
  localparam logic [11:0] l_core_csr_addr_dscratch1      =   12'h7B3;   // Debug scratch register 1


//----------------
// IFU
//----------------

  typedef enum logic       {iab_rd_alignment_word,
                            iab_rd_alignment_hword} t_iab_rd_alignment; 
  
//----------------
// EXU
//----------------


  typedef enum logic [1:0] {exu_op0_rs1,
                           exu_op0_pc,
                           exu_op0_lsu,
                           exu_op0_csr} t_exu_alu_operand0_sel;

  typedef enum logic [2:0] {exu_op1_rs2,
                           exu_op1_imm,
                           exu_op1_lit4,
                           exu_op1_lit2} t_exu_alu_operand1_sel;
						   
  typedef enum logic [2:0] {exu_op2_rs3} t_exu_alu_operand2_sel;
                           
  typedef enum logic [5:0] {exu_alu_op_none,                                             
                           exu_alu_op_add_op0_op1,                                       
                           exu_alu_op_sub_op0_op1,                                       
                           exu_alu_op_xor_op0_op1,                                       
                           exu_alu_op_or_op0_op1,                                        
                           exu_alu_op_and_op0_op1,                                       
                           exu_alu_op_multiply_signed_op0_signed_op1,                    
                           exu_alu_op_multiply_high_signed_op0_signed_op1,               
                           exu_alu_op_multiply_unsigned_op0_unsigned_op1,                
                           exu_alu_op_multiply_high_unsigned_op0_unsigned_op1,           
                           exu_alu_op_multiply_signed_op0_unsigned_op1,                  
                           exu_alu_op_multiply_high_signed_op0_unsigned_op1,             
                           exu_alu_op_divide_signed_op0_signed_op1,                      
                           exu_alu_op_divide_unsigned_op0_unsigned_op1,                  
                           exu_alu_op_remainder_signed_op0_signed_op1,                   
                           exu_alu_op_remainder_unsigned_op0_unsigned_op1,               
                           exu_cmp_op_compare_lt_unsigned_op0_unsigned_op1,              
                           exu_cmp_op_compare_lt_signed_op0_signed_op1,                  
                           exu_cmp_op_compare_gte_unsigned_op0_unsigned_op1,             
                           exu_cmp_op_compare_gte_signed_op0_signed_op1,                 
                           exu_cmp_op_compare_equal_signed_op0_signed_op1,               
                           exu_cmp_op_compare_equal_unsigned_op0_unsigned_op1,           
                           exu_cmp_op_compare_not_equal_signed_op0_signed_op1,           
                           exu_cmp_op_compare_not_equal_unsigned_op0_unsigned_op1,		
						   exu_alu_op_fmadd_op0_op1_op2,                                 
						   exu_alu_op_fmsub_op0_op1_op2,                                 
						   exu_alu_op_fnmadd_op0_op1_op2,                                
						   exu_alu_op_fnmsub_op0_op1_op2,                                
                           exu_alu_op_fadd_op0_op1,                                      
                           exu_alu_op_fsub_op0_op1,                                      
						   exu_alu_op_fmul_op0_op1,                                      
						   exu_alu_op_fdiv_op0_op1,                                      
						   exu_alu_op_fsqrt_op0_op1,                                     
						   exu_alu_op_fsgnj_op0_op1,                                     
						   exu_alu_op_fsgnjn_op0_op1,                                    
						   exu_alu_op_fsgnjx_op0_op1,                                    
						   exu_alu_op_fmin_op0_op1,                                      
						   exu_alu_op_fmax_op0_op1,                                      
						   exu_alu_op_fcvt_w_s_op0_op1,                                  
						   exu_alu_op_fcvt_wu_s_op0_op1,                                 
						   exu_alu_op_feq_op0_op1,                                       
						   exu_alu_op_flt_op0_op1,                                       
						   exu_alu_op_fle_op0_op1,                                       
						   exu_alu_op_fclass_s_op0_op1,                                  
						   exu_alu_op_fcvt_s_w_op0_op1,                                  
						   exu_alu_op_fcvt_s_wu_op0_op1                                 
						   } t_exu_alu_op_sel;                                                    
                                   
  typedef enum logic [1:0] {exu_shifter_op_none,               
                           exu_shifter_op_shift_left,  
                           exu_shifter_op_shift_right,      
                           exu_shifter_op_arithmetic_shift_right} t_exu_shifter_op_sel;
                           
  typedef enum logic [2:0] {shifter_places_operand_none,
                           shifter_places_operand_addr_byte,
                           shifter_places_operand_addr_hword,
                           shifter_places_operand_noshift,
                           shifter_places_operand_rs2,
                           shifter_places_operand_rs3,
                           shifter_places_operand_imm} t_exu_shifter_places_sel;
                           
  typedef enum logic [1:0] {shifter_operand_none,
                           shifter_operand_rs1,
                           shifter_operand_rs2,
                           shifter_operand_rs3}t_exu_shifter_operand_sel; 
                           
  typedef enum logic [3:0] {exu_alu_result_mux_none,
                           exu_alu_result_mux_cmp_lit,
                           exu_alu_result_mux_shifter,
                           exu_alu_result_mux_adder, 
                           exu_alu_result_mux_logical, 
                           exu_alu_result_mux_multiplier,
                           exu_alu_result_mux_divider, 
                           exu_alu_result_mux_acu,
                           exu_alu_result_mux_float }t_exu_alu_result_mux_sel;
                           
  typedef enum logic [2:0] {bcu_operand1_imm,
                           bcu_operand1_epc,
                           bcu_operand1_dpc,
                           bcu_operand1_exvec,
                           bcu_operand1_resetvec}t_exu_bcu_operand1_sel;    
                           
  typedef enum logic [1:0] {bcu_operand0_pc,
                           bcu_operand0_rs1,
                           bcu_operand0_trap_cause}t_exu_bcu_operand0_sel;  
                           
  typedef enum logic       {bcu_op_none,
                           bcu_op_add}t_exu_bcu_op_sel;                      
                           
  typedef struct {logic cmp_cond;} t_exu_flags;
  
  typedef enum logic [1:0] {csr_alu_wr_op_none,
                           csr_alu_wr_op_swap,
                           csr_alu_wr_op_set,
                           csr_alu_wr_op_clr} t_csr_alu_wr_op_sel;
                           
  typedef enum logic {csr_alu_rd_op_none,
                     csr_alu_rd_op_rd} t_csr_alu_rd_op_sel;
                     
typedef struct {    
  logic mvendorid_sw_rd_sel;
  logic marchid_sw_rd_sel;
  logic mimpid_sw_rd_sel;
  logic mhartid_sw_rd_sel;
  logic mstatus_sw_rd_sel;
  logic sstatus_sw_rd_sel;
  logic ustatus_sw_rd_sel;
  logic misa_sw_rd_sel;
  logic medeleg_sw_rd_sel;
  logic mideleg_sw_rd_sel;
  logic mie_sw_rd_sel;
  logic sie_sw_rd_sel;
  logic uie_sw_rd_sel;
  logic mip_sw_rd_sel;
  logic sip_sw_rd_sel; 
  logic uip_sw_rd_sel; 
  logic ip_sw_rd_sel; 
  logic mtvec_sw_rd_sel; 
  logic mepc_sw_rd_sel;
  logic mcause_sw_rd_sel;
  logic mtval_sw_rd_sel;
  logic mcounteren_sw_rd_sel;
  logic mcounterinhibit_sw_rd_sel;
  logic mscratch_sw_rd_sel;
  logic pmpcfg_0_3_sw_rd_sel;
  logic pmpaddr_0_15_sw_rd_sel;
  logic sedeleg_sw_rd_sel;
  logic sideleg_sw_rd_sel;
  logic stvec_sw_rd_sel;
  logic sepc_sw_rd_sel;
  logic scause_sw_rd_sel;
  logic stval_sw_rd_sel;
  logic scounteren_sw_rd_sel;
  logic sscratch_sw_rd_sel;
  logic satp_sw_rd_sel;
  logic utvec_sw_rd_sel;
  logic uepc_sw_rd_sel;
  logic ucause_sw_rd_sel;
  logic utval_sw_rd_sel;
  logic uscratch_sw_rd_sel;
  logic ucycle_sw_rd_sel;
  logic mcycle_sw_rd_sel;
  logic ucycleh_sw_rd_sel;
  logic mcycleh_sw_rd_sel;
  logic utime_sw_rd_sel;
  logic utimeh_sw_rd_sel;
  logic uinstret_sw_rd_sel;
  logic minstret_sw_rd_sel;
  logic uinstreth_sw_rd_sel;
  logic minstreth_sw_rd_sel;
  logic hpmcounter_3_31_sw_rd_sel;
  logic hpmcounter_3_31h_sw_rd_sel;
  logic mhpmcounter_3_31_sw_rd_sel;
  logic mhpmcounter_3_31h_sw_rd_sel;
  logic hpmevent_3_31_sw_rd_sel;
  logic tselect_sw_rd_sel;
  logic tdata1_sw_rd_sel;
  logic tdata2_sw_rd_sel;
  logic tdata3_sw_rd_sel;
  logic dcsr_debugger_rd_sel;
  logic dpc_debugger_rd_sel;
  logic dscratch0_debugger_rd_sel;
  logic dscratch1_debugger_rd_sel;
  logic fflags_sw_rd_sel;
  logic frm_sw_rd_sel;
  logic fcsr_sw_rd_sel;
  } t_csr_reg_rd_sel;   
                    
typedef struct {    
  logic mvendorid_sw_wr_sel;
  logic marchid_sw_wr_sel;
  logic mimpid_sw_wr_sel;
  logic mhartid_sw_wr_sel;
  logic mstatus_sw_wr_sel;
  logic sstatus_sw_wr_sel;
  logic ustatus_sw_wr_sel;
  logic misa_sw_wr_sel;
  logic medeleg_sw_wr_sel;
  logic mideleg_sw_wr_sel;
  logic mie_sw_wr_sel;
  logic sie_sw_wr_sel;
  logic uie_sw_wr_sel;
  logic mip_sw_wr_sel;
  logic sip_sw_wr_sel; 
  logic uip_sw_wr_sel; 
  logic ip_sw_wr_sel; 
  logic mtvec_sw_wr_sel; 
  logic mepc_sw_wr_sel;
  logic mcause_sw_wr_sel;
  logic mtval_sw_wr_sel;
  logic mcounteren_sw_wr_sel;
  logic mcounterinhibit_sw_wr_sel;
  logic mscratch_sw_wr_sel;
  logic pmpcfg_0_3_sw_wr_sel;
  logic pmpaddr_0_15_sw_wr_sel;
  logic sedeleg_sw_wr_sel;
  logic sideleg_sw_wr_sel;
  logic stvec_sw_wr_sel;
  logic sepc_sw_wr_sel;
  logic scause_sw_wr_sel;
  logic stval_sw_wr_sel;
  logic scounteren_sw_wr_sel;
  logic sscratch_sw_wr_sel;
  logic satp_sw_wr_sel;
  logic utvec_sw_wr_sel;
  logic uepc_sw_wr_sel;
  logic ucause_sw_wr_sel;
  logic utval_sw_wr_sel;
  logic uscratch_sw_wr_sel;
  logic ucycle_sw_wr_sel;
  logic mcycle_sw_wr_sel;
  logic ucycleh_sw_wr_sel;
  logic mcycleh_sw_wr_sel;
  logic utime_sw_wr_sel;
  logic utimeh_sw_wr_sel;
  logic uinstret_sw_wr_sel;
  logic minstret_sw_wr_sel;
  logic uinstreth_sw_wr_sel;
  logic minstreth_sw_wr_sel;
  logic hpmcounter_3_31_sw_wr_sel;
  logic hpmcounter_3_31h_sw_wr_sel;
  logic mhpmcounter_3_31_sw_wr_sel;
  logic mhpmcounter_3_31h_sw_wr_sel;
  logic hpmevent_3_31_sw_wr_sel;
  logic tselect_sw_wr_sel;
  logic tdata1_sw_wr_sel;
  logic tdata2_sw_wr_sel;
  logic tdata3_sw_wr_sel;
  logic dcsr_debugger_wr_sel;
  logic dpc_debugger_wr_sel;
  logic dscratch0_debugger_wr_sel;
  logic dscratch1_debugger_wr_sel;
  logic fflags_sw_wr_sel;
  logic frm_sw_wr_sel;
  logic fcsr_sw_wr_sel;
  } t_csr_reg_wr_sel;        
  
//----------------
// LSF/IFU/LSU
//----------------
               
  typedef enum logic [3:0] {lsu_op_none,
                           lsu_op_ld_byte_s,
                           lsu_op_ld_hword_s,
                           lsu_op_ld_word,
                           lsu_op_ld_byte_u,
                           lsu_op_ld_hword_u,
                           lsu_op_str_byte,
                           lsu_op_str_word,
                           lsu_op_str_hword,
                           lsu_op_fence} t_lsu_op;                                                       
                            
//----------------
// IDCTRL
//---------------- 

  typedef enum logic       {expipe_stage_state_ready, 
                            expipe_stage_state_busy} t_expipe_stage_state;

  typedef enum logic [1:0] {branch_cond_none,
                            branch_cond_always,
                            branch_cond_compare_true} t_branch_cond;
                            
  typedef enum logic [1:0] {gpr_wr_mux_sel_none,
                            gpr_wr_mux_sel_lsu,
                            gpr_wr_mux_sel_exu,
                            gpr_wr_mux_sel_csr} t_gpr_wr_mux_sel;
                            
                    
  typedef enum logic [2:0] {alignment_word,
                            alignment_halfword_u,
                            alignment_halfword_s,
                            alignment_byte_u,
                            alignment_byte_s} t_alignment_type;

    typedef struct {logic irq_src_ext;
                    logic irq_src_sw;
                    logic irq_src_timer;
                    } t_irq_src;                         
                            
                            
//-----------------------                
// MMU
//-----------------------
                            
//-----------------------
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
   


////////////////////////////////////////////////////////////////////////////////
//
//   File:      miv_rv32_defs_div_sqrt_mvp.v
//
//   Purpose:   
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 ETH Zurich and University of Bologna.
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// SPDX-License-Identifier: SHL-0.51

// Author: Stefan Mach <smach@iis.ee.ethz.ch>


  // ---------
  // FP TYPES
  // ---------
  // | Enumerator | Format           | Width  | EXP_BITS | MAN_BITS
  // |:----------:|------------------|-------:|:--------:|:--------:
  // | FP32       | IEEE binary32    | 32 bit | 8        | 23
  // | FP64       | IEEE binary64    | 64 bit | 11       | 52
  // | FP16       | IEEE binary16    | 16 bit | 5        | 10
  // | FP8        | binary8          |  8 bit | 5        | 2
  // | FP16ALT    | binary16alt      | 16 bit | 8        | 7
  // | FP8ALT     | binary8alt       |  8 bit | 4        | 3
  // *NOTE:* Add new formats only at the end of the enumeration for backwards compatibilty!

  // Encoding for a format
  typedef struct packed {
    int unsigned exp_bits;
    int unsigned man_bits;
  } fp_encoding_t;

 // localparam              FPU_PIPELINE   = 0; //0 = Disabled, 1=Enabled
  
  localparam int unsigned NUM_FP_FORMATS = 6; // change me to add formats
  localparam int unsigned FP_FORMAT_BITS = $clog2(NUM_FP_FORMATS);

  // FP formats
  typedef enum logic [FP_FORMAT_BITS-1:0] {
    FP32    = 'd0,
    FP64    = 'd1,
    FP16    = 'd2,
    FP8     = 'd3,
    FP16ALT = 'd4,
    FP8ALT  = 'd5
    // add new formats here
  } fp_format_e;

  // Encodings for supported FP formats
  localparam fp_encoding_t [0:NUM_FP_FORMATS-1] FP_ENCODINGS  = '{
    '{8,  23}, // IEEE binary32 (single)
    '{11, 52}, // IEEE binary64 (double)
    '{5,  10}, // IEEE binary16 (half)
    '{5,  2},  // custom binary8
    '{8,  7},  // custom binary16alt
    '{4,  3}   // custom binary8alt
    // add new formats here
  };

  typedef logic [0:NUM_FP_FORMATS-1]       fmt_logic_t;    // Logic indexed by FP format (for masks)
  typedef logic [0:NUM_FP_FORMATS-1][31:0] fmt_unsigned_t; // Unsigned indexed by FP format

  localparam fmt_logic_t CPK_FORMATS  = 6'b110000; // FP32 and FP64 can provide CPK only
  // FP32, FP64 cannot be provided for DOTP
  // Small hack: FP32 only enabled for wide enough wrapper input widths for vsum.s instruction
  localparam fmt_logic_t DOTP_FORMATS = 6'b101111;

  // ---------
  // INT TYPES
  // ---------
  // | Enumerator | Width  |
  // |:----------:|-------:|
  // | INT8       |  8 bit |
  // | INT16      | 16 bit |
  // | INT32      | 32 bit |
  // | INT64      | 64 bit |
  // *NOTE:* Add new formats only at the end of the enumeration for backwards compatibilty!

  localparam int unsigned NUM_INT_FORMATS = 4; // change me to add formats
  localparam int unsigned INT_FORMAT_BITS = $clog2(NUM_INT_FORMATS);

  // Int formats
  typedef enum logic [INT_FORMAT_BITS-1:0] {
    INT8,
    INT16,
    INT32,
    INT64
    // add new formats here
  } int_format_e;

  // Returns the width of an INT format by index
  function automatic int unsigned int_width(int_format_e ifmt);
    unique case (ifmt)
      INT8:  return 8;
      INT16: return 16;
      INT32: return 32;
      INT64: return 64;
      default: begin
        // pragma translate_off
        $fatal(1, "Invalid INT format supplied");
        // pragma translate_on
        // just return any integer to avoid any latches
        // hopefully this error is caught by simulation
        return INT8;
      end
    endcase
  endfunction

  typedef logic [0:NUM_INT_FORMATS-1] ifmt_logic_t; // Logic indexed by INT format (for masks)

  // --------------
  // FP OPERATIONS
  // --------------
  localparam int unsigned NUM_OPGROUPS = 5;

  // Each FP operation belongs to an operation group
  typedef enum logic [2:0] {
    ADDMUL, DIVSQRT, NONCOMP, CONV, DOTP
  } opgroup_e;

  localparam int unsigned OP_BITS = 5;

  typedef enum logic [OP_BITS-1:0] {
    SDOTP, EXVSUM, VSUM,         // DOTP operation group
    FMADD, FNMSUB, ADD, MUL,     // ADDMUL operation group
    DIV, SQRT,                   // DIVSQRT operation group
    SGNJ, MINMAX, CMP, CLASSIFY, // NONCOMP operation group
    F2F, F2I, I2F, CPKAB, CPKCD  // CONV operation group
  } operation_e;

  // -------------------
  // RISC-V FP-SPECIFIC
  // -------------------
  // Rounding modes
  typedef enum logic [2:0] {
    RNE = 3'b000,
    RTZ = 3'b001,
    RDN = 3'b010,
    RUP = 3'b011,
    RMM = 3'b100,
    DYN = 3'b111
  } roundmode_e;

  // Status flags
  typedef struct packed {
    logic NV; // Invalid
    logic DZ; // Divide by zero
    logic OF; // Overflow
    logic UF; // Underflow
    logic NX; // Inexact
  } status_t;

  // CSR encoded alternate fp formats
  typedef struct packed {
    logic src; // Source format selection
    logic dst; // Destination format selection
  } fmt_mode_t;

  // Information about a floating point value
  typedef struct packed {
    logic is_normal;     // is the value normal
    logic is_subnormal;  // is the value subnormal
    logic is_zero;       // is the value zero
    logic is_inf;        // is the value infinity
    logic is_nan;        // is the value NaN
    logic is_signalling; // is the value a signalling NaN
    logic is_quiet;      // is the value a quiet NaN
    logic is_boxed;      // is the value properly NaN-boxed (RISC-V specific)
  } fp_info_t;

  // Classification mask
  typedef enum logic [9:0] {
    NEGINF     = 10'b00_0000_0001,
    NEGNORM    = 10'b00_0000_0010,
    NEGSUBNORM = 10'b00_0000_0100,
    NEGZERO    = 10'b00_0000_1000,
    POSZERO    = 10'b00_0001_0000,
    POSSUBNORM = 10'b00_0010_0000,
    POSNORM    = 10'b00_0100_0000,
    POSINF     = 10'b00_1000_0000,
    SNAN       = 10'b01_0000_0000,
    QNAN       = 10'b10_0000_0000
  } classmask_e;

  // ------------------
  // FPU configuration
  // ------------------
  // Pipelining registers can be inserted (at elaboration time) into operational units
  typedef enum logic [1:0] {
    BEFORE,     // registers are inserted at the inputs of the unit
    AFTER,      // registers are inserted at the outputs of the unit
    INSIDE,     // registers are inserted at predetermined (suboptimal) locations in the unit
    DISTRIBUTED // registers are evenly distributed, INSIDE >= AFTER >= BEFORE
  } pipe_config_t;

  // Arithmetic units can be arranged in parallel (per format), merged (multi-format) or not at all.
  typedef enum logic [1:0] {
    DISABLED, // arithmetic units are not generated
    PARALLEL, // arithmetic units are generated in prallel slices, one for each format
    MERGED    // arithmetic units are contained within a merged unit holding multiple formats
  } unit_type_t;

  // Array of unit types indexed by format
  typedef unit_type_t [0:NUM_FP_FORMATS-1] fmt_unit_types_t;

  // Array of format-specific unit types by opgroup
  typedef fmt_unit_types_t [0:NUM_OPGROUPS-1] opgrp_fmt_unit_types_t;
  // same with unsigned
  typedef fmt_unsigned_t [0:NUM_OPGROUPS-1] opgrp_fmt_unsigned_t;

  // FPU configuration: features
  typedef struct packed {
    int unsigned Width;
    logic        EnableVectors;
    logic        EnableNanBox;
    fmt_logic_t  FpFmtMask;
    ifmt_logic_t IntFmtMask;
  } fpu_features_t;

  localparam fpu_features_t RV64D = '{
    Width:         64,
    EnableVectors: 1'b0,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b110000,
    IntFmtMask:    4'b0011
  };

  localparam fpu_features_t RV32D = '{
    Width:         64,
    EnableVectors: 1'b1,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b110000,
    IntFmtMask:    4'b0010
  };

  localparam fpu_features_t RV32F = '{
    Width:         32,
    EnableVectors: 1'b0,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b100000,
    IntFmtMask:    4'b0010
  };

  localparam fpu_features_t RV64D_Xsflt = '{
    Width:         64,
    EnableVectors: 1'b1,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b111111,
    IntFmtMask:    4'b1111
  };

  localparam fpu_features_t RV32F_Xsflt = '{
    Width:         32,
    EnableVectors: 1'b1,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b101111,
    IntFmtMask:    4'b1110
  };

  localparam fpu_features_t RV32F_Xf16alt_Xfvec = '{
    Width:         32,
    EnableVectors: 1'b1,
    EnableNanBox:  1'b1,
    FpFmtMask:     6'b100010,
    IntFmtMask:    4'b0110
  };


  // FPU configuraion: implementation
  typedef struct packed {
    opgrp_fmt_unsigned_t   PipeRegs;
    opgrp_fmt_unit_types_t UnitTypes;
    pipe_config_t          PipeConfig;
  } fpu_implementation_t;

  localparam fpu_implementation_t DEFAULT_NOREGS = '{
    PipeRegs:   '{default: 0},
    UnitTypes:  '{'{default: PARALLEL}, // ADDMUL
                  '{default: MERGED},   // DIVSQRT
                  '{default: PARALLEL}, // NONCOMP
                  '{default: MERGED},   // CONV
                  '{default: MERGED}},  // DOTP
    PipeConfig: BEFORE
  };

  localparam fpu_implementation_t DEFAULT_SNITCH = '{
    PipeRegs:   '{default: 1},
    UnitTypes:  '{'{default: PARALLEL}, // ADDMUL
                  '{default: DISABLED}, // DIVSQRT
                  '{default: PARALLEL}, // NONCOMP
                  '{default: MERGED},   // CONV
                  '{default: MERGED}},  // DOTP
    PipeConfig: BEFORE
  };

  // -----------------------
  // Synthesis optimization
  // -----------------------
  localparam logic DONT_CARE = 1'b1; // the value to assign as don't care

  // -------------------------
  // General helper functions
  // -------------------------
  function automatic int minimum(int a, int b);
    return (a < b) ? a : b;
  endfunction

  function automatic int maximum(int a, int b);
    return (a > b) ? a : b;
  endfunction

  // -------------------------------------------
  // Helper functions for FP formats and values
  // -------------------------------------------
  // Returns the width of a FP format
  function automatic int unsigned fp_width(fp_format_e fmt);
    return FP_ENCODINGS[fmt].exp_bits + FP_ENCODINGS[fmt].man_bits + 1;
  endfunction

  // Returns the widest FP format present
  function automatic int unsigned max_fp_width(fmt_logic_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++)
      if (cfg[i])
        res = unsigned'(maximum(res, fp_width(fp_format_e'(i))));
    return res;
  endfunction


  function automatic int unsigned max_dotp_dst_fp_width(fmt_logic_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++)
      if (cfg[i])
        res = unsigned'(maximum(res, fp_format_e'(i)));
    return res;
  endfunction

  // Returns the narrowest FP format present
  function automatic int unsigned min_fp_width(fmt_logic_t cfg);
    automatic int unsigned res = max_fp_width(cfg);
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++)
      if (cfg[i])
        res = unsigned'(minimum(res, fp_width(fp_format_e'(i))));
    return res;
  endfunction

  // Returns the number of expoent bits for a format
  function automatic int unsigned exp_bits(fp_format_e fmt);
    return FP_ENCODINGS[fmt].exp_bits;
  endfunction

  // Returns the number of mantissa bits for a format
  function automatic int unsigned man_bits(fp_format_e fmt);
    return FP_ENCODINGS[fmt].man_bits;
  endfunction

  // Returns the bias value for a given format (as per IEEE 754-2008)
  function automatic int unsigned bias(fp_format_e fmt);
    return unsigned'(2**(FP_ENCODINGS[fmt].exp_bits-1)-1); // symmetrical bias
  endfunction

  function automatic fp_encoding_t super_format(fmt_logic_t cfg);
    automatic fp_encoding_t res;
    res = '0;
    for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
      if (cfg[fmt]) begin // only active format
        res.exp_bits = unsigned'(maximum(res.exp_bits, exp_bits(fp_format_e'(fmt))));
        res.man_bits = unsigned'(maximum(res.man_bits, man_bits(fp_format_e'(fmt))));
      end
    return res;
  endfunction

  function automatic fp_format_e expanded_format(fp_format_e input_format);
    automatic fp_format_e res;
    case (input_format)
      FP32    : res = FP64;
      FP64    : res = FP64;
      FP16    : res = FP32;
      FP8     : res = FP16;
      FP16ALT : res = FP32;
      FP8ALT  : res = FP16;
      default : res = FP64;
    endcase
    return res;
  endfunction

  // -------------------------------------------
  // Helper functions for INT formats and values
  // -------------------------------------------
  // Returns the widest INT format present
  function automatic int unsigned max_int_width(ifmt_logic_t cfg);
    automatic int unsigned res = 0;
    for (int ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt++) begin
      if (cfg[ifmt]) res = maximum(res, int_width(int_format_e'(ifmt)));
    end
    return res;
  endfunction

  // --------------------------------------------------
  // Helper functions for operations and FPU structure
  // --------------------------------------------------
  // Returns the operation group of the given operation
  function automatic opgroup_e get_opgroup(operation_e op);
    unique case (op)
      FMADD, FNMSUB, ADD, MUL:     return ADDMUL;
      DIV, SQRT:                   return DIVSQRT;
      SGNJ, MINMAX, CMP, CLASSIFY: return NONCOMP;
      F2F, F2I, I2F, CPKAB, CPKCD: return CONV;
      SDOTP, EXVSUM, VSUM:         return DOTP;
      default:                     return NONCOMP;
    endcase
  endfunction

  // Returns the number of operands by operation group
  function automatic int unsigned num_operands(opgroup_e grp);
    unique case (grp)
      ADDMUL:  return 3;
      DIVSQRT: return 2;
      NONCOMP: return 2;
      CONV:    return 3; // vectorial casts use 3 operands
      DOTP:    return 3; // splitting into 5 operands done in wrapper
      default: return 0;
    endcase
  endfunction

  // Returns the number of lanes according to width, format and vectors
  function automatic int unsigned num_lanes(int unsigned width, fp_format_e fmt, logic vec);
    return vec ? width / fp_width(fmt) : 1; // if no vectors, only one lane
  endfunction

  // Returns the maximum number of lanes in the FPU according to width, format config and vectors
  function automatic int unsigned max_num_lanes(int unsigned width, fmt_logic_t cfg, logic vec);
    return vec ? width / min_fp_width(cfg) : 1; // if no vectors, only one lane
  endfunction

  // Returns a mask of active FP formats that are present in lane lane_no of a multiformat slice
  function automatic fmt_logic_t get_lane_formats(int unsigned width,
                                                  fmt_logic_t cfg,
                                                  int unsigned lane_no);
    automatic fmt_logic_t res;
    for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
      // Mask active formats with the number of lanes for that format
      res[fmt] = cfg[fmt] & (width / fp_width(fp_format_e'(fmt)) > lane_no);
    return res;
  endfunction

  // Returns a mask of active INT formats that are present in lane lane_no of a multiformat slice
  function automatic ifmt_logic_t get_lane_int_formats(int unsigned width,
                                                       fmt_logic_t cfg,
                                                       ifmt_logic_t icfg,
                                                       int unsigned lane_no);
    automatic ifmt_logic_t res;
    automatic fmt_logic_t lanefmts;
    res = '0;
    lanefmts = get_lane_formats(width, cfg, lane_no);

    for (int unsigned ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt++)
      for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
        // Mask active int formats with the width of the float formats
        if ((fp_width(fp_format_e'(fmt)) == int_width(int_format_e'(ifmt))))
          res[ifmt] |= icfg[ifmt] && lanefmts[fmt];
    return res;
  endfunction

  // Returns a mask of active FP formats that are present in lane lane_no of a CONV slice
  function automatic fmt_logic_t get_conv_lane_formats(int unsigned width,
                                                       fmt_logic_t cfg,
                                                       int unsigned lane_no);
    automatic fmt_logic_t res;
    for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
      // Mask active formats with the number of lanes for that format, CPK at least twice
      res[fmt] = cfg[fmt] && ((width / fp_width(fp_format_e'(fmt)) > lane_no) ||
                             (CPK_FORMATS[fmt] && (lane_no < 2)));
    return res;
  endfunction

  // Returns a mask of active FP formats that are currenlty supported for DOTP operations
  function automatic fmt_logic_t get_dotp_lane_formats(int unsigned width,
                                                       fmt_logic_t cfg,
                                                       int unsigned lane_no);
    automatic fmt_logic_t res;
    for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
      // Mask active formats with the number of lanes for that format, CPK at least twice
      res[fmt] = cfg[fmt] && ((width / (fp_width(fp_format_e'(fmt))*2) > (lane_no/2)) && DOTP_FORMATS[fmt]);
    return res;
  endfunction

  // Returns the dotp dest FP format string
  function automatic fmt_logic_t get_dotp_dst_fmts(fmt_logic_t cfg);
    automatic fmt_logic_t res;
    unique case (cfg) // goes through some of the allowed configurations
      6'b001111:  res=6'b101111; // fp8(alt) -> fp16(alt) & fp16(alt) -> fp32
      6'b000101:  res=6'b001111; // fp8(alt) -> fp16(alt)
      default: return '0;
    endcase
    return res;
  endfunction

  // Returns a mask of active INT formats that are present in lane lane_no of a CONV slice
  function automatic ifmt_logic_t get_conv_lane_int_formats(int unsigned width,
                                                            fmt_logic_t cfg,
                                                            ifmt_logic_t icfg,
                                                            int unsigned lane_no);
    automatic ifmt_logic_t res;
    automatic fmt_logic_t lanefmts;
    res = '0;
    lanefmts = get_conv_lane_formats(width, cfg, lane_no);

    for (int unsigned ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt++)
      for (int unsigned fmt = 0; fmt < NUM_FP_FORMATS; fmt++)
        // Mask active int formats with the width of the float formats
        res[ifmt] |= icfg[ifmt] && lanefmts[fmt] &&
                     (fp_width(fp_format_e'(fmt)) == int_width(int_format_e'(ifmt)));
    return res;
  endfunction

  // Return whether any active format is set as MERGED
  function automatic logic any_enabled_multi(fmt_unit_types_t types, fmt_logic_t cfg);
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++)
      if (cfg[i] && types[i] == MERGED)
        return 1'b1;
      return 1'b0;
  endfunction

  // Return whether the given format is the first active one set as MERGED
  function automatic logic is_first_enabled_multi(fp_format_e fmt,
                                                  fmt_unit_types_t types,
                                                  fmt_logic_t cfg);
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++) begin
      if (cfg[i] && types[i] == MERGED) return (fp_format_e'(i) == fmt);
    end
    return 1'b0;
  endfunction

  // Returns the first format that is active and is set as MERGED
  function automatic fp_format_e get_first_enabled_multi(fmt_unit_types_t types, fmt_logic_t cfg);
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++)
      if (cfg[i] && types[i] == MERGED)
        return fp_format_e'(i);
      return fp_format_e'(0);
  endfunction

  // Returns the largest number of regs that is active and is set as MERGED
  function automatic int unsigned get_num_regs_multi(fmt_unsigned_t regs,
                                                     fmt_unit_types_t types,
                                                     fmt_logic_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NUM_FP_FORMATS; i++) begin
      if (cfg[i] && types[i] == MERGED) res = maximum(res, regs[i]);
    end
    return res;
  endfunction


////////////////////////////////////////////////////////////////////////////////
//
//   File:      miv_rv32_defs_div_sqrt_mvp.v
//
//   Purpose:   
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////
// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// This file contains all miv_rv32_div_sqrt_top_mvp parameters
// Authors    : Lei Li  (lile@iis.ee.ethz.ch)


   // op command
   localparam C_RM                  = 3;
   localparam C_RM_NEAREST          = 3'h0;
   localparam C_RM_TRUNC            = 3'h1;
   localparam C_RM_PLUSINF          = 3'h2;
   localparam C_RM_MINUSINF         = 3'h3;
   localparam C_RM_NEAREST_RMM      = 3'h4;
   localparam C_PC                  = 6; // Precision Control
   localparam C_FS                  = 2; // Format Selection
   localparam C_IUNC                = 2; // Iteration Unit Number Control
   localparam Iteration_unit_num_S  = 2'b11; // TS FIX  
   
      // op command
   parameter C_CMD               = 4;
   parameter C_FPU_ADD_CMD       = 4'h0;
   parameter C_FPU_SUB_CMD       = 4'h1;
   parameter C_FPU_MUL_CMD       = 4'h2;
   parameter C_FPU_DIV_CMD       = 4'h3;
   parameter C_FPU_I2F_CMD       = 4'h4;
   parameter C_FPU_F2I_CMD       = 4'h5;
   parameter C_FPU_SQRT_CMD      = 4'h6;
   parameter C_FPU_NOP_CMD       = 4'h7;
   parameter C_FPU_FMADD_CMD     = 4'h8;
   parameter C_FPU_FMSUB_CMD     = 4'h9;
   parameter C_FPU_FNMADD_CMD    = 4'hA;
   parameter C_FPU_FNMSUB_CMD    = 4'hB;

   // FP64
   localparam C_OP_FP64             = 64;
   localparam C_MANT_FP64           = 52;
   localparam C_EXP_FP64            = 11;
   localparam C_BIAS_FP64           = 1023;
   localparam C_BIAS_AONE_FP64      = 11'h400;
   localparam C_HALF_BIAS_FP64      = 511;
   localparam C_EXP_ZERO_FP64       = 11'h000;
   localparam C_EXP_ONE_FP64        = 13'h001; // Bit width is in agreement with in norm
   localparam C_EXP_INF_FP64        = 11'h7FF;
   localparam C_MANT_ZERO_FP64      = 52'h0;
   localparam C_MANT_NAN_FP64       = 52'h8_0000_0000_0000;
   localparam C_PZERO_FP64          = 64'h0000_0000_0000_0000;
   localparam C_MZERO_FP64          = 64'h8000_0000_0000_0000;
   localparam C_QNAN_FP64           = 64'h7FF8_0000_0000_0000;

   // FP32
   localparam C_OP_FP32             = 32;
   localparam C_MANT_FP32           = 23;
   localparam C_EXP_FP32            = 8;
   localparam C_BIAS_FP32           = 127;
   localparam C_BIAS_AONE_FP32      = 8'h80;
   localparam C_HALF_BIAS_FP32      = 63;
   localparam C_EXP_ZERO_FP32       = 8'h00;
   localparam C_EXP_INF_FP32        = 8'hFF;
   localparam C_MANT_ZERO_FP32      = 23'h0;
   localparam C_PZERO_FP32          = 32'h0000_0000;
   localparam C_MZERO_FP32          = 32'h8000_0000;
   localparam C_QNAN_FP32           = 32'h7FC0_0000;

   // FP16
   localparam C_OP_FP16             = 16;
   localparam C_MANT_FP16           = 10;
   localparam C_EXP_FP16            = 5;
   localparam C_BIAS_FP16           = 15;
   localparam C_BIAS_AONE_FP16      = 5'h10;
   localparam C_HALF_BIAS_FP16      = 7;
   localparam C_EXP_ZERO_FP16       = 5'h00;
   localparam C_EXP_INF_FP16        = 5'h1F;
   localparam C_MANT_ZERO_FP16      = 10'h0;
   localparam C_PZERO_FP16          = 16'h0000;
   localparam C_MZERO_FP16          = 16'h8000;
   localparam C_QNAN_FP16           = 16'h7E00;

   // FP16alt
   localparam C_OP_FP16ALT           = 16;
   localparam C_MANT_FP16ALT         = 7;
   localparam C_EXP_FP16ALT          = 8;
   localparam C_BIAS_FP16ALT         = 127;
   localparam C_BIAS_AONE_FP16ALT    = 8'h80;
   localparam C_HALF_BIAS_FP16ALT    = 63;
   localparam C_EXP_ZERO_FP16ALT     = 8'h00;
   localparam C_EXP_INF_FP16ALT      = 8'hFF;
   localparam C_MANT_ZERO_FP16ALT    = 7'h0;
   localparam C_QNAN_FP16ALT         = 16'h7FC0;


//****************************************************************************


typedef enum {
            rv32_default,
            rv32_noexec,
            rv32_trap,
            rv32_reset,
            rv32_dbgexit,
            rv32i_lui,
            rv32i_auipc,
            rv32i_jal,
            rv32i_jalr,
            rv32i_beq,
            rv32i_bne,
            rv32i_blt,
            rv32i_bge,
            rv32i_bltu,
            rv32i_bgeu,
            rv32i_lb,
            rv32i_lh,
            rv32i_lw,
            rv32i_lbu,
            rv32i_lhu,
            rv32i_sb,
            rv32i_sh,
            rv32i_sw,
            rv32i_addi,
            rv32i_slti,
            rv32i_sltiu,
            rv32i_xori,
            rv32i_ori,
            rv32i_andi,
            rv32i_slli,
            rv32i_srli,
            rv32i_srai,
            rv32i_add,
            rv32i_sub,
            rv32i_sll,
            rv32i_slt,
            rv32i_sltu,
            rv32i_xor,
            rv32i_srl,
            rv32i_sra,
            rv32i_or,
            rv32i_and,
            rv32i_fence,
            rv32i_fence_i,
            rv32m_mul,
            rv32m_mulh,
            rv32m_mulhsu,
            rv32m_mulhu,
            rv32m_div,
            rv32m_divu,
            rv32m_rem,
            rv32m_remu,
            rv32c_illegal0,
            rv32c_addi4spn,
            rv32c_lw,
            rv32c_sw,
            rv32c_addi,
            rv32c_addi_hint,
            rv32c_nop,
            rv32c_nop_hint,
            rv32c_jal,
            rv32c_li,
            rv32c_li_hint,
            rv32c_addi16sp,
            rv32c_lui,
            rv32c_lui_hint,
            rv32c_srli,
            rv32c_srli64_hint,
            rv32c_srai,
            rv32c_srai64_hint,
            rv32c_andi,
            rv32c_sub,
            rv32c_xor,
            rv32c_or,
            rv32c_and,
            rv32c_j,
            rv32c_beqz,
            rv32c_bnez,
            rv32c_slli,
            rv32c_slli_hint,
            rv32c_slli64_hint,
            rv32c_lwsp,
            rv32c_jr,
            rv32c_mv,
            rv32c_mv_hint,
            rv32c_ebreak,
            rv32c_jalr,
            rv32c_add,
            rv32c_add_hint,
            rv32c_swsp,
            rv32c_flw,
            rv32c_fsw,
            rv32c_flwsp,
            rv32c_fswsp,
            rv32i_csrrw,
            rv32i_csrrs,
            rv32i_csrrc,
            rv32i_csrrwi,
            rv32i_csrrsi,
            rv32i_csrrci,
            rv32i_ecall,
            rv32i_ebreak,
            rv32i_dret,
            rv32i_mret,
            rv32i_sret,
            rv32i_uret,
            rv32i_wfi,
			rv32f_flw,
            rv32f_fsw,
            rv32f_fmadd_s,
            rv32f_fmsub_s,
            rv32f_fnmsub_s,
            rv32f_fnmadd_s,
            rv32f_fadd_s,
            rv32f_fsub_s,
            rv32f_fmul_s,
            rv32f_fdiv_s,
            rv32f_fsqrt_s,
            rv32f_fsgnj_s,
            rv32f_fsgnjn_s,
            rv32f_fsgnjx_s,
            rv32f_fmin_s,
            rv32f_fmax_s,
            rv32f_fcvt_w_s,
            rv32f_fcvt_wu_s,
            rv32f_fmv_x_w,
            rv32f_feq_s,
            rv32f_flt_s,
            rv32f_fle_s,
            rv32f_fclass_s,
            rv32f_fcvt_s_w,
            rv32f_fcvt_s_wu,
            rv32f_fmv_w_x
            } t_mnemonic_list;

////////////////////////////////////////////////////////////////////////////////
//
//   File:      miv_rv32_cf_math_pkg.v
//
//   Purpose:   
//
//   Author: 
//
//   Version: 1.0
//
////////////////////////////////////////////////////////////////////////////////
// Copyright 2016 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

/// miv_rv32_cf_math_pkg: Constant Function Implementations of Mathematical Functions for HDL Elaboration
///
/// This package contains a collection of mathematical functions that are commonly used when defining
/// the value of constants in HDL code.  These functions are implemented as Verilog constants
/// functions.  Introduced in Verilog 2001 (IEEE Std 1364-2001), a constant function (§ 10.3.5) is a
/// function whose value can be evaluated at compile time or during elaboration.  A constant function
/// must be called with arguments that are constants.


    /// Ceiled Division of Two Natural Numbers
    ///
    /// Returns the quotient of two natural numbers, rounded towards plus infinity.
    function automatic integer ceil_div (input longint dividend, input longint divisor);
        automatic longint remainder;

        // pragma translate_off
        `ifndef VERILATOR
        if (dividend < 0) begin
            $fatal(1, "Dividend %0d is not a natural number!", dividend);
        end

        if (divisor < 0) begin
            $fatal(1, "Divisor %0d is not a natural number!", divisor);
        end

        if (divisor == 0) begin
            $fatal(1, "Division by zero!");
        end
        `endif
        // pragma translate_on

        remainder = dividend;
        for (ceil_div = 0; remainder > 0; ceil_div++) begin
            remainder = remainder - divisor;
        end
    endfunction

    /// Index width required to be able to represent up to `num_idx` indices as a binary
    /// encoded signal.
    /// Ensures that the minimum width if an index signal is `1`, regardless of parametrization.
    ///
    /// Sample usage in type definition:
    /// As parameter:
    ///   `parameter type idx_t = logic[miv_rv32_pkg::idx_width(NumIdx)-1:0]`
    /// As typedef:
    ///   `typedef logic [miv_rv32_pkg::idx_width(NumIdx)-1:0] idx_t`
    function automatic integer unsigned idx_width (input integer unsigned num_idx);
        return (num_idx > 32'd1) ? unsigned'($clog2(num_idx)) : 32'd1;
    endfunction


////////////////////////////////////////////////////////////////////////////////
//
// FUNCTION:
//
// This package should be included in all modules which use the PMC RAM BIST 
// blocks.  The package includes user definable parameters such as the number
// of RAMs, the maximum size of a RAM, test bus, and BIST bus sizes, etc.
//
// A copy of this package should be kept in your design, with the indicated
// parameters modified as required.  
//
// The BIST sequencer talks to all the BIST wrappers using a control bus and
// listens to all the RAM results using an acknowledgement bus.
//
//     input  logic [bistctl_width-1:0] bistctl;
//
// Also, the BIST blocks for a given RAM communicate to each other using another
// bus.  The address and control wrapper (bistone, bisttwo, etc.) communicate
// to the data analyzer (bistonedata, bisttwodata, etc.) using the bus:
//
//     logic [bistwrap_width-1:0] bistwrap;
//
// The above should be used to declare the bus that connects them.  Each 
// address and control wrapper has its own bistwrap bus, so do not try and
// mix them.
//
//
// PARAMETER DESCRIPTION:
//
// BIST_NUM                number of RAMs being tested by the BIST sequencer
// BIST_ADDR_WIDTH         max number of address bits of all the RAMs tested
// BIST_DATA_WIDTH         max number of data bits of all the RAMs tested
// BIST_CMASK_WIDTH        width of the compare mask
// BIST_TEST_WIDTH         width of the test bus connected to the BIST sequencer
// ECC_ERR_INJECT_WIDTH    width of ECC error injection bus in BIST wrapper
// ECC_ERR_WIDTH           width of ECC error bus in the BIST wrapper
// PARITY_ERR_INJECT_WIDth width of parity error injection bus in BIST wrapper
// PARITY_ERR_WIDTH        width of parity error bus in BIST wrapper
// BIST_ECC_NUM            number of RAMs which have ECC
// BIST_NO_ECC_NUM         number of RAMs which don't have ECC
//
// BIST_PE_WIDTH           width of PE bus
// BIST_PE_NORMAL          PE bus for normal mode
// BIST_PE_BIST            PE bus for BIST mode
//
// BISTMODE_WIDTH          width of BIST mode bus
// BISTMODE_RESET          BIST reset mode
// BISTMODE_BIST           automated RAM BIST test mode
// BISTMODE_SHIFT          shifts data on BIST test bus to BIST wrapper
// BISTMODE_RUN            executes test shifted in with bistmode_shift
// BISTMODE_HOLD           pause during shifting, ignored in normal operation
// BISTMODE_REGCHECK       sets BIST reg outputs to inverse of bistmode_reset
// BISTMODE_ERR_INJECT     automated RAM BIST test mode with error injection
// BISTMODE_LOW_POWER      runs low power mode test on low power enabled RAM
//
// BISTACK_WIDTH           width of BIST acknowledge bus
// BISTACKECC_WIDTH        width of BIST ECC acknowledge bus 
// BIST_ERR_INJECT_WIDTH   width of BIST error injection bus
// BISTRM1CTRL_WIDTH       width of RM1 control bus
// BISTRM2CTRL_WIDTH       width of RM2 control bus
// BISTRM3CTRL_WIDTH       width of RM3 control bus
// BISTRMMODE_WIDTH        width of RM mode bus
// BIST_RM1_WIDTH          width of RM1 bus
// BIST_RM2_WIDTH          width of RM2 bus
// BIST_RM3_WIDTH          width of RM3 bus
// BIST_ERR_LIMIT          BIST error limit (0.13um=7, 90nm=9)
// BIST_ERR_BIT            BIST error bit (0.13um=3, 90nm=4)
// BIST_PG_MODE_WIDTH      width of PG mode
//
// BISTCTL_SYNC_CE         BIST control cell enable
// BISTCTL_SYNC_WE         BIST control write enable
// BISTCTL_DUAL_RCE        BIST control read-side cell enable
// BISTCTL_DUAL_RWE        BIST control read-side write enable
// BISTCTL_DUAL_WCE        BIST control write-side cell enable
// BISTCTL_DUAL_WWE        BIST control write-side write enable
// BISTCTL_ADDR0           BIST control address bus 0
// BISTCTL_ADDR1           BIST control address bus 1
// BISTCTL_TEST0           BIST control data bus 0
// BISTCTL_TEST1           BIST control data bus 1
// BISTCTL_CMASK_EN        BIST control compare mask enable
// BISTCTL_CMASK           BIST control compare mask bus
// BISTCTL_PE              BIST control PE bus
// BISTCTL_LP1_BIST        BIST control light sleep mode
// BISTCTL_LP2_BIST        BIST control deep sleep mode
// BISTCTL_LP3_BIST        BIST control shutdown mode
// BISTCTL_SIDE            BIST control side select
// BISTCTL_BIST            BIST control bist mode enable
// BISTCTL_WIDTH           BIST control width
//
// BISTWRAP_WORD           BIST wrapper word
// BISTWRAP_WIDTH          BIST wrapper width
//
// RM_SEL_NORMAL           BIST RM normal mode
// RM_SEL_BIST             BIST RM BIST mode
// RM_SEL_BACKDOOR         BIST RM backdoor mode
//
// BIST_LOW                BIST low 
// BIST_HIGH               BIST high
// BIST_FALSE              BIST false
// BIST_TRUE               BIST true
// BIST_ECC_OFF            BIST ECC off
// BIST_ECC_ON             BIST ECC on
// BIST_PIPELINE_OFF       BIST pipeline off
// BIST_PIPELINE_ON        BIST pipeline on
// BIST_BYPASS_FF_OFF      BIST bypass flip flop off
// BIST_BYPASS_FF_ON       BIST bypass flip flop on
// BIST_BYPASS_FLL_OFF     BIST bypass FLL off
// BIST_BYPASS_ALL_OFF     BIST bypass ALL off
//
////////////////////////////////////////////////////////////////////////////////

  parameter BIST_TEST_WIDTH         = 17;
  parameter BIST_SEED_WIDTH         = 8;
  parameter ECC_ERR_INJECT_WIDTH    = 2;
  parameter ECC_ERR_WIDTH           = 2;
  parameter PARITY_ERR_INJECT_WIDTH = 1;
  parameter PARITY_ERR_WIDTH        = 1;
  // ROM CRC WIDTH
  parameter CRC_WIDTH               = 32;
  
  //PE bus parameters
  parameter BIST_PE_WIDTH           = 26;
  parameter BIST_PEVAL_WIDTH        = 15;
  
  //BIST bus parameters (DO NOT MODIFY)
  parameter BISTMODE_WIDTH = 4;
  typedef enum logic [BISTMODE_WIDTH-1:0] {
    BISTMODE_RESET      = 4'b0000,
    BISTMODE_BIST       = 4'b0001,
    BISTMODE_SHIFT      = 4'b0010,
    BISTMODE_RUN        = 4'b0011,
    BISTMODE_HOLD       = 4'b0100,
    BISTMODE_REGCHECK   = 4'b0101,
    BISTMODE_ERR_INJECT = 4'b0110,
    BISTMODE_LOW_POWER  = 4'b0111,
    BISTMODE_SANITY     = 4'b1001
  } t_bistmode;
  
  parameter BISTRAMSEL_WIDTH       = 2;
  parameter BIST_ERR_INJECT_WIDTH  = 2;
  parameter BISTRM1CTRL_WIDTH      = 3;
  parameter BISTRM2CTRL_WIDTH      = 3;
  parameter BISTRM3CTRL_WIDTH      = 3;
  parameter BISTRMMODE_WIDTH       = 2;
  parameter BIST_RM1_WIDTH         = 3;
  parameter BIST_RM2_WIDTH         = 2;
  parameter BIST_RM3_WIDTH         = 1;
  parameter BIST_ERR_LIMIT         = 9;
  parameter BIST_ERR_BIT           = 4;
  parameter BIST_PG_MODE_WIDTH     = 2;

  parameter logic       BIST_LP1_DEFAULT = 1'b1;
  parameter logic       BIST_LP2_DEFAULT = 1'b1;
  parameter logic       BIST_LP3_DEFAULT = 1'b0;
  parameter logic [2:0] BIST_LP_DEFAULT  = 3'b110;
  parameter logic [2:0] BIST_LP_LS       = 3'b010;
  parameter logic [2:0] BIST_LP_DS_L1    = 3'b100;
  parameter logic [2:0] BIST_LP_DS_L2    = 3'b101;
  parameter logic [2:0] BIST_LP_SD       = 3'b111;
  
  //BIST wrap bus parameters (DO NOT MODIFY)
  parameter BISTWRAP_WORD           = 0;
  parameter BISTWRAP_WIDTH          = BISTWRAP_WORD + 1;
  
  //BIST RM select typedef (DO NOT MODIFY)
  //typedef enum  {
  //  RM_SEL_NORMAL   = 0,
  //  RM_SEL_BIST     = 1,
  //  RM_SEL_BACKDOOR = 2
  //} t_rm_sel_mode;
  
  //BIST low power bus width (DO NOT MODIFY)
  //parameter bist_low_power_width    = LOW_POWER_WIDTH;
  
  //Configuration types (DO NOT MODIFY)
  typedef enum {
    BIST_LOW  = 0,
    BIST_HIGH = 1
  } t_bist_low_high;
  
  typedef enum {
    BIST_FALSE = 0,
    BIST_TRUE  = 1
  } t_bist_true_false;
  
  typedef enum {
    BIST_NO_FF  = 0,
    BIST_POS_FF = 1,
    BIST_NEG_FF = 2
  } t_bist_ff;
  
  typedef enum {
    BIST_ECC_OFF = 0,
    BIST_ECC_ON  = 1
  } t_bist_ecc;
  
  typedef enum {
    BIST_PIPELINE_OFF = 0,
    BIST_PIPELINE_ON  = 1
  } t_bist_pipeline;
  
  typedef enum {
    BIST_BYPASS_FF_OFF  = 0,
    BIST_BYPASS_FF_ON   = 1,
    BIST_BYPASS_FLL_OFF = 2,
    BIST_BYPASS_ALL_OFF = 3
  } t_bist_bypass;
  
  typedef enum {
    BIST_GENERIC_RAM = 0,
    BIST_SPECIAL_RAM = 1
  } t_bist_generic_special;
  
  typedef enum {
     BIST_DPR  = 1,
     BIST_TPR  = 2,
     BIST_TRF  = 3,
     BIST_DHS  = 4,
     BIST_THS  = 5,
     BIST_DPRW = 6,
     BIST_TPRW = 7,
     BIST_TRFW = 8,
     BIST_DHSW = 9,
     BIST_THSW = 10
  } t_bist_ram_type;

  function automatic int parity_num (input int data_num);
    if (data_num == 1) begin
      parity_num = 3;
    end 
    else if (data_num <= 4) begin
      parity_num = 4;
    end
    else if (data_num <= 11) begin
      parity_num = 5;
    end
    else if (data_num <= 26) begin
      parity_num = 6;
    end
    else if (data_num <= 57) begin
      parity_num = 7;
    end
    else if (data_num <= 120) begin
      parity_num = 8;
    end
    else if (data_num <= 247) begin
      parity_num = 9;
    end
    else if (data_num <= 502) begin
      parity_num = 10;
    end
    else if (data_num <= 1013) begin
      parity_num = 11;
    end
    else begin // error
      parity_num = 0;
    end
  endfunction


////////////////////////////////////////////////////////////////////////////////
//
// FUNCTION:
//
// This package should be included in all modules which use the PMC RAM BIST 
// blocks.  The package includes user definable parameters such as the number
// of RAMs, the maximum size of a RAM, test bus, and BIST bus sizes, etc.
//
// A copy of this package should be kept in your design, with the indicated
// parameters modified as required.  
//
// The BIST sequencer talks to all the BIST wrappers using a control bus and
// listens to all the RAM results using an acknowledgement bus.
//
//     input  logic [bistctl_width-1:0] bistctl;
//
// Also, the BIST blocks for a given RAM communicate to each other using another
// bus.  The address and control wrapper (bistone, bisttwo, etc.) communicate
// to the data analyzer (bistonedata, bisttwodata, etc.) using the bus:
//
//     logic [bistwrap_width-1:0] bistwrap;
//
// The above should be used to declare the bus that connects them.  Each 
// address and control wrapper has its own bistwrap bus, so do not try and
// mix them.
//
//
// PARAMETER DESCRIPTION:
//
// BIST_NUM                number of RAMs being tested by the BIST sequencer
// BIST_ADDR_WIDTH         max number of address bits of all the RAMs tested
// BIST_DATA_WIDTH         max number of data bits of all the RAMs tested
// BIST_CMASK_WIDTH        width of the compare mask
// BIST_TEST_WIDTH         width of the test bus connected to the BIST sequencer
// ECC_ERR_INJECT_WIDTH    width of ECC error injection bus in BIST wrapper
// ECC_ERR_WIDTH           width of ECC error bus in the BIST wrapper
// PARITY_ERR_INJECT_WIDth width of parity error injection bus in BIST wrapper
// PARITY_ERR_WIDTH        width of parity error bus in BIST wrapper
// BIST_ECC_NUM            number of RAMs which have ECC
// BIST_NO_ECC_NUM         number of RAMs which don't have ECC
//
// BIST_PE_WIDTH           width of PE bus
// BIST_PE_NORMAL          PE bus for normal mode
// BIST_PE_BIST            PE bus for BIST mode
//
// BISTMODE_WIDTH          width of BIST mode bus
// BISTMODE_RESET          BIST reset mode
// BISTMODE_BIST           automated RAM BIST test mode
// BISTMODE_SHIFT          shifts data on BIST test bus to BIST wrapper
// BISTMODE_RUN            executes test shifted in with bistmode_shift
// BISTMODE_HOLD           pause during shifting, ignored in normal operation
// BISTMODE_REGCHECK       sets BIST reg outputs to inverse of bistmode_reset
// BISTMODE_ERR_INJECT     automated RAM BIST test mode with error injection
// BISTMODE_LOW_POWER      runs low power mode test on low power enabled RAM
//
// BISTACK_WIDTH           width of BIST acknowledge bus
// BISTACKECC_WIDTH        width of BIST ECC acknowledge bus 
// BIST_ERR_INJECT_WIDTH   width of BIST error injection bus
// BISTRMCTRL_WIDTH        width of RM control bus
// BIST_ERR_LIMIT          BIST error limit (0.13um=7, 90nm=9)
// BIST_ERR_BIT            BIST error bit (0.13um=3, 90nm=4)
//
// BISTCTL_SYNC_CE         BIST control cell enable
// BISTCTL_SYNC_WE         BIST control write enable
// BISTCTL_DUAL_RCE        BIST control read-side cell enable
// BISTCTL_DUAL_RWE        BIST control read-side write enable
// BISTCTL_DUAL_WCE        BIST control write-side cell enable
// BISTCTL_DUAL_WWE        BIST control write-side write enable
// BISTCTL_ADDR0           BIST control address bus 0
// BISTCTL_ADDR1           BIST control address bus 1
// BISTCTL_TEST0           BIST control data bus 0
// BISTCTL_TEST1           BIST control data bus 1
// BISTCTL_CMASK_EN        BIST control compare mask enable
// BISTCTL_CMASK           BIST control compare mask bus
// BISTCTL_PE              BIST control PE bus
// BISTCTL_LP1_BIST        BIST control light sleep mode
// BISTCTL_LP2_BIST        BIST control deep sleep mode
// BISTCTL_LP3_BIST        BIST control shutdown mode
// BISTCTL_SIDE            BIST control side select
// BISTCTL_BIST            BIST control bist mode enable
// BISTCTL_RESET           BIST control bist mode reset (1 bit)
// BISTCTL_WIDTH           BIST control width
//
// BISTWRAP_WORD           BIST wrapper word
// BISTWRAP_WIDTH          BIST wrapper width
//
// RM_SEL_NORMAL           BIST RM normal mode
// RM_SEL_BIST             BIST RM BIST mode
// RM_SEL_BACKDOOR         BIST RM backdoor mode
//
// BIST_LOW                BIST low 
// BIST_HIGH               BIST high
// BIST_FALSE              BIST false
// BIST_TRUE               BIST true
// BIST_ECC_OFF            BIST ECC off
// BIST_ECC_ON             BIST ECC on
// BIST_PIPELINE_OFF       BIST pipeline off
// BIST_PIPELINE_ON        BIST pipeline on
// BIST_BYPASS_FF_OFF      BIST bypass flip flop off
// BIST_BYPASS_FF_ON       BIST bypass flip flop on
// BIST_BYPASS_FLL_OFF     BIST bypass FLL off
//
////////////////////////////////////////////////////////////////////////////////

  parameter BIST_NUM                = 73;
  parameter BIST_ADDR_WIDTH         = 13;
  parameter BIST_DATA_WIDTH         = 104;
  parameter BIST_CMASK_WIDTH        = 7;
  parameter BIST_ECC_NUM            = 73;
  parameter BIST_NO_ECC_NUM         = 0;
  parameter BIST_ROM_NUM            = 0;
  parameter BISTACK_WIDTH           = 1;
  parameter BISTACKECC_WIDTH        = 73;
  parameter BISTACKROM_WIDTH        = 1;
  
  parameter BISTCTL_ERR_INJECT      = 0;
  parameter BISTCTL_SYNC_CE         = BIST_ERR_INJECT_WIDTH;
  parameter BISTCTL_SYNC_WE         = BISTCTL_SYNC_CE + 1;
  parameter BISTCTL_DUAL_RCE        = BISTCTL_SYNC_WE + 1;
  parameter BISTCTL_DUAL_RWE        = BISTCTL_DUAL_RCE + 1;
  parameter BISTCTL_DUAL_WCE        = BISTCTL_DUAL_RWE + 1;
  parameter BISTCTL_DUAL_WWE        = BISTCTL_DUAL_WCE + 1;
  parameter BISTCTL_ADDR0           = BISTCTL_DUAL_WWE + 1;
  parameter BISTCTL_ADDR1           = BISTCTL_ADDR0 + BIST_ADDR_WIDTH;
  parameter BISTCTL_TEST0           = BISTCTL_ADDR1 + BIST_ADDR_WIDTH;
  parameter BISTCTL_TEST1           = BISTCTL_TEST0 + BIST_SEED_WIDTH;
  parameter BISTCTL_CMASK_EN        = BISTCTL_TEST1 + BIST_SEED_WIDTH;
  parameter BISTCTL_CMASK           = BISTCTL_CMASK_EN + 1;
  parameter BISTCTL_PE              = BISTCTL_CMASK + BIST_CMASK_WIDTH;
  parameter BISTCTL_LP1_BIST        = BISTCTL_PE + BIST_PE_WIDTH;
  parameter BISTCTL_LP2_BIST        = BISTCTL_LP1_BIST + 1;
  parameter BISTCTL_LP3_BIST        = BISTCTL_LP2_BIST + 1;
  parameter BISTCTL_SIDE            = BISTCTL_LP3_BIST + 1;
  parameter BISTCTL_RESET           = BISTCTL_SIDE + 1;
  parameter BISTCTL_BIST            = BISTCTL_RESET + 1;
  parameter BISTCTL_WIDTH           = BISTCTL_BIST + 1;


endpackage


`default_nettype wire
