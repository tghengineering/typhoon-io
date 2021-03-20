set_global_assignment -entity "vpg_pll" -library "lib_vpg_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "vpg_pll" -library "lib_vpg_pll" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "vpg_pll" -library "lib_vpg_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_vpg_pll" -name SPD_FILE [file join $::quartus(sip_path) "vpg_pll.spd"]

set_global_assignment -library "lib_vpg_pll" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_sim/vpg_pll.vo"]
