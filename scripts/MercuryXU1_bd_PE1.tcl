
################################################################
# This is a generated script based on design: MercuryXU1
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
set scripts_vivado_version 2018.2
set_property target_language VHDL [current_project]
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_msg_id "BD_TCL-1002" "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source MercuryXU1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu6eg-ffvc900-1-i
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name MercuryXU1

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
update_compile_order -fileset sources_1
set_property  ip_repo_paths  "$origin_dir/ip_lib" [current_project]
update_ip_catalog

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:system_management_wiz:*\
xilinx.com:ip:zynq_ultra_ps_e:*\
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



# Proc to create BD system
proc jesd_system { parentCell nameHier } {



  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
  analog.com:user:axi_ad9250:1.0\
  analog.com:user:util_bsplit:1.0\
  xilinx.com:ip:xlconstant:1.1\
  analog.com:user:util_cpack2:1.0\
  analog.com:user:axi_dmac:1.0\
  xilinx.com:ip:proc_sys_reset:5.0\
  xilinx.com:ip:smartconnect:1.0\
  analog.com:user:jesd204_rx:1.0\
  analog.com:user:axi_jesd204_rx:1.0\
  analog.com:user:axi_adxcvr:1.0\
  analog.com:user:util_adxcvr:1.0\
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

  if { $bCheckIPsPassed != 1 } {
    common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }

  
# Hierarchical cell: axi_jesd_xcvr
proc create_hier_cell_axi_jesd_xcvr { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_axi_jesd_xcvr() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I rx_calign_1
  create_bd_pin -dir O -type clk rx_core_clk
  create_bd_pin -dir I rx_data_0_n
  create_bd_pin -dir I rx_data_0_p
  create_bd_pin -dir I rx_data_1_n
  create_bd_pin -dir I rx_data_1_p
  create_bd_pin -dir I rx_data_2_n
  create_bd_pin -dir I rx_data_2_p
  create_bd_pin -dir I rx_data_3_n
  create_bd_pin -dir I rx_data_3_p
  create_bd_pin -dir I -type clk rx_ref_clk_0
  create_bd_pin -dir I -type clk up_clk
  create_bd_pin -dir I -type rst up_rstn

  # Create instance: axi_ad9250_xcvr, and set properties
  set axi_ad9250_xcvr [ create_bd_cell -type ip -vlnv analog.com:user:axi_adxcvr:1.0 axi_ad9250_xcvr ]
  set_property -dict [ list \
   CONFIG.LPM_OR_DFE_N {0} \
   CONFIG.NUM_OF_LANES {4} \
   CONFIG.OUT_CLK_SEL {0x2} \
   CONFIG.QPLL_ENABLE {0} \
   CONFIG.SYS_CLK_SEL {0x0} \
   CONFIG.TX_OR_RX_N {0} \
 ] $axi_ad9250_xcvr

  # Create instance: util_fmcjesdadc1_xcvr, and set properties
  set util_fmcjesdadc1_xcvr [ create_bd_cell -type ip -vlnv analog.com:user:util_adxcvr:1.0 util_fmcjesdadc1_xcvr ]
  set_property -dict [ list \
   CONFIG.CPLL_FBDIV {2} \
   CONFIG.QPLL_FBDIV {0x080} \
   CONFIG.RX_CDR_CFG {0x03000023ff10200020} \
   CONFIG.RX_CLK25_DIV {10} \
   CONFIG.RX_DFE_LPM_CFG {0x0904} \
   CONFIG.RX_NUM_OF_LANES {4} \
   CONFIG.RX_OUT_DIV {1} \
   CONFIG.RX_PMA_CFG {0x00018480} \
   CONFIG.TX_CLK25_DIV {10} \
   CONFIG.TX_NUM_OF_LANES {0} \
   CONFIG.TX_OUT_DIV {1} \
 ] $util_fmcjesdadc1_xcvr

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_m_axi [get_bd_intf_pins m_axi] [get_bd_intf_pins axi_ad9250_xcvr/m_axi]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_ch_0 [get_bd_intf_pins axi_ad9250_xcvr/up_ch_0] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_rx_0]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_ch_1 [get_bd_intf_pins axi_ad9250_xcvr/up_ch_1] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_rx_1]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_ch_2 [get_bd_intf_pins axi_ad9250_xcvr/up_ch_2] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_rx_2]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_ch_3 [get_bd_intf_pins axi_ad9250_xcvr/up_ch_3] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_rx_3]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_es_0 [get_bd_intf_pins axi_ad9250_xcvr/up_es_0] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_es_0]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_es_1 [get_bd_intf_pins axi_ad9250_xcvr/up_es_1] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_es_1]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_es_2 [get_bd_intf_pins axi_ad9250_xcvr/up_es_2] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_es_2]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_up_es_3 [get_bd_intf_pins axi_ad9250_xcvr/up_es_3] [get_bd_intf_pins util_fmcjesdadc1_xcvr/up_es_3]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins axi_ad9250_xcvr/s_axi]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_0 [get_bd_intf_pins rx_0] [get_bd_intf_pins util_fmcjesdadc1_xcvr/rx_0]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_1 [get_bd_intf_pins rx_1] [get_bd_intf_pins util_fmcjesdadc1_xcvr/rx_1]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_2 [get_bd_intf_pins rx_2] [get_bd_intf_pins util_fmcjesdadc1_xcvr/rx_2]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_3 [get_bd_intf_pins rx_3] [get_bd_intf_pins util_fmcjesdadc1_xcvr/rx_3]

  # Create port connections
  connect_bd_net -net axi_ad9250_jesd_phy_en_char_align [get_bd_pins rx_calign_1] [get_bd_pins util_fmcjesdadc1_xcvr/rx_calign_0] [get_bd_pins util_fmcjesdadc1_xcvr/rx_calign_1] [get_bd_pins util_fmcjesdadc1_xcvr/rx_calign_2] [get_bd_pins util_fmcjesdadc1_xcvr/rx_calign_3]
  connect_bd_net -net axi_ad9250_xcvr_up_pll_rst [get_bd_pins axi_ad9250_xcvr/up_pll_rst] [get_bd_pins util_fmcjesdadc1_xcvr/up_cpll_rst_0] [get_bd_pins util_fmcjesdadc1_xcvr/up_cpll_rst_1] [get_bd_pins util_fmcjesdadc1_xcvr/up_cpll_rst_2] [get_bd_pins util_fmcjesdadc1_xcvr/up_cpll_rst_3] [get_bd_pins util_fmcjesdadc1_xcvr/up_qpll_rst_0]
  connect_bd_net -net rx_data_0_n_1 [get_bd_pins rx_data_0_n] [get_bd_pins util_fmcjesdadc1_xcvr/rx_0_n]
  connect_bd_net -net rx_data_0_p_1 [get_bd_pins rx_data_0_p] [get_bd_pins util_fmcjesdadc1_xcvr/rx_0_p]
  connect_bd_net -net rx_data_1_n_1 [get_bd_pins rx_data_1_n] [get_bd_pins util_fmcjesdadc1_xcvr/rx_1_n]
  connect_bd_net -net rx_data_1_p_1 [get_bd_pins rx_data_1_p] [get_bd_pins util_fmcjesdadc1_xcvr/rx_1_p]
  connect_bd_net -net rx_data_2_n_1 [get_bd_pins rx_data_2_n] [get_bd_pins util_fmcjesdadc1_xcvr/rx_2_n]
  connect_bd_net -net rx_data_2_p_1 [get_bd_pins rx_data_2_p] [get_bd_pins util_fmcjesdadc1_xcvr/rx_2_p]
  connect_bd_net -net rx_data_3_n_1 [get_bd_pins rx_data_3_n] [get_bd_pins util_fmcjesdadc1_xcvr/rx_3_n]
  connect_bd_net -net rx_data_3_p_1 [get_bd_pins rx_data_3_p] [get_bd_pins util_fmcjesdadc1_xcvr/rx_3_p]
  connect_bd_net -net rx_ref_clk_1 [get_bd_pins rx_ref_clk] [get_bd_pins util_fmcjesdadc1_xcvr/cpll_ref_clk_0] [get_bd_pins util_fmcjesdadc1_xcvr/cpll_ref_clk_1] [get_bd_pins util_fmcjesdadc1_xcvr/cpll_ref_clk_2] [get_bd_pins util_fmcjesdadc1_xcvr/cpll_ref_clk_3] [get_bd_pins util_fmcjesdadc1_xcvr/qpll_ref_clk_0]
  connect_bd_net -net sys_cpu_clk [get_bd_pins up_clk] [get_bd_pins axi_ad9250_xcvr/s_axi_aclk] [get_bd_pins util_fmcjesdadc1_xcvr/up_clk]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins up_rstn] [get_bd_pins axi_ad9250_xcvr/s_axi_aresetn] [get_bd_pins util_fmcjesdadc1_xcvr/up_rstn]
  connect_bd_net -net util_fmcjesdadc1_xcvr_rx_out_clk_0 [get_bd_pins rx_core_clk] [get_bd_pins util_fmcjesdadc1_xcvr/rx_clk_0] [get_bd_pins util_fmcjesdadc1_xcvr/rx_clk_1] [get_bd_pins util_fmcjesdadc1_xcvr/rx_clk_2] [get_bd_pins util_fmcjesdadc1_xcvr/rx_clk_3] [get_bd_pins util_fmcjesdadc1_xcvr/rx_out_clk_0]
  connect_bd_net [get_bd_pins axi_spi/ext_spi_clk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
  connect_bd_net [get_bd_pins jesd/adc_dma/ext_reset_in1] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  
# Hierarchical cell: axi_ad9250_jesd
proc create_hier_cell_axi_ad9250_jesd { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_axi_ad9250_jesd() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_jesd204:jesd204_rx_bus_rtl:1.0 rx_phy3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi


  # Create pins
  create_bd_pin -dir I -type clk device_clk
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir O phy_en_char_align
  create_bd_pin -dir O -from 127 -to 0 rx_data_tdata
  create_bd_pin -dir O rx_data_tvalid
  create_bd_pin -dir O -from 3 -to 0 rx_eof
  create_bd_pin -dir O -from 3 -to 0 rx_sof
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn
  create_bd_pin -dir O -from 0 -to 0 sync
  create_bd_pin -dir I sysref

  # Create instance: rx, and set properties
  set rx [ create_bd_cell -type ip -vlnv analog.com:user:jesd204_rx:1.0 rx ]
  set_property -dict [ list \
   CONFIG.NUM_LANES {4} \
   CONFIG.NUM_LINKS {1} \
 ] $rx

  # Create instance: rx_axi, and set properties
  set rx_axi [ create_bd_cell -type ip -vlnv analog.com:user:axi_jesd204_rx:1.0 rx_axi ]
  set_property -dict [ list \
   CONFIG.NUM_LANES {4} \
   CONFIG.NUM_LINKS {1} \
 ] $rx_axi

  # Create interface connections
  connect_bd_intf_net -intf_net rx_axi_rx_cfg [get_bd_intf_pins rx/rx_cfg] [get_bd_intf_pins rx_axi/rx_cfg]
  connect_bd_intf_net -intf_net rx_phy0_1 [get_bd_intf_pins rx_phy0] [get_bd_intf_pins rx/rx_phy0]
  connect_bd_intf_net -intf_net rx_phy1_1 [get_bd_intf_pins rx_phy1] [get_bd_intf_pins rx/rx_phy1]
  connect_bd_intf_net -intf_net rx_phy2_1 [get_bd_intf_pins rx_phy2] [get_bd_intf_pins rx/rx_phy2]
  connect_bd_intf_net -intf_net rx_phy3_1 [get_bd_intf_pins rx_phy3] [get_bd_intf_pins rx/rx_phy3]
  connect_bd_intf_net -intf_net rx_rx_event [get_bd_intf_pins rx/rx_event] [get_bd_intf_pins rx_axi/rx_event]
  connect_bd_intf_net -intf_net rx_rx_ilas_config [get_bd_intf_pins rx/rx_ilas_config] [get_bd_intf_pins rx_axi/rx_ilas_config]
  connect_bd_intf_net -intf_net rx_rx_status [get_bd_intf_pins rx/rx_status] [get_bd_intf_pins rx_axi/rx_status]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi] [get_bd_intf_pins rx_axi/s_axi]

  # Create port connections
  connect_bd_net -net device_clk_1 [get_bd_pins device_clk] [get_bd_pins rx/clk] [get_bd_pins rx_axi/core_clk]
  connect_bd_net -net rx_axi_core_reset [get_bd_pins rx/reset] [get_bd_pins rx_axi/core_reset]
  connect_bd_net -net rx_axi_irq [get_bd_pins irq] [get_bd_pins rx_axi/irq]
  connect_bd_net -net rx_phy_en_char_align [get_bd_pins phy_en_char_align] [get_bd_pins rx/phy_en_char_align]
  connect_bd_net -net rx_rx_data [get_bd_pins rx_data_tdata] [get_bd_pins rx/rx_data]
  connect_bd_net -net rx_rx_eof [get_bd_pins rx_eof] [get_bd_pins rx/rx_eof]
  connect_bd_net -net rx_rx_sof [get_bd_pins rx_sof] [get_bd_pins rx/rx_sof]
  connect_bd_net -net rx_rx_valid [get_bd_pins rx_data_tvalid] [get_bd_pins rx/rx_valid]
  connect_bd_net -net rx_sync [get_bd_pins sync] [get_bd_pins rx/sync]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins s_axi_aclk] [get_bd_pins rx_axi/s_axi_aclk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins s_axi_aresetn] [get_bd_pins rx_axi/s_axi_aresetn]
  connect_bd_net -net sysref_1 [get_bd_pins sysref] [get_bd_pins rx/sysref]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  
