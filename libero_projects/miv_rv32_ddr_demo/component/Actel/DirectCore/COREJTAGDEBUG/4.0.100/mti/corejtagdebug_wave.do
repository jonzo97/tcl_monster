## ****************************************************************************#
## Microsemi Corporation Proprietary and Confidential
## Copyright 2017 Microsemi Corporation.  All rights reserved.
##
## ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
## ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
## IN ADVANCE IN WRITING.
##
## Description: 
##
## SVN Revision Information:
## SVN $Revision: 37550 $
## SVN $Date: 2021-01-27 16:55:15 +0000 (Wed, 27 Jan 2021) $
##
## Resolved SARs
## SAR      Date     Who   Description
##
## Notes:
##
## ****************************************************************************#
add wave -divider CoreJTAGDebug_TAP_I/F
add wave -radix hexadecimal -label TRSTB         COREJTAGDEBUG_TESTBENCH/UUT/TRSTB
add wave -radix hexadecimal -label TCK           COREJTAGDEBUG_TESTBENCH/UUT//TCK
add wave -radix hexadecimal -label TMS           COREJTAGDEBUG_TESTBENCH/UUT/TMS
add wave -radix hexadecimal -label TDI           COREJTAGDEBUG_TESTBENCH/UUT/TDI
add wave -radix hexadecimal -label TDO           COREJTAGDEBUG_TESTBENCH/UUT/TDO

for {set idx 0} {$idx < 16} {incr idx} {
    add wave -divider [subst CoreJTAGDebug_Target_${idx}_I/F]
    add wave -radix hexadecimal -label [subst TGT_TRSTN_${idx}] COREJTAGDEBUG_TESTBENCH/UUT/[subst TGT_TRSTN_${idx}]
    add wave -radix hexadecimal -label [subst TGT_TCK_${idx}]   COREJTAGDEBUG_TESTBENCH/UUT/[subst TGT_TCK_${idx}]
    add wave -radix hexadecimal -label [subst TGT_TMS_${idx}]   COREJTAGDEBUG_TESTBENCH/UUT/[subst TGT_TMS_${idx}]
    add wave -radix hexadecimal -label [subst TGT_TDI_${idx}]   COREJTAGDEBUG_TESTBENCH/UUT/[subst TGT_TDI_${idx}]
    add wave -radix hexadecimal -label [subst TGT_TDO_${idx}]   COREJTAGDEBUG_TESTBENCH/UUT/[subst TGT_TDO_${idx}]
}

configure wave -namecolwidth 160
configure wave -valuecolwidth 40

WaveRestoreZoom {0 ns} {7000 ns}
