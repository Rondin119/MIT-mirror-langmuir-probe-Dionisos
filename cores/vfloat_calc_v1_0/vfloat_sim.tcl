
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# vFloatCalc

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:div_gen:5.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
vFloatCalc\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set Div_result [ create_bd_port -dir O -from 31 -to 0 Div_result ]
  set Isat [ create_bd_port -dir I -from 19 -to 0 Isat ]
  set LB_Voltage [ create_bd_port -dir I -from 13 -to 0 LB_Voltage ]
  set LP_current [ create_bd_port -dir I -from 13 -to 0 LP_current ]
  set Temp [ create_bd_port -dir I -from 19 -to 0 Temp ]
  set Temp_lower_lim [ create_bd_port -dir I -from 31 -to 0 Temp_lower_lim ]
  set Temp_upper_lim [ create_bd_port -dir I -from 31 -to 0 Temp_upper_lim ]
  set VFloat_out [ create_bd_port -dir O -from 19 -to 0 VFloat_out ]
  set Volt_out_2 [ create_bd_port -dir O -from 13 -to 0 Volt_out_2 ]
  set adc_clk [ create_bd_port -dir I -type clk adc_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
 ] $adc_clk
  set blk_out [ create_bd_port -dir O -from 15 -to 0 blk_out ]
  set clk_enable [ create_bd_port -dir I clk_enable ]
  set clk_rst [ create_bd_port -dir I clk_rst ]
  set gen_out [ create_bd_port -dir O -from 13 -to 0 gen_out ]

  # Create instance: blk_mem_gen_2, and set properties
  set blk_mem_gen_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_2 ]
  set_property -dict [ list \
   CONFIG.Byte_Size {9} \
   CONFIG.Coe_File {../../../../../../../../../../../../../../../instruments/mirror-langmuir-probe-DIONISOS/cores/vfloat_calc_v1_0/vFloat_lut.coe} \
   CONFIG.EN_SAFETY_CKT {false} \
   CONFIG.Enable_32bit_Address {false} \
   CONFIG.Enable_A {Always_Enabled} \
   CONFIG.Fill_Remaining_Memory_Locations {true} \
   CONFIG.Load_Init_File {true} \
   CONFIG.Operating_Mode_A {READ_FIRST} \
   CONFIG.Read_Width_A {16} \
   CONFIG.Read_Width_B {16} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {true} \
   CONFIG.Use_Byte_Write_Enable {false} \
   CONFIG.Use_RSTA_Pin {false} \
   CONFIG.Write_Depth_A {16384} \
   CONFIG.Write_Width_A {16} \
   CONFIG.Write_Width_B {16} \
   CONFIG.use_bram_block {Stand_Alone} \
 ] $blk_mem_gen_2

  # Create instance: div_gen_1, and set properties
  set div_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:div_gen:5.1 div_gen_1 ]
  set_property -dict [ list \
   CONFIG.dividend_and_quotient_width {14} \
   CONFIG.divisor_width {14} \
   CONFIG.fractional_width {12} \
   CONFIG.latency {30} \
   CONFIG.remainder_type {Fractional} \
 ] $div_gen_1

  # Create instance: vFloatCalc_0, and set properties
  set block_name vFloatCalc
  set block_cell_name vFloatCalc_0
  if { [catch {set vFloatCalc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $vFloatCalc_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net div_gen_1_M_AXIS_DOUT [get_bd_intf_pins div_gen_1/M_AXIS_DOUT] [get_bd_intf_pins vFloatCalc_0/divider]
  connect_bd_intf_net -intf_net vFloatCalc_0_dividend [get_bd_intf_pins div_gen_1/S_AXIS_DIVIDEND] [get_bd_intf_pins vFloatCalc_0/dividend]
  connect_bd_intf_net -intf_net vFloatCalc_0_divisor [get_bd_intf_pins div_gen_1/S_AXIS_DIVISOR] [get_bd_intf_pins vFloatCalc_0/divisor]

  # Create port connections
  connect_bd_net -net Isat_1 [get_bd_ports Isat] [get_bd_pins vFloatCalc_0/iSat]
  connect_bd_net -net LB_Voltage_1 [get_bd_ports LB_Voltage]
  connect_bd_net -net LP_current_1 [get_bd_ports LP_current] [get_bd_pins vFloatCalc_0/LP_current]
  connect_bd_net -net Temp_1 [get_bd_ports Temp] [get_bd_pins vFloatCalc_0/Temp]
  connect_bd_net -net adc_clk_1 [get_bd_ports adc_clk] [get_bd_pins blk_mem_gen_2/clka] [get_bd_pins div_gen_1/aclk] [get_bd_pins vFloatCalc_0/adc_clk]
  connect_bd_net -net blk_mem_gen_2_douta [get_bd_ports blk_out] [get_bd_pins blk_mem_gen_2/douta] [get_bd_pins vFloatCalc_0/BRAMret]
  connect_bd_net -net clk_enable_1 [get_bd_ports clk_enable] [get_bd_pins vFloatCalc_0/clk_en]
  connect_bd_net -net clk_rst_1 [get_bd_ports clk_rst] [get_bd_pins vFloatCalc_0/clk_rst]
  connect_bd_net -net vFloatCalc_0_BRAM_addr [get_bd_ports gen_out] [get_bd_pins blk_mem_gen_2/addra] [get_bd_pins vFloatCalc_0/BRAM_addr]
  connect_bd_net -net vFloatCalc_0_Div_result [get_bd_ports Div_result] [get_bd_pins vFloatCalc_0/Div_result]
  connect_bd_net -net vFloatCalc_0_vFloat [get_bd_ports VFloat_out] [get_bd_pins vFloatCalc_0/vFloat]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