# Hierarchical cell: adc_dma
proc create_hier_cell_adc_dma { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_adc_dma() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi1


  # Create pins
  create_bd_pin -dir O -from 0 -to 0 dout
  create_bd_pin -dir I enable_0
  create_bd_pin -dir I enable_1
  create_bd_pin -dir I enable_2
  create_bd_pin -dir I enable_3
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir I -type rst ext_reset_in1
  create_bd_pin -dir I -type clk fifo_wr_clk
  create_bd_pin -dir I -type clk fifo_wr_clk1
  create_bd_pin -dir I -from 31 -to 0 fifo_wr_data_0
  create_bd_pin -dir I -from 31 -to 0 fifo_wr_data_1
  create_bd_pin -dir I -from 31 -to 0 fifo_wr_data_2
  create_bd_pin -dir I -from 31 -to 0 fifo_wr_data_3
  create_bd_pin -dir I fifo_wr_en
  create_bd_pin -dir I fifo_wr_en1
  create_bd_pin -dir O fifo_wr_overflow
  create_bd_pin -dir O fifo_wr_overflow1
  create_bd_pin -dir O -type intr irq
  create_bd_pin -dir O -type intr irq1
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_reset
  create_bd_pin -dir I -type clk rx_core_clk
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type clk slowest_sync_clk

  # Create instance: GND_1, and set properties
  set GND_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 GND_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {1} \
 ] $GND_1

  # Create instance: axi_ad9250_0_cpack, and set properties
  set axi_ad9250_0_cpack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack2:1.0 axi_ad9250_0_cpack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLES_PER_CHANNEL {2} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $axi_ad9250_0_cpack

  # Create instance: axi_ad9250_0_dma, and set properties
  set axi_ad9250_0_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9250_0_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {false} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {64} \
   CONFIG.DMA_DATA_WIDTH_SRC {64} \
   CONFIG.DMA_LENGTH_WIDTH {24} \
   CONFIG.DMA_TYPE_DEST {0} \
   CONFIG.DMA_TYPE_SRC {2} \
   CONFIG.FIFO_SIZE {8} \
   CONFIG.ID {0} \
   CONFIG.SYNC_TRANSFER_START {true} \
 ] $axi_ad9250_0_dma

  # Create instance: axi_ad9250_1_cpack, and set properties
  set axi_ad9250_1_cpack [ create_bd_cell -type ip -vlnv analog.com:user:util_cpack2:1.0 axi_ad9250_1_cpack ]
  set_property -dict [ list \
   CONFIG.NUM_OF_CHANNELS {2} \
   CONFIG.SAMPLES_PER_CHANNEL {2} \
   CONFIG.SAMPLE_DATA_WIDTH {16} \
 ] $axi_ad9250_1_cpack

  # Create instance: axi_ad9250_1_dma, and set properties
  set axi_ad9250_1_dma [ create_bd_cell -type ip -vlnv analog.com:user:axi_dmac:1.0 axi_ad9250_1_dma ]
  set_property -dict [ list \
   CONFIG.AXI_SLICE_DEST {false} \
   CONFIG.AXI_SLICE_SRC {false} \
   CONFIG.CYCLIC {false} \
   CONFIG.DMA_2D_TRANSFER {false} \
   CONFIG.DMA_DATA_WIDTH_DEST {64} \
   CONFIG.DMA_DATA_WIDTH_SRC {64} \
   CONFIG.DMA_LENGTH_WIDTH {24} \
   CONFIG.DMA_TYPE_DEST {0} \
   CONFIG.DMA_TYPE_SRC {2} \
   CONFIG.ID {0} \
   CONFIG.SYNC_TRANSFER_START {true} \
 ] $axi_ad9250_1_dma

  # Create instance: axi_ad9250_jesd_rstgen, and set properties
  set axi_ad9250_jesd_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 axi_ad9250_jesd_rstgen ]

  # Create instance: axi_hp2_interconnect, and set properties
  set axi_hp2_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp2_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_hp2_interconnect

  # Create instance: axi_hp3_interconnect, and set properties
  set axi_hp3_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_hp3_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {1} \
 ] $axi_hp3_interconnect

  # Create instance: sys_250m_rstgen, and set properties
  set sys_250m_rstgen [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 sys_250m_rstgen ]
  set_property -dict [ list \
   CONFIG.C_EXT_RST_WIDTH {1} \
 ] $sys_250m_rstgen

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ad9250_0_cpack_packed_fifo_wr [get_bd_intf_pins axi_ad9250_0_cpack/packed_fifo_wr] [get_bd_intf_pins axi_ad9250_0_dma/fifo_wr]
  connect_bd_intf_net -intf_net axi_ad9250_0_dma_m_dest_axi [get_bd_intf_pins axi_ad9250_0_dma/m_dest_axi] [get_bd_intf_pins axi_hp2_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_ad9250_1_cpack_packed_fifo_wr [get_bd_intf_pins axi_ad9250_1_cpack/packed_fifo_wr] [get_bd_intf_pins axi_ad9250_1_dma/fifo_wr]
  connect_bd_intf_net -intf_net axi_ad9250_1_dma_m_dest_axi [get_bd_intf_pins axi_ad9250_1_dma/m_dest_axi] [get_bd_intf_pins axi_hp2_interconnect/S01_AXI]
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_m_axi [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_hp3_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins s_axi1] [get_bd_intf_pins axi_ad9250_0_dma/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins axi_ad9250_1_dma/s_axi]
  connect_bd_intf_net -intf_net axi_hp2_interconnect_M00_AXI [get_bd_intf_pins M00_AXI1] [get_bd_intf_pins axi_hp2_interconnect/M00_AXI]
  connect_bd_intf_net -intf_net axi_hp3_interconnect_M00_AXI [get_bd_intf_pins M00_AXI] [get_bd_intf_pins axi_hp3_interconnect/M00_AXI]

  # Create port connections
  connect_bd_net -net GND_1_dout [get_bd_pins dout] [get_bd_pins GND_1/dout]
  connect_bd_net -net axi_ad9250_0_core_adc_clk [get_bd_pins fifo_wr_clk1] [get_bd_pins axi_ad9250_0_dma/fifo_wr_clk]
  connect_bd_net -net axi_ad9250_0_core_adc_data_a [get_bd_pins fifo_wr_data_0] [get_bd_pins axi_ad9250_0_cpack/fifo_wr_data_0]
  connect_bd_net -net axi_ad9250_0_core_adc_data_b [get_bd_pins fifo_wr_data_1] [get_bd_pins axi_ad9250_0_cpack/fifo_wr_data_1]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_a [get_bd_pins enable_0] [get_bd_pins axi_ad9250_0_cpack/enable_0]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_b [get_bd_pins enable_1] [get_bd_pins axi_ad9250_0_cpack/enable_1]
  connect_bd_net -net axi_ad9250_0_core_adc_valid_a [get_bd_pins fifo_wr_en] [get_bd_pins axi_ad9250_0_cpack/fifo_wr_en]
  connect_bd_net -net axi_ad9250_0_cpack_fifo_wr_overflow [get_bd_pins fifo_wr_overflow] [get_bd_pins axi_ad9250_0_cpack/fifo_wr_overflow]
  connect_bd_net -net axi_ad9250_0_dma_irq [get_bd_pins irq1] [get_bd_pins axi_ad9250_0_dma/irq]
  connect_bd_net -net axi_ad9250_1_core_adc_clk [get_bd_pins fifo_wr_clk] [get_bd_pins axi_ad9250_1_dma/fifo_wr_clk]
  connect_bd_net -net axi_ad9250_1_core_adc_data_a [get_bd_pins fifo_wr_data_2] [get_bd_pins axi_ad9250_1_cpack/fifo_wr_data_0]
  connect_bd_net -net axi_ad9250_1_core_adc_data_b [get_bd_pins fifo_wr_data_3] [get_bd_pins axi_ad9250_1_cpack/fifo_wr_data_1]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_a [get_bd_pins enable_2] [get_bd_pins axi_ad9250_1_cpack/enable_0]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_b [get_bd_pins enable_3] [get_bd_pins axi_ad9250_1_cpack/enable_1]
  connect_bd_net -net axi_ad9250_1_core_adc_valid_a [get_bd_pins fifo_wr_en1] [get_bd_pins axi_ad9250_1_cpack/fifo_wr_en]
  connect_bd_net -net axi_ad9250_1_cpack_fifo_wr_overflow [get_bd_pins fifo_wr_overflow1] [get_bd_pins axi_ad9250_1_cpack/fifo_wr_overflow]
  connect_bd_net -net axi_ad9250_1_dma_irq [get_bd_pins irq] [get_bd_pins axi_ad9250_1_dma/irq]
  connect_bd_net -net axi_ad9250_jesd_rstgen_peripheral_reset [get_bd_pins axi_ad9250_0_cpack/reset] [get_bd_pins axi_ad9250_1_cpack/reset] [get_bd_pins axi_ad9250_jesd_rstgen/peripheral_reset]
  connect_bd_net -net sys_250m_clk [get_bd_pins slowest_sync_clk] [get_bd_pins axi_ad9250_0_dma/m_dest_axi_aclk] [get_bd_pins axi_ad9250_1_dma/m_dest_axi_aclk] [get_bd_pins axi_hp2_interconnect/aclk] [get_bd_pins sys_250m_rstgen/slowest_sync_clk]
  connect_bd_net -net sys_250m_reset [get_bd_pins peripheral_reset] [get_bd_pins sys_250m_rstgen/peripheral_reset]
  connect_bd_net -net sys_250m_resetn [get_bd_pins axi_ad9250_0_dma/m_dest_axi_aresetn] [get_bd_pins axi_ad9250_1_dma/m_dest_axi_aresetn] [get_bd_pins axi_hp2_interconnect/aresetn] [get_bd_pins sys_250m_rstgen/peripheral_aresetn]
  connect_bd_net -net sys_cpu_clk [get_bd_pins s_axi_aclk] [get_bd_pins axi_ad9250_0_dma/s_axi_aclk] [get_bd_pins axi_ad9250_1_dma/s_axi_aclk] [get_bd_pins axi_hp3_interconnect/aclk]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins ext_reset_in] [get_bd_pins axi_ad9250_0_dma/s_axi_aresetn] [get_bd_pins axi_ad9250_1_dma/s_axi_aresetn] [get_bd_pins axi_ad9250_jesd_rstgen/ext_reset_in] [get_bd_pins axi_hp3_interconnect/aresetn]
  connect_bd_net -net sys_ps8_pl_resetn0 [get_bd_pins ext_reset_in1] [get_bd_pins sys_250m_rstgen/ext_reset_in]
  connect_bd_net -net util_fmcjesdadc1_xcvr_rx_out_clk_0 [get_bd_pins rx_core_clk] [get_bd_pins axi_ad9250_0_cpack/clk] [get_bd_pins axi_ad9250_1_cpack/clk] [get_bd_pins axi_ad9250_jesd_rstgen/slowest_sync_clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}
  
