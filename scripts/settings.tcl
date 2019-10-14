# Arguments:
# ~~~~~~~~~~
# Leave all arguments except FPGA part on default value
# 
# hw_base_platform       -device family: Mercury, Mars
# module_name            -module name within family: KX1, AX3, ZX3, ...
# fpga_part              -FPGA part - see below the options for Mercury XU1
#    xczu9eg-ffvc900-1-e-es2
#    xczu6eg-ffvc900-1-i
#    xczu9eg-ffvc900-2-i
#    xczu15eg-ffvc900-2-i
# part_specific_text     -specifc text to be added to the directory naming (if needed)
# hw_platforms           -base board platform name PE1, PM3, EB1, STA

set hw_base_platform       Mercury
set module_name            XU1
set fpga_part              xczu6eg-ffvc900-1-i 
set part_specific_text     _
set hw_platforms           PE1
