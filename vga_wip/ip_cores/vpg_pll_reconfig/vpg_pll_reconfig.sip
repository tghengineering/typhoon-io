set_global_assignment -entity "vpg_pll_reconfig" -library "lib_vpg_pll_reconfig" -name IP_TOOL_NAME "altera_pll_reconfig"
set_global_assignment -entity "vpg_pll_reconfig" -library "lib_vpg_pll_reconfig" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "vpg_pll_reconfig" -library "lib_vpg_pll_reconfig" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_vpg_pll_reconfig" -name SPD_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig.spd"]

set_global_assignment -library "lib_vpg_pll_reconfig" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig_sim/vpg_pll_reconfig.v"]
set_global_assignment -library "lib_vpg_pll_reconfig" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig_sim/altera_pll_reconfig/altera_pll_reconfig_top.v"]
set_global_assignment -library "lib_vpg_pll_reconfig" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig_sim/altera_pll_reconfig/altera_pll_reconfig_mif_reader.v"]
set_global_assignment -library "lib_vpg_pll_reconfig" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig_sim/altera_pll_reconfig/altera_pll_reconfig_core.v"]
set_global_assignment -library "lib_vpg_pll_reconfig" -name MISC_FILE [file join $::quartus(sip_path) "vpg_pll_reconfig_sim/altera_pll_reconfig/altera_std_synchronizer.v"]