# Hierarchical cell: adc_core
proc create_hier_cell_adc_core { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_adc_core() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi1


  # Create pins
  create_bd_pin -dir O -type clk adc_clk
  create_bd_pin -dir O -type clk adc_clk1
  create_bd_pin -dir O -from 31 -to 0 adc_data_a
  create_bd_pin -dir O -from 31 -to 0 adc_data_a1
  create_bd_pin -dir O -from 31 -to 0 adc_data_b
  create_bd_pin -dir O -from 31 -to 0 adc_data_b1
  create_bd_pin -dir I adc_dovf
  create_bd_pin -dir I adc_dovf1
  create_bd_pin -dir O adc_enable_a
  create_bd_pin -dir O adc_enable_a1
  create_bd_pin -dir O adc_enable_b
  create_bd_pin -dir O adc_enable_b1
  create_bd_pin -dir O adc_valid_a
  create_bd_pin -dir O adc_valid_a1
  create_bd_pin -dir I -from 127 -to 0 data
  create_bd_pin -dir I -type clk rx_core_clk
  create_bd_pin -dir I -from 3 -to 0 rx_sof
  create_bd_pin -dir I -type clk s_axi_aclk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: axi_ad9250_0_core, and set properties
  set axi_ad9250_0_core [ create_bd_cell -type ip -vlnv analog.com:user:axi_ad9250:1.0 axi_ad9250_0_core ]

  # Create instance: axi_ad9250_1_core, and set properties
  set axi_ad9250_1_core [ create_bd_cell -type ip -vlnv analog.com:user:axi_ad9250:1.0 axi_ad9250_1_core ]

  # Create instance: data_bsplit, and set properties
  set data_bsplit [ create_bd_cell -type ip -vlnv analog.com:user:util_bsplit:1.0 data_bsplit ]
  set_property -dict [ list \
   CONFIG.CHANNEL_DATA_WIDTH {64} \
   CONFIG.NUM_OF_CHANNELS {2} \
 ] $data_bsplit

  # Create interface connections
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins s_axi1] [get_bd_intf_pins axi_ad9250_0_core/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins s_axi] [get_bd_intf_pins axi_ad9250_1_core/s_axi]

  # Create port connections
  connect_bd_net -net axi_ad9250_0_core_adc_clk [get_bd_pins adc_clk1] [get_bd_pins axi_ad9250_0_core/adc_clk]
  connect_bd_net -net axi_ad9250_0_core_adc_data_a [get_bd_pins adc_data_a1] [get_bd_pins axi_ad9250_0_core/adc_data_a]
  connect_bd_net -net axi_ad9250_0_core_adc_data_b [get_bd_pins adc_data_b1] [get_bd_pins axi_ad9250_0_core/adc_data_b]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_a [get_bd_pins adc_enable_a1] [get_bd_pins axi_ad9250_0_core/adc_enable_a]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_b [get_bd_pins adc_enable_b1] [get_bd_pins axi_ad9250_0_core/adc_enable_b]
  connect_bd_net -net axi_ad9250_0_core_adc_valid_a [get_bd_pins adc_valid_a1] [get_bd_pins axi_ad9250_0_core/adc_valid_a]
  connect_bd_net -net axi_ad9250_0_cpack_fifo_wr_overflow [get_bd_pins adc_dovf1] [get_bd_pins axi_ad9250_0_core/adc_dovf]
  connect_bd_net -net axi_ad9250_1_core_adc_clk [get_bd_pins adc_clk] [get_bd_pins axi_ad9250_1_core/adc_clk]
  connect_bd_net -net axi_ad9250_1_core_adc_data_a [get_bd_pins adc_data_a] [get_bd_pins axi_ad9250_1_core/adc_data_a]
  connect_bd_net -net axi_ad9250_1_core_adc_data_b [get_bd_pins adc_data_b] [get_bd_pins axi_ad9250_1_core/adc_data_b]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_a [get_bd_pins adc_enable_a] [get_bd_pins axi_ad9250_1_core/adc_enable_a]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_b [get_bd_pins adc_enable_b] [get_bd_pins axi_ad9250_1_core/adc_enable_b]
  connect_bd_net -net axi_ad9250_1_core_adc_valid_a [get_bd_pins adc_valid_a] [get_bd_pins axi_ad9250_1_core/adc_valid_a]
  connect_bd_net -net axi_ad9250_1_cpack_fifo_wr_overflow [get_bd_pins adc_dovf] [get_bd_pins axi_ad9250_1_core/adc_dovf]
  connect_bd_net -net axi_ad9250_jesd_rx_data_tdata [get_bd_pins data] [get_bd_pins data_bsplit/data]
  connect_bd_net -net axi_ad9250_jesd_rx_sof [get_bd_pins rx_sof] [get_bd_pins axi_ad9250_0_core/rx_sof] [get_bd_pins axi_ad9250_1_core/rx_sof]
  connect_bd_net -net data_bsplit_split_data_0 [get_bd_pins axi_ad9250_0_core/rx_data] [get_bd_pins data_bsplit/split_data_0]
  connect_bd_net -net data_bsplit_split_data_1 [get_bd_pins axi_ad9250_1_core/rx_data] [get_bd_pins data_bsplit/split_data_1]
  connect_bd_net -net sys_cpu_clk [get_bd_pins s_axi_aclk] [get_bd_pins axi_ad9250_0_core/s_axi_aclk] [get_bd_pins axi_ad9250_1_core/s_axi_aclk]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins s_axi_aresetn] [get_bd_pins axi_ad9250_0_core/s_axi_aresetn] [get_bd_pins axi_ad9250_1_core/s_axi_aresetn]
  connect_bd_net -net util_fmcjesdadc1_xcvr_rx_out_clk_0 [get_bd_pins rx_core_clk] [get_bd_pins axi_ad9250_0_core/rx_clk] [get_bd_pins axi_ad9250_1_core/rx_clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_axi_jesd_xcvr() - Empty argument(s)!"}
     return
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

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface ports

  # Create ports
  set rx_core_clk [ create_bd_port -dir O rx_core_clk ]
  set rx_data_0_n [ create_bd_port -dir I rx_data_0_n ]
  set rx_data_0_p [ create_bd_port -dir I rx_data_0_p ]
  set rx_data_1_n [ create_bd_port -dir I rx_data_1_n ]
  set rx_data_1_p [ create_bd_port -dir I rx_data_1_p ]
  set rx_data_2_n [ create_bd_port -dir I rx_data_2_n ]
  set rx_data_2_p [ create_bd_port -dir I rx_data_2_p ]
  set rx_data_3_n [ create_bd_port -dir I rx_data_3_n ]
  set rx_data_3_p [ create_bd_port -dir I rx_data_3_p ]
  set rx_ref_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 rx_ref_clk]
  set rx_sync_0 [ create_bd_port -dir O -from 0 -to 0 rx_sync_0 ]
  set rx_sysref_0 [ create_bd_port -dir I rx_sysref_0 ]

  # Create instance: adc_core
  create_hier_cell_adc_core [current_bd_instance .] adc_core

  # Create instance: adc_dma
  create_hier_cell_adc_dma [current_bd_instance .] adc_dma

  # Create instance: axi_ad9250_jesd
  create_hier_cell_axi_ad9250_jesd [current_bd_instance .] axi_ad9250_jesd

  # Create instance: axi_cpu_interconnect, and set properties
  set axi_cpu_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_cpu_interconnect ]
  set_property -dict [ list \
   CONFIG.NUM_MI {6} \
 ] $axi_cpu_interconnect

  # Create instance: axi_jesd_xcvr
  create_hier_cell_axi_jesd_xcvr [current_bd_instance .] axi_jesd_xcvr

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ad9250_xcvr_m_axi [get_bd_intf_pins adc_dma/S00_AXI] [get_bd_intf_pins axi_jesd_xcvr/m_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M00_AXI [get_bd_intf_pins axi_cpu_interconnect/M00_AXI] [get_bd_intf_pins axi_jesd_xcvr/s_axi]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M01_AXI [get_bd_intf_pins adc_core/s_axi1] [get_bd_intf_pins axi_cpu_interconnect/M01_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M02_AXI [get_bd_intf_pins adc_core/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M02_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M03_AXI [get_bd_intf_pins axi_ad9250_jesd/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M03_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M04_AXI [get_bd_intf_pins adc_dma/s_axi1] [get_bd_intf_pins axi_cpu_interconnect/M04_AXI]
  connect_bd_intf_net -intf_net axi_cpu_interconnect_M05_AXI [get_bd_intf_pins adc_dma/s_axi] [get_bd_intf_pins axi_cpu_interconnect/M05_AXI]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_0 [get_bd_intf_pins axi_ad9250_jesd/rx_phy0] [get_bd_intf_pins axi_jesd_xcvr/rx_0]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_1 [get_bd_intf_pins axi_ad9250_jesd/rx_phy1] [get_bd_intf_pins axi_jesd_xcvr/rx_1]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_2 [get_bd_intf_pins axi_ad9250_jesd/rx_phy2] [get_bd_intf_pins axi_jesd_xcvr/rx_2]
  connect_bd_intf_net -intf_net util_fmcjesdadc1_xcvr_rx_3 [get_bd_intf_pins axi_ad9250_jesd/rx_phy3] [get_bd_intf_pins axi_jesd_xcvr/rx_3]

  # Create port connections
  connect_bd_net -net axi_ad9250_0_core_adc_clk [get_bd_pins adc_core/adc_clk1] [get_bd_pins adc_dma/fifo_wr_clk1]
  connect_bd_net -net axi_ad9250_0_core_adc_data_a [get_bd_pins adc_core/adc_data_a1] [get_bd_pins adc_dma/fifo_wr_data_0]
  connect_bd_net -net axi_ad9250_0_core_adc_data_b [get_bd_pins adc_core/adc_data_b1] [get_bd_pins adc_dma/fifo_wr_data_1]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_a [get_bd_pins adc_core/adc_enable_a1] [get_bd_pins adc_dma/enable_0]
  connect_bd_net -net axi_ad9250_0_core_adc_enable_b [get_bd_pins adc_core/adc_enable_b1] [get_bd_pins adc_dma/enable_1]
  connect_bd_net -net axi_ad9250_0_core_adc_valid_a [get_bd_pins adc_core/adc_valid_a1] [get_bd_pins adc_dma/fifo_wr_en]
  connect_bd_net -net axi_ad9250_0_cpack_fifo_wr_overflow [get_bd_pins adc_core/adc_dovf1] [get_bd_pins adc_dma/fifo_wr_overflow]
  connect_bd_net -net axi_ad9250_1_core_adc_clk [get_bd_pins adc_core/adc_clk] [get_bd_pins adc_dma/fifo_wr_clk]
  connect_bd_net -net axi_ad9250_1_core_adc_data_a [get_bd_pins adc_core/adc_data_a] [get_bd_pins adc_dma/fifo_wr_data_2]
  connect_bd_net -net axi_ad9250_1_core_adc_data_b [get_bd_pins adc_core/adc_data_b] [get_bd_pins adc_dma/fifo_wr_data_3]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_a [get_bd_pins adc_core/adc_enable_a] [get_bd_pins adc_dma/enable_2]
  connect_bd_net -net axi_ad9250_1_core_adc_enable_b [get_bd_pins adc_core/adc_enable_b] [get_bd_pins adc_dma/enable_3]
  connect_bd_net -net axi_ad9250_1_core_adc_valid_a [get_bd_pins adc_core/adc_valid_a] [get_bd_pins adc_dma/fifo_wr_en1]
  connect_bd_net -net axi_ad9250_1_cpack_fifo_wr_overflow [get_bd_pins adc_core/adc_dovf] [get_bd_pins adc_dma/fifo_wr_overflow1]
  connect_bd_net -net axi_ad9250_jesd_phy_en_char_align [get_bd_pins axi_ad9250_jesd/phy_en_char_align] [get_bd_pins axi_jesd_xcvr/rx_calign_1]
  connect_bd_net -net axi_ad9250_jesd_rx_data_tdata [get_bd_pins adc_core/data] [get_bd_pins axi_ad9250_jesd/rx_data_tdata]
  connect_bd_net -net axi_ad9250_jesd_rx_sof [get_bd_pins adc_core/rx_sof] [get_bd_pins axi_ad9250_jesd/rx_sof]
  connect_bd_net -net axi_ad9250_jesd_sync [get_bd_ports rx_sync_0] [get_bd_pins axi_ad9250_jesd/sync]
  connect_bd_net -net rx_data_0_n_1 [get_bd_ports rx_data_0_n] [get_bd_pins axi_jesd_xcvr/rx_data_0_n]
  connect_bd_net -net rx_data_0_p_1 [get_bd_ports rx_data_0_p] [get_bd_pins axi_jesd_xcvr/rx_data_0_p]
  connect_bd_net -net rx_data_1_n_1 [get_bd_ports rx_data_1_n] [get_bd_pins axi_jesd_xcvr/rx_data_1_n]
  connect_bd_net -net rx_data_1_p_1 [get_bd_ports rx_data_1_p] [get_bd_pins axi_jesd_xcvr/rx_data_1_p]
  connect_bd_net -net rx_data_2_n_1 [get_bd_ports rx_data_2_n] [get_bd_pins axi_jesd_xcvr/rx_data_2_n]
  connect_bd_net -net rx_data_2_p_1 [get_bd_ports rx_data_2_p] [get_bd_pins axi_jesd_xcvr/rx_data_2_p]
  connect_bd_net -net rx_data_3_n_1 [get_bd_ports rx_data_3_n] [get_bd_pins axi_jesd_xcvr/rx_data_3_n]
  connect_bd_net -net rx_data_3_p_1 [get_bd_ports rx_data_3_p] [get_bd_pins axi_jesd_xcvr/rx_data_3_p]
  connect_bd_net -net rx_ref_clk_1 [get_bd_ports rx_ref_clk] [get_bd_pins axi_jesd_xcvr/rx_ref_clk_0]
  connect_bd_net -net sys_250m_reset -boundary_type upper [get_bd_pins adc_dma/peripheral_reset]
  connect_bd_net -net sys_cpu_clk [get_bd_pins adc_core/s_axi_aclk] [get_bd_pins adc_dma/s_axi_aclk] [get_bd_pins axi_ad9250_jesd/s_axi_aclk] [get_bd_pins axi_cpu_interconnect/ACLK] [get_bd_pins axi_cpu_interconnect/M00_ACLK] [get_bd_pins axi_cpu_interconnect/M01_ACLK] [get_bd_pins axi_cpu_interconnect/M02_ACLK] [get_bd_pins axi_cpu_interconnect/M03_ACLK] [get_bd_pins axi_cpu_interconnect/M04_ACLK] [get_bd_pins axi_cpu_interconnect/M05_ACLK] [get_bd_pins axi_cpu_interconnect/S00_ACLK] [get_bd_pins axi_jesd_xcvr/up_clk]
  connect_bd_net -net sys_cpu_resetn [get_bd_pins adc_core/s_axi_aresetn] [get_bd_pins adc_dma/ext_reset_in] [get_bd_pins axi_ad9250_jesd/s_axi_aresetn] [get_bd_pins axi_cpu_interconnect/ARESETN] [get_bd_pins axi_cpu_interconnect/M00_ARESETN] [get_bd_pins axi_cpu_interconnect/M01_ARESETN] [get_bd_pins axi_cpu_interconnect/M02_ARESETN] [get_bd_pins axi_cpu_interconnect/M03_ARESETN] [get_bd_pins axi_cpu_interconnect/M04_ARESETN] [get_bd_pins axi_cpu_interconnect/M05_ARESETN] [get_bd_pins axi_cpu_interconnect/S00_ARESETN] [get_bd_pins axi_jesd_xcvr/up_rstn]
  connect_bd_net -net sysref_1 [get_bd_ports rx_sysref_0] [get_bd_pins axi_ad9250_jesd/sysref]
  connect_bd_net -net util_fmcjesdadc1_xcvr_rx_out_clk_0 [get_bd_ports rx_core_clk] [get_bd_pins adc_core/rx_core_clk] [get_bd_pins adc_dma/rx_core_clk] [get_bd_pins axi_ad9250_jesd/device_clk] [get_bd_pins axi_jesd_xcvr/rx_core_clk]

  # Create address segments
  current_bd_instance $oldCurInst

}



  # Create interface ports
  set GPIO [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 GPIO ]

  # Create ports
  set pl_clk1 [ create_bd_port -dir O -type clk pl_clk1 ]
  set pl_resetn0 [ create_bd_port -dir O -type rst pl_resetn0 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_GPIO_WIDTH {8} \
 ] $axi_gpio_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $axi_interconnect_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset proc_sys_reset_0 ]

  # Create instance: system_management_wiz_0, and set properties
  set system_management_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_management_wiz system_management_wiz_0 ]
  set_property -dict [ list \
   CONFIG.TEMPERATURE_ALARM_OT_TRIGGER {85.0} \
 ] $system_management_wiz_0

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e zynq_ultra_ps_e_0 ]
  set_property -dict [ list \
   CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
   CONFIG.PSU_DDR_RAM_HIGHADDR {0x7FFFFFFF} \
   CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x00000002} \
   CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
   CONFIG.PSU_MIO_0_DIRECTION {out} \
   CONFIG.PSU_MIO_0_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_0_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_10_DIRECTION {inout} \
   CONFIG.PSU_MIO_11_DIRECTION {inout} \
   CONFIG.PSU_MIO_12_DIRECTION {inout} \
   CONFIG.PSU_MIO_12_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_12_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_13_DIRECTION {inout} \
   CONFIG.PSU_MIO_13_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_14_DIRECTION {inout} \
   CONFIG.PSU_MIO_14_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_15_DIRECTION {inout} \
   CONFIG.PSU_MIO_15_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_16_DIRECTION {inout} \
   CONFIG.PSU_MIO_16_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_17_DIRECTION {inout} \
   CONFIG.PSU_MIO_17_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_18_DIRECTION {inout} \
   CONFIG.PSU_MIO_18_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_19_DIRECTION {inout} \
   CONFIG.PSU_MIO_19_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_1_DIRECTION {inout} \
   CONFIG.PSU_MIO_1_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_20_DIRECTION {inout} \
   CONFIG.PSU_MIO_20_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_21_DIRECTION {inout} \
   CONFIG.PSU_MIO_21_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_22_DIRECTION {out} \
   CONFIG.PSU_MIO_22_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_22_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_23_DIRECTION {inout} \
   CONFIG.PSU_MIO_23_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_24_DIRECTION {inout} \
   CONFIG.PSU_MIO_25_DIRECTION {inout} \
   CONFIG.PSU_MIO_26_DIRECTION {out} \
   CONFIG.PSU_MIO_26_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_26_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_27_DIRECTION {out} \
   CONFIG.PSU_MIO_27_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_27_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_28_DIRECTION {out} \
   CONFIG.PSU_MIO_28_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_28_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_29_DIRECTION {out} \
   CONFIG.PSU_MIO_29_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_29_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_2_DIRECTION {inout} \
   CONFIG.PSU_MIO_2_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_30_DIRECTION {out} \
   CONFIG.PSU_MIO_30_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_30_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_31_DIRECTION {out} \
   CONFIG.PSU_MIO_31_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_31_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_32_DIRECTION {in} \
   CONFIG.PSU_MIO_32_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_32_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_32_SLEW {slow} \
   CONFIG.PSU_MIO_33_DIRECTION {in} \
   CONFIG.PSU_MIO_33_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_33_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_33_SLEW {slow} \
   CONFIG.PSU_MIO_34_DIRECTION {in} \
   CONFIG.PSU_MIO_34_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_34_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_34_SLEW {slow} \
   CONFIG.PSU_MIO_35_DIRECTION {in} \
   CONFIG.PSU_MIO_35_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_35_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_35_SLEW {slow} \
   CONFIG.PSU_MIO_36_DIRECTION {in} \
   CONFIG.PSU_MIO_36_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_36_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_36_SLEW {slow} \
   CONFIG.PSU_MIO_37_DIRECTION {in} \
   CONFIG.PSU_MIO_37_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_37_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_37_SLEW {slow} \
   CONFIG.PSU_MIO_38_DIRECTION {in} \
   CONFIG.PSU_MIO_38_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_38_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_38_SLEW {slow} \
   CONFIG.PSU_MIO_39_DIRECTION {out} \
   CONFIG.PSU_MIO_39_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_39_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_3_DIRECTION {inout} \
   CONFIG.PSU_MIO_3_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_40_DIRECTION {inout} \
   CONFIG.PSU_MIO_41_DIRECTION {inout} \
   CONFIG.PSU_MIO_42_DIRECTION {inout} \
   CONFIG.PSU_MIO_43_DIRECTION {inout} \
   CONFIG.PSU_MIO_44_DIRECTION {inout} \
   CONFIG.PSU_MIO_45_DIRECTION {inout} \
   CONFIG.PSU_MIO_45_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_45_SLEW {slow} \
   CONFIG.PSU_MIO_46_DIRECTION {inout} \
   CONFIG.PSU_MIO_46_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_47_DIRECTION {inout} \
   CONFIG.PSU_MIO_47_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_48_DIRECTION {inout} \
   CONFIG.PSU_MIO_48_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_49_DIRECTION {inout} \
   CONFIG.PSU_MIO_49_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_4_DIRECTION {inout} \
   CONFIG.PSU_MIO_4_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_50_DIRECTION {inout} \
   CONFIG.PSU_MIO_50_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_51_DIRECTION {out} \
   CONFIG.PSU_MIO_51_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_51_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_52_DIRECTION {in} \
   CONFIG.PSU_MIO_52_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_52_SLEW {slow} \
   CONFIG.PSU_MIO_53_DIRECTION {in} \
   CONFIG.PSU_MIO_53_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_53_SLEW {slow} \
   CONFIG.PSU_MIO_54_DIRECTION {inout} \
   CONFIG.PSU_MIO_55_DIRECTION {in} \
   CONFIG.PSU_MIO_55_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_55_SLEW {slow} \
   CONFIG.PSU_MIO_56_DIRECTION {inout} \
   CONFIG.PSU_MIO_57_DIRECTION {inout} \
   CONFIG.PSU_MIO_58_DIRECTION {out} \
   CONFIG.PSU_MIO_58_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_59_DIRECTION {inout} \
   CONFIG.PSU_MIO_5_DIRECTION {out} \
   CONFIG.PSU_MIO_5_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_5_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_60_DIRECTION {inout} \
   CONFIG.PSU_MIO_61_DIRECTION {inout} \
   CONFIG.PSU_MIO_62_DIRECTION {inout} \
   CONFIG.PSU_MIO_63_DIRECTION {inout} \
   CONFIG.PSU_MIO_64_DIRECTION {out} \
   CONFIG.PSU_MIO_64_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_64_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_64_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_64_SLEW {slow} \
   CONFIG.PSU_MIO_65_DIRECTION {out} \
   CONFIG.PSU_MIO_65_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_65_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_65_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_65_SLEW {slow} \
   CONFIG.PSU_MIO_66_DIRECTION {out} \
   CONFIG.PSU_MIO_66_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_66_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_67_DIRECTION {out} \
   CONFIG.PSU_MIO_67_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_67_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_67_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_67_SLEW {slow} \
   CONFIG.PSU_MIO_68_DIRECTION {out} \
   CONFIG.PSU_MIO_68_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_68_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_69_DIRECTION {out} \
   CONFIG.PSU_MIO_69_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_69_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_6_DIRECTION {out} \
   CONFIG.PSU_MIO_6_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_6_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_70_DIRECTION {in} \
   CONFIG.PSU_MIO_70_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_70_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_70_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_70_SLEW {slow} \
   CONFIG.PSU_MIO_71_DIRECTION {in} \
   CONFIG.PSU_MIO_71_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_71_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_71_SLEW {slow} \
   CONFIG.PSU_MIO_72_DIRECTION {in} \
   CONFIG.PSU_MIO_72_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_72_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_72_SLEW {slow} \
   CONFIG.PSU_MIO_73_DIRECTION {in} \
   CONFIG.PSU_MIO_73_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_73_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_73_SLEW {slow} \
   CONFIG.PSU_MIO_74_DIRECTION {in} \
   CONFIG.PSU_MIO_74_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_74_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_74_SLEW {slow} \
   CONFIG.PSU_MIO_75_DIRECTION {in} \
   CONFIG.PSU_MIO_75_DRIVE_STRENGTH {12} \
   CONFIG.PSU_MIO_75_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_75_SLEW {slow} \
   CONFIG.PSU_MIO_76_DIRECTION {out} \
   CONFIG.PSU_MIO_76_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_77_DIRECTION {inout} \
   CONFIG.PSU_MIO_7_DIRECTION {inout} \
   CONFIG.PSU_MIO_7_INPUT_TYPE {schmitt} \
   CONFIG.PSU_MIO_7_PULLUPDOWN {disable} \
   CONFIG.PSU_MIO_8_DIRECTION {inout} \
   CONFIG.PSU_MIO_9_DIRECTION {inout} \
   CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#I2C 0#I2C 0#GPIO0 MIO#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#Gem 0#UART 0#UART 0#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 0#MDIO 0} \
   CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#clk_for_lpbk#gpio0[7]#gpio0[8]#gpio0[9]#scl_out#sda_out#gpio0[12]#sdio0_data_out[0]#sdio0_data_out[1]#sdio0_data_out[2]#sdio0_data_out[3]#sdio0_data_out[4]#sdio0_data_out[5]#sdio0_data_out[6]#sdio0_data_out[7]#sdio0_cmd_out#sdio0_clk_out#gpio0[23]#gpio0[24]#gpio0[25]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#rxd#txd#gpio1[40]#gpio1[41]#gpio1[42]#gpio1[43]#gpio1[44]#gpio1[45]#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#ulpi_clk_in#ulpi_dir#ulpi_tx_data[2]#ulpi_nxt#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_stp#ulpi_tx_data[3]#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem0_mdc#gem0_mdio_out} \
   CONFIG.PSU_SD0_INTERNAL_BUS_WIDTH {8} \
   CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
   CONFIG.PSU__ACT_DDR_FREQ_MHZ {1199.988037} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1199.988000} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRF_APB__APLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__APLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {599.994000} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {599.994000} \
   CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FBDIV {72} \
   CONFIG.PSU__CRF_APB__DPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__DPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__DPLL_TO_LPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR0 {63} \
   CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__DIVISOR1 {10} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {599.994000} \
   CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {599.994000} \
   CONFIG.PSU__CRF_APB__GPU_REF_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRF_APB__SATA_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999000} \
   CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {533.328000} \
   CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FBDIV {64} \
   CONFIG.PSU__CRF_APB__VPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRF_APB__VPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRF_APB__VPLL_TO_LPD_CTRL__DIVISOR0 {2} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.995000} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__AFI6_REF_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__AMS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.995000} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.985000} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__ACT_FREQMHZ {124.998750} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.998750} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR0 {12} \
   CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.999000} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRL_APB__IOPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__IOPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__IOPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999000} \
   CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.995000} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__NAND_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.498125} \
   CONFIG.PSU__CRL_APB__PCAP_CTRL__DIVISOR0 {8} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {99.999000} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__PL0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ {50} \
   CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {RPLL} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL2_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR0 {4} \
   CONFIG.PSU__CRL_APB__PL3_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {50} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__DIV2 {1} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FBDIV {90} \
   CONFIG.PSU__CRL_APB__RPLL_CTRL__FRACDATA {0.000000} \
   CONFIG.PSU__CRL_APB__RPLL_FRAC_CFG__ENABLED {0} \
   CONFIG.PSU__CRL_APB__RPLL_TO_FPD_CTRL__DIVISOR0 {3} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__ACT_FREQMHZ {199.998000} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR0 {5} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__FREQMHZ {200} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {49.999500} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR0 {30} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {50} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR0 {7} \
   CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {33.333000} \
   CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__DIVISOR0 {1} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999000} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART0_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR0 {15} \
   CONFIG.PSU__CRL_APB__UART1_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB0_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__ACT_FREQMHZ {249.997500} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR0 {6} \
   CONFIG.PSU__CRL_APB__USB1_BUS_REF_CTRL__DIVISOR1 {1} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__ACT_FREQMHZ {19.999800} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR0 {25} \
   CONFIG.PSU__CRL_APB__USB3_DUAL_REF_CTRL__DIVISOR1 {3} \
   CONFIG.PSU__CRL_APB__USB3__ENABLE {1} \
   CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
   CONFIG.PSU__DDRC__CL {17} \
   CONFIG.PSU__DDRC__CWL {12} \
   CONFIG.PSU__DDRC__DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
   CONFIG.PSU__DDRC__ECC {Enabled} \
   CONFIG.PSU__DDRC__ENABLE_LP4_HAS_ECC_COMP {ERR: 1  | 0} \
   CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
   CONFIG.PSU__DDRC__ROW_ADDR_COUNT {15} \
   CONFIG.PSU__DDRC__SB_TARGET {16-16-16} \
   CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400T} \
   CONFIG.PSU__DDRC__T_FAW {30.0} \
   CONFIG.PSU__DDRC__T_RAS_MIN {32.0} \
   CONFIG.PSU__DDRC__T_RC {46.16} \
   CONFIG.PSU__DDRC__T_RCD {17} \
   CONFIG.PSU__DDRC__T_RP {17} \
   CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {0} \
   CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
   CONFIG.PSU__DLL__ISUSED {1} \
   CONFIG.PSU__ENET0__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET0__GRP_MDIO__ENABLE {1} \
   CONFIG.PSU__ENET0__GRP_MDIO__IO {MIO 76 .. 77} \
   CONFIG.PSU__ENET0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__ENET0__PERIPHERAL__IO {MIO 26 .. 37} \
   CONFIG.PSU__ENET0__PTP__ENABLE {0} \
   CONFIG.PSU__ENET0__TSU__ENABLE {0} \
   CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
   CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {0} \
   CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
   CONFIG.PSU__ENET3__PTP__ENABLE {0} \
   CONFIG.PSU__ENET3__TSU__ENABLE {0} \
   CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
   CONFIG.PSU__FPGA_PL1_ENABLE {1} \
   CONFIG.PSU__GEM0_COHERENCY {0} \
   CONFIG.PSU__GEM3_COHERENCY {0} \
   CONFIG.PSU__GEM__TSU__ENABLE {0} \
   CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
   CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
   CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__HIGH_ADDRESS__ENABLE {0} \
   CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11} \
   CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
   CONFIG.PSU__IOU_SLCR__TTC0__FREQMHZ {100.000000} \
   CONFIG.PSU__PL_CLK1_BUF {TRUE} \
   CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;1|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;1|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;1|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1} \
   CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;1|LPD;USB3_0;FF9D0000;FF9DFFFF;1|LPD;UART1;FF010000;FF01FFFF;0|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;0|LPD;TTC2;FF130000;FF13FFFF;0|LPD;TTC1;FF120000;FF12FFFF;0|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;0|LPD;SWDT0;FF150000;FF15FFFF;0|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;1|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|FPD;RCPU_GIC;F9000000;F900FFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;0|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;1|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_GPV;FD700000;FD7FFFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;800000000;0|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;0|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|FPD;CCI_GPV;FD6E0000;FD6EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9000000;F907FFFF;1} \
   CONFIG.PSU__QSPI_COHERENCY {0} \
   CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
   CONFIG.PSU__QSPI__GRP_FBCLK__IO {MIO 6} \
   CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
   CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
   CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
   CONFIG.PSU__SATA__LANE0__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__ENABLE {0} \
   CONFIG.PSU__SATA__LANE1__IO {<Select>} \
   CONFIG.PSU__SATA__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__SATA__REF_CLK_FREQ {<Select>} \
   CONFIG.PSU__SATA__REF_CLK_SEL {<Select>} \
   CONFIG.PSU__SD0_COHERENCY {0} \
   CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
   CONFIG.PSU__SD0__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD0__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
   CONFIG.PSU__SD0__RESET__ENABLE {0} \
   CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
   CONFIG.PSU__SD1_COHERENCY {0} \
   CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
   CONFIG.PSU__SD1__GRP_CD__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_CD__IO {<Select>} \
   CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
   CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
   CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
   CONFIG.PSU__SD1__RESET__ENABLE {0} \
   CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
   CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
   CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
   CONFIG.PSU__UART0__BAUD_RATE {115200} \
   CONFIG.PSU__UART0__MODEM__ENABLE {0} \
   CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 38 .. 39} \
   CONFIG.PSU__USB0_COHERENCY {0} \
   CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB0__PERIPHERAL__IO {MIO 52 .. 63} \
   CONFIG.PSU__USB0__REF_CLK_FREQ {100} \
   CONFIG.PSU__USB0__REF_CLK_SEL {Ref Clk2} \
   CONFIG.PSU__USB1_COHERENCY {0} \
   CONFIG.PSU__USB1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USB1__PERIPHERAL__IO {<Select>} \
   CONFIG.PSU__USB2_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB2_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
   CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
   CONFIG.PSU__USB3_1__EMIO__ENABLE {0} \
   CONFIG.PSU__USB3_1__PERIPHERAL__ENABLE {0} \
   CONFIG.PSU__USE__M_AXI_GP1 {1} \
   CONFIG.PSU__MAXIGP1__DATA_WIDTH {32} \
   CONFIG.PSU__USE__S_AXI_GP0 {1} CONFIG.PSU__USE__S_AXI_GP1 {1} \
   CONFIG.SUBPRESET1 {Custom} \
 ] $zynq_ultra_ps_e_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports GPIO] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins system_management_wiz_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD]

  # Create port connections
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins system_management_wiz_0/s_axi_aresetn]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins system_management_wiz_0/s_axi_aclk] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] [get_bd_pins zynq_ultra_ps_e_0/pl_clk0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk1 [get_bd_ports pl_clk1] [get_bd_pins zynq_ultra_ps_e_0/pl_clk1]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_ports pl_resetn0] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x80000000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x80010000 [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs system_management_wiz_0/S_AXI_LITE/Reg] SEG_system_management_wiz_0_Reg

  jesd_system [current_bd_instance .] jesd 
  # Restore current instance
  
