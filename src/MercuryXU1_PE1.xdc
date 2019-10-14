# -------------------------------------------------------------------------------------------------
# -- Project          : Mercury+ XU1 Reference Design
# -- File description : Pin assignment and timing constraints file for Mercury PE1
# -- File name        : MercuryXU1_PE1.xdc
# -- Author           : Diana Ungureanu
# -------------------------------------------------------------------------------------------------
# -- Copyright (c) 2018 by Enclustra GmbH, Switzerland. All rights are reserved.
# -- Unauthorized duplication of this document, in whole or in part, by any means is prohibited
# -- without the prior written permission of Enclustra GmbH, Switzerland.
# --
# -- Although Enclustra GmbH believes that the information included in this publication is correct
# -- as of the date of publication, Enclustra GmbH reserves the right to make changes at any time
# -- without notice.
# --
# -- All information in this document may only be published by Enclustra GmbH, Switzerland.
# -------------------------------------------------------------------------------------------------
# -- Notes:
# -- The IO standards might need to be adapted to your design
# -------------------------------------------------------------------------------------------------
# -- File history:
# --
# -- Version | Date       | Author             | Remarks
# -- ----------------------------------------------------------------------------------------------
# -- 1.0     | 22.12.2016 | D. Ungureanu       | First released version
# -- 2.0     | 20.10.2017 | D. Ungureanu       | Consistency checks
# -- 3.0     | 11.06.2018 | D. Ungureanu       | Consistency checks
# --
# -------------------------------------------------------------------------------------------------

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

# ----------------------------------------------------------------------------------
# Important! Do not remove this constraint!
# This property ensures that all unused pins are set to high impedance.
# If the constraint is removed, all unused pins have to be set to HiZ in the top level file.
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLNONE [current_design]
# ----------------------------------------------------------------------------------

set_property PACKAGE_PIN R7 [get_ports {rx_ref_clk_n}]
set_property PACKAGE_PIN R8 [get_ports {rx_ref_clk_p}]

set_property PACKAGE_PIN K1 [get_ports {rx_data_n[0]}]
set_property PACKAGE_PIN K2 [get_ports {rx_data_p[0]}]
set_property PACKAGE_PIN H1 [get_ports {rx_data_n[1]}]
set_property PACKAGE_PIN H2 [get_ports {rx_data_p[1]}]
set_property PACKAGE_PIN G3 [get_ports {rx_data_n[2]}]
set_property PACKAGE_PIN G4 [get_ports {rx_data_p[2]}]
set_property PACKAGE_PIN F1 [get_ports {rx_data_n[3]}]
set_property PACKAGE_PIN F2 [get_ports {rx_data_p[3]}]


set_property PACKAGE_PIN T1 [get_ports {rx_sync}]
set_property IOSTANDARD LVCMOS18 [get_ports {rx_sync}]
set_property PACKAGE_PIN U1 [get_ports {rx_sysref}]
set_property IOSTANDARD LVCMOS18 [get_ports {rx_sysref}]

set_property PACKAGE_PIN W5 [get_ports {spi_sdio}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_sdio}]
set_property PACKAGE_PIN V4 [get_ports {spi_clk}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_clk}]
set_property PACKAGE_PIN W4 [get_ports {spi_csn_0}]
set_property IOSTANDARD LVCMOS18 [get_ports {spi_csn_0}]
# -------------------------------------------------------------------------------------------------
# LEDs
# -------------------------------------------------------------------------------------------------

set_property PACKAGE_PIN AE8 [get_ports {Led2_N}]
set_property IOSTANDARD LVCMOS18 [get_ports {Led2_N}]

# -------------------------------------------------------------------------------------------------
# I2C on PL side
# -------------------------------------------------------------------------------------------------

set_property PACKAGE_PIN V3 [get_ports {I2c_Scl}]
set_property IOSTANDARD LVCMOS18 [get_ports {I2c_Scl}]

set_property PACKAGE_PIN Y7 [get_ports {I2c_Sda}]
set_property IOSTANDARD LVCMOS18 [get_ports {I2c_Sda}]

# -------------------------------------------------------------------------------------------------
# bank 64
# -------------------------------------------------------------------------------------------------

## #LVDS example
##set_property IOSTANDARD LVCMOS18 [get_ports {IO_B48_L5_HDGC_D12_N}]
##set_property IOSTANDARD LVCMOS18 [get_ports {IO_B48_L5_HDGC_E12_P}]
##set_property PACKAGE_PIN D11  [get_ports {IO_B48_L4_AD12_D11_P}]

# -------------------------------------------------------------------------------------------------
# PS banks defined in the block design
# -------------------------------------------------------------------------------------------------


create_clock -name rx_ref_clk   -period  4.00 [get_ports rx_ref_clk_clk_p]
create_clock -name rx_div_clk   -period  6.40 [get_pins MercuryXU1_i/jesd/axi_jesd_xcvr/util_fmcjesdadc1_xcvr/inst/i_xch_0/i_gthe4_channel/RXOUTCLK]

set_property ASYNC_REG TRUE [get_cells -hier -filter {name =~ *sysref_en_m*}]
set_false_path -to [get_cells -hier -filter {name =~ *sysref_en_m1*  && IS_SEQUENTIAL}]