connect_bd_net [get_bd_ports rx_data_0_n] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_0_n]
connect_bd_net [get_bd_ports rx_data_0_p] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_0_p]
connect_bd_net [get_bd_ports rx_data_1_n] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_1_n]
connect_bd_net [get_bd_ports rx_data_1_p] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_1_p]
connect_bd_net [get_bd_ports rx_data_2_n] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_2_n]
connect_bd_net [get_bd_ports rx_data_2_p] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_2_p]
connect_bd_net [get_bd_ports rx_data_3_n] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_3_n]
connect_bd_net [get_bd_ports rx_data_3_p] [get_bd_pins jesd/axi_jesd_xcvr/rx_data_3_p]
connect_bd_net [get_bd_ports rx_sysref_0] [get_bd_pins jesd/axi_ad9250_jesd/sysref]

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
set_property -dict [list CONFIG.C_BUF_TYPE {IBUFDSGTE}] [get_bd_cells util_ds_buf_0]
connect_bd_intf_net [get_bd_intf_ports rx_ref_clk] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
connect_bd_net [get_bd_pins jesd/axi_jesd_xcvr/rx_ref_clk_0] [get_bd_pins util_ds_buf_0/IBUF_OUT]
move_bd_cells [get_bd_cells jesd] [get_bd_cells util_ds_buf_0] 
#connect_bd_net [get_bd_ports rx_ref_clk_0] [get_bd_pins jesd/rx_ref_clk_0_2]

connect_bd_net [get_bd_ports rx_sync_0] [get_bd_pins jesd/axi_ad9250_jesd/sync]
connect_bd_net [get_bd_ports rx_core_clk] [get_bd_pins jesd/axi_jesd_xcvr/rx_core_clk]
  set axi_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_spi ]
  set_property -dict [ list \
   CONFIG.C_NUM_SS_BITS {8} \
   CONFIG.C_SCK_RATIO {8} \
   CONFIG.C_USE_STARTUP {0} \
 ] $axi_spi
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_slave {Auto} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_LPD} Slave {/axi_spi/AXI_LITE} intc_ip {/axi_interconnect_0} master_apm {0}}  [get_bd_intf_pins axi_spi/AXI_LITE]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/jesd/axi_jesd_xcvr/axi_ad9250_xcvr/m_axi} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC0_FPD} intc_ip {/jesd/adc_dma/axi_hp3_interconnect} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC0_FPD]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/jesd/adc_dma/axi_ad9250_0_dma/m_dest_axi} Slave {/zynq_ultra_ps_e_0/S_AXI_HPC1_FPD} intc_ip {/jesd/adc_dma/axi_hp2_interconnect} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HPC1_FPD]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (99 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM1_FPD} Slave {/jesd/axi_jesd_xcvr/axi_ad9250_xcvr/s_axi} intc_ip {/jesd/axi_cpu_interconnect} master_apm {0}}  [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD]
  set spi_clk_i [ create_bd_port -dir I spi_clk_i ]
  set spi_clk_o [ create_bd_port -dir O spi_clk_o ]
  set spi_csn_i [ create_bd_port -dir I -from 7 -to 0 spi_csn_i ]
  set spi_csn_o [ create_bd_port -dir O -from 7 -to 0 spi_csn_o ]
  set spi_sdi_i [ create_bd_port -dir I spi_sdi_i ]
  set spi_sdo_i [ create_bd_port -dir I spi_sdo_i ]
  set spi_sdo_o [ create_bd_port -dir O spi_sdo_o ]
  connect_bd_net -net axi_spi_io0_o [get_bd_ports spi_sdo_o] [get_bd_pins axi_spi/io0_o]
  connect_bd_net -net axi_spi_sck_o [get_bd_ports spi_clk_o] [get_bd_pins axi_spi/sck_o]
  connect_bd_net -net axi_spi_ss_o [get_bd_ports spi_csn_o] [get_bd_pins axi_spi/ss_o]
  connect_bd_net -net spi_clk_i_1 [get_bd_ports spi_clk_i] [get_bd_pins axi_spi/sck_i]
  connect_bd_net -net spi_csn_i_1 [get_bd_ports spi_csn_i] [get_bd_pins axi_spi/ss_i]
  connect_bd_net -net spi_sdi_i_1 [get_bd_ports spi_sdi_i] [get_bd_pins axi_spi/io1_i]
  connect_bd_net -net spi_sdo_i_1 [get_bd_ports spi_sdo_i] [get_bd_pins axi_spi/io0_i]


set_property HDL_ATTRIBUTE.DEBUG true [get_bd_nets {axi_spi_ss_o axi_spi_io0_o spi_clk_i_1 spi_sdi_i_1 spi_csn_i_1 axi_spi_sck_o spi_sdo_i_1 }]
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
        [get_bd_nets axi_spi_io0_o] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets axi_spi_sck_o] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets spi_clk_i_1] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets spi_csn_i_1] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets spi_sdi_i_1] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets spi_sdo_i_1] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
        [get_bd_nets axi_spi_ss_o] {PROBE_TYPE "Data and Trigger" CLK_SRC "/zynq_ultra_ps_e_0/pl_clk0" SYSTEM_ILA "Auto" } \
]
set_property -dict [list CONFIG.C_BRAM_CNT {1} CONFIG.C_DATA_DEPTH {4096}] [get_bd_cells system_ila_0]

set_property HDL_ATTRIBUTE.DEBUG true [get_bd_nets {jesd/axi_ad9250_jesd_rx_data_tdata }]
set_property HDL_ATTRIBUTE.DEBUG true [get_bd_nets {jesd/axi_ad9250_0_core_adc_data_a jesd/axi_ad9250_0_core_adc_data_b jesd/axi_ad9250_1_core_adc_data_b jesd/axi_ad9250_1_core_adc_data_a }]
set_property HDL_ATTRIBUTE.DEBUG true [get_bd_nets {jesd/axi_ad9250_1_core_adc_valid_a jesd/axi_ad9250_0_core_adc_enable_a jesd/axi_ad9250_0_core_adc_enable_b jesd/axi_ad9250_1_core_adc_enable_a jesd/axi_ad9250_1_core_adc_enable_b jesd/axi_ad9250_0_core_adc_valid_a }]
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
        [get_bd_nets jesd/axi_ad9250_1_core_adc_data_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_1_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_1_core_adc_data_b] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_1_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_1_core_adc_enable_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_1_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_1_core_adc_enable_b] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_1_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_1_core_adc_valid_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_1_core/adc_clk" SYSTEM_ILA "Auto" } \
]
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
        [get_bd_nets jesd/axi_ad9250_0_core_adc_data_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_0_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_0_core_adc_data_b] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_0_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_0_core_adc_enable_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_0_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_0_core_adc_enable_b] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_0_core/adc_clk" SYSTEM_ILA "Auto" } \
        [get_bd_nets jesd/axi_ad9250_0_core_adc_valid_a] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/adc_core/axi_ad9250_0_core/adc_clk" SYSTEM_ILA "Auto" } \
]
apply_bd_automation -rule xilinx.com:bd_rule:debug -dict [list \
        [get_bd_nets jesd/axi_ad9250_jesd_rx_data_tdata] {PROBE_TYPE "Data and Trigger" CLK_SRC "/jesd/axi_jesd_xcvr/util_fmcjesdadc1_xcvr/rx_out_clk_0" SYSTEM_ILA "Auto" } \
]

exclude_bd_addr_seg [get_bd_addr_segs jesd/adc_dma/axi_ad9250_1_dma/m_dest_axi/SEG_zynq_ultra_ps_e_0_HPC1_QSPI]
exclude_bd_addr_seg [get_bd_addr_segs jesd/adc_dma/axi_ad9250_0_dma/m_dest_axi/SEG_zynq_ultra_ps_e_0_HPC1_QSPI]
exclude_bd_addr_seg [get_bd_addr_segs jesd/axi_jesd_xcvr/axi_ad9250_xcvr/m_axi/SEG_zynq_ultra_ps_e_0_HPC0_QSPI]
exclude_bd_addr_seg [get_bd_addr_segs jesd/axi_jesd_xcvr/axi_ad9250_xcvr/m_axi/SEG_zynq_ultra_ps_e_0_HPC0_LPS_OCM]
exclude_bd_addr_seg [get_bd_addr_segs jesd/adc_dma/axi_ad9250_1_dma/m_dest_axi/SEG_zynq_ultra_ps_e_0_HPC1_LPS_OCM]
set_property range 1G [get_bd_addr_segs {jesd/adc_dma/axi_ad9250_1_dma/m_dest_axi/SEG_zynq_ultra_ps_e_0_HPC1_DDR_LOW}]
set_property offset 0xC0000000 [get_bd_addr_segs {jesd/adc_dma/axi_ad9250_1_dma/m_dest_axi/SEG_zynq_ultra_ps_e_0_HPC1_DDR_LOW}]
set_property range 1G [get_bd_addr_segs {jesd/axi_jesd_xcvr/axi_ad9250_xcvr/m_axi/SEG_zynq_ultra_ps_e_0_HPC0_DDR_LOW}]
set_property offset 0xC0000000 [get_bd_addr_segs {jesd/axi_jesd_xcvr/axi_ad9250_xcvr/m_axi/SEG_zynq_ultra_ps_e_0_HPC0_DDR_LOW}]

  current_bd_instance $oldCurInst
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


